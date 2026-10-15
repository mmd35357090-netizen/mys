import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/list_extension.dart';
import 'package:foap/model/data_wrapper.dart';
import '../../api_handler/apis/post_api.dart';
import '../../model/post_model.dart';
import '../../model/post_search_query.dart';

class PostController extends GetxController {
  RxList<PostModel> posts = <PostModel>[].obs;
  RxList<PostModel> videos = <PostModel>[].obs;

  RxList<UserModel> likedByUsers = <UserModel>[].obs;

  Rx<PostInsight?> insight = Rx<PostInsight?>(null);

  int totalPages = 100;

  DataWrapper postDataWrapper = DataWrapper();
  DataWrapper videosDataWrapper = DataWrapper();

  PostSearchQuery? postSearchQuery;

  DataWrapper postLikedByDataWrapper = DataWrapper();

  clear() {
    totalPages = 100;
    postDataWrapper = DataWrapper();

    posts.value = [];

    clearVideos();
    clearPostLikedByUsers();
    update();
  }

  clearVideos() {
    videos.clear();
    videosDataWrapper = DataWrapper();
  }

  clearPostLikedByUsers() {
    likedByUsers.clear();
    postLikedByDataWrapper = DataWrapper();
  }

  addPosts(List<PostModel> postsList, int? startPage, int? totalPages) {
    postDataWrapper.page = startPage ?? 1;
    this.totalPages = totalPages ?? 100;

    posts.addAll(postsList);
    posts.unique((e) => e.id);
    update();
  }

  setPostSearchQuery(
      {required PostSearchQuery query, required VoidCallback callback}) {
    if (query != postSearchQuery) {
      clear();
    }
    update();
    postSearchQuery = query;
    getPosts(callback);
  }


  removePostFromList(PostModel post) {
    posts.removeWhere((element) => element.id == post.id);

    posts.refresh();
  }

  removeUsersAllPostFromList(PostModel post) {
    posts.removeWhere((element) => element.user.id == post.user.id);

    posts.refresh();
  }

  void getPosts(VoidCallback callback) async {
    if (postDataWrapper.haveMoreData.value == true &&
        totalPages > postDataWrapper.page) {
      if (postDataWrapper.page == 1) {
        postDataWrapper.isLoading.value = true;
      }

      PostApi.getPosts(
          userId: postSearchQuery!.userId,
          isPopular: postSearchQuery!.isPopular,
          isFollowing: postSearchQuery!.isFollowing,
          isSold: postSearchQuery!.isSold,
          isMine: postSearchQuery!.isMine,
          isRecent: postSearchQuery!.isRecent,
          title: postSearchQuery!.title,
          hashtag: postSearchQuery!.hashTag,
          page: postDataWrapper.page,
          resultCallback: (result, metadata) {
            posts.addAll(result);
            posts.sort((a, b) => b.createDate!.compareTo(a.createDate!));
            posts.unique((e) => e.id);

            postDataWrapper.processCompletedWithData(metadata);

            callback();
            update();
          });
    } else {
      callback();
    }
  }

  void getVideos(VoidCallback callback) async {
    if (videosDataWrapper.haveMoreData.value == true &&
        totalPages > videosDataWrapper.page) {
      videosDataWrapper.isLoading.value = true;

      PostApi.getPosts(
          userId: postSearchQuery!.userId,
          isPopular: postSearchQuery!.isPopular,
          isFollowing: postSearchQuery!.isFollowing,
          isSold: postSearchQuery!.isSold,
          isMine: postSearchQuery!.isMine,
          isRecent: postSearchQuery!.isRecent,
          title: postSearchQuery!.title,
          hashtag: postSearchQuery!.hashTag,
          page: videosDataWrapper.page,
          resultCallback: (result, metadata) {
            posts.addAll(result);
            posts.sort((a, b) => b.createDate!.compareTo(a.createDate!));
            posts.unique((e) => e.id);

            videosDataWrapper.processCompletedWithData(metadata);

            callback();

            update();
          });
    } else {
      callback();
    }
  }

  void reportPost(int postId) {
    PostApi.reportPost(
        postId: postId,
        resultCallback: () {
          AppUtil.showToast(
              message: postReportedSuccessfullyString.tr, isSuccess: true);
        });
  }

  viewInsight(int postId) {
    PostApi.getPostInsight(postId, resultCallback: (result) {
      insight.value = result;
      insight.refresh();
    });
  }

  void getPostLikedByUsers(
      {required int postId, required VoidCallback callback}) async {
    if (postLikedByDataWrapper.haveMoreData.value == true) {
      postLikedByDataWrapper.isLoading.value = true;

      PostApi.postLikedByUsers(
          postId: postId,
          page: postLikedByDataWrapper.page,
          resultCallback: (result, metadata) {
            likedByUsers.addAll(result);
            likedByUsers.unique((e) => e.id);

            postLikedByDataWrapper.processCompletedWithData(metadata);

            callback();

            update();
          });
    }
  }
}
