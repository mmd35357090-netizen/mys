import 'package:chewie/chewie.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foap/components/custom_texts.dart';
import 'package:foap/helper/enum.dart';
import 'package:foap/helper/extension.dart';
import 'package:foap/helper/localization_strings.dart';
import 'package:foap/screens/chat/media.dart';
import 'package:foap/screens/post/add_post_screen.dart';
import 'package:foap/theme/theme_icon.dart';
import 'package:foap/util/app_config_constants.dart';
import 'package:foap/util/constant_util.dart';
import 'package:get/get.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:io';
import 'package:flutter/material.dart';

class PreviewReelsScreen extends StatefulWidget {
  final File reel;
  final int? audioId;
  final double? audioStartTime;
  final double? audioEndTime;

  const PreviewReelsScreen(
      {Key? key,
        required this.reel,
        this.audioId,
        this.audioStartTime,
        this.audioEndTime})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PreviewReelsState();
  }
}

class _PreviewReelsState extends State<PreviewReelsScreen> {
  ChewieController? chewieController;
  VideoPlayerController? videoPlayerController;

  @override
  void initState() {
    videoPlayerController = VideoPlayerController.file(widget.reel);
    videoPlayerController!.initialize().then((value) {
      if (!mounted) {
        return;
      }
      chewieController = ChewieController(
        aspectRatio: videoPlayerController!.value.aspectRatio,
        videoPlayerController: videoPlayerController!,
        autoPlay: true,
        looping: true,
        showControls: false,
        showOptions: false,
      );
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    chewieController!.dispose();
    videoPlayerController!.dispose();
    chewieController?.pause();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          // alignment: Alignment.topCenter,
          // fit: StackFit.loose,
            children: [
              const SizedBox(
                height: 50,
              ),
              chewieController == null
                  ? Container()
                  : SizedBox(
                height: (MediaQuery.of(context).size.width - 32) /
                    videoPlayerController!.value.aspectRatio,
                child: Chewie(
                  controller: chewieController!,
                ),
              ).round(20),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const ThemeIconWidget(
                    ThemeIcon.backArrow,
                    size: 25,
                  ).circular.ripple(() {
                    Get.back();
                  }),
                  Container(
                      color: AppColorConstants.themeColor,
                      child: Text(
                        LocalizationString.next,
                        style: TextStyle(
                            fontSize: FontSizes.b2),
                      ).setPadding(left: 16, right: 16, bottom: 8, top: 8))
                      .circular
                      .ripple(() {
                    submitReel();
                  }),
                ],
              ),
              const SizedBox(
                height: 20,
              )
            ]).hP16,
      ),
    );
  }

  submitReel() async {
    EasyLoading.show(status: LocalizationString.loading);
    final thumbnail = await VideoThumbnail.thumbnailData(
      video: widget.reel.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 400,
      // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );

    MediaInfo? mediaInfo = await VideoCompress.compressVideo(
      widget.reel.path,
      quality: VideoQuality.DefaultQuality,
      deleteOrigin: false, // It's false by default
    );

    EasyLoading.dismiss();
    Media media = Media();
    media.id = randomId();
    media.file = File(mediaInfo!.path!);
    media.thumbnail = thumbnail;
    media.size = null;
    media.creationTime = DateTime.now();
    media.title = null;
    media.mediaType = GalleryMediaType.video;

    Get.to(() => AddPostScreen(
      items: [media],
      isReel: true,
      audioId: widget.audioId,
      audioStartTime: widget.audioStartTime,
      audioEndTime: widget.audioEndTime,
    ));
  }
}
