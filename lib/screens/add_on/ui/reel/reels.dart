import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/reel_imports.dart';

import '../../../content_creator_view.dart';
import '../../../../components/reel_ad_page.dart';
import '../../../../util/ad_gate.dart';


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
                  final reels = _reelsController.publicReels;
                  final bool adsOn = ReelSlots.adsOn();
                  final int every = ReelSlots.every();
                  final slots = ReelSlots.layout(reels.length, every, adsOn);
                  return PageView(
                      scrollDirection: Axis.vertical,
                      allowImplicitScrolling: true,
                      onPageChanged: (page) {
                        if (page >= slots.length) return;
                        final r = slots[page];
                        if (r != null) {
                          _reelsController.currentPageChanged(r, reels[r]);
                          AdGate.onReelViewed();
                        }
                      },
                      children: [
                        for (int p = 0; p < slots.length; p++)
                          if (slots[p] != null)
                            SizedBox(
                              height: Get.height,
                              width: Get.width,
                              child: ReelVideoPlayer(
                                reel: reels[slots[p]!],
                              ),
                            )
                          else
                            ReelAdPage(
                              key: ValueKey('reel_ad_page_$p'),
                              adNumber: slots.sublist(0, p).where((e) => e == null).length,
                              hostReelId: reels[slots[p - 1]!].id,
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
                            height: 42,
                            width: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withValues(alpha: 0.35),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25)),
                            ),
                            child: ThemeIconWidget(
                              ThemeIcon.backArrow,
                              color: Colors.white,
                            ).lP8.ripple(() {
                              Get.back();
                            }),
                          )
                        : Container(),
                    Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.35),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25)),
                      ),
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
                    ),
                  ],
                ))
          ],
        ));
  }
}
