class BusinessModel {
  int id;
  String name;
  String description;
  String coverImage;
  String? openTime;
  String? closeTime;
  int? priceRangeFrom;
  int? priceRangeTo;
  String address;
  String city;
  String latitude;
  String longitude;
  String phone;
  int totalCoupons;
  List<String> allImages;
  bool isFavourite;

  BusinessModel({
    required this.id,
    required this.name,
    required this.description,
    required this.coverImage,
    required this.openTime,
    required this.closeTime,
    required this.priceRangeFrom,
    required this.priceRangeTo,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.totalCoupons,
    required this.allImages,
    required this.isFavourite,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) => BusinessModel(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        coverImage: json["imageUrl"] ?? '',
        openTime: json["open_time"] ?? '',
        closeTime: json["close_time"] ?? '',
        priceRangeFrom: json["price_range_from"] ?? 0,
        priceRangeTo: json["price_range_to"] ?? 0,
        address: json["address"] ?? '',
        city: json["city"] ?? '',
        latitude: json["latitude"] ?? '',
        longitude: json["longitude"] ?? '',
        phone: json["phone"] ?? '',
        totalCoupons: json["total_coupon"] ?? 0,
        allImages: json["allImage"] ?? [],
        isFavourite: json["is_favorite"] == 1,
      );
}

class BusinessSearchModel {
  int? categoryId;
  String? name;
}
