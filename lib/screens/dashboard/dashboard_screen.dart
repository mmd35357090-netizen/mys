import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/post/watch_videos.dart';
import '../../components/force_update_view.dart';
import '../../main.dart';
import '../../manager/location_manager.dart';
import '../add_on/ui/reel/reels.dart';
import '../home_feed/home_feed_screen.dart';
import '../profile/my_profile.dart';
import '../settings_menu/settings_controller.dart';
import 'explore.dart';

class DashboardController extends GetxController {
  RxInt currentIndex = 0.obs;
  RxInt unreadMsgCount = 0.obs;
  RxBool isLoading = false.obs;

  indexChanged(int index) {
    currentIndex.value = index;
  }

  updateUnreadMessageCount(int count) {
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

  List<Widget> widgets = [];

  @override
  void initState() {
    super.initState();
    isAnyPageInStack = true;
    _locationManager.postLocation();
    widgets = [
      const HomeFeedScreen(),
      const Explore(),
      const Reels(needBackBtn: false),
      const WatchVideos(),
      const MyProfile(showBack: false),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => _dashboardController.isLoading.value
        ? SizedBox(
            height: Get.height,
            width: Get.width,
            child: const Center(child: CircularProgressIndicator()),
          )
        : _settingsController.forceUpdate.value
            ? ForceUpdateView()
            : _settingsController.appearanceChanged?.value == null
                ? Container()
                : Scaffold(
                    backgroundColor: AppColorConstants.backgroundColor,
                    body: widgets[_dashboardController.currentIndex.value],
                    bottomNavigationBar: BottomNavigationBar(
                      currentIndex:
                          _dashboardController.currentIndex.value,
                      onTap: (index) {
                        _dashboardController.indexChanged(index);
                      },
                      selectedItemColor: AppColorConstants.themeColor,
                      unselectedItemColor: AppColorConstants.iconColor,
                      backgroundColor: AppColorConstants.cardColor,
                      type: BottomNavigationBarType.fixed,
                      items: const [
                        BottomNavigationBarItem(
                          icon: Icon(Icons.home_outlined),
                          label: 'Home',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.search_sharp),
                          label: 'Explore',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.play_arrow_outlined),
                          label: 'Reels',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.videocam_outlined),
                          label: 'Videos',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.account_circle_outlined),
                          label: 'Profile',
                        ),
                      ],
                    ),
                  ));
  }
}
