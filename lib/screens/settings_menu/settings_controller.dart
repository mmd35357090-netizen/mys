import 'package:flutter/services.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/util/constant_util.dart';
import 'package:get/get.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';
import 'package:rate_my_app/rate_my_app.dart';

import '../../apiHandler/api_controller.dart';
import '../../manager/location_manager.dart';
import '../../util/shared_prefs.dart';
import 'package:foap/helper/imports/setting_imports.dart';

import '../dashboard/loading.dart';

class SettingsController extends GetxController {
  final UserProfileManager _userProfileManager = Get.find();

  Rx<SettingModel?> setting = Rx<SettingModel?>(null);
  RxString currentLanguage = 'en'.obs;

  RxBool bioMetricAuthStatus = false.obs;
  RxBool darkMode = false.obs;
  RxBool shareLocation = false.obs;

  RxInt redeemCoins = 0.obs;
  RxBool forceUpdate = false.obs;
  RxBool? appearanceChanged = false.obs;

  var localAuth = LocalAuthentication();
  RxInt bioMetricType = 0.obs;
  RateMyApp rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    minDays: 0, // Show rate popup on first day of install.
    minLaunches:
        0, // Show rate popup after 5 launches of app after minDays is passed.
  );

  List<Map<String, String>> languagesList = [
    {'language_code': 'hi', 'language_name': 'Hindi'},
    {'language_code': 'en', 'language_name': 'English'},
    {'language_code': 'ar', 'language_name': 'Arabic'},
    {'language_code': 'tr', 'language_name': 'Turkish'},
    {'language_code': 'ru', 'language_name': 'Russian'},
    {'language_code': 'es', 'language_name': 'Spanish'},
    {'language_code': 'fr', 'language_name': 'French'},
  ];

  setCurrentSelectedLanguage() async {
    String currentLanguage = await SharedPrefs().getLanguage();
    changeLanguage({'language_code': currentLanguage});
  }

  changeLanguage(Map<String, String> language) async {
    var locale = Locale(language['language_code']!);
    Get.updateLocale(locale);
    currentLanguage.value = language['language_code']!;
    update();
    SharedPrefs().setLanguage(language['language_code']!);
  }

  redeemCoinValueChange(int coins) {
    redeemCoins.value = coins;
  }

  loadSettings() async {
    bool isDarkTheme = await SharedPrefs().isDarkMode();
    bioMetricAuthStatus.value = await SharedPrefs().getBioMetricAuthStatus();
    shareLocation.value =
        _userProfileManager.user.value!.latitude != null;

    setDarkMode(isDarkTheme);
    checkBiometric();
  }

  setDarkMode(bool status) async{
    darkMode.value = status;
    darkMode.refresh();
    isDarkMode = status;
    await SharedPrefs().setDarkMode(status);
    Get.changeThemeMode(status ? ThemeMode.dark : ThemeMode.light);
  }

  appearanceModeChanged(bool status) async {
    await setDarkMode(status);
    appearanceChanged?.value = !appearanceChanged!.value;
  }

  shareLocationToggle(bool status) {
    shareLocation.value = status;
    if (status == true) {
      getIt<LocationManager>().postLocation();
    } else {
      getIt<LocationManager>().stopPostingLocation();
    }
  }

  getSettings() async {
    String? authKey = await SharedPrefs().getAuthorizationKey();

    if (authKey != null) {
      await ApiController().getSettings().then((response) async {
        setting.value = response.settings;

        if (setting.value?.latestVersion! !=
            AppConfigConstants.currentVersion) {
          forceUpdate.value = true;
        }

        // Stripe.publishableKey = setting.value!.stripePublishableKey!;
        // Stripe.merchantIdentifier = 'merchant.com.socialified';
        // Stripe.urlScheme = 'socialifiedstripe';
        // await Stripe.instance.applySettings();

        update();
      });
    }
  }

  Future checkBiometric() async {
    bool bioMetricAuthStatus =
        true; //await SharedPrefs().getBioMetricAuthStatus();
    if (bioMetricAuthStatus == true) {
      List<BiometricType> availableBiometrics =
          await localAuth.getAvailableBiometrics();

      if (availableBiometrics.contains(BiometricType.face)) {
        // Face ID.
        bioMetricType.value = 1;
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        // Touch ID.
        bioMetricType.value = 2;
      }
    }
    return;
  }

  void biometricLogin(bool status) async {
    try {
      bool didAuthenticate = await localAuth.authenticate(
          localizedReason: status == true
              ? LocalizationString.pleaseAuthenticateToUseBiometric
              : LocalizationString.pleaseAuthenticateToRemoveBiometric);

      if (didAuthenticate == true) {
        SharedPrefs().setBioMetricAuthStatus(status);
        bioMetricAuthStatus.value = status;
      }
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
        // Handle this exception here.
      }
    }
  }

  deleteAccount() {
    ApiController().deleteAccountApi().then((response) {
      if (response.success) {
        _userProfileManager.logout();
        AppUtil.showToast(
            message: LocalizationString.accountIsDeleted, isSuccess: true);
      }
    });
  }

  askForRating(BuildContext context) {
    rateMyApp.init().then((value) {
      if (rateMyApp.shouldOpenDialog) {
        rateMyApp.showRateDialog(context);
      }
    });
  }
}
