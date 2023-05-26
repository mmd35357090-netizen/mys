import 'package:foap/apiHandler/api_wrapper.dart';
import 'package:foap/helper/imports/event_imports.dart';
import '../../model/api_meta_data.dart';

class EventApi {
  static getEventCategories(
      {required Function(List<EventCategoryModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.eventsCategories;

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['category'];
        resultCallback(List<EventCategoryModel>.from(
            items.map((x) => EventCategoryModel.fromJson(x))));
      }
    });
  }

  static getEvents(
      {String? name,
      int? categoryId,
      int? status,
      int? isJoined,
      int page = 1,
      required Function(List<EventModel>, APIMetaData) resultCallback}) async {
    var url = NetworkConstantsUtil.searchEvents;
    if (categoryId != null) {
      url = '$url&category_id=$categoryId';
    }
    if (status != null) {
      url = '$url&current_status=$status';
    }
    if (name != null && name.isNotEmpty) {
      url = '$url&name=$name';
    }

    url = '$url&page=$page';

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['event']['items'];
          resultCallback(
              List<EventModel>.from(items.map((x) => EventModel.fromJson(x))),
              APIMetaData.fromJson(result.data['event']['_meta']));

      }
    });
  }

  static getEventDetail(
      {required int eventId,
      required Function(EventModel) resultCallback}) async {
    var url = NetworkConstantsUtil.eventDetails;
    url = url.replaceAll('{{id}}', eventId.toString());

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        resultCallback(EventModel.fromJson(result!.data['event']));
      }
    });
  }

  static getEventMembers(
      {int? eventId,
      int page = 1,
      required Function(List<EventMemberModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.eventMembers + eventId.toString();
    url = '$url&page=$page';

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {}
    });
  }

  static getEventCoupons(
      {required int eventId,
      required Function(List<EventCoupon>) resultCallback}) async {
    var url = NetworkConstantsUtil.eventCoupons;

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['coupon'];

        resultCallback(
            List<EventCoupon>.from(items.map((x) => EventCoupon.fromJson(x))));
      }
    });
  }

  static buyTicket(
      {required EventTicketOrderRequest orderRequest,
      required Function(int?) resultCallback}) async {
    var url = NetworkConstantsUtil.buyTicket;
    dynamic param = orderRequest.toJson();

    ApiWrapper().postApi(url: url, param: param).then((result) {
      if (result?.success == true) {
        resultCallback(result!.data['id']);
      } else {
        resultCallback(null);
      }
    });
  }

  static getEventBookings(
      {String? name,
      required int currentStatus,
      int? status,
      int? isJoined,
      int page = 1,
      required Function(List<EventBookingModel>, APIMetaData)
          resultCallback}) async {
    var url = NetworkConstantsUtil.eventBookings;
    url = '$url&current_status=$currentStatus';

    if (name != null && name.isNotEmpty) {
      url = '$url&name=$name';
    }
    url =
        '$url&expand=payment,event,event.eventOrganisor,giftedToUser,giftedByUser';
    url = '$url&page=$page';
    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['eventBooking']['items'];
          resultCallback(
              List<EventBookingModel>.from(
                  items.map((x) => EventBookingModel.fromJson(x))),
              APIMetaData.fromJson(result.data['eventBooking']['_meta']));

      }
    });
  }

  static joinEvent({
    required int eventId,
  }) async {
    var url = NetworkConstantsUtil.joinEvent;

    ApiWrapper()
        .postApi(url: url, param: {'id': eventId.toString()}).then((result) {
      if (result?.success == true) {}
    });
  }

  static leaveEvent({
    required int eventId,
  }) async {
    var url = NetworkConstantsUtil.leaveEvent;

    ApiWrapper()
        .postApi(url: url, param: {'id': eventId.toString()}).then((result) {
      if (result?.success == true) {}
    });
  }

  static giftEventTicket(
      {required int ticketId,
      required int toUserId,
      required Function(bool) resultCallback}) async {
    var url = NetworkConstantsUtil.giftTicket;

    ApiWrapper().postApi(url: url, param: {
      'id': ticketId.toString(),
      'gifted_to': toUserId.toString()
    }).then((result) {
      if (result?.success == true) {
        resultCallback(true);
      } else {
        resultCallback(false);
      }
    });
  }

  static createEventBooking({
    required int eventId,
  }) async {
    var url = NetworkConstantsUtil.eventBookings;

    ApiWrapper().postApi(url: url, param: {
      'id': eventId.toString(),
    }).then((result) {
      if (result?.success == true) {}
    });
  }

  static cancelEventBooking(
      {required int bookingId, required Function(bool) resultCallback}) async {
    var url = NetworkConstantsUtil.cancelEventBooking;

    ApiWrapper().postApi(url: url, param: {
      'id': bookingId.toString(),
    }).then((result) {
      if (result?.success == true) {
        resultCallback(true);
      } else {
        resultCallback(false);
      }
    });
  }
}
