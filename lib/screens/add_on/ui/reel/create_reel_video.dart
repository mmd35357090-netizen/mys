
import 'dart:async';

import 'package:camera/camera.dart';
import 'package:foap/screens/add_on/controller/reel/create_reel_controller.dart';
import 'package:foap/screens/add_on/ui/reel/select_music.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../../content_creator_view.dart';

class CreateReelScreen extends StatefulWidget {
  const CreateReelScreen({super.key});

  @override
  State<CreateReelScreen> createState() => _CreateReelScreenState();
}

class _CreateReelScreenState extends State<CreateReelScreen>
    with TickerProviderStateMixin {
  final CreateReelController _createReelController = Get.find();

  AnimationController? animationController;
  bool _recordingOperationInProgress = false;
  bool _screenClosing = false;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  @override
  void didUpdateWidget(covariant CreateReelScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void _initAnimation() {
    animationController?.dispose();

    animationController = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: _createReelController.recordingLength.value,
      ),
    );

    animationController!
      ..addListener(_onAnimationChanged)
      ..addStatusListener(_onAnimationStatusChanged);
  }

  void _onAnimationChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed &&
        _createReelController.isRecording.value) {
      unawaited(stopRecording());
    }
  }

  @override
  void dispose() {
    _screenClosing = true;

    animationController?.removeListener(_onAnimationChanged);
    animationController?.removeStatusListener(_onAnimationStatusChanged);
    animationController?.dispose();
    animationController = null;

    // Stop any background audio when leaving the Reel screen.
    if (_createReelController.croppedAudioFile != null) {
      _createReelController.stopPlayingAudio();
    }

    _createReelController.clear();

    super.dispose();
  }

  Future<void> _switchCamera() async {
    if (_screenClosing || _recordingOperationInProgress) return;

    final cameraService = Get.find<CameraControllerService>();
    final camera = cameraService.currentController;

    if (camera == null || !camera.value.isInitialized) return;

    if (camera.value.isRecordingVideo) return;

    final nextDirection =
        camera.description.lensDirection == CameraLensDirection.back
            ? CameraLensDirection.front
            : CameraLensDirection.back;

    await cameraService.initializeCamera(nextDirection);
  }

  Future<void> _toggleFlash() async {
    if (_screenClosing || _recordingOperationInProgress) return;

    final cameraService = Get.find<CameraControllerService>();
    final camera = cameraService.currentController;

    if (camera == null || !camera.value.isInitialized) return;

    // Flash is not available on all cameras.
    if (camera.description.lensDirection == CameraLensDirection.front) {
      return;
    }

    try {
      final turnOn = !_createReelController.flashSetting.value;

      await camera.setFlashMode(
        turnOn ? FlashMode.torch : FlashMode.off,
      );

      if (turnOn) {
        _createReelController.turnOnFlash();
      } else {
        _createReelController.turnOffFlash();
      }
    } on CameraException catch (error) {
      debugPrint('Flash operation failed: ${error.code}');
    } catch (error) {
      debugPrint('Flash error: $error');
    }
  }

  Future<void> _recordVideo() async {
    if (_screenClosing || _recordingOperationInProgress) return;

    if (_createReelController.isRecording.value) {
      await stopRecording();
    } else {
      await startRecording();
    }
  }

  Future<void> startRecording() async {
    if (_screenClosing || _recordingOperationInProgress) return;

    final cameraService = Get.find<CameraControllerService>();
    final camera = cameraService.currentController;

    if (camera == null || !camera.value.isInitialized) {
      debugPrint('Cannot record: camera is not initialized.');
      return;
    }

    if (camera.value.isRecordingVideo) return;

    _recordingOperationInProgress = true;

    try {
      await camera.prepareForVideoRecording();
      await camera.startVideoRecording();

      if (_screenClosing || !mounted) {
        try {
          await camera.stopVideoRecording();
        } catch (_) {}
        return;
      }

      _createReelController.startRecording();

      if (animationController != null) {
        animationController!.reset();
        animationController!.forward();
      }

      final audioFile = _createReelController.croppedAudioFile;
      if (audioFile != null) {
        _createReelController.playAudioFile(audioFile);
      }
    } on CameraException catch (error) {
      debugPrint('Start recording failed: ${error.code}');
    } catch (error) {
      debugPrint('Recording error: $error');
    } finally {
      _recordingOperationInProgress = false;
    }
  }

  Future<void> stopRecording() async {
    if (_recordingOperationInProgress) return;

    final cameraService = Get.find<CameraControllerService>();
    final camera = cameraService.currentController;

    if (camera == null ||
        !camera.value.isInitialized ||
        !camera.value.isRecordingVideo) {
      animationController?.reset();
      _createReelController.isRecording.value = false;
      return;
    }

    _recordingOperationInProgress = true;
    animationController?.stop();

    try {
      final file = await camera.stopVideoRecording();

      _createReelController.stopRecording();

      final audioFile = _createReelController.croppedAudioFile;
      if (audioFile != null) {
        _createReelController.stopPlayingAudio();
      }

      _createReelController.isRecording.value = false;
      animationController?.reset();

      if (!_screenClosing && mounted) {
       _createReelController.createReel(audioFile, file);
      }
    } on CameraException catch (error) {
      debugPrint('Stop recording failed: ${error.code}');
      _createReelController.isRecording.value = false;
      animationController?.reset();
    } catch (error) {
      debugPrint('Stop recording error: $error');
      _createReelController.isRecording.value = false;
      animationController?.reset();
    } finally {
      _recordingOperationInProgress = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          const SizedBox(height: 40),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                const CameraView(),
                Positioned(
                  left: 15,
                  right: 15,
                  top: 25,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        color: AppColorConstants.themeColor,
                        child: ThemeIconWidget(ThemeIcon.close).p4,
                      ).circular.ripple(() {
                        if (_createReelController.isRecording.value) {
                          unawaited(stopRecording());
                        }
                        Get.back();
                      }),
                      Obx(
                        () => Container(
                          color: AppColorConstants.themeColor,
                          child: Row(
                            children: [
                              if (_createReelController.selectedAudio.value !=
                                  null)
                                ThemeIconWidget(
                                  ThemeIcon.music,
                                  color: AppColorConstants.mainTextColor,
                                ),
                              BodyLargeText(
                                _createReelController.selectedAudio.value
                                        ?.name ??
                                    selectMusicString.tr,
                                weight: TextWeight.bold,
                              ),
                            ],
                          ).setPadding(
                            left: DesignConstants.horizontalPadding,
                            right: DesignConstants.horizontalPadding,
                            top: 8,
                            bottom: 8,
                          ),
                        ).circular,
                      ).ripple(() {
                        if (_createReelController.isRecording.value) return;

                        final cameraService =
                            Get.find<CameraControllerService>();

                        Get.bottomSheet(
                          SelectMusic(
                            selectedAudioCallback: (croppedAudio, music) {
                              _createReelController.setCroppedAudio(
                                croppedAudio,
                              );
                              unawaited(
                                cameraService.initializeCamera(
                                  CameraLensDirection.front,
                                ),
                              );
                            },
                          ),
                          isScrollControlled: true,
                          ignoreSafeArea: true,
                        );
                      }),
                      const SizedBox(width: 20),
                    ],
                  ),
                ),
                Positioned(
                  left: 15,
                  top: 150,
                  child: Container(
                    color: AppColorConstants.cardColor.withValues(
                      alpha: 0.4,
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _switchCamera,
                          child: Icon(
                            Icons.cameraswitch_outlined,
                            size: 30,
                            color: AppColorConstants.themeColor,
                          ),
                        ),
                        const SizedBox(height: 25),
                        Obx(
                          () => GestureDetector(
                            onTap: _toggleFlash,
                            child: Icon(
                              _createReelController.flashSetting.value
                                  ? Icons.flash_on
                                  : Icons.flash_off,
                              size: 30,
                              color: AppColorConstants.themeColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Obx(
                          () => GestureDetector(
                            onTap: () {
                              if (_createReelController.isRecording.value) {
                                return;
                              }
                              _createReelController.updateRecordingLength(15);
                              _initAnimation();
                              setState(() {});
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
                                    : AppColorConstants.backgroundColor,
                              ),
                              child: const Center(
                                child: BodySmallText('15s'),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Obx(
                          () => GestureDetector(
                            onTap: () {
                              if (_createReelController.isRecording.value) {
                                return;
                              }
                              _createReelController.updateRecordingLength(30);
                              _initAnimation();
                              setState(() {});
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
                                    : AppColorConstants.backgroundColor,
                              ),
                              child: const Center(
                                child: BodySmallText('30s'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ).setPadding(
                      left: 8,
                      right: 8,
                      top: 12,
                      bottom: 12,
                    ),
                  ).round(20),
                ),
                Positioned(
                  bottom: 20,
                  child: GestureDetector(
                    onTap: _recordVideo,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 60,
                          width: 60,
                          child: CircularProgressIndicator(
                            value: animationController?.value ?? 0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColorConstants.themeColor,
                            ),
                          ),
                        ),
                        Obx(
                          () => Container(
                            height: 50,
                            width: 50,
                            color: AppColorConstants.themeColor,
                            child: ThemeIconWidget(
                              _createReelController.isRecording.value
                                  ? ThemeIcon.pause
                                  : ThemeIcon.play,
                              size: 30,
                            ),
                          ).circular,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
