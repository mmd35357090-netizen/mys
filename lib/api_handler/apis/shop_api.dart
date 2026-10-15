import 'package:foap/model/shop_model/ad_model.dart';
import 'package:foap/model/shop_model/advertisement.dart';
import 'package:foap/model/shop_model/category.dart';
import '../../helper/imports/common_import.dart';
import '../../model/api_meta_data.dart';
import '../../model/shop_model/search_model.dart';
import '../api_wrapper.dart';

class ShopApi {
  static submitAdPost(
      {required AdModel ad, required Function(int) successCallback}) async {
    if (ad.id != null) {
      //update post
      var url = '${NetworkConstantsUtil.updateAd}${ad.id}';
      Loader.show();
      await ApiWrapper().putApi(url: url, param: ad.toJson()).then((response) {
        Loader.dismiss();
        if (response?.success == true) {
          successCallback(ad.id!);
          Future.delayed(const Duration(milliseconds: 500), () {
            AppUtil.showToast(
                message: listingUpdatedSuccessfully.tr, isSuccess: true);
          });
        }
      });
    } else {
      var url = NetworkConstantsUtil.postAd;
      Loader.show();
      await ApiWrapper().postApi(url: url, param: ad.toJson()).then((response) {
        Loader.dismiss();
        if (response?.success == true) {
          successCallback(response!.data['ad_id']);
          Future.delayed(const Duration(milliseconds: 500), () {
            AppUtil.showToast(
                message: listingCreatedSuccessfully.tr, isSuccess: true);
          });
        }
      });
    }
  }

  static searchShopAds(
      {required int page,
      required SearchModel model,
      required Function(List<AdModel>, APIMetaData) resultCallback}) async {
    var url = NetworkConstantsUtil.searchAds;
    url = '$url&page=$page';
    await ApiWrapper().postApi(url: url, param: model.toJson()).then((result) {
      if (result?.success == true) {
        var items = result!.data['ad']['items'];

        resultCallback(
            List<AdModel>.from(items.map((x) => AdModel.fromJson(x))),
            APIMetaData.fromJson(result.data['ad']['_meta']));
      }
    });
  }

  static searchShopMyAds(
      {required int page,
      required int? status,
      required Function(List<AdModel>, APIMetaData) resultCallback}) async {
    var url = NetworkConstantsUtil.myAds;
    if (status != null) {
      url = '$url&status=$status';
    }
    url = '$url&page=$page';
    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['ad']['items'];

        resultCallback(
            List<AdModel>.from(items.map((x) => AdModel.fromJson(x))),
            APIMetaData.fromJson(result.data['ad']['_meta']));
      }
    });
  }

  static getAdvertisements(
      {required int page,
      required Function(List<Advertisement>, APIMetaData)
          resultCallback}) async {
    var url = NetworkConstantsUtil.promotionalAds;
    url = '$url?page=$page';

    await ApiWrapper().getApi(url: url).then((result) {
      // Loader.dismiss();
      if (result?.success == true) {
        var items = result!.data['ad']['items'];
        resultCallback(
            List<Advertisement>.from(
                items.map((x) => Advertisement.fromJson(x))),
            APIMetaData.fromJson(result.data['ad']['_meta']));
      }
    });
  }

  static getShopFavAds(
      {required int page,
      required Function(List<AdModel>, APIMetaData) resultCallback}) async {
    var url = NetworkConstantsUtil.shopFavAds;
    url = '$url&page=$page';

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['ad']['items'];
        resultCallback(
            List<AdModel>.from(items.map((x) => AdModel.fromJson(x))),
            APIMetaData.fromJson(result.data['ad']['_meta']));
      }
    });
  }

  static getShopCategories(
      {required int page,
      required Function(List<ShopCategoryModel>, APIMetaData)
          resultCallback}) async {
    var url = NetworkConstantsUtil.getShopCategories;
    url = '$url&page=$page';

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['category']['items'];
        resultCallback(
            List<ShopCategoryModel>.from(
                items.map((x) => ShopCategoryModel.fromJson(x))),
            APIMetaData.fromJson(result.data['category']['_meta']));
      }
    });
  }

  static favAdPost({
    required int adId,
  }) async {
    var url = NetworkConstantsUtil.shopProductAddTofav;

    await ApiWrapper().postApi(url: url, param: {
      "ad_id": adId,
    }).then((response) {
      if (response?.success == true) {}
    });
  }

  static unFavAdPost({
    required int adId,
  }) async {
    var url = NetworkConstantsUtil.shopProductRemoveFromfav;

    await ApiWrapper().postApi(url: url, param: {
      "ad_id": adId,
    }).then((response) {
      if (response?.success == true) {}
    });
  }

  static updateAdStatus(
      {required int adId,
      required int status,
      required VoidCallback successCallback}) async {
    var url = NetworkConstantsUtil.updateAdStatus;
    dynamic param = {'adId': adId.toString(), 'status': status.toString()};

    await ApiWrapper().postApi(url: url, param: param).then((response) {
      if (response?.success == true) {
        successCallback();
      }
    });
  }
}
