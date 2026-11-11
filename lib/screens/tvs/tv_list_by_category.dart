import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/tv_imports.dart';
import 'package:foap/model/live_tv_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../model/category_model.dart';

class TvListByCategory extends StatefulWidget {
  final TvCategoryModel category;

  const TvListByCategory({super.key, required this.category}) ;

  @override
  State<TvListByCategory> createState() => _TvListByCategoryState();
}

class _TvListByCategoryState extends State<TvListByCategory> {
  final TvStreamingController _tvStreamingController = Get.find();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
    super.initState();
  }

  loadData() {
    _tvStreamingController.getTvs(
        categoryId: widget.category.id,
        callback: () {
          _refreshController.loadComplete();
        });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          children: [
            SizedBox(
              height: 230,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: widget.category.coverImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.35),
                            Colors.black.withValues(alpha: 0.75)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: DesignConstants.horizontalPadding,
                    right: DesignConstants.horizontalPadding,
                    child: Heading4Text(
                      widget.category.name,
                      color: Colors.white,
                      weight: TextWeight.bold,
                    ),
                  ),
                  Positioned(
                      top: 50,
                      left: DesignConstants.horizontalPadding,
                      child: Container(
                        height: 38,
                        width: 38,
                        color: Colors.black.withValues(alpha: 0.35),
                        child: Center(
                          child: ThemeIconWidget(
                            ThemeIcon.backArrow,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ).round(19).ripple(() {
                        Get.back();
                      }))
                ],
              ),
            ).bottomRounded(28),
            const SizedBox(
              height: 16,
            ),
            Expanded(child: tvList())
          ],
        ));
  }

  Widget tvList() {
    return GetBuilder<TvStreamingController>(
        init: _tvStreamingController,
        builder: (ctx) {
          return _tvStreamingController.tvs.isEmpty
              ? SizedBox(
                  height: (Get.height / 1.5),
                  width: (Get.width),
                  child: const Center(child: CircularProgressIndicator()))
              : GridView.builder(
                  padding: EdgeInsets.fromLTRB(DesignConstants.horizontalPadding, 4,
                          DesignConstants.horizontalPadding, 40),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
