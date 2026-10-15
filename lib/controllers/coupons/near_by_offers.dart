import 'package:foap/api_handler/apis/offers_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/models.dart';
import 'package:foap/helper/list_extension.dart';
import 'package:foap/model/business_model.dart';
import '../../model/offer_model.dart';

class NearByOffersController extends GetxController {
  final UserProfileManager _userProfileManager = Get.find();
  RxList<OffersCategoryModel> categories = <OffersCategoryModel>[].obs;
  RxList<BusinessModel> businessList = <BusinessModel>[].obs;
  RxList<OfferModel> offers = <OfferModel>[].obs;
  RxList<OfferModel> favOffers = <OfferModel>[].obs;
  RxList<CommentModel> comments = <CommentModel>[].obs;

  RxBool isLoadingCategories = false.obs;

  Rx<BusinessModel?> currentBusiness = Rx<BusinessModel?>(null);
  Rx<OfferModel?> currentOffer = Rx<OfferModel?>(null);

  int businessPage = 1;
  bool canLoadMoreBusiness = true;
  RxBool isLoadingBusiness = false.obs;

  int offerPage = 1;
  bool canLoadMoreOffers = true;
  RxBool isLoadingOffers = false.obs;

  int favOfferPage = 1;
  bool canLoadMoreFavOffers = true;
  RxBool isLoadingFavOffer = false.obs;

  int commentPage = 1;
  bool canLoadMoreComment = true;
  RxBool isLoadingComments = false.obs;

  RxInt currentIndex = 0.obs;

  RxInt totalOffersFound = 0.obs;
  RxInt totalFavOffersFound = 0.obs;

  RxInt totalBusinessFound = 0.obs;

  OfferSearchModel offerSearchModel = OfferSearchModel();
  OfferSearchModel favOfferSearchModel = OfferSearchModel();

  BusinessSearchModel businessSearchModel = BusinessSearchModel();
  Rx<CommentModel?> replyingComment = Rx<CommentModel?>(null);

  clear() {
    categories.clear();
    businessList.clear();
    offers.clear();
    favOffers.clear();

    isLoadingCategories.value = false;
    currentBusiness.value = null;
    currentOffer.value = null;

    favOfferPage = 1;
    canLoadMoreFavOffers = true;
    isLoadingFavOffer.value = false;

    businessPage = 1;
    canLoadMoreBusiness = true;
    isLoadingBusiness.value = false;
    currentIndex.value = 0;

    offerPage = 1;
    canLoadMoreOffers = true;
    isLoadingOffers.value = false;

    commentPage = 1;
    canLoadMoreComment = true;
    isLoadingComments.value = false;

    replyingComment.value = null;

    totalOffersFound.value = 0;
    totalFavOffersFound.value = 0;
    totalBusinessFound.value = 0;

    offerSearchModel = OfferSearchModel();
    businessSearchModel = BusinessSearchModel();
    favOfferSearchModel = OfferSearchModel();
  }

  clearBusinesses() {
    businessList.clear();
    businessPage = 1;
    canLoadMoreBusiness = true;
    isLoadingBusiness.value = false;
  }

  clearOffers() {
    offers.clear();
    offerPage = 1;
    canLoadMoreOffers = true;
    isLoadingOffers.value = false;
  }

  clearFavOffers() {
    favOffers.clear();
    favOfferPage = 1;
    canLoadMoreFavOffers = true;
    isLoadingFavOffer.value = false;
  }

  clearComments() {
    comments.clear();
    commentPage = 1;
    canLoadMoreComment = true;
    isLoadingComments.value = false;
  }

  initiate() {
    getCategories();
    getBusinesses(() {});
    getOffers(() {});
  }

  setReplyComment(CommentModel? comment) {
    replyingComment.value = comment;
  }

  setCurrentBusiness(BusinessModel business) {
    currentBusiness.value = business;
    clearComments();
    clearOffers();
    setOfferBusinessId(business.id);
    // getBusinessComments(() {});
    getOffers(() {});
  }

  setCurrentOffer(OfferModel offer) {
    currentOffer.value = offer;
    clearComments();
    getOfferComments(() {});
  }

  updateGallerySlider(int index) {
    currentIndex.value = index;
  }

  setOfferBusinessId(int? id) {
    clearOffers();
    offerSearchModel.businessId = id;
    getOffers(() {});
  }

  setOfferCategoryId(int? id) {
    clearOffers();
    offerSearchModel.categoryId = id;
    getOffers(() {});
  }

  setFavOfferBusinessId(int? id) {
    clearFavOffers();
    favOfferSearchModel.businessId = id;
    getFavOffers(() {});
  }

  setFavOfferCategoryId(int? id) {
    clearFavOffers();
    favOfferSearchModel.categoryId = id;
    getFavOffers(() {});
  }

  setFavOfferName(String? name) {
    clearFavOffers();
    favOfferSearchModel.name = name;
    getFavOffers(() {});
  }

  setOfferName(String? name) {
    clearOffers();
    offerSearchModel.name = name;
    getOffers(() {});
  }

  setBusinessCategoryId(int? id) {
    clearBusinesses();
    businessSearchModel.categoryId = id;
    getBusinesses(() {});
  }

  setBusinessName(String? name) {
    clearBusinesses();
    businessSearchModel.name = name;
    getBusinesses(() {});
  }

  getCategories() {
    isLoadingCategories.value = true;
    OffersApi.getCategories(resultCallback: (result) {
      categories.value = result;
      isLoadingCategories.value = false;

      update();
    });
  }

  getBusinesses(VoidCallback callback) {
    if (canLoadMoreBusiness) {
      OffersApi.getBusinesses(
          page: businessPage,
          searchModel: businessSearchModel,
          resultCallback: (result, metadata) {
            businessList.addAll(result);
            businessList.unique((e) => e.id);

            isLoadingBusiness.value = false;

            canLoadMoreBusiness = result.length >= metadata.perPage;
            totalBusinessFound.value = metadata.totalCount;

            businessPage += 1;
            update();
            callback();
          });
    } else {
      callback();
    }
  }

  favUnFavBusiness(BusinessModel business) {
    bool isFav = !business.isFavourite;
    currentBusiness.value?.isFavourite = isFav;
    currentBusiness.refresh();
    businessList.value = businessList.map((currentItem) {
      if (currentBusiness.value!.id == currentItem.id) {
        currentItem.isFavourite = isFav;
      }
      return currentItem;
    }).toList();

    // update();

    OffersApi.favUnfavBusiness(isFav, business.id);
  }

  getOffers(VoidCallback callback) {
    if (canLoadMoreOffers) {
      OffersApi.getOffers(
          page: offerPage,
          searchModel: offerSearchModel,
          resultCallback: (result, metadata) {
            offers.addAll(result);
            offers.unique((e) => e.id);
            isLoadingOffers.value = false;

            canLoadMoreOffers = result.length >= metadata.perPage;
            totalOffersFound.value = metadata.totalCount;
            offerPage += 1;
            update();
            callback();
          });
    } else {
      callback();
    }
  }

  favUnFavOffer(OfferModel offer) {
    bool isFav = !offer.isFavourite;
    currentOffer.value?.isFavourite = isFav;
    currentOffer.refresh();
    offers.value = offers.map((currentItem) {
      if (currentOffer.value!.id == currentItem.id) {
        currentItem.isFavourite = isFav;
      }
      return currentItem;
    }).toList();

    // update();

    OffersApi.favUnfavOffer(isFav, offer.id);
  }

  postOfferComment(String comment) {
    OffersApi.postComment(
        comment: comment,
        offerId: currentOffer.value!.id,
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

  getOfferComments(VoidCallback callback) {
    if (canLoadMoreComment) {
      OffersApi.getComments(
          page: commentPage,
          offerId: currentOffer.value!.id,
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
    required int offerId,
    required int parentId,
  }) {
    OffersApi.getComments(
        offerId: offerId,
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

  void deleteComment({required CommentModel comment}) {
    if (comment.level == 1) {
      comments.removeWhere((element) => element.id == comment.id);
    } else {
      CommentModel mainComment =
          comments.where((e) => e.id == comment.parentId).first;
      mainComment.replies.removeWhere((element) => element.id == comment.id);
    }

    update();
    OffersApi.deleteComment(
        resultCallback: () {
          AppUtil.showToast(message: commentIsDeletedString, isSuccess: true);
        },
        commentId: comment.id);
  }

  void reportComment({required int commentId}) {
    OffersApi.reportComment(
        resultCallback: () {
          AppUtil.showToast(message: commentIsReportedString, isSuccess: true);
        },
        commentId: commentId);
  }

  void favUnfavComment({required CommentModel comment}) {
    if (comment.isFavourite) {
      OffersApi.favComment(resultCallback: () {}, commentId: comment.id);
    } else {
      OffersApi.unfavComment(resultCallback: () {}, commentId: comment.id);
    }
  }

  getFavOffers(VoidCallback callback) {
    if (canLoadMoreFavOffers) {
      OffersApi.getFavOffers(
          page: favOfferPage,
          searchModel: favOfferSearchModel,
          resultCallback: (result, metadata) {
            favOffers.addAll(result);
            favOffers.unique((e) => e.id);
            isLoadingFavOffer.value = false;

            canLoadMoreFavOffers = result.length >= metadata.perPage;
            totalFavOffersFound.value = metadata.totalCount;

            favOfferPage += 1;
            update();
            callback();
          });
    } else {
      callback();
    }
  }
}
