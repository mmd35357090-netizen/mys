import 'dart:ui';
import 'package:foap/api_handler/apis/events_api.dart';
import 'package:foap/api_handler/apis/post_api.dart';
import 'package:foap/helper/enum.dart';
import 'package:foap/helper/list_extension.dart';
import 'package:foap/model/post_model.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/event_imports.dart';
import '../../../../model/data_wrapper.dart';

class EventDetailController extends GetxController {
  final CheckoutController _checkoutController = Get.find();
  Rx<EventModel?> event = Rx<EventModel?>(null);
  RxList<PostModel> posts = <PostModel>[].obs;

  RxList<EventCoupon> coupons = <EventCoupon>[].obs;

  RxBool isLoading = false.obs;
  DataWrapper postDataWrapper = DataWrapper();

  clear() {
    postDataWrapper = DataWrapper();
    posts.clear();
  }

  setEvent(EventModel eventObj) {
    event.value = eventObj;
    event.refresh();
    eventDetail();
    update();

    refreshPosts(id: eventObj.id, callback: () {});
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
    event.value!.reaction = ReactionOnEvent.interested;
    event.refresh();
    EventApi.reactOnEvent(
        reaction: ReactionOnEvent.interested, eventId: event.value!.id);
  }

  leaveEvent() {
    event.value!.reaction = ReactionOnEvent.notInterested;
    event.refresh();
    EventApi.reactOnEvent(
        reaction: ReactionOnEvent.notInterested, eventId: event.value!.id);
  }

  buyEventTicket(EventTicketOrderRequest ticketOrder) {
    EventApi.buyTicket(
        orderRequest: ticketOrder,
        resultCallback: (bookingId) {
          if (bookingId != null) {
            _checkoutController.orderPlaced();

            if (ticketOrder.gifToUser != null) {
              EventApi.giftEventTicket(
                  ticketId: bookingId,
                  toUserId: ticketOrder.gifToUser!.id,
                  resultCallback: (status) {});
            }
            Future.delayed(const Duration(seconds: 2), () {
              EventApi.getEventBookingDetail(
                  bookingId: bookingId,
                  resultCallback: (booking) {
                    Get.to(() => ETicket(
                          booking: booking,
                          autoSendTicket: true,
                        ));
                  });
            });
          } else if (bookingId == null) {
            _checkoutController.orderFailed();
          }
        });
  }

  refreshPosts({required int id, required VoidCallback callback}) {
    postDataWrapper = DataWrapper();
    getPosts(id: id, callback: callback);
  }

  loadMorePosts({required int id, required VoidCallback callback}) {
    if (postDataWrapper.haveMoreData.value == true) {
      if (postDataWrapper.page == 1) {
        postDataWrapper.isLoading.value = true;
      }
      getPosts(id: id, callback: callback);
    } else {
      callback();
    }
  }

  void getPosts({required int id, required VoidCallback callback}) async {
    PostApi.getPosts(
        postType: PostCategory.event,
        eventId: id,
        page: postDataWrapper.page,
        resultCallback: (result, metadata) {
          posts.addAll(result);
          posts.sort((a, b) => b.createDate!.compareTo(a.createDate!));
          posts.unique((e) => e.id);

          postDataWrapper.processCompletedWithData(metadata);

          callback();
          update();
        });
  }
}
