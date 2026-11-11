import 'package:foap/helper/imports/common_import.dart';
import 'dating_card.dart';
import 'like_list.dart';
import 'matched_list.dart';
import 'set_dating_preference.dart';

class DatingDashboardController extends GetxController {
  RxInt currentIndex = 0.obs;
  RxBool isLoading = false.obs;

  indexChanged(int index) {
    currentIndex.value = index;
  }
}

class DatingDashboard extends StatefulWidget {
  const DatingDashboard({super.key}) ;

  @override
  State<DatingDashboard> createState() => DatingDashboardState();
}

class DatingDashboardState extends State<DatingDashboard> {
  final DatingDashboardController _dashboardController =
      DatingDashboardController();
  List<Widget> items = [];

  @override
  void initState() {
    items = [
      const DatingCard(),
      const MatchedList(),
      const LikeList(),
      const SetDatingPreference(),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: items[_dashboardController.currentIndex.value],
        bottomNavigationBar: Container(
          height: MediaQuery.of(context).viewPadding.bottom > 0 ? 90 : 70.0,
          width: Get.width,
          decoration: BoxDecoration(
            color: AppColorConstants.cardColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -4))
            ],
          ),
          child: BottomNavigationBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed,
            currentIndex: _dashboardController.currentIndex.value,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            unselectedItemColor: Colors.grey,
            selectedItemColor: AppColorConstants.themeColor,
            onTap: (index) => {onTabTapped(index)},
            items: [
              BottomNavigationBarItem(
                  icon: ThemeIconWidget(ThemeIcon.dating,
                      size: 24,
                      color: _dashboardController.currentIndex.value == 0
                          ? AppColorConstants.themeColor
                          : AppColorConstants.iconColor),
                  label: ''),
              BottomNavigationBarItem(
                  icon: ThemeIconWidget(ThemeIcon.fav,
                      size: 24,
                      color: _dashboardController.currentIndex.value == 1
                          ? AppColorConstants.themeColor
                          : AppColorConstants.iconColor),
                  label: ''),
              BottomNavigationBarItem(
                  icon: ThemeIconWidget(ThemeIcon.thumbsUp,
                      size: 24,
                      color: _dashboardController.currentIndex.value == 2
                          ? AppColorConstants.themeColor
                          : AppColorConstants.iconColor),
                  label: ''),
              BottomNavigationBarItem(
                icon: ThemeIconWidget(ThemeIcon.filterIcon,
                    size: 24,
                    color: _dashboardController.currentIndex.value == 3
                        ? AppColorConstants.themeColor
                        : AppColorConstants.iconColor),
                label: '',
              ),
            ],
          ),
        )));
  }

  void onTabTapped(int index) async {
    Future.delayed(
        Duration.zero, () => _dashboardController.indexChanged(index));
  }
}
