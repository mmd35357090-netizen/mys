import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/event_imports.dart';

import 'create_event/choose_category.dart';

class ExploreEvents extends StatefulWidget {
  const ExploreEvents({super.key});

  @override
  ExploreEventsState createState() => ExploreEventsState();
}

class ExploreEventsState extends State<ExploreEvents> {
  final EventsController _eventsController = Get.find();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _eventsController.getCategories();
    });

    super.initState();
  }

  loadEvents() {
    _eventsController.clear();
    _eventsController.clearMembers();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _eventsController.clear();
      _eventsController.clearMembers();
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
          color: Colors.white,
        ),
      ).circular.ripple(() {
        Get.to(() => ChooseEventCategory());
      }),
      body: Column(
        children: [
          backNavigationBar(
            title: eventsString.tr,
          ),
          Expanded(
            child: Obx(() {
              List<EventCategoryModel> categories =
                  _eventsController.categories;
              return categories.isEmpty
                  ? emptyData(
                      title: noEventFoundString.tr,
                      subTitle: '',
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: GetBuilder<EventsController>(
                              init: _eventsController,
                              builder: (ctx) {
                                return ListView.separated(
                                    padding: const EdgeInsets.only(
                                        top: 25, bottom: 50),
                                    itemBuilder:
                                        (ctx, categoryGroupIndex) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              BodyLargeText(
                                                      _eventsController
                                                          .categories[
                                                              categoryGroupIndex]
                                                          .name,
                                                      weight:
                                                          TextWeight.bold)
                                                  .lP16,
                                              const Spacer(),
                                              Row(children: [
                                                BodySmallText(
                                                  seeAllString.tr,
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                ThemeIconWidget(
                                                  ThemeIcon.nextArrow,
                                                  size: 15,
                                                ).rP16,
                                              ]).ripple(() {
                                                _eventsController
                                                    .setCategoryId(
                                                        _eventsController
                                                            .categories[
                                                                categoryGroupIndex]
                                                            .id);
                                                _eventsController
                                                    .getEvents();
                                                Get.to(() => CategoryEventsListing(
                                                    category: _eventsController
                                                            .categories[
                                                        categoryGroupIndex]));
                                              })
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 25,
                                          ),
                                          SizedBox(
                                            height: 310,
                                            child: ListView.separated(
                                              padding: EdgeInsets.only(
                                                  left: DesignConstants
                                                      .horizontalPadding,
                                                  right: DesignConstants
                                                      .horizontalPadding),
                                              scrollDirection:
                                                  Axis.horizontal,
                                              itemCount: _eventsController
                                                  .categories[
                                                      categoryGroupIndex]
                                                  .events
                                                  .length,
                                              itemBuilder: (ctx, tvIndex) {
                                                EventModel event =
                                                    _eventsController
                                                        .categories[
                                                            categoryGroupIndex]
                                                        .events[tvIndex];

                                                return EventCard(
                                                  event: event,
                                                  joinBtnClicked: () {},
                                                  leaveBtnClicked: () {},
                                                  previewBtnClicked: () {
                                                    Get.to(() => EventDetail(
                                                        event: event,
                                                        needRefreshCallback:
                                                            () {}));
                                                  },
                                                ).ripple(() {});
                                              },
                                              separatorBuilder:
                                                  (ctx, index) {
                                                return const SizedBox(
                                                    width: 10);
                                              },
                                            ),
                                          )
                                        ],
                                      );
                                    },
                                    separatorBuilder: (ctx, index) {
                                      return const SizedBox(
                                        height: 40,
                                      );
                                    },
                                    itemCount: _eventsController
                                        .categories.length);
                              }),
                        ),
                      ],
                    );
            }),
          ),
        ],
      ),
    );
  }
}
