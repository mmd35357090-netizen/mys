import 'package:foap/apiHandler/api_controller.dart';
import 'package:foap/apiHandler/apis/events_api.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/event_imports.dart';

class EventsController extends GetxController {
  RxList<EventModel> events = <EventModel>[].obs;
  RxList<EventCategoryModel> categories = <EventCategoryModel>[].obs;
  RxList<EventMemberModel> members = <EventMemberModel>[].obs;

  RxBool isLoadingCategories = false.obs;

  int eventsPage = 1;
  bool canLoadMoreEvents = true;
  RxBool isLoadingEvents = false.obs;

  int membersPage = 1;
  bool canLoadMoreMembers = true;
  bool isLoadingMembers = false;

  RxInt segmentIndex = (-1).obs;
  RxString searchText = ''.obs;

  clear() {
    isLoadingEvents.value = false;
    events.value = [];
    eventsPage = 1;
    canLoadMoreEvents = true;
  }

  clearMembers() {
    isLoadingMembers = false;
    members.value = [];
    membersPage = 1;
    canLoadMoreMembers = true;
  }

  searchTextChanged(String text) {
    events.value = [];
    canLoadMoreEvents = true;
    searchText.value = text;
    getEvents(name: text);
  }

  selectedSegmentIndex(int index) {
    if (isLoadingEvents.value == true) {
      return;
    }
    update();

    if (index == 0 && segmentIndex.value != index) {
      clear();
      getEvents();
    } else if (index == 1 && segmentIndex.value != index) {
      clear();
      getEvents(isJoined: 1);
    } else if (index == 2 && segmentIndex.value != index) {
      clear();
      // getEvents(userId: _userProfileManager.user.value!.id);
    }

    segmentIndex.value = index;
  }

  getEvents({String? name, int? categoryId, int? status, int? isJoined}) {
    if (canLoadMoreEvents) {
      isLoadingEvents.value = true;
      EventApi.getEvents(
          name: name,
          status: status,
          categoryId: categoryId,
          isJoined: isJoined,
          page: eventsPage,
          resultCallback: (result, metadata) {
            events.addAll(result);
            isLoadingEvents.value = false;

            canLoadMoreEvents = result.length >= metadata.perPage;
            eventsPage += 1;

            update();
          });
    }
  }

  getMembers({int? eventId}) {
    if (canLoadMoreMembers) {
      isLoadingMembers = true;
      EventApi.getEventMembers(
          eventId: eventId,
          page: membersPage,
          resultCallback: (result) {
            members.addAll(result);
            isLoadingMembers = false;

            membersPage += 1;
            // if (response.eventMembers.length == response.metaData?.perPage) {
            //   canLoadMoreMembers = true;
            // } else {
            //   canLoadMoreMembers = false;
            // }
          });

      update();
    }
  }

  getCategories() {
    isLoadingCategories.value = true;
    EventApi.getEventCategories(resultCallback: (result) {
      categories.value =
          result.where((element) => element.events.isNotEmpty).toList();
      isLoadingCategories.value = false;
    });
  }

  joinEvent(EventModel event) {
    events.value = events.map((element) {
      if (element.id == event.id) {
        element.isJoined = true;
      }
      return element;
    }).toList();

    events.refresh();

    EventApi.joinEvent(eventId: event.id);
  }

  leaveEvent(EventModel event) {
    events.value = events.map((element) {
      if (element.id == event.id) {
        element.isJoined = false;
      }
      return element;
    }).toList();

    events.refresh();
    EventApi.leaveEvent(eventId: event.id);
  }
}
