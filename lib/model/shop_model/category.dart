class ShopCategoryModel {
  int id;
  String name;
  String? picture;
  List<ShopCategoryModel>? subCategories = [];

  ShopCategoryModel(
      {required this.id,
      required this.name,
      required this.picture,
      required this.subCategories});

  factory ShopCategoryModel.fromJson(Map<String, dynamic> json) => ShopCategoryModel(
        id: json["id"],
        name: json["name"],
        picture: json["imageUrl"],
        subCategories: json["subCategory"] == null
            ? []
            : (json["subCategory"] as List<dynamic>)
                .map((e) => ShopCategoryModel.fromJson(e))
                .toList(),
      );
}
//
// class SubCategoryModel extends CategoryModel{
//   int id;
//   String name;
//
//   SubCategoryModel({
//     required this.id,
//     required this.name,
//   });
//
//   factory SubCategoryModel.fromJson(Map<String, dynamic> json) =>
//       SubCategoryModel(
//           id: json["id"] == null ? null : json["id"],
//           name: json["name"] == null ? null : json["name"]);
// }
