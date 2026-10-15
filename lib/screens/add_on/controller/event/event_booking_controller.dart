import 'package:foap/api_handler/apis/events_api.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/event_imports.dart';

class EventBookingsController extends GetxController {
  RxList<EventBookingModel> upcomingBookings = <EventBookingModel>[].obs;
  RxList<EventBookingModel> completedBookings = <EventBookingModel>[].obs;
  RxList<EventBookingModel> cancelledBookings = <EventBookingModel>[].obs;

  RxInt selectedSegment = (-1).obs;
  RxBool isLoading = false.obs;

  int upcomingBookingsPage = 1;
  bool canLoadMoreUpcomingBookings = true;

  int completedBookingsPage = 1;
  bool canLoadMoreCompletedBookings = true;

  int cancelledBookingsPage = 1;
  bool canLoadMoreCancelledBookings = true;

  clear() {
    // selectedSegment.value = -1;

    upcomingBookings.clear();
    completedBookings.clear();
    cancelledBookings.clear();
    upcomingBookingsPage = 1;
    canLoadMoreUpcomingBookings = true;
    completedBookingsPage = 1;
    canLoadMoreCompletedBookings = true;
    cancelledBookingsPage = 1;
    canLoadMoreCancelledBookings = true;
  }

  reload() {
    clear();
    loadData(selectedSegment.value);
  }

  loadData(int segment) {
    switch (segment) {
      case 0:
        getUpcomingBookings();
        break;
      case 1:
        getCompletedBookings();
        break;
      case 2:
        getCancelledBookings();
        break;
    }
    selectedSegment.value = segment;
    update();
  }

  changeSegment(int segment) {
    if (selectedSegment.value == segment) {
      return;
    }
    loadData(segment);
  }

  getCompletedBookings() {
    if (isLoading.value == true) {
      return;
    }
    //upcoming = 1, COMPLETED = 3, CANCELLED = 4
    if (canLoadMoreCompletedBookings) {
      isLoading.value = true;

      EventApi.getEventBookings(
          currentStatus: 3,
          resultCallback: (result, metadata) {
            completedBookings.addAll(result);
            isLoading.value = false;

            completedBookingsPage += 1;
            canLoadMoreCompletedBookings = result.length >= metadata.perPage;

            update();
          });
    }
  }

  getUpcomingBookings() {
    if (isLoading.value == true) {
      return;
    }
    //upcoming = 1, COMPLETED = 3, CANCELLED = 4
    if (canLoadMoreUpcomingBookings) {
      isLoading.value = true;

      EventApi.getEventBookings(
          currentStatus: 1,
          resultCallback: (result, metadata) {
            upcomingBookings.addAll(result);
            isLoading.value = false;

            upcomingBookingsPage += 1;
            canLoadMoreUpcomingBookings = result.length >= metadata.perPage;

            update();
          });
    }
  }

  getCancelledBookings() {
    if (isLoading.value == true) {
      return;
    }

    //upcoming = 1, COMPLETED = 3, CANCELLED = 4
    if (canLoadMoreCancelledBookings) {
      isLoading.value = true;

      EventApi.getEventBookings(
          currentStatus: 4,
          resultCallback: (result, metadata) {
            cancelledBookings.addAll(result);
            isLoading.value = false;

            cancelledBookingsPage += 1;
            canLoadMoreCancelledBookings = result.length >= metadata.perPage;

            update();
          });
    }
  }

  getBookingDetail(
      {required int bookingId,
        required Function(EventBookingModel) successCallback}) {
    EventApi.getEventBookingDetail(
        bookingId: bookingId,
        resultCallback: (result) {
          successCallback(result);
        });
  }
}
