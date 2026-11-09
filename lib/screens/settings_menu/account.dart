import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/profile/blocked_users.dart';
import 'package:foap/screens/settings_menu/my_subscriptions.dart';
import '../live/live_history.dart';
import '../../universal_components/menu_tiles.dart';


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
              padding: EdgeInsets.fromLTRB(DesignConstants.horizontalPadding,
                  16, DesignConstants.horizontalPadding, 40),
              children: [
                MenuSection(tiles: [
                  MenuTile(
                    icon: Icons.sensors_rounded,
                    color: const Color(0xFFEF4444),
                    title: liveHistoryString.tr,
                    onTap: () {
                      Get.to(() => const LiveHistory());
                    },
                  ),
                  MenuTile(
                    icon: Icons.block_rounded,
                    color: const Color(0xFF64748B),
                    title: blockedUserString.tr,
                    onTap: () {
                      Get.to(() => const BlockedUsersList());
                    },
                  ),
                  MenuTile(
                    icon: Icons.workspace_premium_outlined,
                    color: const Color(0xFFF59E0B),
                    title: mySubscriptionString.tr,
                    onTap: () {
                      Get.to(() => const MySubscriptions());
                    },
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
