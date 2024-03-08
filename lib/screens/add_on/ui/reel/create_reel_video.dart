import 'package:camera/camera.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/add_on/ui/reel/select_music.dart';
import 'package:foap/screens/post/content_creator_view.dart';
import '../../controller/reel/create_reel_controller.dart';

class CreateReelScreen extends StatefulWidget {
  const CreateReelScreen({super.key});

  @override
  State<CreateReelScreen> createState() => _CreateReelScreenState();
}

class _CreateReelScreenState extends State<CreateReelScreen>
    with TickerProviderStateMixin {
  final CreateReelController _createReelController = Get.find();
  AnimationController? animationController;

  @override
  void initState() {
    _initAnimation();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CreateReelScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initAnimation();
  }

  @override
  void dispose() {
    _createReelController.clear();
    super.dispose();
  }

  _initAnimation() {
    animationController = AnimationController(
        vsync: this,
        duration:
            Duration(seconds: _createReelController.recordingLength.value));
    animationController!.addListener(() {
      setState(() {});
    });
    animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        stopRecording();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          const SizedBox(
            height: 40,
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              const CameraView(),
              Positioned(
                left: 15,
                right: 15,
                top: 25,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                                color: AppColorConstants.themeColor,
                                child: ThemeIconWidget(ThemeIcon.close).p4)
                            .circular
                            .ripple(() {
                          Get.back();
                        }),
                        Obx(() => Container(
                                color: AppColorConstants.themeColor,
                                child: Row(
                                  children: [
                                    if (_createReelController
                                            .selectedAudio.value !=
                                        null)
                                      ThemeIconWidget(
                                        ThemeIcon.music,
                                        color: AppColorConstants.mainTextColor,
                                      ),
                                    BodyLargeText(
                                      _createReelController
                                                  .selectedAudio.value !=
                                              null
                                          ? _createReelController
                                              .selectedAudio.value!.name
                                          : selectMusicString.tr,
                                      weight: TextWeight.bold,
                                    ),
                                  ],
                                ).setPadding(
                                    left: DesignConstants.horizontalPadding,
                                    right: DesignConstants.horizontalPadding,
                                    top: 8,
                                    bottom: 8))
                            .circular).ripple(() {
                          final cameraService =
                              Get.find<CameraControllerService>();

                          Get.bottomSheet(
                            SelectMusic(
                              selectedAudioCallback: (croppedAudio, music) {
                                _createReelController
                                    .setCroppedAudio(croppedAudio);
                                cameraService.initializeCamera(
                                    CameraLensDirection.front);
                              },
                            ),
                            isScrollControlled: true,
                            ignoreSafeArea: true,
                          );
                        }),
                        const SizedBox(
                          width: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 15,
                top: 150,
                child: Container(
                  color: AppColorConstants.cardColor.withOpacity(0.4),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          final cameraService =
                              Get.find<CameraControllerService>();

                          if (cameraService
                                  .controller.description.lensDirection ==
                              CameraLensDirection.back) {
                            cameraService
                                .initializeCamera(CameraLensDirection.front);
                          } else {
                            cameraService
                                .initializeCamera(CameraLensDirection.back);
                          }
                        },
                        child: Icon(
                          Icons.cameraswitch_outlined,
                          size: 30,
                          color: AppColorConstants.themeColor,
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Obx(() => GestureDetector(
                            onTap: () {
                              final cameraService =
                                  Get.find<CameraControllerService>();
                              if (_createReelController.flashSetting.value) {
                                cameraService.controller
                                    .setFlashMode(FlashMode.off);
                                _createReelController.turnOffFlash();
                              } else {
                                cameraService.controller
                                    .setFlashMode(FlashMode.always);
                                _createReelController.turnOnFlash();
                              }
                            },
                            child: Icon(
                              _createReelController.flashSetting.value
                                  ? Icons.flash_on
                                  : Icons.flash_off,
                              size: 30,
                              color: AppColorConstants.themeColor,
                            ),
                          )),
                      const SizedBox(
                        height: 25,
                      ),
                      Obx(() => GestureDetector(
                            onTap: () {
                              _createReelController.updateRecordingLength(15);
                              _initAnimation();
                            },
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _createReelController
                                              .recordingLength.value ==
                                          15
                                      ? AppColorConstants.themeColor
                                      : AppColorConstants.backgroundColor),
                              child: const Center(child: BodySmallText('15s')),
                            ),
                          )),
                      const SizedBox(
                        height: 25,
                      ),
                      Obx(() => GestureDetector(
                            onTap: () {
                              _createReelController.updateRecordingLength(30);
                              _initAnimation();
                            },
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _createReelController
                                              .recordingLength.value ==
                                          30
                                      ? AppColorConstants.themeColor
                                      : AppColorConstants.backgroundColor),
                              child: const Center(child: BodySmallText('30s')),
                            ),
                          ))
                    ],
                  ).setPadding(left: 8, right: 8, top: 12, bottom: 12),
                ).round(20),
              ),
              Positioned(
                  bottom: 20,
                  child: GestureDetector(
                    onTap: () {
                      animationController!.forward();
                      _recordVideo();
                      // _recordVideo();
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 60,
                          width: 60,
                          child: CircularProgressIndicator(
                            value: animationController!.value,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColorConstants.themeColor),
                          ),
                        ),
                        Obx(() => Container(
                              height: 50,
                              width: 50,
                              color: AppColorConstants.themeColor,
                              child: ThemeIconWidget(
                                _createReelController.isRecording.value
                                    ? ThemeIcon.pause
                                    : ThemeIcon.play,
                                size: 30,
                              ),
                            ).circular)
                      ],
                    ),
                  ))
            ],
          ),
        ],
      ),
    );
  }

  _recordVideo() async {
    if (_createReelController.isRecording.value) {
      stopRecording();
    } else {
      startRecording();
    }
  }

  void stopRecording() async {
    animationController?.reset();
    final cameraService = Get.find<CameraControllerService>();
    final file = await cameraService.controller.stopVideoRecording();
    debugPrint('RecordedFile:: ${file.path}');
    _createReelController.stopRecording();
    if (_createReelController.croppedAudioFile != null) {
      _createReelController.stopPlayingAudio();
    }
    _createReelController.isRecording.value = false;
    _createReelController.createReel(
        _createReelController.croppedAudioFile, file);
  }

  void startRecording() async {
    final cameraService = Get.find<CameraControllerService>();

    await cameraService.controller.prepareForVideoRecording();
    await cameraService.controller.startVideoRecording();
    _createReelController.startRecording();
    if (_createReelController.croppedAudioFile != null) {
      _createReelController
          .playAudioFile(_createReelController.croppedAudioFile!);
    }
    // startRecordingTimer();
  }
}
