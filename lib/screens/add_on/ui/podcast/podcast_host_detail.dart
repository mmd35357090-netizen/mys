import 'package:foap/components/paging_scrollview.dart';
import 'package:foap/controllers/podcast/podcast_streaming_controller.dart';
import 'package:foap/screens/add_on/ui/podcast/podcast_list.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:readmore/readmore.dart' as read_more;
import '../../model/podcast_model.dart';
import 'package:foap/helper/imports/common_import.dart';

class PodcastHostDetail extends StatefulWidget {
  final HostModel? host;

  const PodcastHostDetail({super.key, this.host}) ;

  @override
  State<PodcastHostDetail> createState() => _PodcastHostDetailState();
}

class _PodcastHostDetailState extends State<PodcastHostDetail> {
  final PodcastStreamingController _podcastStreamingController = Get.find();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadMore();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _podcastStreamingController.clearPodcasts();
  }

  loadMore() {
    _podcastStreamingController.setPodcastHostId(widget.host?.id);
    _podcastStreamingController.getPodcasts(callback: () {
      _refreshController.loadComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            backNavigationBar(title: widget.host?.name ?? ""),
            Expanded(
              child: PagingScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          width: Get.width,
                          height: 200,
                          child: CachedNetworkImage(
                            imageUrl: widget.host?.image ?? "",
                            fit: BoxFit.cover,
                            width: Get.width,
                            height: 200,
                          )),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Heading5Text(
                              widget.host?.name ?? "",
                              weight: FontWeight.bold,
                            ).bP16,
                            read_more.ReadMoreText(
                              widget.host?.description ?? "",
                              trimLines: 2,
                              trimMode: read_more.TrimMode.Line,
                              colorClickableText: Colors.white,
                              trimCollapsedText: showMoreString.tr,
                              trimExpandedText: '    ${showLessString.tr}',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColorConstants.mainTextColor,
                              ),
                              moreStyle: TextStyle(
                                  fontSize: 14,
                                  color: AppColorConstants.mainTextColor,
                                  fontWeight: FontWeight.bold),
                              lessStyle: TextStyle(
                                  fontSize: 14,
                                  color: AppColorConstants.mainTextColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            Heading6Text(
                              allPodcastsString.tr,
                              weight: TextWeight.bold,
                            ).tp(40)
                          ]).setPadding(
                          left: DesignConstants.horizontalPadding,
                          right: DesignConstants.horizontalPadding,
                          top: 25),
                      PodcastList(),
                    ]),
                loadMoreCallback: (controller) {
                  _podcastStreamingController.getPodcasts(callback: () {
                    controller.loadComplete();
                  });
                },
              ),
            ),
          ],
        ));
  }
}
