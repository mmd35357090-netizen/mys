import 'package:carousel_slider/carousel_slider.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:video_player/video_player.dart'; // 🌟 যুক্ত করা হয়েছে
import 'package:chewie/chewie.dart';             // 🌟 যুক্ত করা হয়েছে

import '../../model/post_gallery.dart';

class PostMediaFullScreen extends StatefulWidget {
  final List<PostGallery> gallery;
  final int? startIndex;

  const PostMediaFullScreen({Key? key, required this.gallery, this.startIndex})
      : super(key: key);

  @override
  State<PostMediaFullScreen> createState() => _PostMediaFullScreenState();
}

class _PostMediaFullScreenState extends State<PostMediaFullScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Stack(
        children: [
          CarouselSlider(
            items: mediaList(),
            options: CarouselOptions(
              aspectRatio: 1,
              initialPage: widget.startIndex ?? 0,
              enlargeCenterPage: false,
              enableInfiniteScroll: false,
              height: double.infinity,
              viewportFraction: 1,
            ),
          ),
          appBar()
        ],
      ),
    );
  }

  List<Widget> mediaList() {
    return widget.gallery.map((item) {
      if (item.isVideoPost == true) {
        return videoPostTile(item);
      } else {
        return photoPostTile(item);
      }
    }).toList();
  }

  // 🎛 বেসিক প্লেয়ার পরিবর্তন করে কাস্টম ফুলস্ক্রিন কন্ট্রোল প্লেয়ার যুক্ত করা হয়েছে
  Widget videoPostTile(PostGallery media) {
    return Center(
      child: FullScreenVideoControlsPlayer(
        url: media.filePath,
      ),
    );
  }

  Widget photoPostTile(PostGallery media) {
    return CachedNetworkImage(
      imageUrl: media.filePath,
      fit: BoxFit.contain,
      width: Get.width,
      placeholder: (context, url) => AppUtil.addProgressIndicator(size: 100),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    ).addPinchAndZoom();
  }

  Widget appBar() {
    return Positioned(
      child: SizedBox(
        height: 150.0,
        width: Get.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ThemeIconWidget(
              ThemeIcon.backArrow,
              size: 20,
              color: AppColorConstants.iconColor,
            ).ripple(() {
              Get.back();
            }),
          ],
        ).hp(DesignConstants.horizontalPadding),
      ),
    );
  }
}

// =========================================================================
// 🌟 টেনে দেখা এবং পজ করার জন্য তৈরি করা নতুন কাস্টম ভিডিও প্লেয়ার উইজেট
// =========================================================================
class FullScreenVideoControlsPlayer extends StatefulWidget {
  final String url;
  const FullScreenVideoControlsPlayer({Key? key, required this.url}) : super(key: key);

  @override
  State<FullScreenVideoControlsPlayer> createState() => _FullScreenVideoControlsPlayerState();
}

class _FullScreenVideoControlsPlayerState extends State<FullScreenVideoControlsPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  Future<void> initializePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    
    try {
      await _videoPlayerController.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true, // ফুলস্ক্রিনে ওপেন হওয়া মাত্রই প্লে হবে
        looping: true,
        showControls: true, // 🎛 পজ, প্লে এবং টেনে দেখার বার চালু করা হলো
        allowFullScreen: false, // অলরেডি ফুলস্ক্রিন পেজে থাকায় এটি বন্ধ রাখা হয়েছে
        
        // টাইমলাইন বারের কালার কাস্টমাইজেশন (আপনার থিম কালার অনুযায়ী)
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColorConstants.themeColor,
          handleColor: AppColorConstants.themeColor,
          backgroundColor: Colors.white24,
          bufferedColor: Colors.white54,
        ),
        
        placeholder: const Center(
          child: CircularProgressIndicator(),
        ),
      );

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print("Error initializing fullscreen video: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _chewieController == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return AspectRatio(
      aspectRatio: _videoPlayerController.value.aspectRatio,
      child: Chewie(controller: _chewieController!),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}
