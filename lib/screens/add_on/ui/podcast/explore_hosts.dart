import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/event_imports.dart';
import 'package:foap/screens/add_on/ui/podcast/host_list.dart';
import 'package:foap/screens/add_on/ui/podcast/podcast_detail.dart';
import 'package:foap/screens/add_on/ui/podcast/podcast_host_detail.dart';
import '../../../../components/paging_scrollview.dart';
import '../../../../controllers/podcast/podcast_streaming_controller.dart';
import '../../model/podcast_banner_model.dart';

class ExploreHosts extends StatefulWidget {
  final bool addBackBtn;
  final PodcastCategoryModel? category;

  const ExploreHosts({super.key, required this.addBackBtn, this.category});

  @override
  State<ExploreHosts> createState() => _ExploreHostsState();
}

class _ExploreHostsState extends State<ExploreHosts> {
  final PodcastStreamingController _podcastController = Get.find();
  final WKCarouselSliderController _controller =
      WKCarouselSliderController();
  int _current = 0;

  @override
  void initState() {
    _podcastController.getHosts(callback: () {});
    super.initState();
  }

  @override
  void dispose() {
    _podcastController.clearHosts();
    _podcastController.clearHostSearch();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Column(
              children: [
                backNavigationBar(
                  title: hostsString.tr,
                ),
                Expanded(
                  child: Obx(() => PagingScrollView(
                      child: Column(
                        children: [
                          SFSearchBar(
                                  onSearchChanged: (text) {
                                    _podcastController.setHostName(text);
                                  },
                                  onSearchCompleted: (text) {})
                              .p(DesignConstants.horizontalPadding),
                          if (_podcastController.banners.isNotEmpty)
                            banner(),
                          // if (widget.category == null)
                          //   GetBuilder<PodcastStreamingController>(
                          //       init: _podcastController,
                          //       builder: (ctx) {
                          //         return CategorySlider(
                          //           categories: _podcastController.categories,
                          //           onSelection: (category) {
                          //             _podcastController
                          //                 .setOfferCategoryId(category?.id);
                          //           },
                          //         );
                          //       }).bp(40),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(() => _podcastController
                                          .totalHostsFound.value >
                                      0
                                  ? Row(
                                      children: [
                                        Container(
                                          height: 20,
                                          width: 5,
                                          color:
                                              AppColorConstants.themeColor,
                                        ).round(5),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Obx(() => BodyLargeText(
                                            '${found.tr} ${_podcastController.totalHostsFound} ${hostsString.tr.toLowerCase()}',
                                            weight: TextWeight.semiBold)),
                                      ],
                                    ).hp(DesignConstants.horizontalPadding)
                                  : Container()),
                              const SizedBox(
                                height: 20,
                              ),
                              HostList()
                            ],
                          )
                        ],
                      ),
                      loadMoreCallback: (refreshController) {
                        _podcastController.getHosts(callback: () {
                          refreshController.loadComplete();
                        });
                      })),
                ),
              ],
            )));
  }

  banner() {
    return _podcastController.banners.length == 1
        ? CachedNetworkImage(
            imageUrl: _podcastController.banners[0].coverImageUrl!,
            fit: BoxFit.cover,
            width: Get.width,
            height: 200,
          )
            .round(10)
            .setPadding(top: 10, bottom: 15, left: 15, right: 15)
            .ripple(() {
            bannerClickAction(_podcastController.banners.first);
            //2 Show
            // int? showId = _podcastStreamingController.banners[0].referenceId;
          })
        : Stack(children: [
            WKCarouselSlider(
              items: [
                for (PodcastBannerModel banner
                    in _podcastController.banners)
                  CachedNetworkImage(
                    imageUrl: banner.coverImageUrl!,
                    fit: BoxFit.cover,
                    width: Get.width,
                    height: 200,
                  )
                      .round(10)
                      .setPadding(top: 10, bottom: 0, left: 10, right: 10)
                      .ripple(() {
                    bannerClickAction(banner);
                  })
              ],
              autoPlayInterval: const Duration(seconds: 4),
              autoPlay: true,
              enlargeCenterPage: false,
              enableInfiniteScroll: true,
              height: 200,
              viewportFraction: 1,
              onPageChanged: (index) {
                setState(() {
                  _current = index;
                });
              },
            ),
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _podcastController.banners
                    .asMap()
                    .entries
                    .map((entry) {
                  return GestureDetector(
                    onTap: () => _controller.animateToPage(entry.key),
                    child: Container(
                      width: 12.0,
                      height: 12.0,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 4.0),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColorConstants.themeColor
                                  : Colors.grey)
                              .withValues(
                                  alpha:
                                      _current == entry.key ? 0.9 : 0.4)),
                    ),
                  );
                }).toList(),
              ).alignBottomCenter,
            ),
          ]).bp(15);
  }

  bannerClickAction(PodcastBannerModel banner) {
    if (banner.bannerType == PodcastBannerType.show) {
      _podcastController.getPodcastById(banner.referenceId!, (show) {
        Get.to(() => PodcastDetail(podcastModel: show));
        //find channel id in array
      });
    } else if (banner.bannerType == PodcastBannerType.host) {
      _podcastController.getHostById(
          banner.referenceId!,
          (host) => {
                if (_podcastController.hostDetail.value != null)
                  {Get.to(() => PodcastHostDetail(host: host))}
              });
    }
  }
}
