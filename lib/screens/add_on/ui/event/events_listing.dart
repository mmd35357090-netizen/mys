import 'package:foap/components/custom_texts.dart';
import 'package:foap/components/empty_states.dart';
import 'package:foap/components/group_avatars/group_avatar1.dart';
import 'package:foap/components/shimmer_widgets.dart';
import 'package:foap/components/top_navigation_bar.dart';
import 'package:foap/helper/common_components.dart';
import 'package:foap/helper/extension.dart';
import 'package:foap/helper/localization_strings.dart';
import 'package:foap/screens/add_on/controller/event/event_controller.dart';
import 'package:foap/theme/theme_icon.dart';
import 'package:foap/util/app_config_constants.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/event_imports.dart';
import 'package:flutter/material.dart';

import 'category_event_listing.dart';
import 'event_detail.dart';

class EventsListing extends StatefulWidget {
  const EventsListing({Key? key}) : super(key: key);

  @override
  EventsListingState createState() => EventsListingState();
}

class EventsListingState extends State<EventsListing> {
  final EventsController _eventsController = EventsController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _eventsController.getCategories();
      // _eventsController.getEvents();
      // _eventsController.selectedSegmentIndex(0);
    });

    // _controller.addListener(() {
    //   if (_controller.position.atEdge) {
    //     bool isTop = _controller.position.pixels == 0;
    //     if (isTop) {
    //     } else {
    //       _eventsController.getEvents();
    //     }
    //   }
    // });

    super.initState();
  }

  loadEvents() {
    _eventsController.clear();
    _eventsController.clearMembers();
  }

  @override
  void dispose() {
    _eventsController.clear();
    _eventsController.clearMembers();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [

          backNavigationBar(

            title: eventsString.tr,
          ),
          divider().tP8,
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
                        const SizedBox(
                          height: 20,
                        ),
                        _eventsController.isLoadingCategories.value
                            ? const EventCategoriesScreenShimmer()
                            : SizedBox(
                                height: 40,
                                child: ListView.separated(
                                    padding: const EdgeInsets.only(left: 16),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: categories.length,
                                    itemBuilder: (BuildContext ctx, int index) {
                                      EventCategoryModel category =
                                          categories[index];
                                      return CategoryAvatarType2(
                                              category: category)
                                          .ripple(() {
                                        Get.to(() => CategoryEventsListing(
                                                category: category))!
                                            .then((value) {
                                          loadEvents();
                                        });
                                      });
                                    },
                                    separatorBuilder:
                                        (BuildContext ctx, int index) {
                                      return const SizedBox(
                                        width: 10,
                                      );
                                    }),
                              ),
                        const SizedBox(
                          height: 30,
                        ),
                        Expanded(
                          child: GetBuilder<EventsController>(
                              init: _eventsController,
                              builder: (ctx) {
                                return ListView.separated(
                                    padding: const EdgeInsets.only(
                                        top: 25, bottom: 50),
                                    itemBuilder: (ctx, categoryGroupIndex) {
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
                                                  weight: TextWeight.bold
                                              ).lP16,
                                              const Spacer(),
                                              Row(children: [
                                                BodySmallText(
                                                  seeAllString.tr,
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                const ThemeIconWidget(
                                                  ThemeIcon.nextArrow,
                                                  size: 15,
                                                ).rP16,
                                              ]).ripple(() {
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
                                            height: 285,
                                            child: ListView.separated(
                                              padding: const EdgeInsets.only(
                                                  left: 16, right: 16),
                                              scrollDirection: Axis.horizontal,
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
                                              separatorBuilder: (ctx, index) {
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
                                    itemCount:
                                        _eventsController.categories.length);
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
