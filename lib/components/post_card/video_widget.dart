import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:video_player/video_player.dart';
import '../../model/post_gallery.dart';

bool isMute = false;

class VideoPostTile extends StatefulWidget {
  final PostGallery? media;
  final double width;

  final String url;
  final bool isLocalFile;
  final bool play;
  final VoidCallback onTapActionHandler;

  const VideoPostTile(
      {Key? key,
      this.media,
      required this.width,
      required this.url,
      required this.isLocalFile,
      required this.play,
      required this.onTapActionHandler})
      : super(key: key);

  @override
  State<VideoPostTile> createState() => _VideoPostTileState();
}

class _VideoPostTileState extends State<VideoPostTile> {
  late Future<void> initializeVideoPlayerFuture;
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController; // 🌟 চেউই কন্ট্রোলার রেফারেন্স ট্র্যাকিং
  late bool playVideo;

  @override
  void initState() {
    super.initState();
    playVideo = widget.play;
    prepareVideo(url: widget.url, isLocalFile: widget.isLocalFile);
  }

  @override
  void didUpdateWidget(covariant VideoPostTile oldWidget) {
    if (oldWidget.url != widget.url) {
      prepareVideo(url: widget.url, isLocalFile: widget.isLocalFile);
    }
    playVideo = widget.play;

    if (playVideo == true) {
      play();
    } else {
      pause();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    clear();
    super.dispose();
  }

  clear() {
    videoPlayerController?.pause();
    chewieController?.dispose(); // 🌟 মেমোরি লিক ফিক্স
    videoPlayerController?.dispose();
    videoPlayerController?.removeListener(checkVideoProgress);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.media == null
          ? null
          : widget.media!.width != 0
              ? widget.width / (widget.media!.width / widget.media!.height)
              : null,
      child: Stack(
        children: [
          FutureBuilder(
            future: initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && videoPlayerController != null) {
                // 🌟 প্রতিবার বিল্ডে নতুন কন্ট্রোলার তৈরি হওয়া আটকাতে ইনিশিয়ালাইজেশন
                chewieController ??= ChewieController(
                  videoPlayerController: videoPlayerController!,
                  aspectRatio: videoPlayerController!.value.aspectRatio,
                  showControls: true, // 🎛 টাইমলাইন বার এবং কন্ট্রোলস অন করা হলো
                  autoInitialize: true,
                  looping: false,
                  autoPlay: widget.play,
                  allowMuting: true,
                  showOptions: false, // বাড়তি বোরিং সেটিংস বাটন হাইড করা হলো
                  
                  // ফেসবুকের মতো প্রিমিয়াম প্রোগ্রেস বার থিম কালার
                  materialProgressColors: ChewieProgressColors(
                    playedColor: AppColorConstants.themeColor,
                    handleColor: AppColorConstants.themeColor,
                    backgroundColor: Colors.white24,
                    bufferedColor: Colors.white54,
                  ),
                  
                  placeholder: widget.media != null
                      ? CachedNetworkImage(
                          imageUrl: widget.media!.thumbnail,
                          fit: BoxFit.cover,
                          width: Get.width,
                          height: double.infinity,
                        )
                      : Container(),
                  errorBuilder: (context, errorMessage) {
                    return Center(
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  },
                );

                return SizedBox(
                  height: widget.width / videoPlayerController!.value.aspectRatio,
                  key: PageStorageKey(widget.url),
                  child: Chewie(
                    key: PageStorageKey(widget.url),
                    controller: chewieController!,
                  ),
                );
              } else {
                return widget.media == null
                    ? Container()
                    : CachedNetworkImage(
                        imageUrl: widget.media!.thumbnail,
                        fit: BoxFit.cover,
                        width: Get.width,
                      );
              }
            },
          ),
          
          // 🔊 মিউট/আনমিউট করার জন্য ডান কোণার স্মার্ট বাটনটি আলাদা রাখা হলো
          Positioned(
              right: 15,
              bottom: 50, // টাইমলাইন কন্ট্রোলের কিছুটা ওপরে সেট করা হয়েছে যেন ওভারল্যাপ না হয়
              child: GestureDetector(
                onTap: () {
                  if (isMute == true) {
                    unMuteAudio();
                  } else {
                    muteAudio();
                  }
                },
                child: Container(
                  height: 32,
                  width: 32,
                  color: Colors.black54,
                  child: ThemeIconWidget(
                    isMute ? ThemeIcon.micOff : ThemeIcon.mic,
                    size: 18,
                    color: Colors.white,
                  ),
                ).circular,
              )),
        ],
      ),
    );
  }

  prepareVideo({required String url, required bool isLocalFile}) {
    clear();
    chewieController = null; // নতুন ভিডিওর জন্য রিলিজ করা

    if (isLocalFile) {
      videoPlayerController = VideoPlayerController.file(File(url));
    } else {
      videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
    }
    
    initializeVideoPlayerFuture = videoPlayerController!.initialize().then((_) {
      if (isMute) {
        videoPlayerController!.setVolume(0);
      } else {
        videoPlayerController!.setVolume(1);
      }
      if (mounted) setState(() {});
    });

    videoPlayerController!.addListener(checkVideoProgress);
  }

  unMuteAudio() {
    videoPlayerController?.setVolume(1);
    setState(() {
      isMute = false;
    });
  }

  muteAudio() {
    videoPlayerController?.setVolume(0);
    setState(() {
      isMute = true;
    });
  }

  play() {
    if (videoPlayerController != null && !videoPlayerController!.value.isPlaying) {
      videoPlayerController!.play().then((_) {
        videoPlayerController!.addListener(checkVideoProgress);
      });
      if (isMute) {
        videoPlayerController!.setVolume(0);
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          playVideo = true;
        });
      }
    });
  }

  pause() {
    if (videoPlayerController != null && videoPlayerController!.value.isPlaying) {
      videoPlayerController!.pause();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          playVideo = false;
        });
      }
    });
  }

  void checkVideoProgress() {
    if (videoPlayerController == null) return;
    
    if (videoPlayerController!.value.position == videoPlayerController!.value.duration &&
        videoPlayerController!.value.duration > const Duration(milliseconds: 1)) {
      if (!mounted) return;
      setState(() {
        videoPlayerController!.removeListener(checkVideoProgress);
      });
    }
  }
}

// =========================================================================
// 🌟 ফুলস্ক্রিন ভিডিও ভিউ মডিউল (কোডের কাটা অংশটুকু জোড়া দিয়ে ঠিক করা হয়েছে)
// =========================================================================
class FullScreenVideoPostTile extends StatefulWidget {
  final VideoPlayerController videoPlayerController;

  const FullScreenVideoPostTile({
    Key? key,
    required this.videoPlayerController,
  }) : super(key: key);

  @override
  State<FullScreenVideoPostTile> createState() => _FullScreenVideoPostTileState();
}

class _FullScreenVideoPostTileState extends State<FullScreenVideoPostTile> {
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _chewieController = ChewieController(
      videoPlayerController: widget.videoPlayerController,
      aspectRatio: widget.videoPlayerController.value.aspectRatio,
      autoPlay: true,
      showControls: true,
    );
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          SizedBox(
            height: 80,
            width: double.infinity,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: const ThemeIconWidget(
                ThemeIcon.backArrow,
                size: 20,
                color: Colors.white,
              ).ripple(() {
                Navigator.of(context).pop();
              }),
            ),
          ).hp(DesignConstants.horizontalPadding),
          Expanded(
            child: Center(
              child: _chewieController != null
                  ? Chewie(controller: _chewieController!)
                  : const CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}
