import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:foap/api_handler/apis/post_api.dart';
import 'package:foap/helper/file_extension.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/string_extension.dart';
import 'package:video_compress/video_compress.dart';
import '../profile/profile_controller.dart';
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

  /// What the background post is doing right now (shown to the user):
  /// 0 preparing, 1 compressing video, 2 uploading, 3 publishing
  RxInt postingStage = 0.obs;

  /// 0.0 - 1.0 of the whole post (all files)
  RxDouble postingProgress = 0.0.obs;
  RxString postingDetail = ''.obs;

  List<double> _mediaProgress = [];
  VoidCallback? _retryAction;

  void _setProgress(int index, double value) {
    if (index >= _mediaProgress.length) return;
    _mediaProgress[index] = value.clamp(0.0, 1.0);
    final total = _mediaProgress.fold<double>(0, (a, b) => a + b);
    postingProgress.value = (total / _mediaProgress.length).clamp(0.0, 1.0);
  }

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
    postingStage.value = 0;
    postingProgress.value = 0;
    postingDetail.value = '';
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
    final retry = _retryAction;
    if (retry != null) {
      retry();
    }
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
    if (isPosting.value && !isErrorInPosting.value) {
      AppUtil.showToast(
          message: 'Another post is still uploading', isSuccess: false);
      return;
    }

    // everything below runs in the background, the user is free to leave
    if (!isErrorInPosting.value) {
      Get.back();
    }

    currentPostType = postType;
    postingMedia = items;
    postingTitle = title;
    isPosting.value = true;
    isErrorInPosting.value = false;
    postingStage.value = 0;
    postingProgress.value = 0;
    _mediaProgress = List<double>.filled(items.length, 0.0);

    _retryAction = () => submitPost(
        postType: postType,
        items: items,
        title: title,
        allowComments: allowComments,
        postCompletionHandler: postCompletionHandler,
        isPaidContent: isPaidContent,
        competitionId: competitionId,
        clubId: clubId,
        eventId: eventId,
        fundRaisingCampaignId: fundRaisingCampaignId,
        isReel: isReel,
        audioId: audioId,
        audioStartTime: audioStartTime,
        audioEndTime: audioEndTime);

    try {
      var responses = await Future.wait([
        for (int i = 0; i < items.length; i++)
          uploadMedia(items[i], competitionId, i)
      ]);

      postingStage.value = 3;
      postingProgress.value = 1;

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
    } catch (_) {
      _failPosting();
    }
  }

  void _failPosting() {
    Loader.dismiss();
    isErrorInPosting.value = true;
    AppUtil.showToast(message: postFailedString.tr, isSuccess: false);
  }

  Future<Map<String, String>> uploadMedia(
      Media media, int? competitionId, int index) async {
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
          file, media, videoThumbnailPath, competitionId, completer, index);
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
      File videoToUpload = media.file!;
      final bool isSmall = videoToUpload.lengthSync() < 15 * 1024 * 1024;

      if (!isSmall) {
        // step 1: compress, only big videos, progress 0 to 40 percent
        postingStage.value = 1;
        final sub = VideoCompress.compressProgress$.subscribe((p) {
          _setProgress(index, (p / 100.0) * 0.4);
        });
        try {
          MediaInfo? mediaInfo = await VideoCompress.compressVideo(
            media.file!.path,
            quality: VideoQuality.DefaultQuality,
            deleteOrigin: false,
          );
          if (mediaInfo?.file != null) {
            videoToUpload = mediaInfo!.file!;
          }
        } finally {
          sub.unsubscribe();
        }
      }
      _setProgress(index, 0.4);

      // step 2: thumbnail, small
      postingStage.value = 2;
      if (media.thumbnail != null) {
        File videoThumbnail = await File(
                '${tempDir.path}/${media.id!.replaceAll('/', '')}_thumbnail.jpg')
            .create();
        videoThumbnail.writeAsBytesSync(media.thumbnail!);

        final thumbCompleter = Completer<void>();
        await MiscApi.uploadFile(videoThumbnail.path,
            type: UploadMediaType.post,
            mediaType: GalleryMediaType.photo,
            showLoader: false,
            resultCallback: (fileName, filePath) async {
              videoThumbnailPath = fileName;
              await videoThumbnail.delete();
              thumbCompleter.complete();
            },
            failureHandler: () {
              if (!thumbCompleter.isCompleted) thumbCompleter.complete();
            });
        await thumbCompleter.future;
      }

      // step 3: the video itself, progress 40 to 100 percent
      uploadMainFile(videoToUpload, media, videoThumbnailPath, competitionId,
          completer, index,
          deleteAfter: videoToUpload.path != media.file!.path);
    } else {
      // for audio files
      uploadMainFile(media.file!, media, videoThumbnailPath, competitionId,
          completer, index,
          deleteAfter: false);
    }

    return completer.future;
  }

  Future uploadMainFile(File file, Media media, String? videoThumbnailPath,
      int? competitionId, Completer completer, int index,
      {bool deleteAfter = true}) async {
    Map<String, String> gallery = {};
    postingStage.value = 2;
    final bool isVideo = media.mediaType == GalleryMediaType.video;

    await MiscApi.uploadFile(file.path,
        type: UploadMediaType.post,
        mediaType: media.mediaType!,
        showLoader: false,
        onProgress: (sent, total) {
          if (total <= 0) return;
          final fraction = sent / total;
          _setProgress(index, isVideo ? 0.4 + fraction * 0.6 : fraction);
        },
        failureHandler: () {
          if (!completer.isCompleted) {
            completer.completeError('upload failed');
          }
        },
        resultCallback: (fileName, filePath) async {
      String imagePath = fileName;

      if (deleteAfter) {
        try {
          await file.delete();
        } catch (_) {}
      }
      _setProgress(index, 1);

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
            postCompletionHandler();
            postingMedia = [];
            postingTitle = '';

            await linkCollaboratorsToPost(postId);

            PostApi.getPostDetail(postId, resultCallback: (result) {
              if (result != null) {
                _homeController.addNewPost(result);
                if (Get.isRegistered<ProfileController>()) {
                  Get.find<ProfileController>().addMyNewPost(result);
                }
              }
              isPosting.value = false;
              AppUtil.showToast(message: postedString.tr, isSuccess: true);
            });

            clear();
          } else {
            _failPosting();
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
