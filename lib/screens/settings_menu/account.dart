import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/profile/blocked_users.dart';
import 'package:foap/screens/settings_menu/my_subscriptions.dart';
import '../live/live_history.dart';

class AppAccount extends StatefulWidget {
  const AppAccount({super.key});

  @override
  State<AppAccount> createState() => _AppAccountState();
}

class _AppAccountState extends State<AppAccount> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: accountString.tr),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Column(
                  children: [
                    addTileEvent(liveHistoryString.tr, () {
                      Get.to(() => const LiveHistory());
                    }),
                    addTileEvent(blockedUserString.tr, () {
                      Get.to(() => const BlockedUsersList());
                    }),
                    addTileEvent(mySubscriptionString.tr, () {
                      Get.to(() => const MySubscriptions());
                    }),
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
    );
  }

  addTileEvent(String title, VoidCallback action) {
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
                      BodyLargeText(title.tr, weight: TextWeight.medium)
                    ],
                  ),
                ),
                // const Spacer(),
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
