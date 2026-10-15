import 'dart:ui';

import 'package:foap/api_handler/api_wrapper.dart';
import 'package:foap/helper/imports/event_imports.dart';
import '../../helper/enum.dart';
import '../../helper/enum_linking.dart';
import '../../model/api_meta_data.dart';
import '../../model/user_model.dart';
import '../../screens/add_on/model/create_event_model.dart';

class EventApi {
  static getEventCategories(
      {required Function(List<EventCategoryModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.eventsCategories;

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['category'];
        print('items ${items}');
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
      required Function(List<EventModel>, APIMetaData)
          resultCallback}) async {
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

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['event']['items'];
        resultCallback(
            List<EventModel>.from(
                items.map((x) => EventModel.fromJson(x))),
            APIMetaData.fromJson(result.data['event']['_meta']));
      }
    });
  }

  static getEventDetail(
      {required int eventId,
      required Function(EventModel) resultCallback}) async {
    var url = NetworkConstantsUtil.eventDetails;
    url = url.replaceAll('{{id}}', eventId.toString());
    // url = url.replaceAll('{{id}}', '0500978f50ac4f32d883968e9c7fdaf6');

    await ApiWrapper().getApi(url: url).then((result) {
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

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {}
    });
  }

  static getEventCoupons(
      {required int eventId,
      required Function(List<EventCoupon>) resultCallback}) async {
    var url = NetworkConstantsUtil.eventCoupons;

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['coupon'];

        resultCallback(List<EventCoupon>.from(
            items.map((x) => EventCoupon.fromJson(x))));
      }
    });
  }

  static buyTicket(
      {required EventTicketOrderRequest orderRequest,
      required Function(int?) resultCallback}) async {
    var url = NetworkConstantsUtil.buyTicket;
    dynamic param = orderRequest.toJson();

    await ApiWrapper().postApi(url: url, param: param).then((result) {
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
    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['eventBooking']['items'];
        resultCallback(
            List<EventBookingModel>.from(
                items.map((x) => EventBookingModel.fromJson(x))),
            APIMetaData.fromJson(result.data['eventBooking']['_meta']));
      }
    });
  }

  // static joinEvent({
  //   required int eventId,
  // }) async {
  //   var url = NetworkConstantsUtil.joinEvent;
  //
  //   await ApiWrapper().postApi(
  //       url: url, param: {'id': eventId.toString()}).then((result) {
  //     if (result?.success == true) {}
  //   });
  // }
  //
  // static leaveEvent({
  //   required int eventId,
  // }) async {
  //   var url = NetworkConstantsUtil.leaveEvent;
  //
  //   await ApiWrapper().postApi(
  //       url: url, param: {'id': eventId.toString()}).then((result) {
  //     if (result?.success == true) {}
  //   });
  // }

  static giftEventTicket(
      {required int ticketId,
      required int toUserId,
      required Function(bool) resultCallback}) async {
    var url = NetworkConstantsUtil.giftTicket;

    await ApiWrapper().postApi(url: url, param: {
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

    await ApiWrapper().postApi(url: url, param: {
      'id': eventId.toString(),
    }).then((result) {
      if (result?.success == true) {}
    });
  }

  static cancelEventBooking(
      {required int bookingId,
      required Function(bool) resultCallback}) async {
    var url = NetworkConstantsUtil.cancelEventBooking;

    await ApiWrapper().postApi(url: url, param: {
      'id': bookingId.toString(),
    }).then((result) {
      if (result?.success == true) {
        resultCallback(true);
      } else {
        resultCallback(false);
      }
    });
  }

  static getEventBookingDetail(
      {required int bookingId,
      required Function(EventBookingModel) resultCallback}) async {
    var url = NetworkConstantsUtil.eventBookingDetail;
    url =
        '$url$bookingId&expand=payment,event.eventOrganisor,giftedToUser,giftedByUser';

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var item = result!.data['eventBooking'];
        resultCallback(EventBookingModel.fromJson(item));
      }
    });
  }

  static linkTicketToEventBooking(
      {required int bookingId, required String ticketName}) async {
    var url = NetworkConstantsUtil.linkTicketToBooking;

    await ApiWrapper().postApi(url: url, param: {
      'id': bookingId.toString(),
      'image': ticketName,
    }).then((result) {
      if (result?.success == true) {}
    });
  }

  // event creation

  static getMyEvents(
      {String? name,
      int? categoryId,
      int? subCategoryId,
      int? status,
      int? isJoined,
      int page = 1,
      required Function(List<CreateEventModel>, APIMetaData)
          resultCallback}) async {
    var url = NetworkConstantsUtil.myEventsList;
    if (categoryId != null) {
      url = '$url&category_id=$categoryId';
    }
    if (subCategoryId != null) {
      url = '$url&sub_category_id=$subCategoryId';
    }
    if (status != null) {
      url = '$url&current_status=$status';
    }
    if (name != null && name.isNotEmpty) {
      url = '$url&name=$name';
    }

    url = '$url&page=$page';

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['event']['items'];
        resultCallback(
            List<CreateEventModel>.from(
                items.map((x) => CreateEventModel.fromJson(x))),
            APIMetaData.fromJson(result.data['event']['_meta']));
      }
    });
  }

  static createEvent(
      {required CreateEventModel event,
      required Function(int) successCallback,
      required VoidCallback errorCallback}) async {
    var url = NetworkConstantsUtil.createEvent;

    await ApiWrapper()
        .postApi(url: url, param: event.toJson())
        .then((result) {
      if (result?.success == true) {
        successCallback(result!.data['id']);
      } else {
        errorCallback();
      }
    });
  }

  static updateEvent(
      {required CreateEventModel event,
      required Function(int) successCallback,
      required VoidCallback errorCallback}) async {
    var url = '${NetworkConstantsUtil.updateEvent}${event.id}';

    await ApiWrapper()
        .putApi(url: url, param: event.toJson())
        .then((result) {
      if (result?.success == true) {
        successCallback(event.id!);
      } else {
        errorCallback();
      }
    });
  }

  static updateEventStatus(
      {required int eventId,
      required EventStatus status,
      required VoidCallback successHandler}) async {
    var url = NetworkConstantsUtil.updateEventStatus;

    await ApiWrapper().postApi(url: url, param: {
      'id': eventId.toString(),
      'status': eventStatusToId(status),
    }).then((result) {
      if (result?.success == true) {
        successHandler();
      }
    });
  }

  static reactOnEvent(
      {required ReactionOnEvent reaction, required int eventId}) async {
    var url = NetworkConstantsUtil.userReactionOnEvent;

    await ApiWrapper().postApi(url: url, param: {
      'type': 1,
      'reference_id': eventId,
      'reaction': reactionOnEventTypeId(reaction),
    }).then((result) {
      if (result?.success == true) {}
    });
  }

  static getUsersAttendingEvent(
      {required int eventId,
      int page = 1,
      required Function(List<UserModel>, APIMetaData)
          resultCallback}) async {
    var url = NetworkConstantsUtil.usersAttendingEvent;
    url = url.replaceAll('{{event_id}}', eventId.toString());
    url = '$url&page=$page';

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['reactions']['items'];
        resultCallback(
            List<UserModel>.from(items.map((x) => UserModel.fromJson(x['user']))),
            APIMetaData.fromJson(result.data['reactions']['_meta']));
      }
    });
  }
}
