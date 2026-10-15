import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/setting_imports.dart';
import 'package:foap/screens/post/saved_posts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/misc/gift_controller.dart';
import 'received_gifts.dart';
import 'creator_tools/creator_tools.dart';
import 'help_screen.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

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
    return Obx(() => AppScaffold(
          backgroundColor: AppColorConstants.backgroundColor,
          body: Column(
            children: [
              if (_settingsController.appearanceChanged!.value)
                Container(),
              backNavigationBar(title: settingsString.tr),
              Expanded(
                child: Container(
                  color:
                      AppColorConstants.themeColor.withValues(alpha: 0.05),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      Column(
                        children: [
                          addTileEvent(notificationsString.tr, () {
                            Get.to(() => const NotificationsScreen());
                          }, true),
                          addTileEvent(changeLanguageString.tr, () {
                            Get.to(() => const ChangeLanguage());
                          }, true),
                          addTileEvent(paymentAndCoinsString.tr, () {
                            Get.to(() => const PaymentAndCoins());
                          }, true),
                          addTileEvent(giftsReceivedString.tr, () {
                            final GiftController giftController = Get.find();
                            giftController.fetchReceivedGifts();
                            Get.to(() =>  ReceivedGiftsList());
                          }, true),
                          addTileEvent(creatorToolsString.tr, () {
                            Get.to(() => const CreatorTools());
                          }, true),
                          addTileEvent(accountString.tr, () {
                            Get.to(() => const AppAccount());
                          }, true),
                          addTileEvent(savedPostsString.tr, () {
                            Get.to(() => const SavedPosts());
                          }, true),
                          addTileEvent(privacyString.tr, () {
                            Get.to(() => const PrivacyOptions());
                          }, true),
                          addTileEvent(notificationSettingsString.tr, () {
                            Get.to(() => const AppNotificationSettings());
                          }, true),
                          addTileEvent(faqString.tr, () {
                            Get.to(() => const FaqList());
                          }, true),
                          addTileEvent(helpString.tr, () {
                            Get.to(() => const HelpScreen());
                          }, true),
                          if (_settingsController
                              .setting.value!.enableDarkLightModeSwitch)
                            darkModeTile(),
                          if (_settingsController
                                      .setting.value!.iosAppLink !=
                                  null ||
                              _settingsController
                                      .setting.value!.androidAppLink !=
                                  null)
                            addTileEvent(shareString.tr, () {
                              Share.share(
                                  '${installThisCoolAppString.tr}\n${_settingsController.setting.value!.iosAppLink ?? ''}\n ${_settingsController.setting.value!.androidAppLink ?? ''}');
                            }, false),
                          addTileEvent(logoutString.tr, () {
                            AppUtil.showNewConfirmationAlert(
                                title: logoutString.tr,
                                subTitle: logoutConfirmationString.tr,
                                cancelHandler: () {
                                  Get.back();
                                },
                                okHandler: () {
                                  _userProfileManager.logout();
                                });
                          }, false),
                          addTileEvent(deleteAccountString.tr, () {
                            AppUtil.showNewConfirmationAlert(
                                title: deleteAccountString.tr,
                                subTitle:
                                    areYouSureToDeleteAccountString.tr,
                                cancelHandler: () {
                                  Get.back();
                                },
                                okHandler: () {
                                  _settingsController.deleteAccount();
                                });
                          }, false),
                          addTileEvent(createdByString.tr, () async {
                            await launchUrl(Uri.parse(
                                'https://instagram.com/singhcoders/'));
                          }, true),
                        ],
                      ),
                      const SizedBox(
                        height: 50,
                      )
                    ],
                  ),
                ).round(20).p(DesignConstants.horizontalPadding),
              ),
            ],
          ),
        ));
  }

  addTileEvent(String title, VoidCallback action, bool showNextArrow) {
    return InkWell(
        onTap: action,
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BodyLargeText(title.tr).bP4,
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
              ]).hp(DesignConstants.horizontalPadding),
            ),
            divider()
          ],
        ));
  }

  darkModeTile() {
    return Column(
      children: [
        SizedBox(
          height: 50,
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [BodyLargeText(darkModeString.tr)],
              ),
            ),
            // const Spacer(),
            Obx(() => WKToggleSwitch1(
                  inactiveColor: AppColorConstants.disabledColor,
                  activeColor: AppColorConstants.themeColor,
                  width: 50.0,
                  height: 30.0,
                  // valueFontSize: 15.0,
                  // toggleSize: 20.0,
                  initialValue: _settingsController.darkMode.value,
                  // borderRadius: 30.0,
                  // padding: 8.0,
                  // showOnOff: true,
                  onChanged: (val) {
                    _settingsController.appearanceModeChanged(val);
                  },
                )),
          ]).hp(DesignConstants.horizontalPadding),
        ),
        divider()
      ],
    );
  }
}
