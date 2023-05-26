import 'package:foap/apiHandler/apis/post_api.dart';
import 'package:foap/apiHandler/apis/users_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/list_extension.dart';
import '../apiHandler/apis/misc_api.dart';
import '../model/comment_model.dart';
import '../model/hash_tag.dart';

class CommentsController extends GetxController {
  final UserProfileManager _userProfileManager = Get.find();

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

  int accountsPage = 1;
  bool canLoadMoreAccounts = true;
  bool accountsIsLoading = false;

  int commentsPage = 1;
  bool canLoadMoreComments = true;

  // bool accountsIsLoading = false;

  clear() {
    hashtagsPage = 1;
    canLoadMoreHashtags = true;
    hashtagsIsLoading = false;

    accountsPage = 1;
    canLoadMoreAccounts = true;
    accountsIsLoading = false;

    comments.clear();
    commentsPage = 1;
    canLoadMoreComments = true;

    update();
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
    CommentModel newMessage =
        CommentModel.fromNewMessage(comment, _userProfileManager.user.value!);
    newMessage.commentTime = justNowString.tr;
    comments.add(newMessage);
    update();

    PostApi.postComment(
        postId: postId, comment: comment, resultCallback: commentPosted);
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
    if (canLoadMoreAccounts) {
      accountsIsLoading = true;
      UsersApi.searchUsers(
          page: accountsPage,
          isExactMatch: 0,
          searchText: text,
          resultCallback: (result, metadata) {
            searchedUsers.addAll(result);
            accountsIsLoading = false;
            canLoadMoreAccounts = result.length >= metadata.perPage;
            accountsPage += 1;

            if (callback != null) {
              callback();
            }
            update();
          });
    }
  }

  textChanged(String text, int position) {
    clear();
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
}
