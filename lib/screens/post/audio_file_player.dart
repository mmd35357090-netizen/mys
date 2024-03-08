import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/util/constant_util.dart';
import '../../components/audio_progress_bar.dart';
import '../../manager/player_manager.dart';

class AudioFilePlayer extends StatefulWidget {
  final String path;

  const AudioFilePlayer({Key? key, required this.path}) : super(key: key);

  @override
  State<AudioFilePlayer> createState() => _AudioFilePlayerState();
}

class _AudioFilePlayerState extends State<AudioFilePlayer> {
  final PlayerManager _playerManager = Get.find();
  String fileId = randomId();

  @override
  void initState() {
    super.initState();
  }

  playAudio() {
    Audio audio = Audio(id: fileId, url: widget.path);
    _playerManager.playLocalAudio(audio);
  }

  stopAudio() {
    _playerManager.stopAudio();
  }

  pauseAudio() {
    _playerManager.pauseAudio();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _playerManager.currentlyPlayingAudio.value?.id == fileId &&
                      _playerManager.isPlaying.value
                  ? ThemeIconWidget(
                      ThemeIcon.pause,
                      // color: Colors.white,
                      size: 30,
                    ).ripple(() {
                      pauseAudio();
                    })
                  : ThemeIconWidget(
                      ThemeIcon.play,
                      // color: Colors.white,
                      size: 30,
                    ).ripple(() {
                      playAudio();
                    }),
              const SizedBox(
                width: 15,
              ),
              SizedBox(
                width: Get.width - 45 - (2 * DesignConstants.horizontalPadding),
                height: 20,
                child: AudioProgressBar(id: fileId,),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          )
        ],
      );
    });
  }
}
