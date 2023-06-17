import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:foap/apiHandler/apis/post_api.dart';
import 'package:foap/apiHandler/apis/users_api.dart';
import 'package:foap/components/custom_gallery_picker.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/list_extension.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:image_picker/image_picker.dart';
import '../../apiHandler/apis/misc_api.dart';
import '../../helper/imports/chat_imports.dart';
import '../../model/comment_model.dart';
import '../../model/hash_tag.dart';

import '../../screens/settings_menu/settings_controller.dart';
import '../../util/constant_util.dart';
import '../misc/users_controller.dart';

class CommentsController extends GetxController {
  final UserProfileManager _userProfileManager = Get.find();
  final SettingsController _settingsController = Get.find();

  RxInt isEditing = 0.obs;
  RxString currentHashtag = ''.obs;
  RxString currentUserTag = ''.obs;

  RxList<CommentModel> comments = <CommentModel>[].obs;
  RxList<Hashtag> hashTags = <Hashtag>[].obs;
  RxList<UserModel> searchedUsers = <UserModel>[].obs;

  int currentUpdateAbleStartOffset = 0;
  int currentUpdateAbleEndOffset = 0;

  RxString searchText = ''.obs;
  RxInt position = 0.obs;

  int hashtagsPage = 1;
  bool canLoadMoreHashtags = true;
  bool hashtagsIsLoading = false;

  // int accountsPage = 1;
  // bool canLoadMoreAccounts = true;
  // bool accountsIsLoading = false;

  int commentsPage = 1;
  bool canLoadMoreComments = true;

  Rx<Media?> selectedMedia = Rx<Media?>(null);
  final ImagePicker _picker = ImagePicker();

  // bool accountsIsLoading = false;

  clear() {
    hashtagsPage = 1;
    canLoadMoreHashtags = true;
    hashtagsIsLoading = false;

    // accountsPage = 1;
    // canLoadMoreAccounts = true;
    // accountsIsLoading = false;

    comments.clear();
    commentsPage = 1;
    canLoadMoreComments = true;

    selectedMedia = Rx<Media?>(null);
  }

  void getComments(int postId, VoidCallback callback) {
    if (canLoadMoreComments) {
      PostApi.getComments(
          postId: postId,
          page: commentsPage,
          resultCallback: (result, metadata) {
            comments.addAll(result);
            comments.unique((e) => e.id);
            canLoadMoreComments = result.length >= metadata.perPage;
            if (canLoadMoreComments) {
              commentsPage += 1;
            }
            update();
            callback();
          });
    } else {
      callback();
    }
  }

  void postCommentsApiCall(
      {required String comment,
      required int postId,
      required VoidCallback commentPosted}) {
    comments.add(CommentModel.fromNewMessage(
        CommentType.text, _userProfileManager.user.value!,
        comment: comment));
    update();

    PostApi.postComment(
        type: CommentType.text,
        postId: postId,
        comment: comment,
        resultCallback: commentPosted);
  }

  void postMediaCommentsApiCall(
      {required int postId,
      required VoidCallback commentPosted,
      required CommentType type}) async {
    String filename = type == CommentType.image
        ? await uploadMedia(selectedMedia.value!)
        : selectedMedia.value!.fileUrl!;

    comments.add(CommentModel.fromNewMessage(
        type, _userProfileManager.user.value!,
        filename: filename));
    update();

    PostApi.postComment(
        type: type,
        postId: postId,
        filename: filename,
        resultCallback: commentPosted);
  }

  Future<String> uploadMedia(Media media) async {
    String imagePath = '';

    await AppUtil.checkInternet().then((value) async {
      if (value) {
        final tempDir = await getTemporaryDirectory();
        Uint8List mainFileData = await media.file!.compress();

        //media
        File file =
            await File('${tempDir.path}/${media.id!.replaceAll('/', '')}.png')
                .create();
        file.writeAsBytesSync(mainFileData);

        await PostApi.uploadFile(file.path,
            resultCallback: (fileName, filePath) async {
          imagePath = fileName;
          await file.delete();
        });
      } else {
        AppUtil.showToast(message: noInternetString.tr, isSuccess: false);
      }
    });
    return imagePath;
  }

  // adding hashtag and mentions
  startedEditing() {
    isEditing.value = 1;
    update();
  }

  stoppedEditing() {
    isEditing.value = 0;
    update();
  }

  searchHashTags({required String text, VoidCallback? callback}) {
    if (canLoadMoreHashtags) {
      hashtagsIsLoading = true;

      MiscApi.searchHashtag(
          page: hashtagsPage,
          hashtag: text.replaceAll('#', ''),
          resultCallback: (result, metadata) {
            hashTags.addAll(result);
            hashTags.unique((e) => e.name);

            canLoadMoreHashtags = result.length >= metadata.perPage;
            hashtagsIsLoading = false;
            hashtagsPage += 1;
            // if (response.hashtags.length == response.metaData?.perPage) {
            //   canLoadMoreHashtags = true;
            // } else {
            //   canLoadMoreHashtags = false;
            // }

            if (callback != null) {
              callback();
            }
            update();
          });
    }
  }

  addUserTag(String user) {
    String updatedText = searchText.value.replaceRange(
        currentUpdateAbleStartOffset, currentUpdateAbleEndOffset, '$user ');
    searchText.value = updatedText;
    position.value = updatedText.indexOf(user, currentUpdateAbleStartOffset) +
        user.length +
        1;

    currentUserTag.value = '';

    searchedUsers.clear();
    update();
  }

  addHashTag(String hashtag) {
    String updatedText = searchText.value.replaceRange(
        currentUpdateAbleStartOffset, currentUpdateAbleEndOffset, '$hashtag ');
    position.value =
        updatedText.indexOf(hashtag, currentUpdateAbleStartOffset) +
            hashtag.length +
            1;

    searchText.value = updatedText;
    currentHashtag.value = '';

    hashTags.clear();
    update();
  }

  searchUsers({required String text, VoidCallback? callback}) {
    _usersController.setSearchTextFilter(text);
  }

  textChanged(String text, int position) {
    // clear();
    isEditing.value = 1;
    searchText.value = text;
    String substring = text.substring(0, position).replaceAll("\n", " ");
    List<String> parts = substring.split(' ');
    String lastPart = parts.last;

    if (lastPart.startsWith('#') == true && lastPart.contains('@') == false) {
      if (currentHashtag.value.startsWith('#') == false) {
        currentHashtag.value = lastPart;
        currentUpdateAbleStartOffset = position;
      }

      if (lastPart.length > 1) {
        searchHashTags(text: lastPart);
        currentUpdateAbleEndOffset = position;
      }
    } else if (lastPart.startsWith('@') == true &&
        lastPart.contains('#') == false) {
      if (currentUserTag.value.startsWith('@') == false) {
        currentUserTag.value = lastPart;
        currentUpdateAbleStartOffset = position;
      }
      if (lastPart.length > 1) {
        searchUsers(text: lastPart);
        currentUpdateAbleEndOffset = position;
      }
    } else {
      if (currentHashtag.value.startsWith('#') == true) {
        currentHashtag.value = lastPart;
      }
      currentHashtag.value = '';
      hashTags.value = [];

      if (currentUserTag.value.startsWith('!') == true) {
        currentUserTag.value = lastPart;
      }
      currentUserTag.value = '';
      searchedUsers.value = [];
    }

    this.position.value = position;
  }

  selectPhoto(
      {ImageSource source = ImageSource.gallery,
      required VoidCallback handler}) async {
    XFile? image = source == ImageSource.camera
        ? await _picker.pickImage(source: ImageSource.camera)
        : await _picker.pickImage(source: source);
    if (image != null) {
      Media media = Media();
      media.mediaType = GalleryMediaType.photo;
      media.file = File(image.path);
      media.id = randomId();
      selectedMedia.value = media;
      handler();
    }
  }

  void openGify(VoidCallback handler) async {
    String randomId = 'hsvcewd78djhbejkd';

    GiphyGif? gif = await GiphyGet.getGif(
      context: Get.context!,
      //Required
      apiKey: _settingsController.setting.value!.giphyApiKey!,
      //Required.
      lang: GiphyLanguage.english,
      //Optional - Language for query.
      randomID: randomId,
      // Optional - An ID/proxy for a specific user.
      tabColor: Colors.teal, // Optional- default accent color.
    );

    if (gif != null) {
      selectedMedia.value = Media(
          fileUrl: 'https://i.giphy.com/media/${gif.id}/200.gif',
          mediaType: GalleryMediaType.gif);
      handler();
    }
  }
}
