import 'package:foap/screens/add_on/ui/podcast/explore_hosts.dart';
import '../../../../helper/imports/common_import.dart';
import 'explore_podcasts.dart';

class PodcastDashboardController extends GetxController {
  RxInt currentIndex = 0.obs;
  RxBool isLoading = false.obs;

  indexChanged(int index) {
    currentIndex.value = index;
  }
}

class PodcastDashboard extends StatelessWidget {
  PodcastDashboard({super.key});

  final PodcastDashboardController _dashboardController =
      PodcastDashboardController();

  final List<Widget> items = [
    const ExploreHosts(
      addBackBtn: false,
    ),
    const ExplorePodcasts(
      addBackBtn: false,
    ),
    // BusinessCategories(),
    // const ExploreBusiness(
    //   addBackBtn: false,
    // ),
    // const ExploreFavOffers(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: items[_dashboardController.currentIndex.value],
        bottomNavigationBar: SizedBox(
          height: MediaQuery.of(context).viewPadding.bottom > 0 ? 90 : 70.0,
          width: Get.width,
          child: BottomNavigationBar(
            backgroundColor: AppColorConstants.backgroundColor,
            type: BottomNavigationBarType.fixed,
            currentIndex: _dashboardController.currentIndex.value,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            unselectedItemColor: Colors.grey,
            selectedItemColor: AppColorConstants.themeColor,
            onTap: (index) => {onTabTapped(index)},
            items: [
              BottomNavigationBarItem(
                  icon: ThemeIconWidget(ThemeIcon.homeOutlined,
                      size: 20,
                      color: _dashboardController.currentIndex.value == 0
                          ? AppColorConstants.themeColor
                          : AppColorConstants.iconColor),
                  label: ''),
              BottomNavigationBarItem(
                  icon: ThemeIconWidget(ThemeIcon.categories,
                      size: 20,
                      color: _dashboardController.currentIndex.value == 1
                          ? AppColorConstants.themeColor
                          : AppColorConstants.iconColor),
                  label: ''),
              // BottomNavigationBarItem(
              //   icon: ThemeIconWidget(ThemeIcon.business,
              //       size: 20,
              //       color: _dashboardController.currentIndex.value == 2
              //           ? AppColorConstants.themeColor
              //           : AppColorConstants.iconColor),
              //   label: '',
              // ),
              // BottomNavigationBarItem(
              //   icon: ThemeIconWidget(ThemeIcon.fav,
              //       size: 20,
              //       color: _dashboardController.currentIndex.value == 3
              //           ? AppColorConstants.themeColor
              //           : AppColorConstants.iconColor),
              //   label: '',
              // ),
              // BottomNavigationBarItem(
              //   icon: ThemeIconWidget(ThemeIcon.fav,
              //       size: 20,
              //       color: _dashboardController.currentIndex.value == 3
              //           ? AppColorConstants.themeColor
              //           : AppColorConstants.iconColor),
              //   label: '',
              // ),
            ],
          ),
        )));
  }

  void onTabTapped(int index) async {
    Future.delayed(
        Duration.zero, () => _dashboardController.indexChanged(index));
  }
}
