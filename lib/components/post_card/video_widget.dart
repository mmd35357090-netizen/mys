import 'dart:async';
import 'dart:io';
import '../../util/ad_gate.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/models.dart';
import 'package:video_player/video_player.dart';

bool isMute = false;

String _fmt(Duration d) {
  final total = d.inSeconds < 0 ? 0 : d.inSeconds;
  final h = total ~/ 3600;
  final m = (total % 3600) ~/ 60;
  final s = total % 60;
  final ss = s.toString().padLeft(2, '0');
  if (h > 0) {
    return '$h:${m.toString().padLeft(2, '0')}:$ss';
  }
  return '$m:$ss';
}

/// Controls drawn on top of a video: tap to play / pause, double tap the left
/// or right side to go back / forward 10 seconds, drag the bar to seek,
/// mute and full screen buttons. They hide by themselves while playing.
class VideoControlsLayer extends StatefulWidget {
  final VideoPlayerController controller;
  final bool muted;
  final VoidCallback onToggleMute;
  final VoidCallback? onFullScreen;
  final VoidCallback? onClose;
  final ValueChanged<bool>? onUserPauseChanged;

  const VideoControlsLayer(
      {super.key,
      required this.controller,
      required this.muted,
      required this.onToggleMute,
      this.onFullScreen,
      this.onClose,
      this.onUserPauseChanged});

  @override
  State<VideoControlsLayer> createState() => _VideoControlsLayerState();
}

class _VideoControlsLayerState extends State<VideoControlsLayer> {
  bool visible = true;
  Timer? _hideTimer;
  Timer? _skipTimer;
  double _doubleTapX = 0;
  String? _skipLabel;
  bool _skipForward = true;

  VideoPlayerController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    c.addListener(_onVideoChanged);
  }

  @override
  void didUpdateWidget(covariant VideoControlsLayer oldWidget) {
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onVideoChanged);
      widget.controller.addListener(_onVideoChanged);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    c.removeListener(_onVideoChanged);
    _hideTimer?.cancel();
    _skipTimer?.cancel();
    super.dispose();
  }

  bool _lastPlaying = false;

  void _onVideoChanged() {
    if (!mounted) return;
    final playing = c.value.isPlaying;
    if (playing != _lastPlaying) {
      _lastPlaying = playing;
      if (playing) {
        _scheduleHide();
      } else {
        _hideTimer?.cancel();
        visible = true;
      }
      setState(() {});
    }
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && c.value.isPlaying) {
        setState(() => visible = false);
      }
    });
  }

  void _show() {
    setState(() => visible = true);
    if (c.value.isPlaying) _scheduleHide();
  }

  bool get _atEnd =>
      c.value.duration > Duration.zero &&
      c.value.position >= c.value.duration - const Duration(milliseconds: 250);

  Future<void> _togglePlay() async {
    if (!c.value.isInitialized) return;
    if (c.value.isPlaying) {
      await c.pause();
      widget.onUserPauseChanged?.call(true);
    } else {
      if (_atEnd) {
        await c.seekTo(Duration.zero);
      }
      await c.play();
      widget.onUserPauseChanged?.call(false);
    }
    _show();
  }

  Future<void> _skip(int seconds) async {
    if (!c.value.isInitialized) return;
    final target = c.value.position + Duration(seconds: seconds);
    final max = c.value.duration;
    await c.seekTo(target < Duration.zero
        ? Duration.zero
        : (target > max ? max : target));
    _skipTimer?.cancel();
    setState(() {
      _skipForward = seconds > 0;
      _skipLabel = '${seconds > 0 ? '+' : '-'}${seconds.abs()}s';
    });
    _skipTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _skipLabel = null);
    });
    _show();
  }

  Widget _roundButton(IconData icon, VoidCallback onTap, {double size = 22}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onTap();
        _show();
      },
      child: Container(
        height: size + 18,
        width: size + 18,
        decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playing = c.value.isPlaying;
    return LayoutBuilder(builder: (context, box) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (visible && playing) {
            // controls were open: a tap pauses
            _togglePlay();
          } else if (!visible) {
            _show();
          } else {
            _togglePlay();
          }
        },
        onDoubleTapDown: (d) => _doubleTapX = d.localPosition.dx,
        onDoubleTap: () {
          _skip(_doubleTapX < box.maxWidth / 2 ? -10 : 10);
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // soft shade so white controls are readable on any video
            IgnorePointer(
              child: AnimatedOpacity(
                opacity: visible ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.25),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (widget.onClose != null)
              Positioned(
                top: 8,
                left: 8,
                child: _roundButton(Icons.arrow_back_rounded, widget.onClose!),
              ),
            // centre: back 10, play / pause, forward 10
            Center(
              child: AnimatedOpacity(
                opacity: visible ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !visible,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _roundButton(Icons.replay_10_rounded, () => _skip(-10),
                          size: 26),
                      const SizedBox(width: 22),
                      _roundButton(
                          playing
                              ? Icons.pause_rounded
                              : (_atEnd
                                  ? Icons.replay_rounded
                                  : Icons.play_arrow_rounded),
                          _togglePlay,
                          size: 38),
                      const SizedBox(width: 22),
                      _roundButton(Icons.forward_10_rounded, () => _skip(10),
                          size: 26),
                    ],
                  ),
                ),
              ),
            ),
            if (_skipLabel != null)
              Positioned(
                top: 0,
                bottom: 0,
                left: _skipForward ? null : 20,
                right: _skipForward ? 20 : null,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(_skipLabel!,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            // bottom bar: time, seek bar, mute, full screen
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: visible
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 8, 6),
                      child: Row(
                        children: [
                          ValueListenableBuilder<VideoPlayerValue>(
                            valueListenable: c,
                            builder: (_, v, __) => Text(
                              '${_fmt(v.position)} / ${_fmt(v.duration)}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: VideoProgressIndicator(
                              c,
                              allowScrubbing: true,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              colors: VideoProgressColors(
                                playedColor: AppColorConstants.themeColor,
                                bufferedColor:
                                    Colors.white.withValues(alpha: 0.45),
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.25),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              widget.onToggleMute();
                              _show();
                            },
                            icon: Icon(
                                widget.muted
                                    ? Icons.volume_off_rounded
                                    : Icons.volume_up_rounded,
                                color: Colors.white,
                                size: 22),
                          ),
                          if (widget.onFullScreen != null)
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              onPressed: widget.onFullScreen,
                              icon: const Icon(Icons.fullscreen_rounded,
                                  color: Colors.white, size: 26),
                            ),
                        ],
                      ),
                    )
                  : IgnorePointer(
                      child: VideoProgressIndicator(
                        c,
                        allowScrubbing: false,
                        padding: EdgeInsets.zero,
                        colors: VideoProgressColors(
                          playedColor: AppColorConstants.themeColor,
                          bufferedColor: Colors.white.withValues(alpha: 0.3),
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      );
    });
  }
}

class VideoPostTile extends StatefulWidget {
  final PostGallery? media;
  final double width;

  final String url;
  final bool isLocalFile;
  final bool play;
  final VoidCallback onTapActionHandler;

  const VideoPostTile(
      {super.key,
      this.media,
      required this.width,
      required this.url,
      required this.isLocalFile,
      required this.play,
      required this.onTapActionHandler});

  @override
  State<VideoPostTile> createState() => _VideoPostTileState();
}

class _VideoPostTileState extends State<VideoPostTile> {
  VideoPlayerController? videoPlayerController;
  bool initialized = false;
  bool hasError = false;

  // the user paused it by hand: do not start it again until it scrolls away
  bool userPaused = false;

  @override
  void initState() {
    super.initState();
    prepareVideo();
  }

  @override
  void didUpdateWidget(covariant VideoPostTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url ||
        oldWidget.isLocalFile != widget.isLocalFile) {
      prepareVideo();
      return;
    }
    if (oldWidget.play != widget.play) {
      if (widget.play) {
        userPaused = false;
        play();
      } else {
        pause();
      }
    }
  }

  @override
  void dispose() {
    clear();
    super.dispose();
  }

  void clear() {
    final old = videoPlayerController;
    videoPlayerController = null;
    initialized = false;
    if (old != null) {
      old.pause();
      old.dispose();
    }
  }

  void prepareVideo() {
    clear();
    hasError = false;
    userPaused = false;
    final controller = widget.isLocalFile
        ? VideoPlayerController.file(File(widget.url))
        : VideoPlayerController.networkUrl(Uri.parse(widget.url));
    videoPlayerController = controller;
    controller.initialize().then((_) {
      if (!mounted || videoPlayerController != controller) return;
      controller.setVolume(isMute ? 0 : 1);
      setState(() => initialized = true);
      if (widget.play && !userPaused) {
        play();
      }
    }).catchError((_) {
      if (mounted) setState(() => hasError = true);
    });
  }

  void openFullScreen() {
    final c = videoPlayerController;
    if (c == null) return;
    Navigator.of(context)
        .push(MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return FullScreenVideoPostTile(videoPlayerController: c);
            },
            fullscreenDialog: true))
        .then((_) {
      if (mounted) setState(() {});
      AdGate.onVideoClosed();
    });
  }

  void toggleMute() {
    final c = videoPlayerController;
    if (c == null) return;
    setState(() {
      isMute = !isMute;
    });
    c.setVolume(isMute ? 0 : 1);
  }

  void play() {
    final c = videoPlayerController;
    if (c == null || !c.value.isInitialized || userPaused) return;
    c.setVolume(isMute ? 0 : 1);
    c.play();
  }

  void pause() {
    videoPlayerController?.pause();
  }

  Widget thumbnail() {
    return widget.media == null
        ? Container(
            height: widget.width * 0.56,
            width: widget.width,
            color: Colors.black,
          )
        : CachedNetworkImage(
            imageUrl: widget.media!.thumbnail,
            fit: BoxFit.cover,
            width: Get.width,
          );
  }

  @override
  Widget build(BuildContext context) {
    final c = videoPlayerController;
    if (hasError) {
      return Container(
        height: widget.width * 0.56,
        width: widget.width,
        color: Colors.black,
        child: const Center(
            child: Icon(Icons.error_outline, color: Colors.white, size: 36)),
      );
    }
    if (c == null || !initialized) {
      return Stack(
        alignment: Alignment.center,
        children: [
          thumbnail(),
          const SizedBox(
              height: 28,
              width: 28,
              child: CircularProgressIndicator(
                  strokeWidth: 3, color: Colors.white)),
        ],
      );
    }
    final aspect = c.value.aspectRatio == 0 ? 16 / 9 : c.value.aspectRatio;
    final maxHeight = Get.height * 0.75;
    final double height =
        (widget.width / aspect).clamp(0.0, maxHeight).toDouble();

    return SizedBox(
      width: widget.width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.black),
          Center(
            child: AspectRatio(
              aspectRatio: aspect,
              child: VideoPlayer(c),
            ),
          ),
          VideoControlsLayer(
            controller: c,
            muted: isMute,
            onToggleMute: toggleMute,
            onFullScreen: openFullScreen,
            onUserPauseChanged: (paused) => userPaused = paused,
          ),
        ],
      ),
    );
  }
}

class FullScreenVideoPostTile extends StatefulWidget {
  final VideoPlayerController videoPlayerController;

  const FullScreenVideoPostTile({
    super.key,
    required this.videoPlayerController,
  });

  @override
  State<FullScreenVideoPostTile> createState() =>
      _FullScreenVideoPostTileState();
}

class _FullScreenVideoPostTileState extends State<FullScreenVideoPostTile> {
  @override
  Widget build(BuildContext context) {
    final c = widget.videoPlayerController;
    final aspect = c.value.aspectRatio == 0 ? 16 / 9 : c.value.aspectRatio;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: aspect,
                child: VideoPlayer(c),
              ),
            ),
            VideoControlsLayer(
              controller: c,
              muted: isMute,
              onToggleMute: () {
                setState(() {
                  isMute = !isMute;
                });
                c.setVolume(isMute ? 0 : 1);
              },
              onClose: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
