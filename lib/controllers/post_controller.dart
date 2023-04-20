import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';
import 'package:foap/apiHandler/api_controller.dart';
import 'package:foap/screens/profile/other_user_profile.dart';

import '../model/post_model.dart';
import '../model/post_search_query.dart';

class PostController extends GetxController {
  RxList<PostModel> posts = <PostModel>[].obs;
  RxList<PostModel> mentions = <PostModel>[].obs;

  Rx<PostInsight?> insight = Rx<PostInsight?>(null);

  int totalPages = 100;

  bool isLoadingPosts = false;
  int postsCurrentPage = 1;
  bool canLoadMorePosts = true;

  int mentionsPostPage = 1;
  bool canLoadMoreMentionsPosts = true;
  bool mentionsPostsIsLoading = false;

  PostSearchQuery? postSearchQuery;

  MentionedPostSearchQuery? mentionedPostSearchQuery;

  clearPosts() {
    totalPages = 100;
    isLoadingPosts = false;
    postsCurrentPage = 1;
    canLoadMorePosts = true;

    mentionsPostPage = 1;
    canLoadMoreMentionsPosts = true;
    mentionsPostsIsLoading = false;

    posts.value = [];
    mentions.value = [];

    update();
  }

  addPosts(List<PostModel> postsList, int? startPage, int? totalPages) {
    mentionsPostPage = startPage ?? 1;
    postsCurrentPage = startPage ?? 1;
    this.totalPages = totalPages ?? 100;

    posts.addAll(postsList);
    update();
  }

  setPostSearchQuery(PostSearchQuery query) {
    if (query != postSearchQuery) {
      clearPosts();
    }
    update();
    postSearchQuery = query;
    getPosts();
  }

  setMentionedPostSearchQuery(MentionedPostSearchQuery query) {
    mentionedPostSearchQuery = query;
    getMyMentions();
  }

  removePostFromList(PostModel post) {
    posts.removeWhere((element) => element.id == post.id);
    mentions.removeWhere((element) => element.id == post.id);

    posts.refresh();
    mentions.refresh();
  }

  removeUsersAllPostFromList(PostModel post) {
    posts.removeWhere((element) => element.user.id == post.user.id);
    mentions.removeWhere((element) => element.user.id == post.user.id);

    posts.refresh();
    mentions.refresh();
  }

  void getPosts() async {
    if (canLoadMorePosts == true && totalPages > postsCurrentPage) {
      AppUtil.checkInternet().then((value) async {
        if (value) {
          isLoadingPosts = true;
          ApiController()
              .getPosts(
                  userId: postSearchQuery!.userId,
                  isPopular: postSearchQuery!.isPopular,
                  isFollowing: postSearchQuery!.isFollowing,
                  isSold: postSearchQuery!.isSold,
                  isMine: postSearchQuery!.isMine,
                  isRecent: postSearchQuery!.isRecent,
                  title: postSearchQuery!.title,
                  hashtag: postSearchQuery!.hashTag,
                  page: postsCurrentPage)
              .then((response) async {
            // posts.value = [];
            posts.addAll(response.success
                ? response.posts
                    .where((element) => element.gallery.isNotEmpty)
                    .toList()
                : []);
            posts.sort((a, b) => b.createDate!.compareTo(a.createDate!));
            isLoadingPosts = false;

            postsCurrentPage += 1;

            if (response.posts.length == response.metaData?.pageCount) {
              canLoadMorePosts = true;
              totalPages = response.metaData!.pageCount;
            } else {
              canLoadMorePosts = false;
            }
            update();
          });
        }
      });
    }
  }

  void getMyMentions() {
    if (canLoadMoreMentionsPosts) {
      AppUtil.checkInternet().then((value) {
        if (value) {
          mentionsPostsIsLoading = true;
          ApiController()
              .getMyMentions(userId: mentionedPostSearchQuery!.userId)
              .then((response) async {
            mentionsPostsIsLoading = false;

            mentions.addAll(
                response.success ? response.posts.reversed.toList() : []);

            mentionsPostPage += 1;
            if (response.posts.length == response.metaData?.perPage) {
              canLoadMoreMentionsPosts = true;
            } else {
              canLoadMoreMentionsPosts = false;
            }
            update();
          });
        }
      });
    }
  }

  void reportPost(int postId, BuildContext context) {
    AppUtil.checkInternet().then((value) async {
      if (value) {
        ApiController().reportPost(postId).then((response) async {});
      } else {
        AppUtil.showToast(
            message: LocalizationString.noInternet, isSuccess: true);
      }
    });
  }

  postTextTapHandler({required PostModel post, required String text}) {
    if (text.startsWith('#')) {
      PostSearchQuery query = PostSearchQuery();
      query.hashTag = text.replaceAll('#', '');
      setPostSearchQuery(query);

      // Get.to(() => Posts(
      //     hashTag: text.replaceAll('#', ''), source: PostSource.posts))!
      //     .then((value) {
      getPosts();
      // });
    } else {
      String userTag = text.replaceAll('@', '');
      if (post.mentionedUsers
          .where((element) => element.userName == userTag)
          .isNotEmpty) {
        int mentionedUserId = post.mentionedUsers
            .where((element) => element.userName == userTag)
            .first
            .id;
        Get.to(() => OtherUserProfile(userId: mentionedUserId))!.then((value) {
          getPosts();
        });
      } else {
        // print('not found');
      }
    }
  }

  viewInsight(int postId) {
    ApiController().getPostInsight(postId).then((response) {
      insight.value = response.insight;
      insight.refresh();
    });
  }
}
