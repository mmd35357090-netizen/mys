import 'package:chewie/chewie.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:foap/screens/chat/media.dart';
import 'package:foap/screens/post/add_post_screen.dart';
import 'package:foap/util/constant_util.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:io';
import 'package:foap/helper/imports/common_import.dart';

// ---- reel size settings (change here) ----
const int kReelMaxSeconds = 60; // longest reel
const int kReelShortSide = 480; // 480p  (use 360 for even smaller files)
const int kReelCrf = 29; // higher = smaller file, lower quality
const String kReelMaxRate = '500k'; // upper limit of the video bitrate
const String kReelAudioRate = '64k';

class PreviewReelsScreen extends StatefulWidget {
  final File reel;
  final int? audioId;
  final double? audioStartTime;
  final double? audioEndTime;

  const PreviewReelsScreen(
      {super.key,
      required this.reel,
      this.audioId,
      this.audioStartTime,
      this.audioEndTime})
      ;

  @override
  State<StatefulWidget> createState() {
    return _PreviewReelsState();
  }
}

class _PreviewReelsState extends State<PreviewReelsScreen> {
  ChewieController? chewieController;
  VideoPlayerController? videoPlayerController;
  double _durationSec = 0;
  double _start = 0;
  double _end = 0;

  void _onTick() {
    final c = videoPlayerController;
    if (c == null || !c.value.isInitialized || _end <= 0) return;
    // play only the selected part, again and again
    if (c.value.position.inMilliseconds / 1000 >= _end - 0.05) {
      c.seekTo(Duration(milliseconds: (_start * 1000).round()));
    }
  }

  String _fmt(double s) {
    final t = s.round();
    return '${t ~/ 60}:${(t % 60).toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    videoPlayerController = VideoPlayerController.file(widget.reel);
    videoPlayerController!.initialize().then((value) {
      if (!mounted) {
        return;
      }
      _durationSec = videoPlayerController!.value.duration.inMilliseconds / 1000;
      _start = 0;
      _end = _durationSec > kReelMaxSeconds ? kReelMaxSeconds.toDouble() : _durationSec;
      videoPlayerController!.addListener(_onTick);
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
    super.dispose();
    videoPlayerController?.removeListener(_onTick);
    chewieController?.dispose();
    videoPlayerController!.dispose();
    chewieController?.pause();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
            // alignment: Alignment.topCenter,
            children: [
              const SizedBox(
                height: 50,
              ),
              chewieController == null
                  ? Container()
                  : SizedBox(
                      height: (Get.width - 32) /
                          videoPlayerController!.value.aspectRatio,
                      child: Chewie(
                        controller: chewieController!,
                      ),
                    ).round(20),
              if (chewieController != null && _durationSec > 2)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Column(children: [
                    RangeSlider(
                      min: 0,
                      max: _durationSec,
                      values: RangeValues(_start, _end),
                      onChanged: (v) {
                        var a = v.start, b = v.end;
                        if (b - a > kReelMaxSeconds) {
                          // keep the selection within the longest allowed reel
                          if (a != _start) {
                            b = a + kReelMaxSeconds;
                          } else {
                            a = b - kReelMaxSeconds;
                          }
                        }
                        if (b - a < 1) return;
                        setState(() {
                          _start = a;
                          _end = b;
                        });
                        videoPlayerController
                            ?.seekTo(Duration(milliseconds: (a * 1000).round()));
                      },
                    ),
                    Text(
                      'Selected ${_fmt(_start)} - ${_fmt(_end)}  (${(_end - _start).round()}s, max $kReelMaxSeconds s)',
                      style: TextStyle(
                          fontSize: FontSizes.b4,
                          color: AppColorConstants.mainTextColor),
                    ),
                  ]),
                ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ThemeIconWidget(
                    ThemeIcon.backArrow,
                    size: 25,
                  ).circular.ripple(() {
                    Get.back();
                  }),
                  Container(
                          color: AppColorConstants.themeColor,
                          child: Text(
                            nextString.tr,
                            style: TextStyle(fontSize: FontSizes.b2),
                          ).setPadding(
                              left: DesignConstants.horizontalPadding,
                              right: DesignConstants.horizontalPadding,
                              bottom: 8,
                              top: 8))
                      .circular
                      .ripple(() {
                    submitReel();
                  }),
                ],
              ),
              const SizedBox(
                height: 20,
              )
            ]).hp(DesignConstants.horizontalPadding),
      ),
    );
  }

  submitReel() async {
    Loader.show(status: loadingString.tr);
    // cut the chosen part and make the file small (480p, low bitrate) before it is uploaded
    File reelFile = widget.reel;
    try {
      final out =
          '${Directory.systemTemp.path}/reel_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final len = (_end - _start);
      final cmd = '-y -ss ${_start.toStringAsFixed(2)} -t ${len.toStringAsFixed(2)} '
          '-i "${widget.reel.path}" '
          "-vf \"scale='if(gt(iw,ih),-2,min($kReelShortSide,iw))':'if(gt(iw,ih),min($kReelShortSide,ih),-2)'\" "
          '-c:v libx264 -preset veryfast -crf $kReelCrf -maxrate $kReelMaxRate -bufsize 1000k -r 30 '
          '-pix_fmt yuv420p -c:a aac -b:a $kReelAudioRate -movflags +faststart "$out"';
      final session = await FFmpegKit.execute(cmd);
      final rc = await session.getReturnCode();
      if (ReturnCode.isSuccess(rc) && File(out).existsSync() && File(out).lengthSync() > 0) {
        reelFile = File(out);
      }
    } catch (_) {
      // if cutting / compressing fails, the original video is sent
    }

    final thumbnail = await VideoThumbnail.thumbnailData(
      video: reelFile.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 400,
      // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 25,
    );

    final videoInfo = await VideoCompress.getMediaInfo(reelFile.path);
    Loader.dismiss();
    Media media = Media();
    media.id = randomId();
    media.file = reelFile;
    media.thumbnail = thumbnail;
    media.size =
        Size(videoInfo.width!.toDouble(), videoInfo.height!.toDouble());
    media.creationTime = DateTime.now();
    media.title = null;
    media.mediaType = GalleryMediaType.video;

    // _selectPostMediaController.mediaSelected([media]);

    chewieController?.pause();

    Get.to(() => AddPostScreen(
          items: [media],
          isReel: true,
          audioId: widget.audioId,
          audioStartTime: widget.audioStartTime,
          audioEndTime: widget.audioEndTime,
          postType: PostCategory.reel,
          postCompletionHandler: () {
            Get.close(2);
          },

          // postType: PostType.reel,
        ));
  }
}
