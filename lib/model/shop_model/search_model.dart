class LocationModel {
  String? address;
  String? latitude;
  String? longitude;

  LocationModel();
}

class SearchModel {
  String? title;
  int? userId;
  int? categoryId;
  int? subCategoryId;
  int? cityId;
  int? status = 10;

  double? minPrice;
  double? maxPrice;

  int? isDeal;
  int? isFeatured;
  int? bannerId;
  int? isVerified;

  SearchModel(
      {this.title,
      this.userId,
      this.categoryId,
      this.subCategoryId,
      this.cityId,
      this.minPrice,
      this.maxPrice,
      this.isDeal,
      this.isFeatured,
      this.isVerified,
      this.bannerId,
      this.status});

  Map<String, dynamic> toJson() => {
        "title": title ?? '',
        "user_id": userId ?? '',
        "category_id": categoryId ?? '',
        "sub_category_id": subCategoryId ?? '',
        "city_id": cityId ?? '',
        "min_price": minPrice ?? '',
        "max_price": maxPrice ?? '',
        "isDeal": isDeal ?? '',
        "featured": isFeatured ?? '',
        "isVerified": isVerified ?? '',
        "package_banner_id": bannerId ?? '',
        "status": status ?? '',
      };
}
