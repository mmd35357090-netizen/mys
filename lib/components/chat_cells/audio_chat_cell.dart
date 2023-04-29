import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';

import '../../manager/player_manager.dart';

class AudioChatTile extends StatefulWidget {
  final ChatMessageModel message;

  const AudioChatTile({Key? key, required this.message}) : super(key: key);

  @override
  State<AudioChatTile> createState() => _AudioChatTileState();
}

class _AudioChatTileState extends State<AudioChatTile> {
  final PlayerManager _playerManager = Get.find();

  @override
  void initState() {
    super.initState();
  }

  playAudio() {
    Audio audio = Audio(
        id: widget.message.localMessageId,
        url: widget.message.mediaContent.audio!);
    _playerManager.playAudio(audio);
  }

  stopAudio() {
    _playerManager.stopAudio();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _playerManager.currentlyPlayingAudio.value?.id ==
                        widget.message.id.toString()
                    ? const ThemeIconWidget(
                        ThemeIcon.stop,
                        color: Colors.white,
                        size: 30,
                      ).ripple(() {
                        stopAudio();
                      })
                    : const ThemeIconWidget(
                        ThemeIcon.play,
                        color: Colors.white,
                        size: 30,
                      ).ripple(() {
                        playAudio();
                      }),
                const SizedBox(
                  width: 15,
                ),
                SizedBox(
                  width: 230,
                  height: 20,
                  child: AudioProgressBar(),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            )
          ],
        ));
  }
}

class AudioProgressBar extends StatelessWidget {
  final PlayerManager _playerManager = Get.find();

  AudioProgressBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => ProgressBar(
          thumbColor: AppColorConstants.themeColor.darken(),
          progressBarColor: AppColorConstants.themeColor,
          baseBarColor: AppColorConstants.backgroundColor.lighten(),
          thumbRadius: 8,
          barHeight: 2,
          progress: _playerManager.progress.value?.current ??
              const Duration(seconds: 0),
          // buffered: value.buffered,
          total: _playerManager.progress.value?.total ??
              const Duration(seconds: 0),
          timeLabelPadding: 5,
          timeLabelTextStyle: TextStyle(
              fontSize: FontSizes.b4, fontWeight: TextWeight.bold)

          // onSeek: pageManager.seek,
        ));
  }
}
