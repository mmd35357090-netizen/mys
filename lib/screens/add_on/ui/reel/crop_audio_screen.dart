import 'package:foap/components/custom_texts.dart';
import 'package:foap/helper/extension.dart';
import 'package:foap/helper/localization_strings.dart';
import 'package:foap/screens/add_on/controller/reel/create_reel_controller.dart';
import 'package:foap/screens/add_on/model/reel_music_model.dart';
import 'package:foap/theme/theme_icon.dart';
import 'package:foap/util/app_config_constants.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/reel_imports.dart';
import 'package:flutter/material.dart';

class CropAudioScreen extends StatefulWidget {
  final ReelMusicModel reelMusicModel;

  const CropAudioScreen({Key? key, required this.reelMusicModel})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CropAudioState();
  }
}

class _CropAudioState extends State<CropAudioScreen> {
  final CreateReelController _createReelController = Get.find();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createReelController.playAudioFileUntil(
          widget.reelMusicModel,
          _createReelController.audioStartTime ?? 0,
          _createReelController.audioEndTime ?? 0);
    });

    super.initState();
  }

  @override
  void dispose() {
    _createReelController.stopPlayingAudio();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(children: [
        Row(
          children: [
            const ThemeIconWidget(
              ThemeIcon.backArrow,
              size: 25,
            ).ripple(() {
              _createReelController.stopPlayingAudio();
              Get.back();
            }),
            const SizedBox(
              width: 10,
            ),
          ],
        ).setPadding(left: 16, right: 16, top: 25, bottom: 20),
        const SizedBox(
          height: 20,
        ),
        Center(
          child: Obx(
                () => SizedBox(
              height: 80,
              width: Get.width * 0.8,
              child: WaveSlider(
                positionTextColor: AppColorConstants.themeColor,
                backgroundColor: Colors.transparent,
                heightWaveSlider: 30,
                widthWaveSlider: Get.width * 0.8,
                sliderColor: Colors.cyan,
                duration: widget.reelMusicModel.duration.toDouble(),
                cutterDuration:
                _createReelController.recordingLength.toDouble(),
                callbackEnd: (startDuration, endDuration) {
                  debugPrint("Start $startDuration End  $endDuration");
                  _createReelController.setAudioCropperTime(
                      startDuration, endDuration);
                  // this.startDuration = startDuration;
                  // this.endDuration = endDuration;
                  _createReelController.stopPlayingAudio();
                  _createReelController.playAudioFileUntil(
                      widget.reelMusicModel, startDuration, endDuration);
                },
                callbackStart: (double duration, double endDuration) {},
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 40,
        ),
        Center(
          child: Container(
              color: AppColorConstants.themeColor,
              child: Text(
                LocalizationString.use,
                style: TextStyle(
                    fontSize: FontSizes.b2),
              ).p8)
              .circular
              .ripple(() {
            _createReelController.trimAudio();
          }),
        )
      ]),
    );
  }
}
