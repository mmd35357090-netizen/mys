import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/tvs/tv_channel_detail.dart';
import 'package:foap/model/live_tv_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../controllers/tv/live_tv_streaming_controller.dart';

class FavTvList extends StatefulWidget {
  const FavTvList({super.key}) ;

  @override
  State<FavTvList> createState() => _FavTvListState();
}

class _FavTvListState extends State<FavTvList> {
  final TvStreamingController _tvStreamingController = Get.find();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tvStreamingController.clearTvs();
      loadData();
    });
    super.initState();
  }

  loadData() {
    _tvStreamingController.getFavTvs();
  }

  @override
  void dispose() {
    _tvStreamingController.clearTvs();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          children: [

            backNavigationBar(title: favouriteString),
            Expanded(child: tvList()),
          ],
        ));
  }

  Widget tvList() {
    return GetBuilder<TvStreamingController>(
        init: _tvStreamingController,
        builder: (ctx) {
          return _tvStreamingController.isLoadingFavTvs
              ? SizedBox(
                  height: (Get.height / 1.5),
                  width: (Get.width),
                  child: const Center(child: CircularProgressIndicator()))
              : _tvStreamingController.tvs.isEmpty
                  ? emptyData(title: noDataString, subTitle: '')
                  : GridView.builder(
                      padding: EdgeInsets.fromLTRB(DesignConstants.horizontalPadding, 4,
                          DesignConstants.horizontalPadding, 40),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        mainAxisExtent: 150,
                      ),
                      itemCount: _tvStreamingController.tvs.length,
                      itemBuilder: (BuildContext context, int index) {
                        TvModel tvModel = _tvStreamingController.tvs[index];
                        return Container(
  decoration: BoxDecoration(
    color: AppColorConstants.cardColor,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
        color: AppColorConstants.dividerColor.withValues(alpha: 0.5),
        width: 0.6),
    boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 5))
          ],
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: Stack(fit: StackFit.expand, children: [
      CachedNetworkImage(
        imageUrl: tvModel.image,
        fit: BoxFit.cover,
      ),
      Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: Container(
          padding: const EdgeInsets.fromLTRB(6, 14, 6, 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.7)
              ],
            ),
          ),
          child: BodySmallText(tvModel.name,
              color: Colors.white,
              maxLines: 1,
              weight: TextWeight.semiBold),
        ),
      ),
    ]),
  ),
).ripple(() {
  Get.to(() => TVChannelDetail(
        tvModel: tvModel,
      ));
});
                      },
                    ).addPullToRefresh(
                      refreshController: _refreshController,
                      onRefresh: () {},
                      onLoading: () {
                        loadData();
                      },
                      enablePullUp: true,
                      enablePullDown: false);
        });
  }
}
