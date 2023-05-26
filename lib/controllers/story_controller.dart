import 'package:foap/apiHandler/apis/misc_api.dart';
import 'package:foap/apiHandler/apis/post_api.dart';
import 'package:foap/apiHandler/apis/story_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:async';
import 'package:foap/manager/db_manager.dart';
import 'package:foap/apiHandler/api_controller.dart';
import 'package:foap/components/custom_gallery_picker.dart';
import 'package:foap/model/story_model.dart';
import 'package:foap/screens/dashboard/dashboard_screen.dart';
import 'package:foap/screens/chat/media.dart';
import 'package:path_provider/path_provider.dart';

class AppStoryController extends GetxController {
  RxList<Media> mediaList = <Media>[].obs;
  RxBool allowMultipleSelection = false.obs;
  RxInt numberOfItems = 0.obs;

  Rx<StoryMediaModel?> storyMediaModel = Rx<StoryMediaModel?>(null);
  bool isLoading = false;

  mediaSelected(List<Media> media) {
    mediaList.value = media;
  }

  toggleMultiSelectionMode() {
    allowMultipleSelection.value = !allowMultipleSelection.value;
    update();
  }

  deleteStory(VoidCallback callback) {
    StoryApi.deleteStory(id: storyMediaModel.value!.id, callback: callback);
  }

  setCurrentStoryMedia(StoryMediaModel storyMedia) {
    storyMediaModel.value = storyMedia;
    getIt<DBManager>().storyViewed(storyMedia);
    update();
  }

  void uploadAllMedia(
      {required List<Media> items}) async {
    var responses =
        await Future.wait([for (Media media in items) uploadMedia(media)])
            .whenComplete(() {});

    publishAction(galleryItems: responses);
  }

  Future<Map<String, String>> uploadMedia(Media media) async {
    Map<String, String> gallery = {};
    final completer = Completer<Map<String, String>>();

    final tempDir = await getTemporaryDirectory();
    File mainFile;
    String? videoThumbnailPath;

    if (media.mediaType == GalleryMediaType.photo) {
      Uint8List mainFileData = await media.file!.compress();
      //image media
      mainFile =
          await File('${tempDir.path}/${media.id!.replaceAll('/', '')}.png')
              .create();
      mainFile.writeAsBytesSync(mainFileData);
    } else {
      Uint8List mainFileData = media.file!.readAsBytesSync();
      // video
      mainFile =
          await File('${tempDir.path}/${media.id!.replaceAll('/', '')}.mp4')
              .create();
      mainFile.writeAsBytesSync(mainFileData);

      File videoThumbnail = await File(
              '${tempDir.path}/${media.id!.replaceAll('/', '')}_thumbnail.png')
          .create();

      videoThumbnail.writeAsBytesSync(media.thumbnail!);

      await MiscApi.uploadFile(videoThumbnail.path,
          type: UploadMediaType.storyOrHighlights,
          resultCallback: (fileName, filePath) async {
        videoThumbnailPath = fileName;
        await videoThumbnail.delete();
      });
    }

    EasyLoading.show(status: loadingString.tr);

    await MiscApi.uploadFile(mainFile.path,
        type: UploadMediaType.storyOrHighlights,
        resultCallback: (fileName, filePath) async {
      String mainFileUploadedPath = fileName;
      await mainFile.delete();
      gallery = {
        // 'image': media.mediaType == 1 ? mainFileUploadedPath : '',
        'image': media.mediaType == GalleryMediaType.photo
            ? mainFileUploadedPath
            : videoThumbnailPath!,
        'video': media.mediaType == GalleryMediaType.photo
            ? ''
            : mainFileUploadedPath,
        'type': media.mediaType == GalleryMediaType.photo ? '2' : '3',
        'description': '',
        'background_color': '',
      };
      completer.complete(gallery);
    });

    return completer.future;
  }

  void publishAction({
    required List<Map<String, String>> galleryItems,
  }) {
    StoryApi.postStory(gallery: galleryItems);
    Get.offAll(const DashboardScreen());
  }

// isSelected(String id) {
//   return selectedItems.where((item) => item.id == id).isNotEmpty;
// }
//
// selectItem(int index) async {
//   var galleryImage = mediaList[index];
//
//   if (isSelected(galleryImage.id)) {
//     selectedItems.removeWhere((anItem) => anItem.id == galleryImage.id);
//     // if (selectedItems.isEmpty) {
//     //   print('4');
//     //
//     //   selectedItems.add(galleryImage);
//     // }
//   } else {
//     if (selectedItems.length < 10) {
//       selectedItems.add(galleryImage);
//     }
//   }
//
//   update();
// }
}
