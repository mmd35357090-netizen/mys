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
  late CameraController controller;

  Future<void> initializeCamera(CameraLensDirection lensDirection) async {
    final camera = cameras
        .firstWhere((camera) => camera.lensDirection == lensDirection);

    controller = CameraController(camera, ResolutionPreset.max);
    await controller.initialize().then((_) {}).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });

    update(); // Notify listeners
  }

  clear() {
    controller.dispose();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class CameraView extends StatelessWidget {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CameraControllerService>(
      builder: (controllerService) {
        if (!controllerService.controller.value.isInitialized) {
          return Container();
        }

        // Check if the camera is front-facing
        bool isFrontCamera =
            controllerService.controller.description.lensDirection ==
                CameraLensDirection.front;

        return Transform(
          alignment: Alignment.center,
          // transform: isFrontCamera
          //     ? (Matrix4.identity()..scale(-1.0, 1.0)) // Flip horizontally
          //     : Matrix4.identity(),
          transform: Matrix4.identity(),
          // above code of scale was not working for iphone as it was flipping camera on iphone
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20), // Rounds corners
            child: CameraPreview(controllerService.controller),
          ),
        );
      },
    );
  }
}

class ContentCreatorView extends StatefulWidget {
  final int? animateToIndex;

  const ContentCreatorView({super.key, this.animateToIndex});

  @override
  State<ContentCreatorView> createState() => _ContentCreatorViewState();
}

class _ContentCreatorViewState extends State<ContentCreatorView>
    with SingleTickerProviderStateMixin {
  List<String> tabs = [postString.tr];

  late TabController tabController;
  final SettingsController _settingsController = Get.find();
  final AgoraLiveController _agoraLiveController = Get.find();

  @override
  void initState() {
    askForPermission();
    final cameraService = Get.find<CameraControllerService>();

    // Initialize the camera if not already initialized
    // if (!cameraService.controller.value.isInitialized) {
    cameraService.initializeCamera(CameraLensDirection.front);
    // }
    if (_settingsController.setting.value!.enableReel) {
      tabs.add(reelString.tr);
    }
    if (_settingsController.setting.value!.enableLive) {
      tabs.add(liveString.tr);
    }
    tabController = TabController(vsync: this, length: tabs.length)
      ..addListener(() {});
    if (widget.animateToIndex != null) {
      tabController.animateTo(widget.animateToIndex!);
    }
    super.initState();
  }

  askForPermission() {
    PermissionUtils.requestPermission(
        [Permission.camera, Permission.microphone],
        isOpenSettings: true,
        permissionGrant: () async {}, permissionDenied: () {
      // AppUtil.showToast(
      //     message: pleaseAllowAccessToCameraForLiveString.tr,
      //     isSuccess: false);
    }, permissionNotAskAgain: () {
      // AppUtil.showToast(
      //     message: pleaseAllowAccessToCameraForLiveString.tr,
      //     isSuccess: false);
    });
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
                    // Container(),
                    if (_settingsController.setting.value!.enableLive)
                      CheckingLiveFeasibility(
                          successCallbackHandler: () {})
                  ]),
            ),
            Obx(() => _agoraLiveController.startLiveStreaming.value !=
                    LiveStreamingStatus.none
                ? Container()
                : Container(
                    color: AppColorConstants.themeColor
                        .withValues(alpha: 0.2),
                    child: SMTabBar(
                      tabs: tabs,
                      canScroll: true,
                      hideDivider: false,
                      controller: tabController,
                    ),
                  ).round(50)),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
