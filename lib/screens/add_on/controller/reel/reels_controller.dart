import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/post_model.dart';
import 'package:foap/model/post_search_query.dart';
import 'package:get/get.dart';
import 'package:foap/apiHandler/api_controller.dart';

import '../../../../apiHandler/apis/post_api.dart';

class ReelsController extends GetxController {
  RxList<PostModel> publicMoments = <PostModel>[].obs;
  RxList<PostModel> filteredMoments = <PostModel>[].obs;
  RxList<PostModel> likedReels = <PostModel>[].obs;

  Rx<PostModel?> currentViewingReel = Rx<PostModel?>(null);

  bool isLoadingReelsWithAudio = false;
  int reelsWithAudioCurrentPage = 1;
  bool canLoadMoreReelsWithAudio = true;

  bool isLoadingReels = false;
  int reelsCurrentPage = 1;
  bool canLoadMoreReels = true;
  PostSearchQuery reelSearchQuery = PostSearchQuery();

  clearReels() {
    isLoadingReels = false;
    reelsCurrentPage = 1;
    canLoadMoreReels = true;
    currentViewingReel.value = null;

    update();
  }

  clearReelsWithAudio() {
    isLoadingReelsWithAudio = false;
    reelsWithAudioCurrentPage = 1;
    canLoadMoreReelsWithAudio = true;
    filteredMoments.clear();
  }

  setCurrentViewingReel(PostModel reel) {
    currentViewingReel.value = reel;
    currentViewingReel.refresh();
    update();
  }

  currentPageChanged(int index, PostModel reel) {
    setCurrentViewingReel(reel);
    // currentPage.value = index;
    // currentPage.refresh();
  }

  addReels(List<PostModel> reelsList, int? startPage) {
    filteredMoments.clear();
    reelsCurrentPage = startPage ?? 1;
    filteredMoments.addAll(reelsList);
    update();
  }

  setReelsSearchQuery(PostSearchQuery query) {
    if (query != reelSearchQuery) {
      clearReels();
    }
    update();
    reelSearchQuery = query;
    getReels();
  }

  void getReels() async {
    if (canLoadMoreReels == true) {
      isLoadingReels = true;

      PostApi.getPosts(
          isReel: 1,
          userId: reelSearchQuery.userId,
          isPopular: reelSearchQuery.isPopular,
          isFollowing: reelSearchQuery.isFollowing,
          isSold: reelSearchQuery.isSold,
          isMine: reelSearchQuery.isMine,
          isRecent: reelSearchQuery.isRecent,
          title: reelSearchQuery.title,
          hashtag: reelSearchQuery.hashTag,
          page: reelsCurrentPage,
          resultCallback: (result, metadata) {
            publicMoments.addAll(
                result.where((element) => element.gallery.isNotEmpty).toList());
            publicMoments
                .sort((a, b) => b.createDate!.compareTo(a.createDate!));
            isLoadingReels = false;
            if (reelsCurrentPage == 1 && publicMoments.isNotEmpty) {
              currentPageChanged(0, publicMoments.first);
            }
            if (reelsCurrentPage >= metadata.pageCount) {
              canLoadMoreReels = false;
            } else {
              canLoadMoreReels = true;
            }
            reelsCurrentPage += 1;
            // totalPages = metadata.pageCount;

            update();
          });
    }
  }

  void getReelsWithAudio(int audioId) async {
    if (canLoadMoreReelsWithAudio == true) {
      isLoadingReelsWithAudio = true;

      PostApi.getPosts(
          isReel: 1,
          audioId: audioId,
          page: reelsWithAudioCurrentPage,
          resultCallback: (result, metadata) {
            filteredMoments.addAll(
                result.where((element) => element.gallery.isNotEmpty).toList());
            // reels.sort((a, b) => b.createDate!.compareTo(a.createDate!));
            isLoadingReelsWithAudio = false;

            if (reelsWithAudioCurrentPage == 1) {
              currentPageChanged(0, publicMoments.first);
            }

            reelsWithAudioCurrentPage += 1;
            if (result.length == metadata.pageCount) {
              canLoadMoreReelsWithAudio = true;
              // totalPages = response.metaData!.pageCount;
            } else {
              canLoadMoreReelsWithAudio = false;
            }
            update();
          });
    }
  }

  void likeUnlikeReel(
      {required PostModel post}) {
    post.isLike = !post.isLike;
    if (post.isLike) {
      likedReels.add(post);
    } else {
      likedReels.remove(post);
    }
    likedReels.refresh();
    post.totalLike = post.isLike ? (post.totalLike) + 1 : (post.totalLike) - 1;
    PostApi.likeUnlikePost(like: post.isLike, postId: post.id);
  }
}
