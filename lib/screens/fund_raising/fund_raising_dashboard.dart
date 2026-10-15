import '../../controllers/fund_raising/fund_raising_controller.dart';
import '../../helper/imports/common_import.dart';
import 'explore_campaigns.dart';
import 'fav_fund_rasing_campaigns_list.dart';
import 'fund_raising_categories.dart';
import 'fundraising_campaign_feed.dart';

class FundRaisingDashboardController extends GetxController {
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

class FundRaisingDashboard extends StatelessWidget {
  FundRaisingDashboard({super.key});

  final FundRaisingDashboardController _dashboardController =
      FundRaisingDashboardController();
  final FundRaisingController _fundRaisingController = Get.find();

  final List<Widget> items = [
    const ExploreCampaigns(
      fromCategory: false,
    ),
    const FundraisingFeedScreen(),
    FundRaisingCategories(),
    FavFundRaisingCampaignList(),
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
                  icon: ThemeIconWidget(ThemeIcon.fundRaisingCampaign,
                      size: 20,
                      color: _dashboardController.currentIndex.value == 0
                          ? AppColorConstants.themeColor
                          : AppColorConstants.iconColor),
                  label: ''),
              BottomNavigationBarItem(
                  icon: ThemeIconWidget(ThemeIcon.homeOutlined,
                      size: 20,
                      color: _dashboardController.currentIndex.value == 1
                          ? AppColorConstants.themeColor
                          : AppColorConstants.iconColor),
                  label: ''),
              BottomNavigationBarItem(
                  icon: ThemeIconWidget(ThemeIcon.categories,
                      size: 20,
                      color: _dashboardController.currentIndex.value == 2
                          ? AppColorConstants.themeColor
                          : AppColorConstants.iconColor),
                  label: ''),
              BottomNavigationBarItem(
                icon: ThemeIconWidget(ThemeIcon.fav,
                    size: 20,
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
    if (index == 0) {
      _fundRaisingController.getCampaigns(() {});
    } else if (index == 1) {
      _fundRaisingController.getCategories();
    } else if (index == 2) {
      _fundRaisingController.getFavCampaigns(() {});
    }
    Future.delayed(
        Duration.zero, () => _dashboardController.indexChanged(index));
  }
}
