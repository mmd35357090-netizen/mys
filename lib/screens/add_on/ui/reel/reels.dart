import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/reel_imports.dart';

import '../../../content_creator_view.dart';

class Reels extends StatefulWidget {
  final bool needBackBtn;

  const Reels({super.key, required this.needBackBtn});

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
    _reelsController.clearReels();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
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
                            index, _reelsController.publicReels[index]);
                      },
                      children: [
                        for (int i = 0;
                            i < _reelsController.publicReels.length;
                            i++)
                          SizedBox(
                            height: Get.height,
                            width: Get.width,
                            // color: Colors.brown,
                            child: ReelVideoPlayer(
                              reel: _reelsController.publicReels[i],
                              // play: false,
                            ),
                          )
                      ]);
                }),
            Positioned(
                right: DesignConstants.horizontalPadding,
                left: DesignConstants.horizontalPadding,
                top: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widget.needBackBtn
                        ? Container(
                            height: 40,
                            width: 40,
                            color: AppColorConstants.themeColor
                                .withValues(alpha: 0.5),
                            child: ThemeIconWidget(
                              ThemeIcon.backArrow,
                              color: Colors.white,
                            ).lP8.ripple(() {
                              Get.back();
                            }),
                          ).circular
                        : Container(),
                    Container(
                      height: 40,
                      width: 40,
                      color: AppColorConstants.themeColor
                          .withValues(alpha: 0.5),
                      child: ThemeIconWidget(
                        ThemeIcon.camera,
                        color: Colors.white,
                      ).ripple(() {
                        // Get.to(() => const CreateReelScreen());
                        Future.delayed(
                          Duration.zero,
                          () => showGeneralDialog(
                              context: Get.context!,
                              pageBuilder: (context, animation,
                                      secondaryAnimation) =>
                                  const ContentCreatorView(
                                    animateToIndex: 1,
                                  )),
                        );
                      }),
                    ).circular,
                  ],
                ))
          ],
        ));
  }
}
