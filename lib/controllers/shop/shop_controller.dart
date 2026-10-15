import 'package:camera/camera.dart';
import 'package:foap/api_handler/apis/misc_api.dart';
import 'package:foap/api_handler/apis/shop_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/list_extension.dart';
import 'package:foap/model/data_wrapper.dart';
import 'package:foap/model/shop_model/category.dart';
import '../../model/shop_model/ad_model.dart';
import '../../model/shop_model/advertisement.dart';
import '../../model/shop_model/search_model.dart';
import '../../screens/shop_feature/post_ad/product_created_success.dart';

class ShopController extends GetxController {
  RxList<AdModel> ads = <AdModel>[].obs;
  RxList<AdModel> myAds = <AdModel>[].obs;
  RxList<AdModel> favAds = <AdModel>[].obs;
  RxList<ShopCategoryModel> categories = <ShopCategoryModel>[].obs;
  RxList<Advertisement> thirdPartyAdvertisement = <Advertisement>[].obs;
  RxList<Advertisement> usedThirdPartyAdvertisement = <Advertisement>[].obs;

  SearchModel model = SearchModel();
  SearchModel myAdsSearchModel = SearchModel();

  DataWrapper adsDataWrapper = DataWrapper();
  DataWrapper myAdsDataWrapper = DataWrapper();
  DataWrapper favAdsDataWrapper = DataWrapper();
  DataWrapper thirdPartyAdsDataWrapper = DataWrapper();
  DataWrapper categoryDataWrapper = DataWrapper();

  RxInt selectSegment = 0.obs;

  clear() {
    ads.value = [];
    myAds.value = [];
    favAds.value = [];
    categories.value = [];
    thirdPartyAdvertisement.value = [];

    adsDataWrapper = DataWrapper();
    myAdsDataWrapper = DataWrapper();
    favAdsDataWrapper = DataWrapper();
    thirdPartyAdsDataWrapper = DataWrapper();
    categoryDataWrapper = DataWrapper();

    model = SearchModel();
    myAdsSearchModel = SearchModel();
  }

  clearAds() {
    ads.value = [];
    adsDataWrapper = DataWrapper();
  }

  clearMyAds() {
    myAds.value = [];
    myAdsDataWrapper = DataWrapper();
  }

  postAd({required AdModel ad}) {
    ShopApi.submitAdPost(
        ad: ad,
        successCallback: (id) {
          refreshMyAds(() {});

          Get.to(() => ProductCreatedSuccess(
                productId: id,
              ));
          // Get.close(5);
        });
  }

  setCategoryId(int? categoryId) {
    clearAds();
    model.categoryId = categoryId;
    refreshAds(() {});
  }

  setSearchText(String? text) {
    clearAds();
    model.title = text;
    refreshAds(() {});
  }

  setStatus(int status) {
    clearAds();
    myAdsSearchModel.status = status;
    refreshAds(() {});
  }

  loadFeatureAds() {
    clearAds();
    model.isFeatured = 1;
    refreshAds(() {});
  }

  refreshAds(VoidCallback callback) {
    clearAds();
    loadAds(callback);
  }

  loadMoreAds(VoidCallback callback) async {
    if (adsDataWrapper.haveMoreData.value) {
      loadAds(callback);
    } else {
      callback();
    }
  }

  loadAds(VoidCallback callback) async {
    ShopApi.searchShopAds(
        page: adsDataWrapper.page,
        model: model,
        resultCallback: (result, metadata) {
          ads.addAll(result);
          ads.unique((e) => e.id);
          adsDataWrapper.processCompletedWithData(metadata);

          callback();
        });
  }

  refreshMyAds(VoidCallback callback) {
    loadMyAds(callback);
  }

  loadMoreMyAds(VoidCallback callback) {
    if (myAdsDataWrapper.haveMoreData.value) {
      loadMyAds(callback);
    } else {
      callback();
    }
  }

  loadMyAds(VoidCallback callback) async {
    ShopApi.searchShopMyAds(
        status: myAdsSearchModel.status,
        page: myAdsDataWrapper.page,
        resultCallback: (result, metadata) {
          myAds.addAll(result);
          myAds.unique((e) => e.id);

          myAdsDataWrapper.processCompletedWithData(metadata);

          callback();
        });
  }

  refreshFavAds(VoidCallback callback) {
    loadFavAds(callback);
  }

  loadMoreFavAds(VoidCallback callback) {
    if (favAdsDataWrapper.haveMoreData.value) {
      loadFavAds(callback);
    } else {
      callback();
    }
  }

  loadFavAds(VoidCallback callback) async {
    ShopApi.getShopFavAds(
        page: favAdsDataWrapper.page,
        resultCallback: (result, metadata) {
          favAds.addAll(result);
          favAds.unique((e) => e.id);
          favAdsDataWrapper.processCompletedWithData(metadata);
        });
  }

  loadMoreCategories(VoidCallback callback) {
    if (categoryDataWrapper.haveMoreData.value) {
      getCategories(callback);
    } else {
      callback();
    }
  }

  getCategories(VoidCallback callback) async {
    ShopApi.getShopCategories(
        page: categoryDataWrapper.page,
        resultCallback: (result, metadata) {
          categories.addAll(result);
          categories.unique((e) => e.id);
          categoryDataWrapper.processCompletedWithData(metadata);
        });
  }

  refreshThirdPartyAds(VoidCallback callback) {
    loadAdverstisements(callback);
  }

  loadMoreThirdPartyAds(VoidCallback callback) {
    if (thirdPartyAdsDataWrapper.haveMoreData.value) {
      loadAdverstisements(callback);
    } else {
      callback();
    }
  }

  loadAdverstisements(VoidCallback callback) async {
    ShopApi.getAdvertisements(
        page: thirdPartyAdsDataWrapper.page,
        resultCallback: (result, metadata) {
          thirdPartyAdvertisement.addAll(result);
          thirdPartyAdvertisement.unique((e) => e.id);
          thirdPartyAdvertisement.shuffle();
          thirdPartyAdsDataWrapper.processCompletedWithData(metadata);
        });
  }

  favUnfavAd(AdModel ad) {
    if (ad.isFavorite == 1) {
      ShopApi.favAdPost(adId: ad.id!);
    } else {
      ShopApi.unFavAdPost(adId: ad.id!);
    }
  }

  updateStatus({required AdModel ad, required int status}) {
    ShopApi.updateAdStatus(
        adId: ad.id!,
        status: status,
        successCallback: () {
          clearMyAds();
          refreshMyAds(() {});
          Future.delayed(const Duration(milliseconds: 500), () {
            AppUtil.showToast(
                message: listingUpdatedSuccessfully.tr, isSuccess: true);
          });
        });
  }

  Future uploadAdImage(
      {required XFile pickedFile,
      required Function(String) successCallback}) async {
    await MiscApi.uploadFile(pickedFile.path,
        mediaType: GalleryMediaType.photo,
        type: UploadMediaType.shop, resultCallback: (fileName, filePath) {
      successCallback(filePath);
    });
  }

  addUsersThirdPartyAds(Advertisement ad) {
    if (usedThirdPartyAdvertisement.where((e) => e.id == ad.id).isEmpty) {
      usedThirdPartyAdvertisement.add(ad);
    }
    usedThirdPartyAdvertisement.refresh();
  }

  handleSegmentChange(int index) {
    if (selectSegment.value != index) {
      clearMyAds();
      selectSegment.value = index;

      switch (index) {
        case 0:
          setStatus(10);
          break;
        case 1:
          setStatus(1);
          break;
        case 2:
          setStatus(2);
          break;
        case 3:
          setStatus(3);
          break;
        case 4:
          setStatus(4);
          break;
        case 5:
          setStatus(0);
          break;
      }
      refreshMyAds(() {});
    }
  }
}
