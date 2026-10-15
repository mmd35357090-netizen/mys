import 'package:foap/helper/enum.dart';
import 'package:foap/helper/enum_linking.dart';
import 'package:foap/model/post_promotion_model.dart';
import 'package:foap/model/user_model.dart';
import 'package:foap/util/app_util.dart';
import 'package:intl/intl.dart';

class EventModel {
  int id;
  String name;
  int categoryId;
  String image;
  int startDate;
  int endDate;
  String placeName;
  String completeAddress;
  String latitude;
  String longitude;
  String disclaimer;
  String description;

  int createdAt;
  int status;
  int eventCurrentStatus;

  int createdBy;
  int? updatedAt;
  int? updatedBy;
  bool isFree;
  List<String> gallery;

  ReactionOnEvent reaction;
  int totalMembers;
  bool isFavourite;
  bool isTicketBooked;

  List<EventOrganizer> organizers;
  List<EventTicketType> tickets;
  bool isCompleted;

  String? shareLink;
  UserModel createdByUser;

  EventModel(
      {required this.id,
      required this.name,
      required this.categoryId,
      required this.image,
      required this.startDate,
      required this.endDate,
      required this.placeName,
      required this.completeAddress,
      required this.latitude,
      required this.longitude,
      required this.disclaimer,
      required this.description,
      required this.createdAt,
      required this.status,
      required this.createdBy,
      required this.updatedAt,
      required this.updatedBy,
      required this.gallery,
      required this.isFree,
      required this.reaction,
      required this.totalMembers,
      required this.isFavourite,
      required this.tickets,
      required this.organizers,
      required this.eventCurrentStatus,
      required this.isTicketBooked,
      required this.isCompleted,
      required this.createdByUser,
      this.shareLink});

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        id: json["id"],
        name: json["name"],
        categoryId: json["category_id"],
        image: json["imageUrl"],
        startDate: json["start_date"],
        endDate: json["end_date"],
        placeName: json["place_name"],
        completeAddress: json["address"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        disclaimer: json["disclaimer"],
        description: json["description"],
        status: json["status"],
        eventCurrentStatus: json["eventCurrentStatus"],
        isFree: json["is_paid"] == 0,
        isTicketBooked: json["is_ticket_booked"] == 1,
        isCompleted: json["eventCurrentStatus"] == 3 ||
            json["eventCurrentStatus"] == 4,
        createdAt: json["created_at"],
        createdBy: json["created_by"],
        updatedAt: json["updated_at"],
        updatedBy: json["updated_by"],
        gallery: json["eventGallaryImages"] == null
            ? []
            : (json["eventGallaryImages"] as List<dynamic>)
                .map((e) => e.toString())
                .toList(),
        organizers: json["eventOrganisor"] != null
            ? [EventOrganizer.fromJson(json["eventOrganisor"])]
            : [],
        createdByUser: UserModel.fromJson(json["createdByUser"]),
        tickets: json["eventTicket"] == null
            ? []
            : (json["eventTicket"] as List<dynamic>)
                .map((e) => EventTicketType.fromJson(e))
                .where((e) => e.availableTicket > 0)
                .toList(),
        isFavourite: json["isFavourite"] == 1,
        totalMembers: json["totalReaction"] ?? 0,
        reaction: reactionOnEventType(json["isReact"] ?? 0),
        shareLink: json["share_link"],
      );

  EventStatus get statusType {
    switch (eventCurrentStatus) {
      case 1:
        return EventStatus.upcoming;
      case 2:
        return EventStatus.active;
      case 3:
        return EventStatus.completed;
      case 4:
        return EventStatus.completed;
    }
    return EventStatus.upcoming;
  }

  bool get ticketsAdded {
    List<EventTicketType> ticketTypes = tickets
        .where((element) =>
            element.availableTicket > 0 && element.status == 10)
        .toList();
    return ticketTypes.isNotEmpty;
  }

  bool get isSoldOut {
    List<EventTicketType> ticketTypes = tickets
        .where((element) => element.availableTicket > 0)
        .toList();
    return ticketTypes.isEmpty;
  }

  String get startAtDate {
    DateTime callStartTime = AppUtil.convertToDateTime(startDate);

    return DateFormat('dd-MMM-yyyy').format(callStartTime);
  }

  String get endAtDate {
    DateTime callStartTime =
        DateTime.fromMillisecondsSinceEpoch(endDate * 1000);

    return DateFormat('dd-MMM-yyyy').format(callStartTime);
  }

  String get startAtFullDate {
    DateTime callStartTime =
        DateTime.fromMillisecondsSinceEpoch(startDate * 1000);

    return DateFormat('EEE, dd-MMM-yyyy').format(callStartTime);
  }

  String get endAtFullDate {
    DateTime callStartTime =
        DateTime.fromMillisecondsSinceEpoch(endDate * 1000);

    return DateFormat('dd-MMM-yyyy').format(callStartTime);
  }

  String get startAtDateTime {
    DateTime callStartTime =
        DateTime.fromMillisecondsSinceEpoch(startDate * 1000);

    return DateFormat('dd-MM-yyyy hh:mm a').format(callStartTime);
  }

  String get endAtDateTime {
    DateTime callStartTime =
        DateTime.fromMillisecondsSinceEpoch(endDate * 1000);

    return DateFormat('dd-MM-yyyy hh:mm a').format(callStartTime);
  }

  String get startAtTime {
    DateTime callStartTime =
        DateTime.fromMillisecondsSinceEpoch(startDate * 1000);

    return DateFormat('hh:mm a').format(callStartTime);
  }

  String get endAtTime {
    DateTime callStartTime =
        DateTime.fromMillisecondsSinceEpoch(endDate * 1000);

    return DateFormat('hh:mm a').format(callStartTime);
  }

  double? get minTicketPrice {
    tickets.sort((a, b) => a.price.compareTo(b.price));

    if (tickets.isNotEmpty) {
      return tickets.first.price;
    } else {
      return null;
    }
  }

  double? get maxTicketPrice {
    tickets.sort((a, b) => a.price.compareTo(b.price));

    if (tickets.isNotEmpty) {
      return tickets.last.price;
    } else {
      return null;
    }
  }
}

class EventTicketType {
  int id;
  int eventId;
  String name;
  double price;
  int limit;
  int availableTicket;
  int status;

  EventTicketType({
    required this.id,
    required this.eventId,
    required this.name,
    required this.price,
    required this.limit,
    required this.availableTicket,
    required this.status,
  });

  factory EventTicketType.fromJson(Map<String, dynamic> json) =>
      EventTicketType(
        id: json["id"],
        eventId: json["event_id"],
        name: json["ticket_type"],
        price: double.parse(json["price"].toString()),
        limit: json["limit"],
        availableTicket: json["available_ticket"],
        status: json["status"],
      );
}

class EventOrganizer {
  int id;
  String name;
  String image;

  EventOrganizer({
    required this.id,
    required this.name,
    required this.image,
  });

  factory EventOrganizer.fromJson(Map<String, dynamic> json) =>
      EventOrganizer(
        id: json["id"],
        name: json["name"],
        image: json["campaginImage"],
      );
}

class EventCoupon {
  int id;
  String title;
  String subTitle;

  String code;
  double minimumOrderPrice;
  String image;
  double discount;

  EventCoupon({
    required this.id,
    required this.title,
    required this.subTitle,
    required this.code,
    required this.minimumOrderPrice,
    required this.image,
    required this.discount,
  });

  factory EventCoupon.fromJson(Map<String, dynamic> json) => EventCoupon(
        id: json["id"],
        title: json["title"],
        subTitle: json["subtitle"],
        code: json["code"],
        minimumOrderPrice:
            double.parse(json["minimum_order_price"].toString()),
        image: json["imageUrl"],
        discount: double.parse(json["coupon_value"].toString()),
      );
}

class EventTicketOrderRequest {
  int? eventId;
  int? eventTicketTypeId;
  int? qty;

  String? coupon;
  double? discount;
  double? ticketAmount;
  double? amountToBePaid;
  String? itemName;

  List<Payment> payments;
  UserModel? gifToUser;

  EventTicketOrderRequest({
    this.eventId,
    this.eventTicketTypeId,
    this.qty,
    this.coupon,
    this.discount,
    this.ticketAmount,
    this.itemName,
    this.gifToUser,
    required this.payments,
  });

  Map<String, dynamic> toJson() => {
        "event_id": eventId.toString(),
        "event_ticket_id": eventTicketTypeId.toString(),
        "ticket_qty": qty.toString(),
        "coupon": coupon,
        "coupon_discount_value":
            discount == null || discount == 0 ? 0 : discount,
        "ticket_amount": ticketAmount,
        "paid_amount": paidAmount,
        "payments": payments.map((e) => e.toJson()).toList(),
      };

  double get paidAmount {
    return payments.fold(0, (total, payment) {
      if (payment.amount != null) {
        return (total) + (double.tryParse(payment.amount!) ?? 0);
      } else {
        return total;
      }
    });
  }
}
