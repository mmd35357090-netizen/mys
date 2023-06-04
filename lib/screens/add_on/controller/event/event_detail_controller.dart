import 'package:foap/apiHandler/apis/events_api.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/event_imports.dart';

class EventDetailController extends GetxController {
  Rx<EventModel?> event = Rx<EventModel?>(null);
  RxList<EventCoupon> coupons = <EventCoupon>[].obs;
  double? minTicketPrice;
  double? maxTicketPrice;

  RxBool isLoading = false.obs;

  setEvent(EventModel eventObj) {
    event.value = eventObj;
    event.refresh();
    eventDetail();
    update();
  }

  eventDetail() {
    isLoading.value = true;
    EventApi.getEventDetail(
        eventId: event.value!.id,
        resultCallback: (result) {
          event.value = result;
          isLoading.value = false;

          List<EventTicketType> ticketTypes = event.value!.tickets;
          ticketTypes.sort((a, b) => a.price.compareTo(b.price));

          if (!event.value!.isFree) {
            minTicketPrice = ticketTypes.first.price;
            maxTicketPrice = ticketTypes.last.price;
          }

          update();
        });
  }

  loadEventCoupons(int eventId) {
    EventApi.getEventCoupons(
        eventId: eventId,
        resultCallback: (result) {
          coupons.value = result;
          update();
        });
  }

  joinEvent() {
    event.value!.isJoined = true;
    event.refresh();
    EventApi.joinEvent(eventId: event.value!.id);
  }

  leaveEvent() {
    event.value!.isJoined = false;
    event.refresh();
    EventApi.leaveEvent(eventId: event.value!.id);
  }
}
