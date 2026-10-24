
import 'package:camera/camera.dart';
import 'package:foap/components/sm_tab_bar.dart';
import 'package:foap/helper/imports/live_imports.dart';
import 'package:foap/helper/imports/post_imports.dart';
import 'package:foap/helper/imports/setting_imports.dart';
import 'package:permission_handler/permission_handler.dart';

import '../helper/imports/common_import.dart';
import '../helper/permission_utils.dart';
import '../main.dart';
import 'add_on/ui/reel/create_reel_video.dart';

class CameraControllerService extends GetxController {
  CameraController? _controller;
  Future<void> _cameraOperation = Future<void>.value();
  bool _isClosing = false;

  CameraController? get currentController => _controller;

  bool get isInitialized =>
      _controller?.value.isInitialized == true;

  // Existing code that uses cameraService.controller can continue
  // using this getter, provided the camera has been initialized.
  CameraController get controller {
    final camera = _controller;
    if (camera == null) {
      throw StateError('Camera controller is not initialized.');
    }
    return camera;
  }

  Future<void> initializeCamera(
    CameraLensDirection lensDirection,
  ) {
    final operation = _cameraOperation.then((_) async {
      await _initializeCamera(lensDirection);
    });

    _cameraOperation = operation.catchError((Object error) {
      debugPrint('Camera operation failed: $error');
    });

    return _cameraOperation;
  }

  Future<void> _initializeCamera(
    CameraLensDirection lensDirection,
  ) async {
    if (_isClosing || isClosed) return;

    CameraDescription cameraDescription;

    try {
      cameraDescription = cameras.firstWhere(
        (camera) => camera.lensDirection == lensDirection,
      );
    } catch (error) {
      debugPrint('Requested camera is unavailable: $error');
      return;
    }

    final existing = _controller;

    if (existing != null) {
      if (existing.value.isInitialized &&
          existing.description.lensDirection == lensDirection) {
        return;
      }

      // Do not switch cameras in the middle of a recording.
      if (existing.value.isRecordingVideo) {
        debugPrint('Cannot switch cameras while recording.');
        return;
      }

      await _clearCamera();
    }

    if (_isClosing || isClosed) return;

    final newController = CameraController(
      cameraDescription,
      ResolutionPreset.max,
      enableAudio: true,
    );

    _controller = newController;

    try {
      await newController.initialize();

      // The screen may have closed while initialization was running.
      if (_isClosing ||
          isClosed ||
          !identical(_controller, newController)) {
        if (identical(_controller, newController)) {
          _controller = null;
        }
        await newController.dispose();
        return;
      }

      update();
    } on CameraException catch (error) {
      debugPrint(
        'Camera initialization failed: ${error.code} ${error.description ?? ''}',
      );

      if (identical(_controller, newController)) {
        _controller = null;
      }

      try {
        await newController.dispose();
      } catch (disposeError) {
        debugPrint('Camera cleanup failed: $disposeError');
      }

      if (!_isClosing && !isClosed) {
        update();
      }
    } catch (error) {
      debugPrint('Unexpected camera error: $error');

      if (identical(_controller, newController)) {
        _controller = null;
      }

      try {
        await newController.dispose();
      } catch (disposeError) {
        debugPrint('Camera cleanup failed: $disposeError');
      }

      if (!_isClosing && !isClosed) {
        update();
      }
    }
  }

  Future<void> clear() {
    final operation = _cameraOperation.then((_) async {
      await _clearCamera();
    });

    _cameraOperation = operation.catchError((Object error) {
      debugPrint('Camera cleanup operation failed: $error');
    });

    return _cameraOperation;
  }

  Future<void> _clearCamera() async {
    final oldController = _controller;

    // Clear the reference first so the UI stops using the old controller.
    _controller = null;

    if (oldController != null) {
      try {
        if (oldController.value.isInitialized &&
            oldController.value.isRecordingVideo) {
          await oldController.stopVideoRecording();
        }
      } catch (error) {
        debugPrint('Stopping camera recording failed: $error');
      }

      try {
        await oldController.dispose();
      } catch (error) {
        debugPrint('Disposing camera failed: $error');
      }
    }

    if (!_isClosing && !isClosed) {
      update();
    }
  }

  @override
  void onClose() {
    _isClosing = true;
    clear();
    super.onClose();
  }
}

class CameraView extends StatelessWidget {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CameraControllerService>(
      builder: (cameraService) {
        final camera = cameraService.currentController;

        if (camera == null || !camera.value.isInitialized) {
          return const SizedBox.shrink();
        }

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CameraPreview(camera),
          ),
        );
      },
    );
  }
}

class ContentCreatorView extends StatefulWidget {
  final int? animateToIndex;

  const ContentCreatorView({
    super.key,
    this.animateToIndex,
  });

  @override
  State<ContentCreatorView> createState() =>
      _ContentCreatorViewState();
}

class _ContentCreatorViewState extends State<ContentCreatorView>
    with SingleTickerProviderStateMixin {
  final List<String> tabs = [postString.tr];

  late TabController tabController;

  final SettingsController _settingsController = Get.find();
  final AgoraLiveController _agoraLiveController = Get.find();

  @override
  void initState() {
    super.initState();

    if (_settingsController.setting.value!.enableReel) {
      tabs.add(reelString.tr);
    }

    if (_settingsController.setting.value!.enableLive) {
      tabs.add(liveString.tr);
    }

    tabController = TabController(
      vsync: this,
      length: tabs.length,
    );

    if (widget.animateToIndex != null &&
        widget.animateToIndex! >= 0 &&
        widget.animateToIndex! < tabs.length) {
      tabController.animateTo(widget.animateToIndex!);
    }

    askForPermission();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameraService = Get.find<CameraControllerService>();

    final cameraPermission = await Permission.camera.request();

    if (!cameraPermission.isGranted || !mounted) {
      return;
    }

    await cameraService.initializeCamera(
      CameraLensDirection.front,
    );
  }

  void askForPermission() {
    PermissionUtils.requestPermission(
      [Permission.camera, Permission.microphone],
      isOpenSettings: true,
      permissionGrant: () async {},
      permissionDenied: () {},
      permissionNotAskAgain: () {},
    );
  }

  @override
  void dispose() {
    tabController.dispose();

    // Release camera resources when leaving the creator screen.
    Get.find<CameraControllerService>().clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        height: Get.height,
        width: Get.width,
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: tabController,
                children: [
                  AddPostScreen(
                    postType: PostCategory.basic,
                    postCompletionHandler: () {},
                  ),
                  if (_settingsController.setting.value!.enableReel)
                    const CreateReelScreen(),
                  if (_settingsController.setting.value!.enableLive)
                    CheckingLiveFeasibility(
                      successCallbackHandler: () {},
                    ),
                ],
              ),
            ),
            Obx(
              () => _agoraLiveController.startLiveStreaming.value !=
                      LiveStreamingStatus.none
                  ? Container()
                  : Container(
                      color: AppColorConstants.themeColor.withValues(
                        alpha: 0.2,
                      ),
                      child: SMTabBar(
                        tabs: tabs,
                        canScroll: true,
                        hideDivider: false,
                        controller: tabController,
                      ),
                    ).round(50),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
