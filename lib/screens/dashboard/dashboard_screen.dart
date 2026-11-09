import 'package:flutter/material.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/chat_imports.dart';
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
      const ChatHistory(),
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
                    bottomNavigationBar: _bottomBar(),
                  ));
  }

  Widget _bottomBar() {
    const items = [
      [Icons.home_outlined, Icons.home_rounded, 'Home'],
      [Icons.search_rounded, Icons.search_rounded, 'Explore'],
      [Icons.play_circle_outline_rounded, Icons.play_circle_rounded, 'Reels'],
      [Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Chat'],
      [Icons.account_circle_outlined, Icons.account_circle_rounded, 'Profile'],
    ];
    final int current = _dashboardController.currentIndex.value;
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: AppColorConstants.cardColor,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
              color: AppColorConstants.dividerColor.withValues(alpha: 0.5),
              width: 0.6),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 22,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          children: List.generate(items.length, (i) {
            final bool active = i == current;
            final Color color = active
                ? AppColorConstants.themeColor
                : AppColorConstants.iconColor;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _dashboardController.indexChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: active
                        ? AppColorConstants.themeColor.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(active ? items[i][1] as IconData : items[i][0] as IconData,
                              size: 25, color: color),
                          if (i == 3 &&
                              _dashboardController.unreadMsgCount.value > 0)
                            Positioned(
                              right: -4,
                              top: -2,
                              child: Container(
                                height: 9,
                                width: 9,
                                decoration: BoxDecoration(
                                  color: AppColorConstants.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppColorConstants.cardColor,
                                      width: 1.5),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        items[i][2] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w500,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
