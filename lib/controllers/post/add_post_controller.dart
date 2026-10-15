import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:foap/api_handler/apis/post_api.dart';
import 'package:foap/helper/file_extension.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/string_extension.dart';
import 'package:video_compress/video_compress.dart';
import '../../api_handler/apis/misc_api.dart';
import '../../helper/enum_linking.dart';
import '../../model/location.dart';
import '../../screens/chat/media.dart';
import '../home/home_controller.dart';
import 'package:path_provider/path_provider.dart';

class AddPostController extends GetxController {
  final HomeController _homeController = Get.find();

  RxInt currentIndex = 0.obs;

  RxBool isPosting = false.obs;
  RxBool isErrorInPosting = false.obs;

  RxBool enableComments = true.obs;

  List<Media> postingMedia = [];
  late String postingTitle;

  RxBool isPreviewMode = false.obs;
  RxBool isPaidContent = false.obs;

  Rx<LocationModel?> taggedLocation = Rx<LocationModel?>(null);
  RxList<UserModel> collaborators = <UserModel>[].obs;

  PostCategory? currentPostType;

  clear() {
    currentIndex.value = 0;
    isPosting.value = false;
    isErrorInPosting.value = false;
    isPreviewMode.value = false;
    enableComments.value = true;
    taggedLocation.value = null;
    collaborators.clear();

    update();
  }

  updateGallerySlider(int index) {
    currentIndex.value = index;
    update();
  }

  togglePreviewMode() {
    isPreviewMode.value = !isPreviewMode.value;
    update();
  }

  togglePaidContentMode() {
    isPaidContent.value = !isPaidContent.value;
    update();
  }

  toggleEnableComments() {
    enableComments.value = !enableComments.value;
    update();
  }

  discardFailedPost() {
    postingMedia = [];
    postingTitle = '';
    isPosting.value = false;
    isErrorInPosting.value = false;
    clear();
  }

  retryPublish() {
    submitPost(
        items: postingMedia,
        title: postingTitle,
        postType: currentPostType!,
        isPaidContent: false,
        allowComments: true,
        postCompletionHandler: () {});
  }

  void submitPost(
      {required PostCategory postType,
      required List<Media> items,
      required String title,
      required bool allowComments,
      required VoidCallback postCompletionHandler,
      required bool isPaidContent,
      int? competitionId,
      int? clubId,
      int? eventId,
      int? fundRaisingCampaignId,
      bool isReel = false,
      int? audioId,
      double? audioStartTime,
      double? audioEndTime}) async {
    currentPostType = postType;
    postingMedia = items;
    postingTitle = title;
    isPosting.value = true;

    var responses = await Future.wait([
      for (Media media in items)
        uploadMedia(
          media,
          competitionId,
        )
    ]).whenComplete(() {});

    publishAction(
      postType: postType,
      galleryItems: responses,
      postCompletionHandler: postCompletionHandler,
      title: title,
      tags: title.getHashtags(),
      location: taggedLocation.value,
      mentions: title.getMentions(),
      allowComments: allowComments,
      competitionId: competitionId,
      isPaidContent: isPaidContent,
      clubId: clubId,
      eventId: eventId,
      fundRaisingCampaignId: fundRaisingCampaignId,
      isReel: isReel,
      audioId: audioId,
      audioStartTime: audioStartTime,
      audioEndTime: audioEndTime,
    );
  }

  Future<Map<String, String>> uploadMedia(
      Media media, int? competitionId) async {
    Map<String, String> gallery = {};
    final completer = Completer<Map<String, String>>();

    final tempDir = await getTemporaryDirectory();
    File file;
    String? videoThumbnailPath;

    if (media.mediaType == GalleryMediaType.photo) {
      Uint8List mainFileData = await media.file!.compress();

      file = await File(
              '${tempDir.path}/${media.id!.replaceAll('/', '')}.${media.file!.extension}')
          .create();
      file.writeAsBytesSync(mainFileData);
      uploadMainFile(
          file, media, videoThumbnailPath, competitionId, completer);
    } else if (media.mediaType == GalleryMediaType.gif) {
      gallery = {
        'filename': media.filePath!,
        'video_thumb': videoThumbnailPath ?? '',
        'type': competitionId == null ? '1' : '2',
        'media_type':
            mediaTypeIdFromMediaType(media.mediaType!).toString(),
        'is_default': '1',
      };
      completer.complete(gallery);
    } else if (media.mediaType == GalleryMediaType.video) {
      Loader.show(status: loadingString.tr);
      MediaInfo? mediaInfo = await VideoCompress.compressVideo(
        media.file!.path,
        quality: VideoQuality.DefaultQuality,
        deleteOrigin: false, // It's false by default
      );

      // code after compressing
      file = mediaInfo!.file!;

      File videoThumbnail = await File(
              '${tempDir.path}/${media.id!.replaceAll('/', '')}_thumbnail.jpg')
          .create();

      videoThumbnail.writeAsBytesSync(media.thumbnail!);

      await MiscApi.uploadFile(videoThumbnail.path,
          type: UploadMediaType.post, mediaType: media.mediaType!,
          resultCallback: (fileName, filePath) async {
        videoThumbnailPath = fileName;
        await videoThumbnail.delete();
      });

      uploadMainFile(
          file, media, videoThumbnailPath, competitionId, completer);
    } else {
      // for audio files
      uploadMainFile(media.file!, media, videoThumbnailPath, competitionId,
          completer);
    }

    return completer.future;
  }

  Future uploadMainFile(File file, Media media, String? videoThumbnailPath,
      int? competitionId, Completer completer) async {
    Map<String, String> gallery = {};

    await MiscApi.uploadFile(file.path,
        type: UploadMediaType.post, mediaType: media.mediaType!,
        resultCallback: (fileName, filePath) async {
      String imagePath = fileName;

      await file.delete();

      gallery = {
        'filename': imagePath,
        'video_thumb': videoThumbnailPath ?? '',
        'type': competitionId == null ? '1' : '2',
        'media_type':
            mediaTypeIdFromMediaType(media.mediaType!).toString(),
        'is_default': '1',
        'height': (media.size?.height ?? 0).toString(),
        'width': (media.size?.width ?? 0).toString(),
        'audio_time': media.duration.toString()
      };
      completer.complete(gallery);
    });
  }

  void publishAction({
    required PostCategory postType,
    required List<Map<String, String>> galleryItems,
    required String title,
    required List<String> tags,
    required List<String> mentions,
    required bool allowComments,
    required VoidCallback postCompletionHandler,
    required bool isPaidContent,
    LocationModel? location,
    int? competitionId,
    int? clubId,
    int? eventId,
    int? fundRaisingCampaignId,
    bool isReel = false,
    int? audioId,
    double? audioStartTime,
    double? audioEndTime,
  }) {
    PostApi.addPost(
        postType: postType,
        postContentType: galleryItems.isEmpty
            ? PostContentType.text
            : PostContentType.media,
        title: title,
        gallery: galleryItems,
        allowComments: allowComments,
        isPaidContent: isPaidContent,
        hashTag: tags.join(','),
        mentions: mentions.join(','),
        location: location,
        competitionId: competitionId,
        clubId: clubId,
        eventId: eventId,
        fundRaisingCampaignId: fundRaisingCampaignId,
        audioId: audioId,
        audioStartTime: audioStartTime,
        audioEndTime: audioEndTime,
        resultCallback: (postId) async {
          if (postId != null) {
            Get.back();
            postCompletionHandler();
            postingMedia = [];
            postingTitle = '';

            await linkCollaboratorsToPost(postId);

            PostApi.getPostDetail(postId, resultCallback: (result) {
              if (result != null) {
                _homeController.addNewPost(result);
              }
              isPosting.value = false;
            });

            clear();
          } else {
            isErrorInPosting.value = true;
          }
        });
  }

  void updatePost({
    required int postId,
    required String title,
    required bool allowComments,
  }) {
    HomeController homeController = Get.find();

    PostApi.updatePost(
        postId: postId,
        title: title,
        allowComments: allowComments,
        successHandler: () {
          PostApi.getPostDetail(postId, resultCallback: (post) {
            if (post != null) {
              homeController.postEdited(post);
            }
          });
          Get.back();
        });
  }

  setTaggedLocation(LocationModel? location) {
    taggedLocation.value = location;
  }

  void shareToFeed(
      {required int productId, required PostContentType contentType}) {
    PostApi.addPost(
        postType: PostCategory.basic,
        postContentType: contentType,
        contentRefId: productId,
        isPaidContent: false,
        title: '',
        gallery: [],
        allowComments: true,
        hashTag: '',
        mentions: '',
        location: null,
        competitionId: null,
        clubId: null,
        audioId: null,
        audioStartTime: null,
        audioEndTime: null,
        resultCallback: (postId) {
          if (postId != null) {
            HomeController homeController = Get.find();
            homeController.getPosts(callback: () {});
            AppUtil.showToast(message: postedString.tr, isSuccess: true);
          }
        });
  }

  addCollaborator(UserModel user) {
    if (collaborators.where((e) => e.id == user.id).isNotEmpty) {
      collaborators.removeWhere((e) => e.id == user.id);
    } else {
      if (collaborators.length == 5) {
        AppUtil.showToast(
            message: max5CollaboratorsInPostString.tr, isSuccess: false);
      } else {
        collaborators.add(user);
      }
    }
  }

  linkCollaboratorsToPost(int postId) async {
    for (UserModel user in collaborators) {
      await PostApi.linkCollaborator(
          postId: postId, collaboratorId: user.id);
    }

    collaborators.clear();
  }

  updateCollaborationStatus(
      {required int id, required CollaborationStatusType status}) {
    PostApi.updateCollaborationStatus(id: id, status: status);
  }

  createPoll(Map<String, dynamic> data) {
    PostApi.createPoll(
        question: data["question"],
        options: data["options"],
        successCallback: (id) {
          PostApi.addPost(
              postType: PostCategory.basic,
              postContentType: PostContentType.poll,
              title: '',
              gallery: [],
              allowComments: true,
              isPaidContent: false,
              contentRefId: id,
              resultCallback: (postId) {
                if (postId != null) {
                  Get.close(2);
                  PostApi.getPostDetail(postId, resultCallback: (result) {
                    if (result != null) {
                      _homeController.addNewPost(result);
                    }
                    isPosting.value = false;
                  });
                } else {
                  AppUtil.showToast(
                      message: errorMessageString.tr, isSuccess: false);
                }
              });
        },
        failureCallback: () {});
  }
}
