
import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:image_picker/image_picker.dart';
import '../../components/force_update_view.dart';
import '../../main.dart';
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

  List<Widget> items = [];
  final picker = ImagePicker();
  bool hasPermission = false;

  @override
  void initState() {
    isAnyPageInStack = true;

    items = [
      const HomeFeedScreen(),
      const Explore(),
      const Reels(needBackBtn: false),
      const ChatHistory(),
      const MyProfile(showBack: false),
    ];

    super.initState();
  }

  // Premium animated Reels navigation button
  Widget _buildPremiumReelsButton() {
    return Obx(() {
      final bool isSelected =
          _dashboardController.currentIndex.value == 2;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColorConstants.themeColor,
                    AppColorConstants.themeColor.withOpacity(0.65),
                  ],
                )
              : null,
          color: isSelected
              ? null
              : AppColorConstants.themeColor.withOpacity(0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.white.withOpacity(0.35)
                : AppColorConstants.themeColor.withOpacity(0.30),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColorConstants.themeColor.withOpacity(0.35),
                    blurRadius: 12,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: ThemeIconWidget(
          ThemeIcon.reels,
          size: 26,
          color: isSelected
              ? Colors.white
              : AppColorConstants.iconColor,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _dashboardController.isLoading.value
          ? SizedBox(
              height: Get.height,
              width: Get.width,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          : _settingsController.forceUpdate.value
              ? ForceUpdateView()
              : _settingsController.appearanceChanged?.value == null
                  ? Container()
                  : Scaffold(
                      backgroundColor:
                          AppColorConstants.backgroundColor,
                      body: items[
                          _dashboardController.currentIndex.value],
                      floatingActionButtonLocation:
                          FloatingActionButtonLocation.centerDocked,
                      bottomNavigationBar: SizedBox(
                        height:
                            MediaQuery.of(context).viewPadding.bottom > 0
                                ? 100
                                : 80,
                        width: Get.width,
                        child: BottomNavigationBar(
                          backgroundColor:
                              AppColorConstants.backgroundColor,
                          type: BottomNavigationBarType.fixed,
                          currentIndex:
                              _dashboardController.currentIndex.value,
                          selectedFontSize: 12,
                          unselectedFontSize: 12,
                          unselectedItemColor: Colors.grey,
                          selectedItemColor:
                              AppColorConstants.themeColor,
                          onTap: onTabTapped,
                          items: [
                            BottomNavigationBarItem(
                              icon: Obx(
                                () => ThemeIconWidget(
                                  ThemeIcon.home,
                                  size: 28,
                                  color: _dashboardController
                                              .currentIndex.value ==
                                          0
                                      ? AppColorConstants.themeColor
                                      : AppColorConstants.iconColor,
                                ).bP8,
                              ),
                              label: homeString.tr,
                            ),
                            BottomNavigationBarItem(
                              icon: Obx(
                                () => ThemeIconWidget(
                                  ThemeIcon.search,
                                  size: 28,
                                  color: _dashboardController
                                              .currentIndex.value ==
                                          1
                                      ? AppColorConstants.themeColor
                                      : AppColorConstants.iconColor,
                                ),
                              ),
                              label: exploreString.tr,
                            ),
                            BottomNavigationBarItem(
                              icon: _buildPremiumReelsButton(),
                              label: reelsString.tr,
                            ),
                            BottomNavigationBarItem(
                              icon: Obx(
                                () => Stack(
                                  children: [
                                    ThemeIconWidget(
                                      ThemeIcon.chat,
                                      size: 28,
                                      color: _dashboardController
                                                  .currentIndex.value ==
                                              3
                                          ? AppColorConstants.themeColor
                                          : AppColorConstants.iconColor,
                                    ).bP8,
                                    if (_dashboardController
                                            .unreadMsgCount.value >
                                        0)
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          height: 12,
                                          width: 12,
                                          decoration: BoxDecoration(
                                            color: AppColorConstants
                                                .themeColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              label: chatsString.tr,
                            ),
                            BottomNavigationBarItem(
                              icon: Obx(
                                () => ThemeIconWidget(
                                  ThemeIcon.account,
                                  size: 28,
                                  color: _dashboardController
                                              .currentIndex.value ==
                                          4
                                      ? AppColorConstants.themeColor
                                      : AppColorConstants.iconColor,
                                ).bP8,
                              ),
                              label: accountString.tr,
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }

  void onTabTapped(int index) {
    Future.delayed(
      Duration.zero,
      () => _dashboardController.indexChanged(index),
    );
  }
}
