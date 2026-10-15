import 'package:foap/screens/shop_feature/home/shop_categories.dart';
import 'package:foap/screens/shop_feature/my_ads/my_ads.dart';
import '../../../helper/imports/common_import.dart';
import 'fav_list.dart';
import 'marketplace_screen.dart';

class ShopDashboardController extends GetxController {
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

class ShopDashboard extends StatelessWidget {
  ShopDashboard({super.key}) ;

  final ShopDashboardController _dashboardController =
      ShopDashboardController();

  final List<Widget> items = [
    const Marketplace(),
    const FavProductsListScreen(),
    ShopCategories(),
    const MyAds(),
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
                  icon: ThemeIconWidget(ThemeIcon.fav,
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
                label: '',
              ),
              BottomNavigationBarItem(
                icon: ThemeIconWidget(ThemeIcon.product,
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
    Future.delayed(
        Duration.zero, () => _dashboardController.indexChanged(index));
  }
}
