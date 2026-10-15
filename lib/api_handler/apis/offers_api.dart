import 'dart:ui';

import 'package:foap/helper/imports/models.dart';
import 'package:foap/model/business_model.dart';
import 'package:foap/model/offer_model.dart';
import '../api_wrapper.dart';

class OffersApi {
  static getCategories(
      {required Function(List<OffersCategoryModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.businessCategories;

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['category'];

        resultCallback(List<OffersCategoryModel>.from(
            items.map((x) => OffersCategoryModel.fromJson(x))));
      }
    });
  }

  static getBusinesses(
      {required int page,
      required BusinessSearchModel searchModel,
      required Function(List<BusinessModel>, APIMetaData)
          resultCallback}) async {
    var url = NetworkConstantsUtil.searchBusiness;

    if (searchModel.categoryId != null) {
      url = '$url&business_category_id=${searchModel.categoryId!}';
    }
    if (searchModel.name != null) {
      url = '$url&name=${searchModel.name!}';
    }

    url = '$url&page=$page';

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['business']['items'];

        resultCallback(
            List<BusinessModel>.from(
                items.map((x) => BusinessModel.fromJson(x))),
            APIMetaData.fromJson(result.data['business']['_meta']));
      }
    });
  }

  static favUnfavBusiness(bool fav, int businessId) async {
    var url =
        (fav ? NetworkConstantsUtil.favOffer : NetworkConstantsUtil.unFavOffer);

    await ApiWrapper().postApi(url: url, param: {
      "reference_id": businessId.toString(),
      "type": "2"
    }).then((result) {
      if (result?.success == true) {}
    });
  }

  static getOffers(
      {required int page,
      required OfferSearchModel searchModel,
      required Function(List<OfferModel>, APIMetaData) resultCallback}) async {
    var url = NetworkConstantsUtil.offersList;

    if (searchModel.categoryId != null) {
      url = '$url&business_category_id=${searchModel.categoryId!}';
    }
    if (searchModel.businessId != null) {
      url = '$url&business_id=${searchModel.businessId!}';
    }
    if (searchModel.name != null) {
      url = '$url&name=${searchModel.name!}';
    }
    url = '$url&page=$page';

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['coupon']['items'];

        resultCallback(
            List<OfferModel>.from(items.map((x) => OfferModel.fromJson(x))),
            APIMetaData.fromJson(result.data['coupon']['_meta']));
      }
    });
  }

  static favUnfavOffer(bool fav, int offerId) async {
    var url =
        (fav ? NetworkConstantsUtil.favOffer : NetworkConstantsUtil.unFavOffer);

    await ApiWrapper().postApi(url: url, param: {
      "reference_id": offerId.toString(),
      "type": "1"
    }).then((result) {
      if (result?.success == true) {}
    });
  }

  static getFavOffers(
      {required int page,
      required OfferSearchModel searchModel,
      required Function(List<OfferModel>, APIMetaData) resultCallback}) async {
    var url = NetworkConstantsUtil.getFavOffer;
    if (searchModel.categoryId != null) {
      url = '$url&business_category_id=${searchModel.categoryId!}';
    }
    if (searchModel.businessId != null) {
      url = '$url&business_id=${searchModel.businessId!}';
    }
    if (searchModel.name != null) {
      url = '$url&name=${searchModel.name!}';
    }
    url = '$url&page=$page';
    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['couponFavoriteList']['items'];

        resultCallback(
            List<OfferModel>.from(items.map((x) => OfferModel.fromJson(x))),
            APIMetaData.fromJson(result.data['couponFavoriteList']['_meta']));
      }
    });
  }

  static getComments(
      {required int page,
      required int offerId,
      int? parentId,
      required Function(List<CommentModel>, APIMetaData)
          resultCallback}) async {
    var url = NetworkConstantsUtil.offerCommentsList;
    url = '$url&reference_id=$offerId';

    if (parentId != null) {
      url = '$url&parent_id=$parentId';
    }
    url = '$url&page=$page';

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['commentLists']['items'];

        resultCallback(
            List<CommentModel>.from(items.map((x) => CommentModel.fromJson(x))),
            APIMetaData.fromJson(result.data['commentLists']['_meta']));
      }
    });
  }

  static deleteComment(
      {required int commentId, required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.deleteOfferComment;

    await ApiWrapper()
        .postApi(url: url, param: {"id": commentId.toString()}).then((value) {
      resultCallback();
    });
  }

  static reportComment(
      {required int commentId, required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.reportGenericComment;

    await ApiWrapper().postApi(url: url, param: {
      "reference_id": commentId.toString(),
      "type": '2'
    }).then((value) {
      resultCallback();
    });
  }

  static favComment(
      {required int commentId, required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.likeComment;

    await ApiWrapper().postApi(url: url, param: {
      "comment_id": commentId.toString(),
      "source_type": "3"
    }).then((value) {
      resultCallback();
    });
  }

  static unfavComment(
      {required int commentId, required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.unLikeComment;

    await ApiWrapper().postApi(url: url, param: {
      "comment_id": commentId.toString(),
      "source_type": "3"
    }).then((value) {
      resultCallback();
    });
  }

  static postComment(
      {required String comment,
      required int offerId,
      int? parentCommentId,
      required Function(int) resultCallback}) async {
    var url = NetworkConstantsUtil.addCommentOnOffer;
    await ApiWrapper().postApi(url: url, param: {
      'reference_id': offerId,
      'parent_id': parentCommentId ?? 0,
      'comment': comment
    }).then((response) {
      if (response?.success == true) {
        var id = response!.data['id'];

        resultCallback(id);
      }
    });
  }
}
