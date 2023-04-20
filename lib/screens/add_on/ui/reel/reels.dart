import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/add_on/components/reel/reel_video_player.dart';
import 'package:foap/screens/add_on/controller/reel/reels_controller.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/reel_imports.dart';

import 'create_reel_video.dart';

class Reels extends StatefulWidget {
  const Reels({Key? key}) : super(key: key);

  @override
  State<Reels> createState() => _ReelsState();
}

class _ReelsState extends State<Reels> {
  final ReelsController _reelsController = Get.find();

  @override
  void initState() {
    super.initState();
    _reelsController.getReels();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
          backgroundColor: AppColorConstants.backgroundColor,
          body: Stack(
            children: [
              GetBuilder<ReelsController>(
                  init: _reelsController,
                  builder: (ctx) {
                    return PageView(
                        scrollDirection: Axis.vertical,
                        allowImplicitScrolling: true,
                        onPageChanged: (index) {
                          _reelsController.currentPageChanged(
                              index, _reelsController.publicMoments[index]);
                        },
                        children: [
                          for (int i = 0;
                          i < _reelsController.publicMoments.length;
                          i++)
                            SizedBox(
                              height: Get.height,
                              width: Get.width,
                              // color: Colors.brown,
                              child: ReelVideoPlayer(
                                reel: _reelsController.publicMoments[i],
                                // play: false,
                              ),
                            )
                        ]);
                  }),
              Positioned(
                  right: 16,
                  top: 50,
                  child: const ThemeIconWidget(ThemeIcon.camera).ripple(() {
                    Get.to(() => const CreateReelScreen());
                  }))
            ],
          )),
    );
  }
}
