import '../helper/color_extension.dart';
import '../helper/imports/common_import.dart';
import '../screens/settings_menu/settings_controller.dart';
import 'constant_util.dart';

final SettingsController settingsController = Get.find();

class AppConfigConstants {
  // Name of app
  static String appName = 'Connect to Friends';

  static String currentVersion = '2.5';
  static const liveAppLink = 'https://facehub.sbehf.com/';

  static String appTagline = 'Share your day activity with friends';
  static const googleMapApiKey = 'AIzaSyA4vcqErGvq5NRbvhvq8JKSp0VFpNBBPjE';
  static const restApiBaseUrl = 'https://facehub.sbehf.com/api/web/v1/';

  // Socket api url
  static const socketApiBaseUrl = "https://chat.sbehf.com/";

  // Chat encryption key -- DO NOT CHANGE THIS
  static const encryptionKey = 'bbC2H19lkVbQDfakxcrtNMQdd0FloLyw';

  // enable encryption -- DO NOT CHANGE THIS
  static const int enableEncryption = 1;

  // chat version
  static const int chatVersion = 1;

  // is demo app
  static const bool isDemoApp = false;
  static const bool askForFollow = false;

  // parameters for delete chat
  static const secondsInADay = 86400;
  static const secondsInThreeDays = 259200;
  static const secondsInSevenDays = 604800;
  static const liveBattleConfirmationWaitTime = 30;

  // Marketplace
  static int showAdvertiesmentAfter =
      2; // specifiy number of ads after which app will show advertisement
  static int showAdmobBannerAfter =
      20; // specifiy number of ads after which app will show admob banner

  static List<String> sortArray = [
    'Newest first',
    'Older first',
    'Price - Low to high',
    'Price - High to low',
    'Popular',
    'Most viewed'
  ];
}

class DesignConstants {
  static double horizontalPadding = 20;
}

class AppColorConstants {
  static Color themeColor = settingsController.setting.value == null
      ? Colors.blue
      : HexColor.fromHex(settingsController.setting.value!.themeColor!);

  static Color get backgroundColor => isDarkMode
      ? HexColor.fromHex(
          settingsController.setting.value?.bgColorForDarkTheme ??
              '202020')
      : HexColor.fromHex(
          settingsController.setting.value?.bgColorForLightTheme ??
              'FFFFFF');

  static Color get cardColor => isDarkMode
      ? HexColor.fromHex(
              settingsController.setting.value?.bgColorForDarkTheme ??
                  '202020')
          .lighten(0.05)
      : HexColor.fromHex(
              settingsController.setting.value?.bgColorForLightTheme ??
                  'FFFFFF')
          .darken(0.05);

  static Color get dividerColor => isDarkMode
      ? const Color(0xFFFFFFFF).withValues(alpha: 0.4)
      : Colors.grey.withValues(alpha: 0.7);

  static Color get borderColor => isDarkMode
      ? Colors.white.withValues(alpha: 0.9)
      : Colors.grey.withValues(alpha: 0.2);

  static Color get disabledColor => isDarkMode
      ? Colors.grey.withValues(alpha: 0.2)
      : Colors.grey.withValues(alpha: 0.2);

  static Color get shadowColor => isDarkMode
      ? Colors.white.withValues(alpha: 0.2)
      : Colors.black.withValues(alpha: 0.2);

  // static Color get inputFieldBackgroundColor =>
  //     isDarkMode ? const Color(0xFF212121) : const Color(0xFF212121);

  static Color get iconColor =>
      isDarkMode ? Colors.white : const Color(0xFF212121);

  static Color get inputFieldTextColor =>
      isDarkMode ? const Color(0xFFFAFAFA) : const Color(0xFF212121);

  static Color get inputFieldPlaceholderTextColor => isDarkMode
      ? const Color(0xFFFAFAFA).lighten()
      : const Color(0xFF212121).darken();

  static Color get red => isDarkMode ? Colors.red : Colors.red;

  static Color get green => isDarkMode ? Colors.green : Colors.green;

  // text colors

  static Color get mainTextColor => isDarkMode
      ? settingsController.setting.value == null
          ? Colors.white
          : HexColor.fromHex(
              settingsController.setting.value!.textColorForDarkTheme!)
      : settingsController.setting.value == null
          ? Colors.black
          : HexColor.fromHex(
              settingsController.setting.value!.textColorForLightTheme!);

  static Color get subHeadingTextColor => isDarkMode
      ? settingsController.setting.value == null
          ? const Color(0xFF34495e)
          : HexColor.fromHex(
                  settingsController.setting.value!.textColorForDarkTheme!)
              .withValues(alpha: 0.8)
      : settingsController.setting.value == null
          ? const Color(0xFFecf0f1)
          : HexColor.fromHex(settingsController
                  .setting.value!.textColorForLightTheme!)
              .withValues(alpha: 0.8);
}

class DatingProfileConstants {
  static List<String> genders = [
    maleString.tr,
    femaleString.tr,
    nonBinaryString.tr
  ];
  static List<String> colors = [
    blackString.tr,
    whiteString.tr,
    brownString.tr,
    fairString.tr
  ];
  static List<String> passionateAbout = [
    bodyString.tr,
    mindString.tr,
    soulString.tr,
    spiritString.tr
  ];
  static List<String> religions = [
    christianString.tr,
    muslimString.tr,
    hinduString.tr,
    buddhistString.tr,
    sikhString.tr,
    jainismString.tr,
    judaismString.tr
  ];
  static List<String> maritalStatus = [
    singleString.tr,
    marriedString.tr,
    divorcedString.tr
  ];
  static List<String> drinkHabits = [
    noString.tr,
    regularString.tr,
    planningToQuitString.tr,
    sociallyString.tr
  ];
}
