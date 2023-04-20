import 'package:flutter_switch/flutter_switch.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/setting_imports.dart';
import 'package:share_plus/share_plus.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final SettingsController _settingsController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  @override
  void initState() {
    super.initState();
    _settingsController.loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: AppColorConstants.backgroundColor,
          body: Column(
            children: [
              if (_settingsController.appearanceChanged!.value) Container(),
              const SizedBox(
                height: 50,
              ),
              titleNavigationBar(
                  context: context, title: LocalizationString.settings),
              divider(context: context).tP8,
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Column(
                      children: [
                        addTileEvent('assets/language.png',
                            LocalizationString.changeLanguage, '', () {
                          Get.to(() => const ChangeLanguage());
                        }, true),
                        addTileEvent('assets/coins.png',
                            LocalizationString.paymentAndCoins, '', () {
                          Get.to(() => const PaymentAndCoins());
                        }, true),
                        addTileEvent('assets/account.png',
                            LocalizationString.account, '', () {
                          Get.to(() => const AppAccount());
                        }, true),
                        addTileEvent('assets/privacy.png',
                            LocalizationString.privacy, '', () {
                          Get.to(() => const PrivacyOptions());
                        }, true),
                        addTileEvent(
                            'assets/settings.png',
                            LocalizationString.notificationSettings,
                            LocalizationString.tuneSettings, () {
                          Get.to(() => const AppNotificationSettings());
                        }, true),
                        addTileEvent('assets/faq.png', LocalizationString.faq,
                            LocalizationString.faqMessage, () {
                          Get.to(() => const FaqList());
                        }, true),
                        if (_settingsController
                            .setting.value!.enableDarkLightModeSwitch)
                          darkModeTile(),
                        addTileEvent(
                            'assets/share.png',
                            LocalizationString.share,
                            LocalizationString.shareAppSubtitle, () {
                          Share.share(
                              '${LocalizationString.installThisCoolApp} ${AppConfigConstants.liveAppLink}');
                        }, false),
                        addTileEvent(
                            'assets/logout.png',
                            LocalizationString.logout,
                            LocalizationString.exitApp, () {
                          AppUtil.showConfirmationAlert(
                              title: LocalizationString.logout,
                              subTitle: LocalizationString.logoutConfirmation,
                              okHandler: () {
                                _userProfileManager.logout();
                              });
                        }, false),
                        addTileEvent(
                            'assets/delete_account.png',
                            LocalizationString.deleteAccount,
                            LocalizationString.deleteAccountSubheading, () {
                          AppUtil.showConfirmationAlert(
                              title: LocalizationString.deleteAccount,
                              subTitle:
                                  LocalizationString.areYouSureToDeleteAccount,
                              okHandler: () {
                                _settingsController.deleteAccount();
                              });
                        }, false),
                      ],
                    ),
                    const SizedBox(
                      height: 50,
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  addTileEvent(String icon, String title, String subTitle, VoidCallback action,
      bool showNextArrow) {
    return InkWell(
        onTap: action,
        child: Column(
          children: [
            SizedBox(
              height: 65,
              child: Row(children: [
                Container(
                        color: AppColorConstants.themeColor.withOpacity(0.2),
                        child: Image.asset(
                          icon,
                          height: 20,
                          width: 20,
                          color: AppColorConstants.themeColor,
                        ).p8)
                    .circular,
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BodyLargeText(title.tr, weight: TextWeight.medium).bP4,
                    ],
                  ),
                ),
                // const Spacer(),
                if (showNextArrow)
                  ThemeIconWidget(
                    ThemeIcon.nextArrow,
                    color: AppColorConstants.iconColor,
                    size: 15,
                  )
              ]).hP16,
            ),
            divider(context: context)
          ],
        ));
  }

  darkModeTile() {
    return Column(
      children: [
        SizedBox(
          height: 65,
          child: Row(children: [
            Container(
                    color: AppColorConstants.themeColor.withOpacity(0.2),
                    child: Image.asset(
                      'assets/dark-mode.png',
                      height: 20,
                      width: 20,
                      color: AppColorConstants.themeColor,
                    ).p8)
                .circular,
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BodyLargeText(LocalizationString.darkMode.tr,
                      weight: TextWeight.medium)
                ],
              ),
            ),
            // const Spacer(),
            Obx(() => FlutterSwitch(
                  inactiveColor: AppColorConstants.disabledColor,
                  activeColor: AppColorConstants.themeColor,
                  width: 50.0,
                  height: 30.0,
                  valueFontSize: 15.0,
                  toggleSize: 20.0,
                  value: _settingsController.darkMode.value,
                  borderRadius: 30.0,
                  padding: 8.0,
                  // showOnOff: true,
                  onToggle: (val) {
                    _settingsController.appearanceModeChanged(val);
                  },
                )),
          ]).hP16,
        ),
        divider(context: context)
      ],
    );
  }
}
