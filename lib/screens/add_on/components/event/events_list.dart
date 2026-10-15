import 'package:foap/helper/enum.dart';
import 'package:foap/helper/extension.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../util/app_config_constants.dart';
import '../../controller/event/event_controller.dart';
import '../../model/event_model.dart';
import '../../ui/event/event_detail.dart';
import 'event_card.dart';

class EventsList extends StatelessWidget {
  final EventsController _eventsController = Get.find();

  EventsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      ScrollController scrollController = ScrollController();
      scrollController.addListener(() {
        if (scrollController.position.maxScrollExtent ==
            scrollController.position.pixels) {
          if (!_eventsController.isLoadingEvents.value) {
            _eventsController.getEvents();
          }
        }
      });

      List<EventModel> events = _eventsController.events;
      return events.isEmpty
          ? Container()
          : SizedBox(
              height: events.length * 200,
              child: ListView.separated(
                  padding: EdgeInsets.only(
                      left: DesignConstants.horizontalPadding,
                      right: DesignConstants.horizontalPadding,
                      top: 20,
                      bottom: 50),
                  itemCount: events.length,
                  itemBuilder: (BuildContext ctx, int index) {
                    return EventCard2(
                      event: events[index],
                      joinBtnClicked: () {
                        _eventsController.reactOnEvent(
                            reaction: ReactionOnEvent.interested,
                            eventId: events[index].id);
                      },
                      leaveBtnClicked: () {
                        _eventsController.reactOnEvent(
                            reaction: ReactionOnEvent.notInterested,
                            eventId: events[index].id);
                      },
                      previewBtnClicked: () {},
                    ).ripple(() {
                      Get.to(() => EventDetail(
                            event: events[index],
                            needRefreshCallback: () {
                              _eventsController.getEvents();
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
    });
  }
}
