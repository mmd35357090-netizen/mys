import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/event_imports.dart';
import 'package:foap/screens/add_on/ui/podcast/podcast_list.dart';
import '../../../../components/category_slider.dart';
import '../../../../components/paging_scrollview.dart';
import '../../../../controllers/podcast/podcast_streaming_controller.dart';

class ExplorePodcasts extends StatefulWidget {
  final bool addBackBtn;
  final PodcastCategoryModel? category;

  const ExplorePodcasts({super.key, required this.addBackBtn, this.category});

  @override
  State<ExplorePodcasts> createState() => _ExplorePodcastsState();
}

class _ExplorePodcastsState extends State<ExplorePodcasts> {
  final PodcastStreamingController _podcastController = Get.find();

  @override
  void initState() {
    _podcastController.getPodcastCategories();
    _podcastController.getPodcasts(callback: () {});
    super.initState();
  }

  @override
  void dispose() {
    _podcastController.clearPodcasts();
    _podcastController.clearPodcastSearch();

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
                  title: podcastString.tr,
                ),
                Expanded(
                  child: PagingScrollView(
                      child: Column(
                        children: [
                          SFSearchBar(
                                  onSearchChanged: (text) {
                                    _podcastController.setPodcastName(text);
                                  },
                                  onSearchCompleted: (text) {})
                              .p(DesignConstants.horizontalPadding),
                          if (widget.category == null)
                            GetBuilder<PodcastStreamingController>(
                                init: _podcastController,
                                builder: (ctx) {
                                  return CategorySlider(
                                    categories: _podcastController.categories,
                                    onSelection: (category) {
                                      _podcastController
                                          .setPodcastCategoryId(category?.id);
                                    },
                                  );
                                }).bp(40),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(() =>
                                  _podcastController.totalPodcastFound.value > 0
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
                                                '${found.tr} ${_podcastController.totalPodcastFound} ${podcastString.tr.toLowerCase()}',
                                                weight: TextWeight.semiBold)),
                                          ],
                                        ).hp(DesignConstants.horizontalPadding)
                                      : Container()),
                              const SizedBox(
                                height: 20,
                              ),
                              PodcastList()
                            ],
                          )
                        ],
                      ),
                      loadMoreCallback: (refreshController) {
                        _podcastController.getPodcasts(callback: () {
                          refreshController.loadComplete();
                        });
                      }),
                ),
              ],
            )));
  }
}
