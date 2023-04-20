import 'package:foap/components/top_navigation_bar.dart';
import 'package:foap/helper/common_components.dart';
import 'package:foap/helper/extension.dart';
import 'package:foap/screens/add_on/controller/event/event_controller.dart';
import 'package:foap/util/app_config_constants.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/event_imports.dart';
import 'package:flutter/material.dart';

import 'event_detail.dart';

class CategoryEventsListing extends StatefulWidget {
  final EventCategoryModel category;

  const CategoryEventsListing({Key? key, required this.category})
      : super(key: key);

  @override
  CategoryEventsListingState createState() => CategoryEventsListingState();
}

class CategoryEventsListingState extends State<CategoryEventsListing> {
  final EventsController _eventsController = EventsController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _eventsController.getEvents(categoryId: widget.category.id);
    });

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _eventsController.clear();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          backNavigationBar(
            context: context,
            title: widget.category.name,
          ),
          divider(context: context).tP8,
          Expanded(
            child: Obx(() {
              ScrollController scrollController = ScrollController();
              scrollController.addListener(() {
                if (scrollController.position.maxScrollExtent ==
                    scrollController.position.pixels) {
                  if (!_eventsController.isLoadingEvents.value) {
                    _eventsController.getEvents(categoryId: widget.category.id);
                  }
                }
              });

              List<EventModel> events = _eventsController.events;
              return events.isEmpty
                  ? Container()
                  : SizedBox(
                      height: events.length * 200,
                      child: ListView.separated(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 20, bottom: 50),
                          itemCount: events.length,
                          itemBuilder: (BuildContext ctx, int index) {
                            return EventCard2(
                              event: events[index],
                              joinBtnClicked: () {
                                _eventsController.joinEvent(events[index]);
                              },
                              leaveBtnClicked: () {
                                _eventsController.leaveEvent(events[index]);
                              },
                              previewBtnClicked: () {
                              },
                            ).ripple(() {
                              Get.to(() => EventDetail(
                                    event: events[index],
                                    needRefreshCallback: () {
                                      _eventsController.getEvents(
                                          categoryId: widget.category.id);
                                    },
                                  ));
                            });
                          },
                          separatorBuilder: (BuildContext ctx, int index) {
                            return const SizedBox(
                              height: 25,
                            );
                          }),
                    );
            }),
          ),
        ],
      ),
    );
  }


}
