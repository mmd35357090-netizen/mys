import 'package:foap/helper/extension.dart';
import 'package:foap/screens/add_on/ui/event/search_events.dart';
import 'package:foap/util/app_config_constants.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'event_bookings.dart';
import 'events_listing.dart';

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
  const EventsDashboardScreen({Key? key}) : super(key: key);

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
      const EventsListing(),
      const SearchEventListing(),
      const EventBookingScreen()
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: items[_dashboardController.currentIndex.value],
        bottomNavigationBar: SizedBox(
          height: MediaQuery.of(context).viewPadding.bottom > 0 ? 90 : 70.0,
          width: MediaQuery.of(context).size.width,
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
                  icon: Image.asset('assets/event.png',
                      height: 20,
                      width: 20,
                      color: _dashboardController.currentIndex.value == 0
                          ? AppColorConstants.themeColor
                          : AppColorConstants.disabledColor),
                  label: ''),
              BottomNavigationBarItem(
                  icon: Image.asset('assets/search.png',
                      height: 20,
                      width: 20,
                      color: _dashboardController.currentIndex.value == 1
                          ? AppColorConstants.themeColor
                          : AppColorConstants.disabledColor),
                  label: ''),
              BottomNavigationBarItem(
                icon: Image.asset('assets/bookings.png',
                    height: 20,
                    width: 20,
                    color: _dashboardController.currentIndex.value == 2
                        ? AppColorConstants.themeColor
                        : AppColorConstants.disabledColor),
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
