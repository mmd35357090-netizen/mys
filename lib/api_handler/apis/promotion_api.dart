import 'package:foap/helper/imports/models.dart';
import '../../controllers/post/promotion_controller.dart';
import '../../helper/imports/common_import.dart';
import '../../model/audience_model.dart';
import '../../model/post_promotion_model.dart';
import '../../model/promotion_report_model.dart';
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
        List<PostModel> posts = PostModel.parseList(data);
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
      final bool ok = response?.success == true;
      if (!ok) {
        // show the real reason from the server, so a failed order is not a mystery
        final String reason = (response?.message ?? '').trim();
        AppUtil.showToast(
            message: reason.isEmpty ? 'The promotion could not be created.' : reason,
            isSuccess: false);
      }
      completionHandler(ok);
    });
  }

  /// Limits, tax and currency decided by the server.
  static getPricing(
      {required Function(PromotionPricing) pricingCallback}) async {
    await ApiWrapper()
        .getApi(url: NetworkConstantsUtil.promotionPricing)
        .then((response) async {
      if (response?.success == true && response!.data['pricing'] != null) {
        pricingCallback(PromotionPricing.fromJson(response.data['pricing']));
      }
    });
  }

  /// The real price for a budget plus an estimate of how many people it can reach.
  static getEstimate(
      {required double dailyBudget,
      required int duration,
      int? audienceId,
      required Function(PromotionEstimate) estimateCallback}) async {
    String url =
        '${NetworkConstantsUtil.promotionEstimate}?amount=${dailyBudget.round()}&duration=$duration';
    if (audienceId != null) {
      url = '$url&audience_id=$audienceId';
    }
    await ApiWrapper().getApi(url: url).then((response) async {
      if (response?.success == true && response!.data['estimate'] != null) {
        estimateCallback(PromotionEstimate.fromJson(response.data['estimate']));
      }
    });
  }

  /// type: 'ACTIVE' or 'COMPLETED'
  static getCampaigns(
      {required String type,
      required int page,
      required Function(List<PromotionCampaign>, APIMetaData)
          campaignsCallback}) async {
    String url =
        '${NetworkConstantsUtil.promotionCampaigns}?type=$type&page=$page';
    await ApiWrapper().getApi(url: url).then((response) async {
      if (response?.success == true && response!.data['campaigns'] != null) {
        List data = response.data['campaigns']['items'] ?? [];
        List<PromotionCampaign> campaigns =
            data.map((e) => PromotionCampaign.fromJson(e)).toList();
        campaignsCallback(campaigns,
            APIMetaData.fromJson(response.data['campaigns']['_meta']));
      }
    });
  }

  static getReport(
      {required int promotionId,
      required Function(PromotionCampaign) reportCallback}) async {
    String url = '${NetworkConstantsUtil.promotionReport}?id=$promotionId';
    await ApiWrapper().getApi(url: url).then((response) async {
      if (response?.success == true && response!.data['report'] != null) {
        reportCallback(PromotionCampaign.fromJson(response.data['report']));
      }
    });
  }

  /// Records what a person did with a promoted post. event: click, profile_visit, message, website.
  /// Tracking must never disturb the app, so errors are ignored.
  static trackEvent({required int promotionId, required String event}) {
    try {
      ApiWrapper()
          .postApi(url: NetworkConstantsUtil.promotionTrack, param: {
            'post_promotion_id': promotionId.toString(),
            'event': event,
          })
          .then((_) {})
          .catchError((_) {});
    } catch (_) {}
  }

  /// status: 3 = pause, 10 = resume
  static updateStatus(
      {required int promotionId,
      required int status,
      required Function(bool, String?) completionHandler}) async {
    await ApiWrapper().postApi(
        url: NetworkConstantsUtil.promotionUpdateStatus,
        param: {
          'id': promotionId.toString(),
          'status': status.toString(),
        }).then((response) {
      completionHandler(response?.success == true, response?.message);
    });
  }

  static cancelPromotion(
      {required int promotionId,
      required Function(bool, String?) completionHandler}) async {
    await ApiWrapper().postApi(
        url: NetworkConstantsUtil.promotionCancel,
        param: {'id': promotionId.toString()}).then((response) {
      completionHandler(response?.success == true, response?.message);
    });
  }
}
