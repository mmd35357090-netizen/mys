import 'package:image_picker/image_picker.dart';
import '../user_model.dart';

class AdModel {
  Location? locations;
  int? id;
  String? statusText;
  int? isFavorite;
  List<String> images = [];
  int? subCategoryId;
  int? brandId;
  UserModel? user;
  int? packageBannerId;
  int? isBannerAd;
  String? price;
  String? currency;
  String? categoryName;
  int featured = 0;
  int? categoryId;
  String? description;
  int? isReported;
  int? status;
  String? title;
  String? subCategoryName;
  int? view;
  int? userId;
  int? createdAt;
  int? isDeal;
  double? dealPrice;
  String? phone;
  String? address;

  late List<XFile> pickedImages = [];

  bool isThirdPartyAds = false;

  AdModel({
    this.id,
    this.locations,
    this.statusText,
    this.isFavorite,
    required this.images,
    this.subCategoryId,
    this.user,
    this.packageBannerId,
    this.isBannerAd,
    this.price,
    this.currency,
    this.categoryName,
    this.featured = 0,
    this.categoryId,
    this.description,
    this.isReported,
    this.status,
    this.title,
    this.subCategoryName,
    this.view,
    this.userId,
    this.createdAt,
    this.isDeal,
    this.dealPrice,
    this.phone,
  });

  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      locations: json["locations"] == null
          ? null
          : Location?.fromJson(json["locations"]),
      id: json["id"],
      statusText: json["status_text"],
      isFavorite: json["is_favorite"] ?? 1,
      images: json["images"] == null
          ? []
          : List<String>.from(json["images"].map((x) => x)),
      subCategoryId: json["sub_category_id"],
      user: json["user"] == null ? null : UserModel?.fromJson(json["user"]),
      packageBannerId: json["package_banner_id"],
      isBannerAd: json["is_banner_ad"],
      price: json["price"],
      currency: json["currency"],
      categoryName: json["cateogry_name"],
      featured: json["featured"],
      categoryId: json["category_id"],
      description: json["description"],
      isReported: json["is_reported"],
      status: json["status"],
      title: json["title"],
      subCategoryName: json["sub_cateogry_name"],
      view: json["view"],
      userId: json["user_id"],
      createdAt: json["created_at"],
      isDeal: json["is_deal"],
      dealPrice: json["deal_price"],
      phone: json["phone"],
    );
  }

  Map<String, dynamic> toJson() => {
        "category_id": categoryId,
        "sub_category_id": subCategoryId,
        "title": title,
        "description": description,
        "price": price,
        "locations": [
          {
            "country_id": "0",
            "country_name": "",
            "state_name": "",
            "state_id": "0",
            "city_id": "0",
            "city_name": "",
            "latitude": "",
            "longitude": "",
            "custom_location": address
          }
        ],
        "images": List<dynamic>.from((images).map((x) => x.split('/').last)),
        "phone": phone,
        "featured": featured.toString() ,
        "currency": currency,
      };

  bool canEdit() {
    if (statusText == "Active" || statusText == "Pending") {
      return true;
    }
    return false;
  }

  double get priceDoubleValue {
    return double.parse(price!);
  }

  String get actualPriceString {
    return '\$ $price';
  }

  String get dealPriceString {
    // return (currency ?? '\$') + ' ' + dealPrice.toString();
    return '\$ $dealPrice';
  }

  String get finalPriceString {
    if (isDeal != 1) {
      return '${currency ?? '\$'} $price';
    } else {
      return '${currency ?? '\$'} $dealPrice';
    }
  }

  bool get isSold {
    return status == 4;
  }

  bool get isDeleted {
    return status == 0;
  }
}

class Location {
  Location({
    this.id,
    this.countryId,
    this.stateId,
    this.countryName,
    this.longitude,
    this.customLocation,
    this.userId,
    this.type,
    this.stateName,
    this.cityId,
    this.latitude,
    this.createdAt,
    this.cityName,
    this.adId,
    this.status,
  });

  int? id;
  int? countryId;
  int? stateId;
  String? countryName;
  String? longitude;
  String? customLocation;
  int? userId;
  int? type;
  String? stateName;
  int? cityId;
  String? latitude;
  int? createdAt;
  String? cityName;
  int? adId;
  int? status;

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        id: json["id"],
        countryId: json["country_id"],
        stateId: json["state_id"],
        countryName: json["country_name"],
        longitude: json["longitude"],
        customLocation: json["custom_location"],
        userId: json["user_id"],
        type: json["type"],
        stateName: json["state_name"],
        cityId: json["city_id"],
        latitude: json["latitude"],
        createdAt: json["created_at"],
        cityName: json["city_name"],
        adId: json["ad_id"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "country_id": countryId,
        "state_id": stateId,
        "country_name": countryName,
        "longitude": longitude,
        "custom_location": customLocation,
        "user_id": userId,
        "type": type,
        "state_name": stateName,
        "city_id": cityId,
        "latitude": latitude,
        "created_at": createdAt,
        "city_name": cityName,
        "ad_id": adId,
        "status": status,
      };
}
