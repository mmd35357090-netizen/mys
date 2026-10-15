import 'package:foap/api_handler/apis/fund_raising_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/event_imports.dart';
import 'package:foap/helper/list_extension.dart';
import '../../api_handler/apis/post_api.dart';
import '../../api_handler/apis/users_api.dart';
import '../../model/comment_model.dart';
import '../../model/data_wrapper.dart';
import '../../model/fund_raising_campaign.dart';
import '../../model/post_model.dart';

class FundRaisingController extends GetxController {
  TextEditingController donationAmountTE = TextEditingController();

  final UserProfileManager _userProfileManager = Get.find();

  RxList<FundRaisingCampaignCategoryModel> categories =
      <FundRaisingCampaignCategoryModel>[].obs;
  RxList<FundRaisingCampaign> campaigns = <FundRaisingCampaign>[].obs;
  RxList<FundRaisingCampaign> favCampaigns = <FundRaisingCampaign>[].obs;
  RxList<CommentModel> comments = <CommentModel>[].obs;
  RxList<UserModel> donors = <UserModel>[].obs;
  RxList<PostModel> posts = <PostModel>[].obs;

  Rx<CommentModel?> replyingComment = Rx<CommentModel?>(null);

  FundRaisingCampaignSearchModel searchModel = FundRaisingCampaignSearchModel();

  RxBool isLoadingCategories = false.obs;

  Rx<FundRaisingCampaign?> currentCampaign = Rx<FundRaisingCampaign?>(null);

  DataWrapper postDataWrapper = DataWrapper();

  int campaignPage = 1;
  bool canLoadMoreCampaigns = true;
  RxBool isLoadingCampaigns = false.obs;

  int favPage = 1;
  bool canLoadMoreFav = true;
  RxBool isLoadingFav = false.obs;

  int donorsPage = 1;
  bool canLoadMoreDonors = true;
  RxBool isLoadingDonor = false.obs;

  RxInt currentIndex = 0.obs;

  int commentPage = 1;
  bool canLoadMoreComment = true;
  RxBool isLoadingComments = false.obs;

  RxInt totalCampaignsFound = 0.obs;
  RxInt totalFavCampaignsFound = 0.obs;
  RxInt totalDonorsFound = 0.obs;

  double donationAmount = 0.0;

  clear() {
    categories.clear();
    favCampaigns.clear();
    isLoadingCategories.value = false;

    currentCampaign.value = null;

    favPage = 1;
    canLoadMoreFav = true;
    isLoadingFav.value = false;

    totalFavCampaignsFound.value = 0;
    totalCampaignsFound.value = 0;
    totalDonorsFound.value = 0;

    searchModel = FundRaisingCampaignSearchModel();
    donationAmount = 0.0;
    replyingComment.value = null;

    postDataWrapper = DataWrapper();
    posts.clear();

    clearComments();
    clearCampaigns();
    clearDonors();
  }

  clearDonors() {
    donors.clear();
    resetDonorsPaging();
  }

  resetDonorsPaging() {
    donorsPage = 1;
    canLoadMoreDonors = true;
    isLoadingDonor.value = false;
  }

  clearCampaigns() {
    campaigns.clear();
    resetCampaignsPaging();
  }

  resetCampaignsPaging() {
    campaignPage = 1;
    canLoadMoreCampaigns = true;
    isLoadingCampaigns.value = false;
  }

  clearComments() {
    comments.clear();
    resetCommentsPaging();
  }

  resetCommentsPaging() {
    commentPage = 1;
    canLoadMoreComment = true;
    isLoadingComments.value = false;
  }

  initiate() {
    getCategories();
    getFavCampaigns(() {});
    getCampaigns(() {});
  }

  setReplyComment(CommentModel? comment) {
    replyingComment.value = comment;
  }

  setCurrentCampaign(FundRaisingCampaign campaign) {
    clearComments();
    currentCampaign.value = campaign;
    getComments(() {});
    getCampaignDonors(() {});
    refreshPosts(id: campaign.id, callback: () {});
  }

  setCategoryId(int? categoryId) {
    clearCampaigns();
    searchModel.categoryId = categoryId;
    getCampaigns(() {});
  }

  setTitle(String? title) {
    clearCampaigns();
    searchModel.title = title;
    getCampaigns(() {});
  }

  setCampaignerId(int? id) {
    clearCampaigns();
    searchModel.campaignerId = id;
    getCampaigns(() {});
  }

  setCampaignForId(int? id) {
    clearCampaigns();
    searchModel.campaignForId = id;
    getCampaigns(() {});
  }

  getCategories() {
    isLoadingCategories.value = true;
    FundRaisingApi.getCategories(resultCallback: (result) {
      categories.value = result;
      isLoadingCategories.value = false;

      update();
    });
  }

  updateGallerySlider(int index) {
    currentIndex.value = index;
  }

  getCampaigns(VoidCallback callback) {
    if (canLoadMoreCampaigns) {
      FundRaisingApi.getCampaigns(
          searchModel: searchModel,
          page: campaignPage,
          resultCallback: (result, metadata) {
            campaigns.addAll(result);
            campaigns.unique((e) => e.id);
            isLoadingCampaigns.value = false;

            canLoadMoreCampaigns = result.length >= metadata.perPage;
            totalCampaignsFound.value = metadata.totalCount;
            campaignPage += 1;
            update();
            callback();
          });
    } else {
      callback();
    }
  }

  favUnFavCampaign(FundRaisingCampaign campaign) {
    bool isFav = !campaign.isFavourite;
    currentCampaign.value?.isFavourite = isFav;
    currentCampaign.refresh();
    campaigns.value = campaigns.map((currentItem) {
      if (currentCampaign.value!.id == currentItem.id) {
        currentItem.isFavourite = isFav;
      }
      return currentItem;
    }).toList();

    if (isFav == false) {
      favCampaigns.removeWhere((element) => element.id == campaign.id);
    } else {
      favCampaigns.add(campaign);
    }

    FundRaisingApi.favUnfavCampaign(isFav, campaign.id);
  }

  getFavCampaigns(VoidCallback callback) {
    if (canLoadMoreFav) {
      FundRaisingApi.getFavCampaigns(
          page: favPage,
          resultCallback: (result, metadata) {
            favCampaigns.addAll(result);
            favCampaigns.unique((e) => e.id);
            isLoadingFav.value = false;

            canLoadMoreFav = result.length >= metadata.perPage;
            totalFavCampaignsFound.value = metadata.totalCount;

            favPage += 1;
            update();
            callback();
          });
    } else {
      callback();
    }
  }

  getCampaignDonors(VoidCallback callback) {
    if (canLoadMoreDonors) {
      FundRaisingApi.getCampaignDonors(
          campaignId: currentCampaign.value!.id,
          page: donorsPage,
          resultCallback: (result, metadata) {
            donors.addAll(result);
            // donors.unique((e) => e.id);
            isLoadingDonor.value = false;

            canLoadMoreDonors = result.length >= metadata.perPage;
            totalDonorsFound.value = metadata.totalCount;

            donorsPage += 1;
            update();
            callback();
          });
    } else {
      callback();
    }
  }

  followDonor(UserModel user) {
    user.followingStatus = FollowingStatus.following;
    if (donors.where((e) => e.id == user.id).isNotEmpty) {
      donors[donors.indexWhere((element) => element.id == user.id)] = user;
    }

    update();

    UsersApi.followUnfollowUser(isFollowing: true, user: user);
  }

  unFollowDonor(UserModel user) {
    user.followingStatus = FollowingStatus.notFollowing;
    if (donors.where((e) => e.id == user.id).isNotEmpty) {
      donors[donors.indexWhere((element) => element.id == user.id)] = user;
    }

    update();
    UsersApi.followUnfollowUser(isFollowing: false, user: user);
  }

  postComment(String comment) {
    FundRaisingApi.postComment(
        comment: comment,
        campaignId: currentCampaign.value!.id,
        parentCommentId: replyingComment.value?.id,
        resultCallback: (id) {
          CommentModel newComment = CommentModel.fromNewMessage(
              CommentType.text, _userProfileManager.user.value!,
              comment: comment, id: id);
          if (replyingComment.value == null) {
            comments.add(newComment);
          } else {
            newComment.level = 2;
            CommentModel mainComment =
                comments.where((e) => e.id == replyingComment.value!.id).first;
            mainComment.replies.add(newComment);
          }

          replyingComment.value = null;
          update();
        });
  }

  void deleteComment({required CommentModel comment}) {
    if (comment.level == 1) {
      comments.removeWhere((element) => element.id == comment.id);
    } else {
      CommentModel mainComment =
          comments.where((e) => e.id == comment.parentId).first;
      mainComment.replies.removeWhere((element) => element.id == comment.id);
    }

    update();
    FundRaisingApi.deleteComment(
        resultCallback: () {
          AppUtil.showToast(message: commentIsDeletedString, isSuccess: true);
        },
        commentId: comment.id);
  }

  void reportComment({required int commentId}) {
    FundRaisingApi.reportComment(
        resultCallback: () {
          AppUtil.showToast(message: commentIsReportedString, isSuccess: true);
        },
        commentId: commentId);
  }

  void favUnfavComment({required CommentModel comment}) {
    if (comment.isFavourite) {
      FundRaisingApi.favComment(resultCallback: () {}, commentId: comment.id);
    } else {
      FundRaisingApi.unfavComment(resultCallback: () {}, commentId: comment.id);
    }
  }

  getComments(VoidCallback callback) {
    if (canLoadMoreComment) {
      FundRaisingApi.getComments(
          page: commentPage,
          campaignId: currentCampaign.value!.id,
          resultCallback: (result, metadata) {
            comments.addAll(result);
            comments.unique((e) => e.id);
            isLoadingComments.value = false;

            canLoadMoreComment = result.length >= metadata.perPage;
            commentPage += 1;
            update();
            callback();
          });
    } else {
      callback();
    }
  }

  void getChildComments({
    required int page,
    required int refId,
    required int parentId,
  }) {
    FundRaisingApi.getComments(
        campaignId: refId,
        parentId: parentId,
        page: page,
        resultCallback: (result, metadata) {
          CommentModel mainComment =
              comments.where((e) => e.id == parentId).first;
          mainComment.currentPageForReplies = metadata.currentPage + 1;
          mainComment.pendingReplies =
              metadata.totalCount - (metadata.currentPage * metadata.perPage);
          mainComment.replies.addAll(result);
          update();
        });
  }

  setDonationAmount(int amount) {
    donationAmountTE.text = amount.toString();
    donationAmount = amount.toDouble();
  }

  FundraisingDonationRequest get order {
    FundraisingDonationRequest donationOrder =
        FundraisingDonationRequest(payments: []);

    donationOrder.campaignId = currentCampaign.value!.id;
    donationOrder.totalAmount = donationAmount;
    donationOrder.itemName = currentCampaign.value!.title;

    return donationOrder;
  }

  makeDonation(FundraisingDonationRequest donationOrder) {
    final CheckoutController checkoutController = Get.find();

    FundRaisingApi.makeDonationPayment(
        orderRequest: donationOrder,
        resultCallback: (status) {
          if (status) {
            checkoutController.orderPlaced();
          } else {
            checkoutController.orderFailed();
          }
        });
  }

  refreshPosts({ int? id, required VoidCallback callback}) {
    postDataWrapper = DataWrapper();
    getPosts(id: id, callback: callback);
  }

  loadMorePosts({ int? id, required VoidCallback callback}) {
    if (postDataWrapper.haveMoreData.value == true) {
      if (postDataWrapper.page == 1) {
        postDataWrapper.isLoading.value = true;
      }
      getPosts(id: id, callback: callback);
    } else {
      callback();
    }
  }

  void getPosts({ int? id, required VoidCallback callback}) async {
    PostApi.getPosts(
        postType: PostCategory.fundRaising,
        fundRaisingCampaignId: id,
        page: postDataWrapper.page,
        resultCallback: (result, metadata) {
          posts.addAll(result);
          posts.sort((a, b) => b.createDate!.compareTo(a.createDate!));
          posts.unique((e) => e.id);

          postDataWrapper.processCompletedWithData(metadata);

          callback();
          update();
        });
  }

  removePostFromList(PostModel post) {
    posts.removeWhere((element) => element.id == post.id);
    posts.refresh();
  }

  removeUsersAllPostFromList(PostModel post) {
    posts.removeWhere((element) => element.user.id == post.user.id);
    posts.refresh();
  }
}
