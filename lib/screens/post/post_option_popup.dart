import 'dart:io';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../components/giphy/giphy_get.dart';
import '../../helper/imports/common_import.dart';
import '../../util/constant_util.dart';
import '../chat/drawing_screen.dart';
import '../chat/media.dart';
import '../chat/voice_record.dart';
import '../settings_menu/settings_controller.dart';

enum PostContext { none, dailyDrop, challenge, riverRun, chat }

class PostOptionsPopup extends StatelessWidget {
  final SettingsController _settingsController = Get.find();
  final Function(List<Media>)? selectedMediaList;
  final Function(Media)? selectGif;
  final Function(Media)? recordedAudio;
  final ImagePicker _picker = ImagePicker();

  PostOptionsPopup({
    super.key,
    this.selectedMediaList,
    this.selectGif,
    this.recordedAudio,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> options = [];

    options.add(cameraButton());

    if (_settingsController.setting.value!.enableImagePost) {
      options.add(galleryButton());
    }
    if (_settingsController.setting.value!.enableVideoPost) {
      options.add(videoButton());
    }

    options.add(drawButton());
    options.add(gifButton());

    return SizedBox(
      height: 30,
      child: ListView.separated(
        padding: EdgeInsets.only(
            left: DesignConstants.horizontalPadding,
            right: DesignConstants.horizontalPadding),
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        itemBuilder: (ctx, index) {
          return options[index];
        },
        separatorBuilder: (ctx, index) {
          return const SizedBox(
            width: 8,
          );
        },
      ),
    );
  }

  Widget cameraButton() {
    return ModalComponents(
      check: true,
      icon: ThemeIcon.camera,
      name: cameraString.tr,
      onPress: () async {
        selectPhoto(
          source: ImageSource.camera,
        );
      },
    );
  }

  Widget galleryButton() {
    return ModalComponents(
      check: true,
      icon: ThemeIcon.gallery,
      name: galleryString,
      onPress: () async {
        selectPhoto(
          source: ImageSource.gallery,
        );
      },
    );
  }

  Widget videoButton() {
    return ModalComponents(
      check: true,
      icon: ThemeIcon.videoCamera,
      name: videoString.tr,
      onPress: () async {
        selectVideo(
          source: ImageSource.gallery,
        );
      },
    );
  }

  Widget drawButton() {
    return ModalComponents(
      check: true,
      icon: ThemeIcon.drawing,
      name: drawingString.tr,
      imageUrl: 'assets/images/dashboard/draw_icon.svg',
      onPress: () {
        openDrawingBoard();
      },
    );
  }

  Widget gifButton() {
    return ModalComponents(
      check: true,
      icon: ThemeIcon.gif,
      name: gifString.tr,
      onPress: () {
        openGify();
      },
    );
  }

  void openGify() async {
    String randomId = 'hsvcewd78djhbejkd';

    GiphyGif? gif = await GiphyGet.getGif(
      context: Get.context!,
      //Required
      apiKey: _settingsController.setting.value!.giphyApiKey!,
      //Required.
      lang: GiphyLanguage.english,
      //Optional - Language for query.
      randomID: randomId,
      // Optional - An ID/proxy for a specific user.
      tabColor: Colors.teal, // Optional- default accent color.
    );

    if (gif != null) {
      Media media = Media();
      media.filePath = 'https://i.giphy.com/media/${gif.id}/200.gif';
      media.mediaType = GalleryMediaType.gif;
      if (selectGif != null) {
        selectGif!(media);
      }
    }
  }

  void openDrawingBoard() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: Get.context!,
        // isDismissible: false,
        isScrollControlled: true,
        // enableDrag: false,
        builder: (context) => FractionallySizedBox(
            heightFactor: 0.9,
            child: DrawingScreen(
              drawingCompleted: (media) {
                if (selectedMediaList != null) {
                  // Navigator.of(context).pop();
                  EasyLoading.show(status: loadingString);
                  Future.delayed(const Duration(milliseconds: 200), () {
                    EasyLoading.dismiss();
                    selectedMediaList!([media]);
                  });
                }
              },
            )));
  }

  selectPhoto({
    required ImageSource source,
  }) async {
    if (source == ImageSource.camera) {
      XFile? image = await _picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        convertToMedias(files: [image], mediaType: GalleryMediaType.photo);
      }
    } else {
      List<XFile> images = await _picker.pickMultiImage();
      // print('images ${images.length}');
      convertToMedias(files: images, mediaType: GalleryMediaType.photo);
    }
  }

  selectVideo({
    required ImageSource source,
  }) async {
    XFile? file = await _picker.pickVideo(source: source);

    if (file != null) {
      convertToMedias(files: [file], mediaType: GalleryMediaType.video);
    }
  }

  convertToMedias(
      {required List<XFile> files, required GalleryMediaType mediaType}) async {
    List<Media> medias = [];
    for (XFile mediaFile in files) {
      Media media = Media();
      media.mediaType = mediaType;
      File file = File(mediaFile.path);
      media.file = file;

      if (mediaType == GalleryMediaType.video) {
        final videoInfo = await FlutterVideoInfo().getVideoInfo(mediaFile.path);

        media.size =
            Size(videoInfo!.width!.toDouble(), videoInfo.height!.toDouble());

        media.thumbnail = await VideoThumbnail.thumbnailData(
          video: mediaFile.path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 500,
          // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
          quality: 25,
        );
      }

      media.id = randomId();
      medias.add(media);
    }

    selectedMediaList!(medias);
  }
}

class ModalComponents extends StatelessWidget {
  final bool check;
  final String? imageUrl;
  final ThemeIcon icon;
  final String name;
  final VoidCallback? onPress;

  const ModalComponents(
      {super.key,
      required this.check,
      this.imageUrl,
      required this.icon,
      required this.name,
      this.onPress});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ThemeIconWidget(icon),
        const SizedBox(
          width: 10,
        ),
        BodySmallText(
          name,
        ),
      ],
    ).hP8.borderWithRadius(value: 0.5, radius: 5).ripple(() {
      onPress!();
    });
  }
}
