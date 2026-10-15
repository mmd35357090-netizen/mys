import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/post/watch_videos.dart';
import '../../components/force_update_view.dart';
import '../../main.dart';
import '../../manager/location_manager.dart';
import '../add_on/ui/reel/reels.dart';
import '../home_feed/home_feed_screen.dart';
import '../profile/my_profile.dart';
import '../settings_menu/settings_controller.dart';
import '../chat/chat_history.dart';
import 'explore.dart';

class DashboardController extends GetxController {
  RxInt currentIndex = 0.obs;
  RxInt unreadMsgCount = 0.obs;
  RxBool isLoading = false.obs;

  void indexChanged(int index) {
    currentIndex.value = index;
  }

  void updateUnreadMessageCount(int count) {
    unreadMsgCount.value = count;
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<DashboardScreen> {
  final DashboardController _dashboardController = Get.find();
  final SettingsController _settingsController = Get.find();
  final LocationManager _locationManager = Get.find();

  late final List<Widget> widgets;

  @override
  void initState() {
    super.initState();

    isAnyPageInStack = true;
    _locationManager.postLocation();

    widgets = [
      const HomeFeedScreen(),              // Home
      const Explore(),                     // Explore
      const Reels(needBackBtn: false),     // Clips
      const ChatHistory(showBack: false),  // Chats
      const MyProfile(showBack: false),    // Account
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_dashboardController.isLoading.value) {
        return SizedBox(
          height: Get.height,
          width: Get.width,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (_settingsController.forceUpdate.value) {
        return ForceUpdateView();
      }

      if (_settingsController.appearanceChanged?.value == null) {
        return Container();
      }

      final selectedIndex =
          _dashboardController.currentIndex.value;

      return Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: IndexedStack(
          index: selectedIndex,
          children: widgets,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: _dashboardController.indexChanged,
          selectedItemColor: AppColorConstants.themeColor,
          unselectedItemColor: AppColorConstants.iconColor,
          backgroundColor: AppColorConstants.cardColor,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.smart_display_outlined),
              activeIcon: Icon(Icons.smart_display_rounded),
              label: 'Clips',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              activeIcon: Icon(Icons.chat_rounded),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined),
              activeIcon: Icon(Icons.account_circle_rounded),
              label: 'Account',
            ),
          ],
        ),
      );
    });
  }
}
