class Advertisement {
  int id;
  String name;
  String image;
  int startDate;
  int endDate;
  String? video;

  // int adMediaType;

  Advertisement({
    required this.id,
    required this.name,
    required this.image,
    required this.startDate,
    required this.endDate,
    this.video,
  });

  factory Advertisement.fromJson(Map<String, dynamic> json) => Advertisement(
        id: json["id"],

        name: json["name"],
        image: json["imageUrl"],
        startDate: json["start_date"],
        endDate: json["end_date"],
        video: json["video"],
        // adMediaType: json["ad_type"],
      );

  bool isVideoAd() {
    return video != null;
  }
}
