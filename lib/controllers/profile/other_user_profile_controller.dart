import 'dart:async';

import 'package:foap/helper/enum_linking.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/list_extension.dart';
import 'package:foap/model/data_wrapper.dart';
import '../../api_handler/apis/gift_api.dart';
import '../../api_handler/apis/post_api.dart';
import '../../api_handler/apis/users_api.dart';
import 'package:foap/controllers/post/post_controller.dart';
import 'package:foap/model/gift_model.dart';
import 'package:foap/model/post_model.dart';

class OtherUserProfileController extends GetxController {
  final PostController postController = Get.find<PostController>();
  final UserProfileManager _userProfileManager = Get.find();

  DataWrapper postDataWrapper = DataWrapper();
  DataWrapper reelsDataWrapper = DataWrapper();
  DataWrapper mentionedPostDataWrapper = DataWrapper();
  DataWrapper collaborationsDataWrapper = DataWrapper();

  Rx<UserModel?> user = Rx<UserModel?>(null);

  int totalPages = 100;

  RxInt userNameCheckStatus = (-1).obs;
  RxBool isLoading = true.obs;

  RxInt selectedSegment = 0.obs;

  RxBool noDataFound = false.obs;

  RxList<PostModel> posts = <PostModel>[].obs;
  RxList<PostModel> mentions = <PostModel>[].obs;
  RxList<PostModel> reels = <PostModel>[].obs;
  RxList<PostModel> collaborations = <PostModel>[].obs;

  Rx<GiftModel?> sendingGift = Rx<GiftModel?>(null);

  clear() {
    selectedSegment.value = 0;

    postDataWrapper = DataWrapper();
    reelsDataWrapper = DataWrapper();
    mentionedPostDataWrapper = DataWrapper();
    collaborationsDataWrapper = DataWrapper();

    totalPages = 100;

    posts.clear();
    mentions.clear();
    reels.clear();
    collaborations.clear();
  }

  setUser(UserModel userObj) {
    user.value = userObj;
    update();
  }

  segmentChanged(int index) {
    selectedSegment.value = index;
    postController.update();
    update();
  }

  //////////////********** other user profile **************/////////////////

  void getOtherUserDetail(
      {required int userId,
      required Function(UserModel) completionBlock}) {
    UsersApi.getOtherUser(
        userId: userId,
        resultCallback: (result) {
          user.value = result;

          completionBlock(result);

          update();
        });
  }

  void followUnFollowUser({required UserModel user}) {
    if (user.isPrivateProfile &&
        user.followingStatus == FollowingStatus.notFollowing) {
      this.user.value!.followingStatus = FollowingStatus.requested;
    } else if (user.followingStatus == FollowingStatus.notFollowing) {
      this.user.value!.followingStatus = FollowingStatus.following;
    } else {
      this.user.value!.followingStatus = FollowingStatus.notFollowing;
    }

    this.user.refresh();
    update();

    UsersApi.followUnfollowUser(
            isFollowing: this.user.value!.followingStatus ==
                    FollowingStatus.notFollowing
                ? false
                : true,
            user: user)
        .then((value) {
      this.user.refresh();
      update();
    });
  }

  void reportUser() {
    user.value!.isReported = true;
    update();

    UsersApi.reportUser(userId: user.value!.id, resultCallback: () {});
  }

  void blockUser() {
    user.value!.isReported = true;
    update();

    UsersApi.blockUser(userId: user.value!.id, resultCallback: () {});
  }

//////////////********** other user profile **************/////////////////

  followUser(UserModel user) {
    user.followingStatus = user.isPrivateProfile
        ? FollowingStatus.requested
        : FollowingStatus.following;
    update();
    UsersApi.followUnfollowUser(isFollowing: true, user: user)
        .then((value) {
      update();
    });
  }

  unFollowUser(UserModel user) {
    user.followingStatus = FollowingStatus.notFollowing;

    update();
    UsersApi.followUnfollowUser(isFollowing: false, user: user)
        .then((value) {
      update();
    });
  }

  //******************** Posts ****************//
  removePostFromList(PostModel post) {
    posts.removeWhere((element) => element.id == post.id);
    mentions.removeWhere((element) => element.id == post.id);
    reels.removeWhere((element) => element.id == post.id);
    collaborations.removeWhere((element) => element.id == post.id);

    posts.refresh();
    mentions.refresh();
    reels.refresh();
    collaborations.refresh();
  }

  removeUsersAllPostFromList(PostModel post) {
    posts.removeWhere((element) => element.user.id == post.user.id);
    mentions.removeWhere((element) => element.user.id == post.user.id);
    reels.removeWhere((element) => element.user.id == post.user.id);
    collaborations
        .removeWhere((element) => element.user.id == post.user.id);

    posts.refresh();
    mentions.refresh();
    reels.refresh();
    collaborations.refresh();
  }

  void getPosts(
      {required int userId, required VoidCallback callback}) async {
    if (postDataWrapper.haveMoreData.value == true &&
        totalPages > postDataWrapper.page) {
      if (postDataWrapper.page == 1) {
        postDataWrapper.isLoading.value = true;
      }

      PostApi.getPosts(
          userId: userId,
          page: postDataWrapper.page,
          resultCallback: (result, metadata) {
            posts.addAll(result);
            posts.unique((e) => e.id);
            postDataWrapper.processCompletedWithData(metadata);

            callback();
            update();
          });
    } else {
      callback();
    }
  }

  void getReels(int userId) async {
    if (reelsDataWrapper.haveMoreData.value == true) {
      reelsDataWrapper.isLoading.value = true;
      PostApi.getPosts(
          userId: userId,
          postType: PostCategory.reel,
          page: reelsDataWrapper.page,
          resultCallback: (result, metadata) {
            reels.addAll(result);
            reels.unique((e) => e.id);
            reelsDataWrapper.processCompletedWithData(metadata);
            update();
          });
    }
  }

  void getMentionPosts(int userId) {
    if (mentionedPostDataWrapper.haveMoreData.value) {
      mentionedPostDataWrapper.isLoading.value = true;

      PostApi.getMentionedPosts(
          userId: userId,
          page: mentionedPostDataWrapper.page,
          resultCallback: (result, metadata) {
            mentions.addAll(result.reversed.toList());
            mentions.unique((e) => e.id);
            mentionedPostDataWrapper.processCompletedWithData(metadata);
            update();
          });
    }
  }

  void getCollaborationsPosts() {
    if (collaborationsDataWrapper.haveMoreData.value) {
      collaborationsDataWrapper.isLoading.value = true;

      PostApi.getPosts(
          isCollaboration: 1,
          page: collaborationsDataWrapper.page,
          resultCallback: (result, metadata) {
            collaborations.addAll(result.reversed.toList());
            collaborations.unique((e) => e.id);
            collaborationsDataWrapper.processCompletedWithData(metadata);
            update();
          });
    }
  }

  otherUserProfileView(
      {required int refId, required UserViewSourceType viewSource}) {
    UsersApi.otherUserProfileView(
        refId: refId, sourceType: userViewSourceTypeToId(viewSource));
  }

  sendGift(GiftModel gift) {
    if (_userProfileManager.user.value!.coins > gift.coins) {
      sendingGift.value = gift;
      GiftApi.sendStickerGift(
          gift: gift,
          liveId: null,
          postId: null,
          receiverId: user.value!.id,
          resultCallback: () {
            Timer(const Duration(seconds: 1), () {
              sendingGift.value = null;
            });

            // refresh profile to get updated wallet info
            AppUtil.showToast(
                message: giftSentSuccessfullyString.tr, isSuccess: true);
            _userProfileManager.refreshProfile();
          });
    } else {}
  }

}
