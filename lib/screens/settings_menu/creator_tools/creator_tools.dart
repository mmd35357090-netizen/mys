import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/settings_menu/creator_tools/my_subscribers.dart';
import 'package:foap/screens/settings_menu/creator_tools/subscription_plan.dart';
import 'package:foap/screens/settings_menu/settings_controller.dart';

import 'package:foap/screens/wallet/creator_dashboard.dart';
import '../../../universal_components/menu_tiles.dart';
import 'account_verification/request_verification.dart';
import 'not_elegible_for_subscription.dart';

class CreatorTools extends StatefulWidget {
  const CreatorTools({super.key});

  @override
  State<CreatorTools> createState() => _CreatorToolsState();
}

class _CreatorToolsState extends State<CreatorTools> {
  final UserProfileManager _userProfileManager = Get.find();
  final SettingsController _settingsController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => AppScaffold(
          backgroundColor: AppColorConstants.backgroundColor,
          body: Column(
            children: [
              backNavigationBar(title: creatorToolsString.tr),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                      DesignConstants.horizontalPadding, 16,
                      DesignConstants.horizontalPadding, 40),
                  children: [
                    MenuSection(tiles: [
                      MenuTile(
                        icon: Icons.insights_rounded,
                        color: const Color(0xFF8B5CF6),
                        title: 'Creator dashboard',
                        subtitle: 'Earnings, gifts and ad revenue',
                        onTap: () {
                          Get.to(() => const CreatorDashboardScreen());
                        },
                      ),
                      MenuTile(
                        icon: Icons.workspace_premium_outlined,
                        color: const Color(0xFFF59E0B),
                        title: subscriptionString.tr,
                        subtitle: 'Paid plans for your followers',
                        onTap: () {
                          if (_userProfileManager
                              .user.value!.isEligibleForSubscription) {
                            Get.to(() => const CreateSubscriptionPlan());
                          } else {
                            Get.to(() => const NotEligibleForSubscription());
                          }
                        },
                      ),
                      if (_settingsController
                          .setting.value!.enableProfileVerification)
                        MenuTile(
                          icon: Icons.verified_outlined,
                          color: const Color(0xFF3B82F6),
                          title: requestVerificationString.tr,
                          onTap: () {
                            Get.to(() => const RequestVerification());
                          },
                        ),
                      if (_userProfileManager
                          .user.value!.subscriptionPlans.isNotEmpty)
                        MenuTile(
                          icon: Icons.groups_2_outlined,
                          color: const Color(0xFF10B981),
                          title: mySubscribersString.tr,
                          onTap: () {
                            Get.to(() => const MySubscribers());
                          },
                        ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
