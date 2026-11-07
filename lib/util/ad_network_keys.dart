import 'dart:io';
import 'package:get/get.dart';
import '../screens/settings_menu/settings_controller.dart';

class FacebookAudienceNetworkKeys {
  SettingsController settingsController = Get.find();
   String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return settingsController.setting.value!.fbInterstitialAdUnitIdForAndroid!;
    } else if (Platform.isIOS) {
      return settingsController.setting.value!.fbInterstitialAdUnitIdForiOS!;
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  String get rewardInterstitialAdUnitId {
    if (Platform.isAndroid) {
      return  settingsController.setting.value!.fbRewardInterstitialAdUnitIdForAndroid!;
    } else if (Platform.isIOS) {
      return settingsController.setting.value!.fbRewardInterstitialAdUnitIdForiOS!;
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }
}

class AdmobKeys {
  SettingsController settingsController = Get.find();
  String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return settingsController.setting.value!.interstitialAdUnitIdForAndroid!;
    } else if (Platform.isIOS) {
      return  settingsController.setting.value!.interstitialAdUnitIdForiOS!;
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  String get rewardInterstitialAdUnitId {
    if (Platform.isAndroid) {
      return settingsController.setting.value!.rewardInterstitlAdUnitIdForAndroid!;
    } else if (Platform.isIOS) {
      return settingsController.setting.value!.rewardInterstitialAdUnitIdForiOS!;
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  /// Interstitial unit id, empty (not a crash) when the admin has not set one.
  String get interstitialAdUnitIdSafe {
    if (Platform.isAndroid) {
      return settingsController.setting.value?.interstitialAdUnitIdForAndroid ?? '';
    } else if (Platform.isIOS) {
      return settingsController.setting.value?.interstitialAdUnitIdForiOS ?? '';
    }
    return '';
  }

  /// Native ad unit for the home feed; empty when the admin has not set one.
  String get nativeAdUnitId {
    if (Platform.isAndroid) {
      return settingsController.setting.value?.nativeAdUnitIdForAndroid ?? '';
    } else if (Platform.isIOS) {
      return settingsController.setting.value?.nativeAdUnitIdForiOS ?? '';
    }
    return '';
  }

  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return settingsController.setting.value!.bannerAdUnitIdForAndroid!;
    } else if (Platform.isIOS) {
      return settingsController.setting.value!.bannerAdUnitIdForiOS!;
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }
}
