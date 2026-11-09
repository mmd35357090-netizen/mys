import 'dart:async';
import 'package:foap/screens/checkout/checkout.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_map;
import '../../api_handler/apis/promotion_api.dart';
import '../../helper/imports/common_import.dart';
import '../../model/audience_model.dart';
import '../../model/post_model.dart';
import '../../model/post_promotion_model.dart';
import '../../model/promotion_report_model.dart';
import '../../model/regional_location_model.dart';
import '../../screens/add_on/controller/event/checkout_controller.dart';
import '../misc/map_screen_controller.dart';

class PromotionController extends GetxController {
  final MapScreenController _mapScreenController = MapScreenController();

  PageController pageController = PageController();
  List<String> pageName = [goal.tr, audience.tr, budgetDuration.tr, review.tr];

  RxInt pageChanged = 0.obs;

  // Rx<PostModel?> promotingPost = Rx<PostModel?>(null);
  // Rx<GoalType?> goalType = Rx<GoalType?>(null);
  TextEditingController websiteUrl = TextEditingController();
  // own text of the website button (empty = the chosen preset)
  TextEditingController websiteButtonText = TextEditingController();
  // phone number for the WhatsApp and Call goals (with the country code)
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController phoneButtonText = TextEditingController();
  Rx<bool?> isValidWebsite = Rx<bool?>(null);

  PostPromotionOrderRequest order = PostPromotionOrderRequest();

  // Limits, tax and currency from the server, and the estimate for the chosen budget
  Rx<PromotionPricing?> pricing = Rx<PromotionPricing?>(null);
  Rx<PromotionEstimate?> estimate = Rx<PromotionEstimate?>(null);
  Timer? _estimateTimer;

  String get currency => pricing.value?.currencySymbol ?? '\$';
  int get minDailyBudget => pricing.value?.minDailyBudget ?? 1;
  int get maxDailyBudget => pricing.value?.maxDailyBudget ?? 1000;
  int get minDuration => pricing.value?.minDuration ?? 2;
  int get maxDuration => pricing.value?.maxDuration ?? 30;
  List<String> actionButtons = [
    learnMore.tr,
    showNow.tr,
    watchMore.tr,
    contactUs.tr,
    bookNow.tr,
    signUpString.tr
  ];
  RxInt actionSelected = 0.obs;

  RxList<AudienceModel> audiences = <AudienceModel>[].obs;

  // RxInt audienceSelected = 0.obs;
  RxString audienceSelectedInfo = ''.obs;

  TextEditingController audienceName = TextEditingController();
  List<String> locationType = [regional.tr, local.tr];

  Rx<bool> isLocationEnabled = Rx<bool>(false);
  RxList<RegionalLocationModel> regionalLocations =
      <RegionalLocationModel>[].obs;
  RxList<RegionalLocationModel> selectedLocations =
      <RegionalLocationModel>[].obs;
  RxString selectedLocationNames = ''.obs;

  late final google_map.GoogleMapController mapController;
  Rx<double?> latitude = Rx<double?>(null);
  Rx<double?> longitude = Rx<double?>(null);
  Rx<double> radius = Rx<double>(9);

  RxList<InterestModel> interests = <InterestModel>[].obs;
  RxList<InterestModel> searchedInterests = <InterestModel>[].obs;
  RxString selectedNames = ''.obs;

  Rx<RangeValues> ageRange = Rx<RangeValues>(const RangeValues(16, 50));
  List<String> genderType = [maleString.tr, femaleString.tr, otherString.tr];
  Rx<String?> selectedGender = Rx<String?>(null);

  clear() {
    order = PostPromotionOrderRequest();
    order.taxPercent = pricing.value?.taxPercent ?? order.taxPercent;
    estimate.value = null;
    pageChanged.value = 0;

    websiteUrl.text = '';
    isValidWebsite.value = null;
    actionSelected.value = 0;

    // audienceSelected.value = 0;
    audienceSelectedInfo.value = '';
    audienceName.text = '';

    isLocationEnabled.value = false;
    regionalLocations.clear();
    selectedLocations.clear();
    selectedLocationNames.value = '';
    latitude = Rx<double?>(null);
    longitude = Rx<double?>(null);
    radius.value = 9;

    selectedGender = Rx<String?>(null);
    interests.clear();
    searchedInterests.clear();
    selectedNames.value = '';
    ageRange = Rx<RangeValues>(const RangeValues(16, 50));
    selectedGender = Rx<String?>(null);
    // budget.value = 100;
    // duration.value = 6;
    // gst.value = 30;
  }

  clearAudience() {
    order.audience = null;
    // audienceSelected.value = 0;
    audienceSelectedInfo.value = '';
    audienceName.text = '';

    isLocationEnabled.value = false;
    regionalLocations.clear();
    selectedLocations.clear();
    selectedLocationNames.value = '';
    latitude = Rx<double?>(null);
    longitude = Rx<double?>(null);
    radius.value = 9;

    interests.clear();
    searchedInterests.clear();
    selectedNames.value = '';
    ageRange = Rx<RangeValues>(const RangeValues(16, 50));
    selectedGender = Rx<String?>(null);
  }

  clearWebsiteData() {
    websiteUrl.text = '';
    websiteButtonText.text = '';
    phoneNumber.text = '';
    phoneButtonText.text = '';
    isValidWebsite.value = null;
    actionSelected.value = 0;
  }


  /// Readable place name for a coordinate. Never throws, never reads an empty list.
  Future<String> _placeName(double lat, double lng) async {
    try {
      List<Placemark> placeMarks = await placemarkFromCoordinates(lat, lng);
      if (placeMarks.isEmpty) return '';
      Placemark first = placeMarks.first;
      return '${first.name ?? ''}, ${first.country ?? ''}';
    } catch (_) {
      return '';
    }
  }

  setPromotingPost(PostModel post) {
    // promotingPost.value = post;
    order.post = post;
    update();
    loadPricing();
  }

  pageChangedEvent(int value) {
    pageChanged.value = value;
    update();
  }

  //Goal Screen Events
  selectGoalType(GoalType type) {
    // goalType.value = type;
    order.goalType = type;

    clearWebsiteData();
    update();
    refreshEstimate();
  }

  validateUrl(String value) {
    bool validURL = false;
    try {
      Uri uri = Uri.parse(value.trim());
      validURL = (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.host.contains('.');
    } catch (_) {
      validURL = false;
    }
    isValidWebsite.value = validURL;
    order.goalType = validURL ? GoalType.website : null;
    if (validURL) {
      order.url = value.trim();
      order.urlText ??= actionButtons[actionSelected.value];
    } else {
      order.url = null;
    }
    update();
  }

  /// Called by the Done button on the website screen.
  /// Returns true when the link is valid and the goal is saved.
  bool confirmWebsiteGoal() {
    validateUrl(websiteUrl.text);
    if (isValidWebsite.value != true) return false;
    order.goalType = GoalType.website;
    order.url = websiteUrl.text.trim();
    final String own = websiteButtonText.text.trim();
    order.urlText = own.isNotEmpty ? own : actionButtons[actionSelected.value];
    update();
    refreshEstimate();
    return true;
  }

  /// Digits of the phone number, with the country code. Empty when it is not a valid number.
  String phoneDigits() {
    final String digits = phoneNumber.text.replaceAll(RegExp(r'[^0-9]'), '');
    return (digits.length >= 7 && digits.length <= 15) ? digits : '';
  }

  /// Done button of the WhatsApp / Call screen. Returns true when the number is valid.
  bool confirmPhoneGoal(GoalType type) {
    final String digits = phoneDigits();
    if (digits.isEmpty) return false;
    order.goalType = type;
    order.url = digits;
    final String own = phoneButtonText.text.trim();
    order.urlText = own.isNotEmpty
        ? own
        : (type == GoalType.whatsapp ? 'WhatsApp us' : 'Call now');
    update();
    refreshEstimate();
    return true;
  }

  selectAction(int selection) {
    actionSelected.value = selection;
    order.urlText = actionButtons[selection];

    update();
  }

  //Audience Screen Events
  selectAudience(AudienceModel? audience) async {
    if (audience != null) {
      // AudienceModel model = audiences[selection - 1];
      String genderAge =
          '${audience.gender}, ages ${audience.ageStartRange}-${audience.ageEndRange}';

      String location = '';
      if (audience.locationType == 1) {
        location = audience.regions
            .expand((element) => [element.fullName])
            .toList()
            .join(', ');
      } else {
        location = await _placeName(double.tryParse(audience.latitude) ?? 0.0,
            double.tryParse(audience.longitude) ?? 0.0);
      }
      location = location.isEmpty ? '' : ', $location';

      String interest = audience.interests
          .expand((element) => [element.name])
          .toList()
          .join(', ');
      interest = interest.isEmpty ? '' : ', $interest';

      audienceSelectedInfo.value = genderAge + location + interest;
    }
    // audienceSelected.value = selection;
    order.audience = audience;
    update();
    refreshEstimate();
  }

  setCurrentLocation(bool selection, VoidCallback action) {
    if (selection) {
      _mapScreenController.getLocation((location) async {
        latitude.value = location.latitude;
        longitude.value = location.longitude;
        isLocationEnabled.value = true;

        selectedLocationNames.value =
            await _placeName(latitude.value ?? 0.0, longitude.value ?? 0.0);

        update();
        action();
      });
    } else {
      isLocationEnabled.value = false;
      update();
    }
  }

  setRadiusRange(double radiusVal) {
    radius.value = radiusVal;
    update();
  }

  selectLocations(RegionalLocationModel model) {
    int index =
        selectedLocations.indexWhere((element) => element.id == model.id);
    index == -1
        ? selectedLocations.add(model)
        : selectedLocations.removeAt(index);
    selectedLocationNames.value = selectedLocations
        .expand((element) => [element.fullName])
        .toList()
        .join(' | ');
    update();
  }

  searchInterests(String value) {
    searchedInterests.value = interests
        .where((item) => item.name.toLowerCase().contains(value.toLowerCase()))
        .toList();
    update();
  }

  selectInterests(InterestModel model) {
    model.isSelected = !model.isSelected;
    selectedNames.value = searchedInterests
        .expand((element) => [if (element.isSelected == true) element.name])
        .toList()
        .join(', ');
    update();
  }

  editAudienceSetup(AudienceModel model) async {
    audienceName.text = model.name;
    isLocationEnabled.value = model.locationType == 2;

    if (model.locationType == 1) {
      selectedLocations.value = model.regions;
      selectedLocationNames.value = selectedLocations
          .expand((element) => [element.fullName])
          .toList()
          .join(' | ');
    } else {
      latitude.value = double.parse(model.latitude);
      longitude.value = double.parse(model.longitude);
      selectedLocationNames.value =
          await _placeName(latitude.value ?? 0.0, longitude.value ?? 0.0);

      radius.value = model.radius.toDouble();
    }

    selectedNames.value =
        model.interests.expand((element) => [element.name]).toList().join(', ');
    ageRange = Rx<RangeValues>(RangeValues(
        model.ageStartRange.toDouble(), model.ageEndRange.toDouble()));
    selectedGender.value = model.gender;
  }

  selectAgeRange(RangeValues rangeValues) {
    ageRange.value = rangeValues;
    update();
  }

  selectGender(String gender) {
    selectedGender.value = gender;
    update();
  }

  getAgeAndGender() {
    return selectedGender.value == null
        ? ''
        : '${ageRange.value.start.toInt()} - ${ageRange.value.end.toInt()} years | ${selectedGender.value}';
  }

  setBudgetRange(double val) {
    // budget.value = val;
    order.dailyBudget = val.roundToDouble();
    update();
    refreshEstimate();
  }

  setBudgetDurationRange(int val) {
    // duration.value = val;
    order.duration = val;
    update();
    refreshEstimate();
  }

  getTotalPayment() {
    return order.grandTotalAmount;
  }

  /// Loads limits, tax and currency from the server (once per wizard start).
  loadPricing() {
    PromotionApi.getPricing(pricingCallback: (result) {
      pricing.value = result;
      order.taxPercent = result.taxPercent;
      // keep the chosen budget inside the limits the server allows
      if (order.dailyBudget > result.maxDailyBudget) {
        order.dailyBudget = result.maxDailyBudget.toDouble();
      }
      if (order.dailyBudget < result.minDailyBudget) {
        order.dailyBudget = result.minDailyBudget.toDouble();
      }
      if (order.duration < result.minDuration) {
        order.duration = result.minDuration;
      }
      if (order.duration > result.maxDuration) {
        order.duration = result.maxDuration;
      }
      update();
      refreshEstimate();
    });
  }

  /// Asks the server what this budget costs and how many people it can reach.
  /// Waits a moment, so dragging a slider does not send a request for every step.
  refreshEstimate() {
    _estimateTimer?.cancel();
    _estimateTimer = Timer(const Duration(milliseconds: 400), () {
      PromotionApi.getEstimate(
          dailyBudget: order.dailyBudget,
          duration: order.duration,
          audienceId: order.audience?.id,
          goal: goalTypeCode(order.goalType),
          estimateCallback: (result) {
            estimate.value = result;
            update();
          });
    });
  }

  previousButtonEvent() {
    pageChanged.value = pageChanged.value - 1;
    pageController.animateToPage(pageChanged.value,
        duration: const Duration(milliseconds: 250), curve: Curves.bounceInOut);
    update();
  }

  nextButtonEvent() {
    pageChanged.value = pageChanged.value + 1;
    pageController.animateToPage(pageChanged.value,
        duration: const Duration(milliseconds: 250), curve: Curves.bounceInOut);
    update();
  }

  void getInterests() async {
    PromotionApi.getInterests(interestsCallback: (locations) {
      interests.value = locations;
      searchedInterests.value = locations;
      update();
    });
  }

  searchLocations(String search) {
    if (search.isNotEmpty) {
      PromotionApi.getSearchedLocation(
          location: search,
          locationsCallback: (locations) {
            regionalLocations.value = locations;
            update();
          });
    } else {
      regionalLocations.value = [];
      update();
    }
  }

  createAudienceApi(AudienceModel? audience, VoidCallback handler) {
    if (audienceName.text.isEmpty) {
      AppUtil.showToast(message: enterAudienceName.tr, isSuccess: false);
    } else if (selectedLocations.isEmpty &&
        (latitude.value == null && longitude.value == null)) {
      AppUtil.showToast(message: locationAndTarget.tr, isSuccess: false);
    } else if (selectedNames.value == '') {
      AppUtil.showToast(message: audienceInterest.tr, isSuccess: false);
    } else if (selectedGender.value == null) {
      AppUtil.showToast(message: selectGenderAge.tr, isSuccess: false);
    } else {
      int? id = audience?.id;
      Loader.show(status: loadingString.tr);

      PromotionApi.submitAudience(
          audienceId: id,
          resultCallback: () {
            getAudienceApi();
            Loader.dismiss();

            handler();
          });
    }
  }

  getAudienceApi() {
    PromotionApi.getAudienceApi(audienceCallback: (result) {
      audiences.value = result;
      update();
    });
  }

  createPostPromotionApi() {
    final CheckoutController checkoutController = Get.find();
    final PromotionController promotionController = Get.find();

    Get.to(() => Checkout(
          amountToPay: order.grandTotalAmount,
          itemName: postPromotionString.tr,
          transactionCallbackHandler: (paymentTransactions) {
            order.payments = paymentTransactions;

            PromotionApi.createPromotion(
                order: order,
                completionHandler: (status) {
                  if (status) {
                    promotionController.clear();
                    checkoutController.orderPlaced();
                  } else {
                    checkoutController.orderFailed();
                  }
                });
          },
        ));
  }
}
