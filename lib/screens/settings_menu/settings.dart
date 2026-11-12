import 'package:foap/screens/profile/relations_screen.dart';
import 'package:foap/screens/post/collections_screen.dart';
import 'package:foap/util/biometric_helper.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/setting_imports.dart';
import 'package:foap/screens/post/saved_posts.dart';
import 'package:foap/screens/post/post_promotion/promotion_campaigns.dart';
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
              if (_settingsController.appearanceChanged!.value) Container(),
              backNavigationBar(title: settingsString.tr),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                      DesignConstants.horizontalPadding, 8,
                      DesignConstants.horizontalPadding, 40),
                  children: [
                    _section('', [
                      _tile(Icons.notifications_none_rounded,
                          const Color(0xFFF59E0B), notificationsString.tr, () {
                        Get.to(() => const NotificationsScreen());
                      }),
                      _tile(Icons.language_rounded, const Color(0xFF3B82F6),
                          changeLanguageString.tr, () {
                        Get.to(() => const ChangeLanguage());
                      }),
                    ]),
                    _section('Money & creator', [
                      _tile(Icons.account_balance_wallet_outlined,
                          const Color(0xFF10B981), paymentAndCoinsString.tr,
                          () {
                        Get.to(() => const PaymentAndCoins());
                      }),
                      _tile(Icons.card_giftcard_rounded,
                          const Color(0xFFEC4899), giftsReceivedString.tr, () {
                        final GiftController giftController = Get.find();
                        giftController.fetchReceivedGifts();
                        Get.to(() => ReceivedGiftsList());
                      }),
                      _tile(Icons.auto_graph_rounded, const Color(0xFF8B5CF6),
                          creatorToolsString.tr, () {
                        Get.to(() => const CreatorTools());
                      }),
                      _tile(Icons.rocket_launch_outlined,
                          const Color(0xFFEF4444), boostMyCampaigns.tr, () {
                        Get.to(() => const PromotionCampaignsScreen());
                      }),
                    ]),
                    _section('Account & privacy', [
                      _tile(Icons.person_outline_rounded,
                          const Color(0xFF6366F1), accountString.tr, () {
                        Get.to(() => const AppAccount());
                      }),
                      _tile(Icons.bookmark_border_rounded,
                          const Color(0xFF0EA5E9), savedPostsString.tr, () {
                        Get.to(() => const SavedPosts());
                      }),
                      _tile(Icons.people_outline_rounded,
                          const Color(0xFFF59E0B), relationsString.tr, () {
                        Get.to(() => const RelationsScreen());
                      }),
                      _tile(Icons.folder_copy_outlined,
                          const Color(0xFF8B5CF6), collectionsString.tr, () {
                        Get.to(() => const CollectionsScreen());
                      }),
                      _tile(Icons.lock_outline_rounded,
                          const Color(0xFF14B8A6), privacyString.tr, () {
                        Get.to(() => const PrivacyOptions());
                      }),
                      _tile(Icons.tune_rounded, const Color(0xFFF97316),
                          notificationSettingsString.tr, () {
                        Get.to(() => const AppNotificationSettings());
                      }),
                    ]),
                    _section('Support', [
                      _tile(Icons.quiz_outlined, const Color(0xFF64748B),
                          faqString.tr, () {
                        Get.to(() => const FaqList());
                      }),
                      _tile(Icons.support_agent_rounded,
                          const Color(0xFF22C55E), helpString.tr, () {
                        Get.to(() => const HelpScreen());
                      }),
                      if (_settingsController.setting.value!.iosAppLink !=
                              null ||
                          _settingsController.setting.value!.androidAppLink !=
                              null)
                        _tile(Icons.ios_share_rounded, const Color(0xFF3B82F6),
                            shareString.tr, () {
                          Share.share(
                              '${installThisCoolAppString.tr}\n${_settingsController.setting.value!.iosAppLink ?? ''}\n ${_settingsController.setting.value!.androidAppLink ?? ''}');
                        }),
                    ]),
                    if (_settingsController
                        .setting.value!.enableDarkLightModeSwitch)
                      _section('', [darkModeTile()]),
                    _section('', [
                      _tile(Icons.logout_rounded, const Color(0xFFEF4444),
                          logoutString.tr, () {
                        AppUtil.showNewConfirmationAlert(
                            title: logoutString.tr,
                            subTitle: logoutConfirmationString.tr,
                            cancelHandler: () {
                              Get.back();
                            },
                            okHandler: () {
                              _userProfileManager.logout();
                            });
                      }, danger: true),
                      _tile(Icons.delete_outline_rounded,
                          const Color(0xFFEF4444), deleteAccountString.tr, () {
                        AppUtil.showNewConfirmationAlert(
                            title: deleteAccountString.tr,
                            subTitle: areYouSureToDeleteAccountString.tr,
                            cancelHandler: () {
                              Get.back();
                            },
                            okHandler: () async {
                              final ok =
                                  await BiometricHelper.confirmIfEnabled(
                                      deleteAccountString.tr);
                              if (ok) {
                                _settingsController.deleteAccount();
                              }
                            });
                      }, danger: true),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _section(String title, List<Widget> tiles) {
    final List<Widget> rows = [];
    for (int i = 0; i < tiles.length; i++) {
      rows.add(tiles[i]);
      if (i != tiles.length - 1) {
        rows.add(Padding(
          padding: const EdgeInsets.only(left: 68),
          child: Divider(
              height: 1,
              thickness: 0.6,
              color: AppColorConstants.dividerColor.withValues(alpha: 0.6)),
        ));
      }
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 8, top: 4),
              child: BodySmallText(
                title.toUpperCase(),
                weight: TextWeight.bold,
                color: AppColorConstants.subHeadingTextColor,
              ),
            ),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColorConstants.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColorConstants.dividerColor.withValues(alpha: 0.5),
                  width: 0.6),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 5)),
              ],
            ),
            child: Column(children: rows),
          ),
        ],
      ),
    );
  }

  Widget _iconBubble(IconData icon, Color color) {
    return Container(
      height: 38,
      width: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }

  Widget _tile(IconData icon, Color color, String title, VoidCallback action,
      {bool danger = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              _iconBubble(icon, color),
              const SizedBox(width: 14),
              Expanded(
                child: BodyLargeText(
                  title.tr,
                  color: danger
                      ? AppColorConstants.red
                      : AppColorConstants.mainTextColor,
                ),
              ),
              if (!danger)
                Icon(Icons.chevron_right_rounded,
                    size: 22, color: AppColorConstants.iconColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget darkModeTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      child: Row(
        children: [
          _iconBubble(Icons.dark_mode_outlined, const Color(0xFF475569)),
          const SizedBox(width: 14),
          Expanded(child: BodyLargeText(darkModeString.tr)),
          Obx(() => WKToggleSwitch1(
                inactiveColor: AppColorConstants.disabledColor,
                activeColor: AppColorConstants.themeColor,
                width: 50.0,
                height: 30.0,
                initialValue: _settingsController.darkMode.value,
                onChanged: (val) {
                  _settingsController.appearanceModeChanged(val);
                },
              )),
        ],
      ),
    );
  }
}
