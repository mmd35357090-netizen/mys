import '../../../model/category_model.dart';
import 'event_model.dart';

class EventCategoryModel extends CategoryModel {
  List<EventModel> events = [];

  EventCategoryModel({
    required super.name,
    required super.id,
    required super.coverImage,
    required this.events,
  });

  factory EventCategoryModel.fromJson(Map<String, dynamic> json) {
    EventCategoryModel category = EventCategoryModel(
      name: json["name"],
      id: json["id"],
      coverImage: json["imageUrl"],
      events: json["event"] == null
          ? []
          : (json["event"] as List<dynamic>)
          .map((e) => EventModel.fromJson(e))
          .toList(),
    );


    return category;
  }
}
