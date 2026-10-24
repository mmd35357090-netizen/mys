import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/live_imports.dart';
import 'package:permission_handler/permission_handler.dart';

import '../content_creator_view.dart';

class CheckingLiveFeasibility extends StatefulWidget {
  final LiveModel? battle;
  final VoidCallback successCallbackHandler;

  const CheckingLiveFeasibility({
    super.key,
    this.battle,
    required this.successCallbackHandler,
  });

  @override
  State<CheckingLiveFeasibility> createState() =>
      _CheckingLiveFeasibilityState();
}

class _CheckingLiveFeasibilityState
    extends State<CheckingLiveFeasibility> {
  final AgoraLiveController _agoraLiveController = Get.find();

  bool _isStartingLive = false;

  openSettingAppForAccess() {
    _agoraLiveController.checkFeasibilityToLive(
      isOpenSettings: true,
      battle: widget.battle,
      successCallbackHandler: widget.successCallbackHandler,
    );
  }

  Future<void> goToLive() async {
    // Prevent duplicate calls from the animation callback.
    if (_isStartingLive || !mounted) return;

    _isStartingLive = true;

    try {
      final cameraService = Get.find<CameraControllerService>();

      // Wait until the previous camera session has been released.
      await cameraService.clear();

      if (!mounted) return;

      // Start Live only after camera cleanup completes.
      _agoraLiveController.showLiveStreaming();
    } catch (error, stackTrace) {
      debugPrint('Camera cleanup before Live failed: $error');
      debugPrintStack(stackTrace: stackTrace);

      // Do not start Live if camera cleanup failed.
      if (mounted) {
        _isStartingLive = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const colorizeColors = [
      Colors.purple,
      Colors.blue,
      Colors.yellow,
      Colors.red,
    ];

    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Obx(
        () => Stack(
          children: [
            if (_agoraLiveController.startLiveStreaming.value ==
                    LiveStreamingStatus.none ||
                _agoraLiveController.startLiveStreaming.value ==
                    LiveStreamingStatus.checking ||
                _agoraLiveController.startLiveStreaming.value ==
                    LiveStreamingStatus.preparing)
              Column(
                children: [
                  const SizedBox(height: 40),
                  Stack(
                    children: [
                      const CameraView(),

                      if (_agoraLiveController.startLiveStreaming.value !=
                          LiveStreamingStatus.checking)
                        Positioned(
                          top: 20,
                          left: DesignConstants.horizontalPadding,
                          child: Row(
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                color: AppColorConstants.backgroundColor,
                                child: Center(
                                  child: ThemeIconWidget(ThemeIcon.close),
                                ),
                              ).circular.ripple(() {
                                Get.back();
                              }),
                            ],
                          ),
                        ),

                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 70,
                              width: 70,
                              color: AppColorConstants.red,
                              child: Center(
                                child: ThemeIconWidget(
                                  ThemeIcon.videoCamera,
                                  size: 40,
                                ),
                              ),
                            ).circular.ripple(() {
                              if (_isStartingLive) return;

                              _agoraLiveController.checkFeasibilityToLive(
                                isOpenSettings: false,
                                battle: widget.battle,
                                successCallbackHandler:
                                    widget.successCallbackHandler,
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

            if (_agoraLiveController.startLiveStreaming.value ==
                LiveStreamingStatus.streaming)
              const LiveBroadcastScreen(),

            if (_agoraLiveController.startLiveStreaming.value ==
                    LiveStreamingStatus.checking ||
                _agoraLiveController.startLiveStreaming.value ==
                    LiveStreamingStatus.preparing)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Obx(() {
                  final status =
                      _agoraLiveController.startLiveStreaming.value;

                  if (status == LiveStreamingStatus.checking) {
                    return Center(
                      child: AnimatedTextKit(
                        animatedTexts: [
                          ColorizeAnimatedText(
                            checkingConnectionString.tr,
                            textStyle: TextStyle(
                              fontSize: FontSizes.h3,
                              fontWeight: FontWeight.bold,
                            ),
                            colors: colorizeColors,
                          ),
                        ],
                        isRepeatingAnimation: true,
                        onTap: () {},
                      ),
                    );
                  }

                  if (status == LiveStreamingStatus.failed) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 200,
                          width: 200,
                          color: AppColorConstants.red.withValues(
                            alpha: 0.5,
                          ),
                          child: ThemeIconWidget(
                            ThemeIcon.camera,
                            size: 100,
                          ),
                        ).circular,

                        const SizedBox(height: 150),

                        Text(
                          _agoraLiveController.errorMessage ??
                              'Unable to start Live.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: FontSizes.h4,
                            color: AppColorConstants.mainTextColor,
                            fontWeight: TextWeight.regular,
                          ),
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: 200,
                          height: 50,
                          child: AppThemeButton(
                            text: allowString.tr,
                            onPress: () {
                              openAppSettings();
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: 200,
                          height: 45,
                          child: Center(
                            child: Heading4Text(backString.tr),
                          ),
                        ).ripple(() {
                          Get.back();
                        }),
                      ],
                    ).hp(DesignConstants.horizontalPadding);
                  }

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 20, height: 100),

                      Heading3Text(goingLiveString.tr),

                      const SizedBox(width: 20, height: 100),

                      DefaultTextStyle(
                        style: TextStyle(
                          fontSize: FontSizes.h3,
                          fontWeight: TextWeight.semiBold,
                          color: AppColorConstants.themeColor,
                        ),
                        child: AnimatedTextKit(
                          pause: const Duration(milliseconds: 10),
                          totalRepeatCount: 1,
                          animatedTexts: [
                            RotateAnimatedText(
                              '3',
                              duration: const Duration(seconds: 1),
                              textStyle: TextStyle(
                                fontSize: FontSizes.h3,
                                fontWeight: TextWeight.regular,
                              ),
                            ),
                            RotateAnimatedText(
                              '2',
                              duration: const Duration(seconds: 1),
                              textStyle: TextStyle(
                                fontSize: FontSizes.h3,
                                fontWeight: TextWeight.regular,
                              ),
                            ),
                            RotateAnimatedText(
                              '1',
                              duration: const Duration(seconds: 1),
                              textStyle: TextStyle(
                                fontSize: FontSizes.h3,
                                fontWeight: TextWeight.regular,
                              ),
                            ),
                            RotateAnimatedText(
                              goString.tr,
                              duration: const Duration(seconds: 1),
                              textStyle: TextStyle(
                                fontSize: FontSizes.h3,
                                fontWeight: TextWeight.regular,
                              ),
                            ),
                          ],
                          onTap: () {},
                          onFinished: () {
                            goToLive();
                          },
                        ),
                      ),
                    ],
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }
}