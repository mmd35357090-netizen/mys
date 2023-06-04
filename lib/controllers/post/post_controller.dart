import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/list_extension.dart';
import '../../apiHandler/apis/post_api.dart';
import '../../model/post_model.dart';
import '../../model/post_search_query.dart';

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

  clear() {
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
    posts.unique((e) => e.id);
    update();
  }

  setPostSearchQuery({required PostSearchQuery query, required VoidCallback callback}) {
    if (query != postSearchQuery) {
      clear();
    }
    update();
    postSearchQuery = query;
    getPosts(callback);
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

  void getPosts(VoidCallback callback) async {
    if (canLoadMorePosts == true && totalPages > postsCurrentPage) {
      isLoadingPosts = true;

      PostApi.getPosts(
          userId: postSearchQuery!.userId,
          isPopular: postSearchQuery!.isPopular,
          isFollowing: postSearchQuery!.isFollowing,
          isSold: postSearchQuery!.isSold,
          isMine: postSearchQuery!.isMine,
          isRecent: postSearchQuery!.isRecent,
          title: postSearchQuery!.title,
          hashtag: postSearchQuery!.hashTag,
          page: postsCurrentPage,
          resultCallback: (result, metadata) {
            posts.addAll(
                result.where((element) => element.gallery.isNotEmpty).toList());
            posts.sort((a, b) => b.createDate!.compareTo(a.createDate!));
            posts.unique((e) => e.id);
            isLoadingPosts = false;

            if (postsCurrentPage >= metadata.pageCount) {
              canLoadMorePosts = false;
            } else {
              canLoadMorePosts = true;
            }
            postsCurrentPage += 1;

            callback();

            print('posts = ${posts.length}');
            update();
          });
    }
  }

  void getMyMentions() {
    if (canLoadMoreMentionsPosts) {
      PostApi.getMentionedPosts(
          userId: mentionedPostSearchQuery!.userId,
          resultCallback: (result, metaData) {
            mentionsPostsIsLoading = false;
            mentions.addAll(result.reversed.toList());
            mentions.unique((e)=> e.id);

            mentionsPostPage += 1;
            if (result.length == metaData.perPage) {
              canLoadMoreMentionsPosts = true;
            } else {
              canLoadMoreMentionsPosts = false;
            }
            update();
          });
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

  // postTextTapHandler({required PostModel post, required String text}) {
  //   if (text.startsWith('#')) {
  //     PostSearchQuery query = PostSearchQuery();
  //     query.hashTag = text.replaceAll('#', '');
  //     setPostSearchQuery(query);
  //
  //     // Get.to(() => Posts(
  //     //     hashTag: text.replaceAll('#', ''), source: PostSource.posts))!
  //     //     .then((value) {
  //     getPosts();
  //     // });
  //   } else {
  //     String userTag = text.replaceAll('@', '');
  //     if (post.mentionedUsers
  //         .where((element) => element.userName == userTag)
  //         .isNotEmpty) {
  //       int mentionedUserId = post.mentionedUsers
  //           .where((element) => element.userName == userTag)
  //           .first
  //           .id;
  //       Get.to(() => OtherUserProfile(userId: mentionedUserId))!.then((value) {
  //         getPosts();
  //       });
  //     } else {
  //       // print('not found');
  //     }
  //   }
  // }

  viewInsight(int postId) {
    PostApi.getPostInsight(postId, resultCallback: (result) {
      insight.value = result;
      insight.refresh();
    });
  }
}
