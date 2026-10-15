class OfferModel {
  int id;
  String name;
  String description;
  String code;
  DateTime startDate;
  DateTime endDate;

  String coverImage;
  bool isFavourite;

  OfferModel({
    required this.id,
    required this.name,
    required this.description,
    required this.code,
    required this.startDate,
    required this.endDate,
    required this.coverImage,
    required this.isFavourite,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) => OfferModel(
        name: json["name"],
        id: json["id"],
        coverImage: json["imageUrl"] ?? '',
        code: json["code"] ?? '',
        description: json["description"] ?? '',
        startDate:
            DateTime.fromMillisecondsSinceEpoch(json['start_date'] * 1000),
        endDate:
            DateTime.fromMillisecondsSinceEpoch(json['expiry_date'] * 1000),
        isFavourite: json["is_favorite"] == 1,
      );
}

class OfferSearchModel {
  int? businessId;
  int? categoryId;
  String? name;
}
