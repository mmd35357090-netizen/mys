class PromoBannerModel {
  int id;
  String name;
  String fee;
  int status;
  String inAppId;
  String image;

  PromoBannerModel({
    required this.id,
    required this.name,
    required this.fee,
    required this.inAppId,
    required this.image,
    required this.status,

  });

  factory PromoBannerModel.fromJson(Map<String, dynamic> json) =>
      PromoBannerModel(
        id: json["id"],
        name: json["name"],
        fee: json["ad_fee"],
        inAppId: json["in_app_purchase_id_ios"],
        image: json["imageUrl"],
        status: json["status"],
      );
}
