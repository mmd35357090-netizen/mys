import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/reel_imports.dart';

import '../../../../components/reel_ad_page.dart';
import '../../../../util/ad_gate.dart';

class ReelsList extends StatefulWidget {
  final int? audioId;
  final int index;
  final String? hashTag;
  final int? userId;
  final int? locationId;
  final List<PostModel>? reels;
  final TimelineType? source;
  final int? page;
  final int? totalPages;

  const ReelsList({
    super.key,
    this.audioId,
    required this.index,
    this.page,
    this.totalPages,
    this.hashTag,
    this.userId,
    this.locationId,
    this.reels,
    this.source,
  }) ;

  @override
  State<ReelsList> createState() => _ReelsListState();
}

class _ReelsListState extends State<ReelsList> {
  final ReelsController _reelsController = Get.find();

  PageController controller = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reelsController.addReels(widget.reels ?? [], widget.page);

      controller.jumpToPage(ReelSlots.pageOfReel(
          widget.index, ReelSlots.every(), ReelSlots.adsOn()));
      loadData();
    });
  }

  void loadData() {
    if (widget.userId != null) {
      PostSearchQuery query = PostSearchQuery();
      query.userId = widget.userId!;
      _reelsController.setReelsSearchQuery(query);
    }
    if (widget.hashTag != null) {
      PostSearchQuery query = PostSearchQuery();
      query.hashTag = widget.hashTag!;
      _reelsController.setReelsSearchQuery(query);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  GetBuilder<ReelsController>(
                      init: _reelsController,
                      builder: (ctx) {
                        final reels = _reelsController.filteredReels;
                        final bool adsOn = ReelSlots.adsOn();
                        final int every = ReelSlots.every();
                        final slots = ReelSlots.layout(reels.length, every, adsOn);
                        return PageView(
                            controller: controller,
                            scrollDirection: Axis.vertical,
                            allowImplicitScrolling: true,
                            onPageChanged: (page) {
                              if (page >= slots.length) return;
                              final r = slots[page];
                              if (r == null) return;
                              _reelsController.currentPageChanged(r, reels[r]);
                              AdGate.onReelViewed();
                              if (r == reels.length - 2) {
                                _reelsController.getReels();
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
                  // Positioned(
                  //     left: 0,
                  //     right: 0,
                  //     top: 0,
                  //     child: backNavigationBar(
                  //          title: reelsString.tr))
                ],
              ),
            ),
            // Container(
            //   height: 90,
            //   color: AppColorConstants.backgroundColor,
            //   child: Align(
            //     alignment: Alignment.centerLeft,
            //     child: SizedBox(
            //       height: 50,
            //       child: Text(addCommentString.tr),
            //     ).hp(DesignConstants.horizontalPadding),
            //   ),
            // ).ripple(() {})
          ],
        ));
  }
}
