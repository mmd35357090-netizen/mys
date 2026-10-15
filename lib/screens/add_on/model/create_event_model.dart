import 'package:foap/helper/enum.dart';
import 'package:intl/intl.dart';
import '../../../model/category_model.dart';

String eventDateTimeFormat = "yyyy-MM-dd hh:mm a";
String eventDateFullFormat = "EEE, yyyy-MM-dd";
String eventDateFormat = "yyyy-MM-dd";

class CreateEventModel {
  int? id;
  String? name;
  int? categoryId;
  int? subCategoryId;
  String? imageName;
  String? image;
  int? startDateInMillisecond;
  int? endDateInMillisecond;
  String? placeName;
  String? completeAddress;
  String? latitude;
  String? longitude;
  String? disclaimer;
  String? description;

  int? createdAt;
  int? status;
  int? eventCurrentStatus;

  int? createdBy;
  int? updatedAt;
  int? updatedBy;
  bool? isFree;

  List<String> gallery;
  List<String> galleryImageName;

  bool? isJoined;
  int? totalMembers;
  bool? isFavourite;

  bool? isCompleted;
  CategoryModel? category;
  CategoryModel? subCategory;

  CreateEventModel({
    this.id,
    this.name,
    this.categoryId,
    this.subCategoryId,
    this.image,
    this.startDateInMillisecond,
    this.endDateInMillisecond,
    this.placeName,
    this.completeAddress,
    this.latitude,
    this.longitude,
    this.disclaimer,
    this.description,
    this.createdAt,
    this.status,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    required this.gallery,
    required this.galleryImageName,
    this.isFree,
    this.isJoined,
    this.totalMembers,
    this.isFavourite,
    this.eventCurrentStatus,
    this.isCompleted,
  });

  factory CreateEventModel.fromJson(Map<String, dynamic> json) =>
      CreateEventModel(
        id: json["id"],
        name: json["name"],
        categoryId: json["category_id"],
        subCategoryId: json["sub_category_id"],
        image: json["imageUrl"],
        startDateInMillisecond:
            json["start_date"] == null ? 0 : json["start_date"] * 1000,
        endDateInMillisecond:
            json["end_date"] == null ? 0 : json["end_date"] * 1000,
        placeName: json["place_name"],
        completeAddress: json["address"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        disclaimer: json["disclaimer"],
        description: json["description"],
        status: json["status"],
        eventCurrentStatus: json["eventCurrentStatus"],
        isFree: json["is_paid"] == 0,
        isCompleted: json["eventCurrentStatus"] == 3 ||
            json["eventCurrentStatus"] == 4,
        createdAt: json["created_at"],
        createdBy: json["created_by"],
        updatedAt: json["updated_at"],
        updatedBy: json["updated_by"],
        gallery: List<String>.from(json["eventGallaryImages"]),
        isFavourite: json["isFavourite"] == 1,
        totalMembers: json["totalReaction"] ?? 0,
        isJoined: json["isJoined"] == 1,
        galleryImageName: List<String>.from(json["eventGallaryImages"])
            .map((x) => Uri.parse(x).fileName)
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "category_id": category?.id ?? categoryId,
        "sub_category_id": subCategory?.id ?? subCategoryId,
        "start_date": startAtDateTimeString,
        "end_date": endAtDateTimeString,
        "is_paid": isFree == true || isFree == null ? "0" : "1",
        "place_name": placeName,
        "address": completeAddress,
        "latitude": latitude,
        "longitude": longitude,
        "imageFile": imageName,
        "gallaryFile": galleryImageName.join(','),
        "description": description,
        "disclaimer": disclaimer
      };

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

  String? get startAtDateString {
    if (startDate == null) {
      return null;
    }
    return DateFormat(eventDateFormat).format(startDate!);
  }

  String? get endAtDateString {
    if (endDate == null) {
      return null;
    }
    return DateFormat(eventDateFormat).format(endDate!);
  }

  String? get startAtFullDateSting {
    if (startDate == null) {
      return null;
    }
    return DateFormat(eventDateFullFormat).format(startDate!);
  }

  String? get endAtFullDateString {
    if (endDate == null) {
      return null;
    }
    return DateFormat(eventDateFullFormat).format(endDate!);
  }

  String? get startAtDateTimeString {
    if (startDate == null) {
      return null;
    }
    return DateFormat(eventDateTimeFormat).format(startDate!);
  }

  String? get endAtDateTimeString {
    if (endDate == null) {
      return null;
    }
    return DateFormat(eventDateTimeFormat).format(endDate!);
  }

  String? get startAtTimeString {
    if (startDate == null) {
      return null;
    }
    return DateFormat('hh:mm a').format(startDate!);
  }

  String? get endAtTimeString {
    if (endDate == null) {
      return null;
    }
    return DateFormat('hh:mm a').format(endDate!);
  }

  DateTime? get startDate {
    if (startDateInMillisecond == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(startDateInMillisecond!);
  }

  DateTime? get endDate {
    if (endDateInMillisecond == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(endDateInMillisecond!);
  }
}

extension UriExtensions on Uri {
  String get fileName {
    // Get the path from the URL
    String path = this.path;

    // Extract the file name from the path
    return path.split('/').last;
  }
}
