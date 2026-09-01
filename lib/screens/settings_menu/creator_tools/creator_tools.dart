import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/settings_menu/creator_tools/my_subscribers.dart';
import 'package:foap/screens/settings_menu/creator_tools/subscription_plan.dart';
import 'package:foap/screens/settings_menu/settings_controller.dart';
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
              IntrinsicHeight(
                child: Container(
                  color: AppColorConstants.themeColor.withOpacity(0.05),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        addTileEvent(subscriptionString.tr, () {
                          if (_userProfileManager
                              .user.value!.isEligibleForSubscription) {
                            Get.to(() => const CreateSubscriptionPlan());
                          } else {
                            Get.to(
                                () => const NotEligibleForSubscription());
                          }
                        }, true),
                        if (_settingsController
                            .setting.value!.enableProfileVerification)
                          addTileEvent(requestVerificationString.tr, () {
                            Get.to(() => const RequestVerification());
                          }, true),
                        if (_userProfileManager
                            .user.value!.subscriptionPlans.isNotEmpty)
                          addTileEvent(mySubscribersString.tr, () {
                            Get.to(() => const MySubscribers());
                          }, true),
                      ],
                    ),
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
}
