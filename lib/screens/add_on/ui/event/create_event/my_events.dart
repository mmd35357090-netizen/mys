import 'package:foap/helper/imports/event_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../../../segmentAndMenu/horizontal_menu.dart';
import '../../../controller/event/create_event/add_event_controller.dart';
import '../../../controller/event/create_event/my_events_controller.dart';
import '../../../model/create_event_model.dart';
import 'choose_category.dart';
import 'create_event.dart';
import 'event_detail.dart';

class MyEventListing extends StatefulWidget {
  const MyEventListing({super.key});

  @override
  MyEventListingState createState() => MyEventListingState();
}

class MyEventListingState extends State<MyEventListing> {
  final MyEventsController _eventsController = Get.find();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final AddEventController addEventController = Get.find();

  @override
  void initState() {
    super.initState();
    _eventsController.refreshEvents(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _eventsController.clear();
      _eventsController.clearSegment();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      floatingActionButton: Container(
        height: 50,
        width: 50,
        color: AppColorConstants.themeColor,
        child: ThemeIconWidget(
          ThemeIcon.plusSymbol,
          size: 25,
          color: Colors.white,
        ),
      ).circular.ripple(() {
        Get.to(() => ChooseEventCategory());
      }),
      body: Column(
        children: [
          const SizedBox(
            height: 40,
          ),
          Row(
            children: [
              ThemeIconWidget(
                ThemeIcon.backArrow,
                size: 25,
              ).ripple(() {
                Get.back();
              }),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: SFSearchBar(
                    hintText: searchString.tr,
                    showSearchIcon: true,
                    iconColor: AppColorConstants.themeColor,
                    onSearchChanged: (value) {
                      _eventsController.searchEvents(value);
                    },
                    onSearchStarted: () {},
                    onSearchCompleted: (searchTerm) {}),
              ),
            ],
          ).setPadding(
              left: DesignConstants.horizontalPadding,
              right: DesignConstants.horizontalPadding,
              top: 25,
              bottom: 20),
          segmentView(),
          Expanded(
            child: Obx(() {
              List<CreateEventModel> events = _eventsController.events;
              return events.isEmpty
                  ? emptyData(title: noDataString.tr, subTitle: '')
                  : ListView.separated(
                      padding: EdgeInsets.only(
                          left: DesignConstants.horizontalPadding,
                          right: DesignConstants.horizontalPadding,
                          top: 20,
                          bottom: 50),
                      itemCount: events.length,
                      itemBuilder: (BuildContext ctx, int index) {
                        return ProviderEventCard2(
                          event: events[index],
                          editBtnClicked: () {
                            addEventController
                                .setEditableEvent(events[index]);
                            Get.to(() => EnterEventDetail());
                          },
                          addTicketsBtnClicked: () {},
                          viewTicketsBtnClicked: () {},
                          previewBtnClicked: () {
                            Get.to(() => ProviderEventDetail(
                                      event: events[index],
                                      needRefreshCallback: () {
                                        _eventsController
                                            .refreshEvents((() {}));
                                      },
                                    ))!
                                .then((status) {
                              if (status == true) {
                                _eventsController.refreshEvents(() {});
                              }
                            });
                          },
                        );
                      },
                      separatorBuilder: (BuildContext ctx, int index) {
                        return const SizedBox(
                          height: 25,
                        );
                      }).addPullToRefresh(
                      refreshController: _refreshController,
                      onRefresh: () {
                        _eventsController.refreshEvents(() {
                          _refreshController.refreshCompleted();
                        });
                      },
                      onLoading: () {
                        _eventsController.loadMoreEvents(() {
                          _refreshController.loadComplete();
                        });
                      },
                      enablePullUp: true,
                      enablePullDown: true);
            }),
          ),
        ],
      ),
    );
  }

  Widget segmentView() {
    return Obx(() => HorizontalMenuBar(
          menus: [
            activeString.tr,
            upcomingString.tr,
            completedString.tr,
          ],
          selectedIndex: _eventsController.selectSegment.value,
          onSegmentChange: (selectedMenu) {
            _eventsController.handleSegmentChange(selectedMenu);
          },
        ));
  }
}
