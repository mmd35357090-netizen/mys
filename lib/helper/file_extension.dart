import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:foap/helper/enum.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../screens/chat/media.dart';
import '../util/constant_util.dart';

extension FileCompressor on File {
  Future<Uint8List> compress(
      {int? byQuality, int? minWidth, int? minHeight}) async {
    var result = await FlutterImageCompress.compressWithFile(
      absolute.path,
      minWidth: minWidth ?? 1000,
      minHeight: minHeight ?? 1000,
      quality: byQuality ?? 60,
      rotate: 0,
    );

    return result!;
  }
}

extension FileExtension on File {
  GalleryMediaType get mediaType {
    // Extract file extension
    final String extension = path.split('.').last.toLowerCase();

    switch (extension) {
      case 'png':
      case 'jpg':
      case 'jpeg':
        return GalleryMediaType.photo;

      case 'mp4':
      case 'mpeg':
        return GalleryMediaType.video;

      case 'mp3':
      case 'wav':
      case 'aac':
        return GalleryMediaType.audio;

      case 'pdf':
        return GalleryMediaType.pdf;

      case 'doc':
      case 'dot':
      case 'docx':
      case 'dotx':
        return GalleryMediaType.doc;

      case 'xls':
      case 'xlsx':
      case 'csv':
        return GalleryMediaType.xls;

      case 'ppt':
      case 'pptx':
        return GalleryMediaType.ppt;

      case 'txt':
        return GalleryMediaType.txt;

      default:
        return GalleryMediaType.photo; // Default to photo if unknown
    }
  }

  String get extension {
    final path = this.path;
    final index = path.lastIndexOf('.');

    if (index == -1 || index == path.length - 1) {
      return ''; // No extension found or dot is last character
    }

    return path.substring(index + 1).toLowerCase();
  }
}

extension XFileExtension on XFile {
  Future<Media> toMedia(GalleryMediaType mediaType) async {
    Media media = Media();
    media.mediaType = mediaType;
    media.file = File(path);
    media.mainFileBytes = await readAsBytes();
    media.title = name;
    if (mediaType == GalleryMediaType.video) {
      media.thumbnail = await VideoThumbnail.thumbnailData(
        video: path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 500,
        quality: 25,
      );
    }

    media.id = randomId();
    return media;
  }
}
