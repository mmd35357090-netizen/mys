import 'package:foap/components/empty_states.dart';
import 'package:foap/components/shimmer_widgets.dart';
import 'package:foap/components/top_navigation_bar.dart';
import 'package:foap/helper/common_components.dart';
import 'package:foap/helper/extension.dart';
import 'package:foap/helper/localization_strings.dart';
import 'package:foap/screens/profile/other_user_profile.dart';
import 'package:foap/util/app_config_constants.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/event_imports.dart';
import 'package:flutter/material.dart';

class EventMembers extends StatefulWidget {
  final EventModel event;

  const EventMembers({Key? key, required this.event}) : super(key: key);

  @override
  EventMembersState createState() => EventMembersState();
}

class EventMembersState extends State<EventMembers> {
  final EventsController _eventsController = EventsController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() {
    _eventsController.getMembers(eventId: widget.event.id);
  }

  @override
  void didUpdateWidget(covariant EventMembers oldWidget) {
    loadData();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
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
                 title: clubMembersString.tr),
            divider().tP8,
            Expanded(
              child: GetBuilder<EventsController>(
                  init: _eventsController,
                  builder: (ctx) {
                    ScrollController scrollController = ScrollController();
                    scrollController.addListener(() {
                      if (scrollController.position.maxScrollExtent ==
                          scrollController.position.pixels) {
                        if (!_eventsController.isLoadingMembers) {
                          _eventsController.getMembers(
                              eventId: widget.event.id);
                        }
                      }
                    });

                    List<EventMemberModel> membersList =
                        _eventsController.members;
                    return _eventsController.isLoadingMembers
                        ? const ShimmerUsers().hP16
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              membersList.isEmpty
                                  ? noUserFound(context)
                                  : Expanded(
                                      child: ListView.separated(
                                        padding: const EdgeInsets.only(
                                            top: 20, bottom: 50),
                                        controller: scrollController,
                                        itemCount: membersList.length,
                                        itemBuilder: (context, index) {
                                          return EventMemberTile(
                                            member: membersList[index],
                                            viewCallback: () {
                                              Get.to(() => OtherUserProfile(
                                                      userId: membersList[index]
                                                          .id))!
                                                  .then(
                                                      (value) => {loadData()});
                                            },
                                          );
                                        },
                                        separatorBuilder: (context, index) {
                                          return const SizedBox(
                                            height: 20,
                                          );
                                        },
                                      ).hP16,
                                    ),
                            ],
                          );
                  }),
            ),
          ],
        ));
  }
}
