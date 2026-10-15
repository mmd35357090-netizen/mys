class UploadedGalleryMedia {
  int mediaType;
  String? thumbnail;
  String? video;
  String? audio;
  String? file;

  UploadedGalleryMedia(
      {required this.thumbnail,
      required this.mediaType,
      required this.video,
      required this.audio,
      required this.file});
}
