import 'package:foap/screens/add_on/ui/event/event_feed.dart';
import 'package:foap/screens/add_on/ui/event/search_events.dart';
import 'create_event/my_events.dart';
import 'event_bookings.dart';
import 'explore_events.dart';
import 'package:foap/helper/imports/common_import.dart';

class EventsDashboardController extends GetxController {
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

class EventsDashboardScreen extends StatefulWidget {
  const EventsDashboardScreen({super.key});

  @override
  EventsDashboardScreenState createState() => EventsDashboardScreenState();
}

class EventsDashboardScreenState extends State<EventsDashboardScreen> {
  final EventsDashboardController _dashboardController =
      EventsDashboardController();

  List<Widget> items = [];
  bool hasPermission = false;

  @override
  void initState() {
    items = [
      const ExploreEvents(),
      const EventFeedScreen(),
      const SearchEventListing(),
      const EventBookingScreen(),
      const MyEventListing()
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: items[_dashboardController.currentIndex.value],
        bottomNavigationBar: SizedBox(
          height:
              MediaQuery.of(context).viewPadding.bottom > 0 ? 90 : 70.0,
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
                  icon: ThemeIconWidget(ThemeIcon.event,
                      color: _dashboardController.currentIndex.value == 0
                          ? AppColorConstants.themeColor
                          : AppColorConstants.iconColor),
                  label: ''),
              BottomNavigationBarItem(
                  icon: ThemeIconWidget(ThemeIcon.home,
                      color: _dashboardController.currentIndex.value == 1
                          ? AppColorConstants.themeColor
                          : AppColorConstants.iconColor),
                  label: ''),
              BottomNavigationBarItem(
                  icon: ThemeIconWidget(ThemeIcon.search,
                      color: _dashboardController.currentIndex.value == 2
                          ? AppColorConstants.themeColor
                          : AppColorConstants.iconColor),
                  label: ''),
              BottomNavigationBarItem(
                icon: ThemeIconWidget(ThemeIcon.bookings,
                    color: _dashboardController.currentIndex.value == 3
                        ? AppColorConstants.themeColor
                        : AppColorConstants.iconColor),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: ThemeIconWidget(ThemeIcon.account,
                    color: _dashboardController.currentIndex.value == 4
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
