import 'package:camera/camera.dart';
import 'package:foap/components/sm_tab_bar.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/live_imports.dart';
import 'package:foap/helper/imports/post_imports.dart';
import 'package:foap/helper/imports/setting_imports.dart';
import 'package:foap/main.dart';
import 'package:foap/screens/add_on/ui/reel/create_reel_video.dart';

class CameraControllerService extends GetxController {
  late CameraController controller;

  Future<void> initializeCamera(CameraLensDirection lensDirection) async {
    final camera =
        cameras.firstWhere((camera) => camera.lensDirection == lensDirection);

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
        return CameraPreview(controllerService.controller).round(20);
      },
    );
  }
}

class ContentCreatorView extends StatefulWidget {
  const ContentCreatorView({super.key});

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        height: Get.height,
        width: Get.width,
        child: Stack(
          children: [
            TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: tabController,
                children: [
                  AddPostScreen(
                    postType: PostType.basic,
                    postCompletionHandler: () {},
                  ),
                  if (_settingsController.setting.value!.enableReel)
                    const CreateReelScreen(),
                  // Container(),
                  if (_settingsController.setting.value!.enableLive)
                    CheckingLiveFeasibility(successCallbackHandler: () {})
                ]),
            Obx(() => _agoraLiveController.startLiveStreaming.value !=
                    LiveStreamingStatus.none
                ? Container()
                : Positioned(
                    left: 80,
                    right: 80,
                    bottom: 25,
                    child: Container(
                      color: AppColorConstants.themeColor.withOpacity(0.2),
                      child: SMTabBar(
                        tabs: tabs,
                        canScroll: true,
                        hideDivider: false,
                        controller: tabController,
                      ),
                    ).round(50)))
          ],
        ),
      ),
    );
  }
}
