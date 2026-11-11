import 'package:foap/controllers/podcast/podcast_streaming_controller.dart';
import 'package:foap/screens/add_on/model/podcast_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:readmore/readmore.dart' as read_more;
import 'audio_song_player.dart';
import 'package:foap/helper/imports/common_import.dart';

class PodcastDetail extends StatefulWidget {
  final PodcastModel podcastModel;

  const PodcastDetail({super.key, required this.podcastModel}) ;

  @override
  State<PodcastDetail> createState() => _PodcastDetailState();
}

class _PodcastDetailState extends State<PodcastDetail> {
  final PodcastStreamingController _podcastStreamingController = Get.find();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _podcastStreamingController.getPodcastEpisode(
          podcastId: widget.podcastModel.id, callback: () {});
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _podcastStreamingController.clearPodcastEpisodes();
  }

  loadMore() {
    _podcastStreamingController.getPodcastEpisode(
        podcastId: widget.podcastModel.id,
        callback: () {
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
              backNavigationBar(title: widget.podcastModel.name),
              Expanded(
                child: CustomScrollView(slivers: [
                  SliverList(
                      delegate: SliverChildListDelegate([
                    podcastInfo(),
                    const SizedBox(
                      height: 40,
                    ),
                    Heading6Text(
                      episodesString.tr,
                      // color: AppColorConstants.themeColor,
                      weight: TextWeight.bold,
                    ).hp(DesignConstants.horizontalPadding),
                    const SizedBox(
                      height: 20,
                    ),
                    Obx(() => SizedBox(
                          height: _podcastStreamingController
                                  .podcastEpisodes.length *
                              70,
                          child: ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.vertical,
                            itemCount: _podcastStreamingController
                                .podcastEpisodes.length,
                            itemBuilder: (BuildContext context, int index) {
                              return addRecord(index);
                            },
                            separatorBuilder: (ctx, index) {
                              return const SizedBox(
                                height: 10,
                              );
                            },
                          ).hp(DesignConstants.horizontalPadding),
                        )),
                  ]))
                ]).addPullToRefresh(
                    refreshController: _refreshController,
                    onRefresh: () {},
                    onLoading: () {
                      loadMore();
                    },
                    enablePullUp: true,
                    enablePullDown: false),
              )
            ]));
  }

  Widget podcastInfo() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CachedNetworkImage(
        imageUrl: widget.podcastModel.image,
        fit: BoxFit.cover,
        width: Get.width,
        height: 220,
      ).round(22).setPadding(
          left: DesignConstants.horizontalPadding,
          right: DesignConstants.horizontalPadding,
          top: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            Container(
                    color: AppColorConstants.themeColor.withValues(alpha: 0.12),
                    child: BodyMediumText(widget.podcastModel.ageGroup,
                            color: AppColorConstants.themeColor,
                            weight: TextWeight.semiBold)
                        .setPadding(left: 12, right: 12, top: 5, bottom: 5))
                .round(14),
            const SizedBox(width: 10),
            Container(
                    color: AppColorConstants.themeColor.withValues(alpha: 0.12),
                    child: BodyMediumText(widget.podcastModel.language,
                            color: AppColorConstants.themeColor,
                            weight: TextWeight.semiBold)
                        .setPadding(left: 12, right: 12, top: 5, bottom: 5))
                .round(14),
          ],
        ),
        Heading5Text(
          widget.podcastModel.name,
          weight: TextWeight.bold,
        ).vP16,
        read_more.ReadMoreText(
          widget.podcastModel.description,
          trimLines: 2,
          trimMode: read_more.TrimMode.Line,
          colorClickableText: Colors.white,
          trimCollapsedText: showMoreString.tr,
          style:
              TextStyle(fontSize: 14, color: AppColorConstants.mainTextColor),
          trimExpandedText: '    ${showLessString.tr}',
          moreStyle: TextStyle(
              fontSize: 14,
              color: AppColorConstants.mainTextColor,
              fontWeight: FontWeight.bold),
          lessStyle: TextStyle(
              fontSize: 14,
              color: AppColorConstants.mainTextColor,
              fontWeight: FontWeight.bold),
        ),
      ]).setPadding(
          left: DesignConstants.horizontalPadding,
          right: DesignConstants.horizontalPadding,
          top: 15),
    ]);
  }

  Widget addRecord(int index) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorConstants.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColorConstants.dividerColor.withValues(alpha: 0.5),
            width: 0.6),
      ),
      height: 60,
      child: ListTile(
        contentPadding: const EdgeInsets.all(6),
        leading: Stack(
          children: [
            CachedNetworkImage(
              imageUrl:
                  _podcastStreamingController.podcastEpisodes[index].imageUrl,
              fit: BoxFit.cover,
              height: 50,
              width: 50,
            ).round(10),
            Positioned.fill(
                child: Icon(Icons.play_circle_fill_rounded,
                    color: Colors.white.withValues(alpha: 0.9)))
          ],
        ),
        title: BodyLargeText(
          _podcastStreamingController.podcastEpisodes[index].name,
          maxLines: 2,

        ),
        dense: true,
      ),
    ).ripple(() {
      Get.to(() => AudioSongPlayer(
          currentSongIndex: index,
          songsArray: _podcastStreamingController.podcastEpisodes,
          show: widget.podcastModel));
    });
  }
}
