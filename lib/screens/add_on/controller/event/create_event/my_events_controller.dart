import 'dart:ui';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foap/api_handler/apis/events_api.dart';
import 'package:foap/helper/list_extension.dart';
import 'package:get/get.dart';
import 'package:foap/screens/add_on/model/create_event_model.dart';

import '../../../../../helper/enum.dart';
import '../../../../../helper/enum_linking.dart';
import '../../../../../model/data_wrapper.dart';
import '../../../../../model/shop_model/search_model.dart';

class MyEventsController extends GetxController {
  RxList<CreateEventModel> events = <CreateEventModel>[].obs;

  DataWrapper eventsDataWrapper = DataWrapper();

  RxInt selectSegment = 0.obs;

  SearchModel searchModel =
      SearchModel(status: eventStatusToId(EventStatus.active));

  clear() {
    eventsDataWrapper = DataWrapper();
    events.value = [];
    searchModel =
        SearchModel(status: eventStatusToId(EventStatus.active));
  }

  clearSegment() {
    selectSegment.value = 0;
  }

  clearEvents() {
    events.value = [];
    eventsDataWrapper = DataWrapper();
  }

  handleSegmentChange(int index) {
    if (selectSegment.value != index) {
      clear();
      selectSegment.value = index;

      switch (index) {
        case 0:
          setStatus(EventStatus.active);
          break;
        case 1:
          setStatus(EventStatus.upcoming);
          break;
        case 2:
          setStatus(EventStatus.completed);
          break;

      }
      refreshEvents(() {});
    }
  }

  setStatus(EventStatus status) {
    clear();
    searchModel.status = eventStatusToId(status);
    refreshEvents(() {});
  }

  searchEvents(String text) {
    if (searchModel.title != text) {
      clearEvents();
      searchModel.title = text;
      refreshEvents(() {});
    }
  }

  setCategoryId(int categoryId) {
    events.value = [];
    eventsDataWrapper = DataWrapper();
    searchModel.categoryId = categoryId;
    refreshEvents(() {});
  }

  refreshEvents(VoidCallback callback) {
    clearEvents();
    loadEvents(callback);
  }

  loadMoreEvents(VoidCallback callback) async {
    if (eventsDataWrapper.haveMoreData.value) {
      eventsDataWrapper.isLoading.value = true;

      loadEvents(callback);
    } else {
      callback();
    }
  }

  loadEvents(VoidCallback callback) {
    EventApi.getMyEvents(
        name: searchModel.title,
        status: searchModel.status,
        categoryId: searchModel.categoryId,
        subCategoryId: searchModel.subCategoryId,
        page: eventsDataWrapper.page,
        resultCallback: (result, metadata) {
          eventsDataWrapper.processCompletedWithData(metadata);
          events.addAll(result);
          events.unique((e) => e.id);

          update();
        });
  }

  cancelEvent(
      {required int eventId, required VoidCallback successHandler}) {
    EasyLoading.show();
    EventApi.updateEventStatus(
        eventId: eventId,
        status: EventStatus.cancelled,
        successHandler: () {
          EasyLoading.dismiss();
          successHandler();
        });
  }
}
