import 'package:foap/helper/imports/models.dart';
import '../../controllers/post/promotion_controller.dart';
import '../../helper/imports/common_import.dart';
import '../../model/audience_model.dart';
import '../../model/post_promotion_model.dart';
import '../../model/regional_location_model.dart';
import '../api_wrapper.dart';

class PromotionApi {
  static getSearchedLocation(
      {required String location,
      required Function(List<RegionalLocationModel>) locationsCallback}) async {
    var url = NetworkConstantsUtil.searchLocation + location;

    await ApiWrapper().getApi(url: url).then((response) async {
      if (response?.success == true) {
        List data = response!.data!['regional_location'];
        List<RegionalLocationModel> locations =
            List<RegionalLocationModel>.from(
                data.map((x) => RegionalLocationModel.fromJson(x)));
        locationsCallback(locations);
      }
    });
  }

  static getInterests(
      {required Function(List<InterestModel>) interestsCallback}) async {
    var url = NetworkConstantsUtil.interests;

    await ApiWrapper().getApi(url: url).then((response) async {
      if (response?.success == true) {
        List data = response!.data!['interest'];
        List<InterestModel> interests = List<InterestModel>.from(
            data.map((x) => InterestModel.fromJson(x)));
        interestsCallback(interests);
      }
    });
  }

  static getAudienceApi(
      {required Function(List<AudienceModel>) audienceCallback}) async {
    var url = NetworkConstantsUtil.getAudiences;
    await ApiWrapper().getApi(url: url).then((response) async {
      if (response?.success == true) {
        List data = response!.data!['audience'];
        List<AudienceModel> audienceList = List<AudienceModel>.from(
            data.map((x) => AudienceModel.fromJson(x)));
        audienceCallback(audienceList);
      }
    });
  }

  static getPromotionsApi(
      {required int page,
      required Function(List<PostModel>, APIMetaData) postsCallback}) async {
    var url = '${NetworkConstantsUtil.getPromotedPosts}&page=$page';

    await ApiWrapper().getApi(url: url).then((response) async {
      if (response?.success == true) {
        List data = response!.data!['postPromotionList']['items'];
        List<PostModel> posts =
            List<PostModel>.from(data.map((x) => PostModel.fromJson(x)));
        postsCallback(posts,
            APIMetaData.fromJson(response.data!['postPromotionList']['_meta']));
      }
    });
  }

  static submitAudience(
      {int? audienceId, required VoidCallback resultCallback}) async {
    var url = (audienceId != null
        ? '${NetworkConstantsUtil.createAudiences}/$audienceId'
        : NetworkConstantsUtil.createAudiences);

    final PromotionController promotionController = Get.find();
    int gender = promotionController.selectedGender.value == maleString.tr
        ? 1
        : promotionController.selectedGender.value == femaleString.tr
            ? 2
            : 3;

    String interests = promotionController.searchedInterests
        .expand((element) => [if (element.isSelected == true) element.id])
        .toList()
        .join(', ');

    String countryId = promotionController.selectedLocations
        .expand((element) => [if (element.type == 'country') element.id])
        .toList()
        .join(', ');

    String stateId = promotionController.selectedLocations
        .expand((element) => [if (element.type == 'state') element.id])
        .toList()
        .join(', ');

    String cityId = promotionController.selectedLocations
        .expand((element) => [if (element.type == 'city') element.id])
        .toList()
        .join(', ');

    var param = {
      "name": promotionController.audienceName.text,
      "gender": gender.toString(), //gender : 1=male, 2=female, 3=others
      "age_start_range":
          promotionController.ageRange.value.start.toInt().toString(),
      "age_end_range":
          promotionController.ageRange.value.end.toInt().toString(),
      "profile_category_type": "",
      "interest": interests,
      "location_type":
          promotionController.selectedLocations.isNotEmpty ? "1" : "2",
      "latitude": promotionController.selectedLocations.isNotEmpty
          ? ""
          : promotionController.latitude.value.toString(),
      "longitude": promotionController.selectedLocations.isNotEmpty
          ? ""
          : promotionController.longitude.value.toString(),
      "radius": promotionController.selectedLocations.isNotEmpty
          ? ""
          : promotionController.radius.value.toInt().toString(),
      "country_id": countryId,
      "state_id": stateId,
      "city_id": cityId,
    };

    if (audienceId != null) {
      ApiWrapper().putApi(url: url, param: param).then((response) {
        resultCallback();
      });
    } else {
      ApiWrapper().postApi(url: url, param: param).then((response) {
        resultCallback();
      });
    }
  }

  static createPromotion(
      {required PostPromotionOrderRequest order,
      required Function(bool) completionHandler}) async {
    var url = NetworkConstantsUtil.createPromotions;

    dynamic param = order.toJson();

    ApiWrapper().postApi(url: url, param: param).then((response) {
      completionHandler(response?.success == true);
    });
  }
}
