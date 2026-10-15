import 'package:foap/helper/imports/common_import.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../../components/post_card/post_card.dart';
import '../../../../controllers/post/add_post_controller.dart';
import '../../../../model/post_model.dart';
import '../../controllers/fund_raising/fund_raising_controller.dart';

class FundraisingFeedScreen extends StatefulWidget {
  const FundraisingFeedScreen({super.key});

  @override
  FundraisingFeedScreenState createState() => FundraisingFeedScreenState();
}

class FundraisingFeedScreenState extends State<FundraisingFeedScreen> {
  final FundRaisingController _fundRaisingController = Get.find();
  final AddPostController _addPostController = Get.find();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final _controller = ScrollController();

  String? selectedValue;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
  }

  loadData() {
    _fundRaisingController.loadMorePosts(callback: () {
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
    });
  }

  refreshData() {
    _fundRaisingController.refreshPosts(callback: () {
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
    });
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
            backNavigationBar(
              title: postsString.tr,
            ),
            Expanded(child: postsView()),
          ],
        ));
  }

  Widget postingView() {
    return Obx(() => _addPostController.isPosting.value
        ? Container(
            height: 55,
            color: AppColorConstants.cardColor,
            child: Row(
              children: [
                _addPostController.postingMedia.isNotEmpty &&
                        _addPostController.postingMedia.first.mediaType !=
                            GalleryMediaType.gif
                    ? _addPostController.postingMedia.first.thumbnail != null
                        ? Image.memory(
                            _addPostController.postingMedia.first.thumbnail!,
                            fit: BoxFit.cover,
                            width: 40,
                            height: 40,
                          ).round(5)
                        : _addPostController.postingMedia.first.mediaType ==
                                GalleryMediaType.photo
                            ? Image.file(
                                _addPostController.postingMedia.first.file!,
                                fit: BoxFit.cover,
                                width: 40,
                                height: 40,
                              ).round(5)
                            // : BodyLargeText(_addPostController.postingTitle)
                            : Container()
                    // : BodyLargeText(_addPostController.postingTitle),
                    : Container(),
                const SizedBox(
                  width: 10,
                ),
                Heading5Text(
                  _addPostController.isErrorInPosting.value
                      ? postFailedString.tr
                      : postingString.tr,
                ),
                const Spacer(),
                _addPostController.isErrorInPosting.value
                    ? Row(
                        children: [
                          Heading5Text(
                            discardString.tr,
                            weight: TextWeight.medium,
                          ).ripple(() {
                            _addPostController.discardFailedPost();
                          }),
                          const SizedBox(
                            width: 20,
                          ),
                          Heading5Text(
                            retryString.tr,
                            weight: TextWeight.medium,
                          ).ripple(() {
                            _addPostController.retryPublish();
                          }),
                        ],
                      )
                    : Container()
              ],
            ).hP8,
          ).backgroundCard(radius: 10).bp(20)
        : Container());
  }

  postsView() {
    return Obx(() {
      return ListView.separated(
              controller: _controller,
              padding: const EdgeInsets.only(top: 20, bottom: 100),
              itemCount: _fundRaisingController.posts.length,
              itemBuilder: (context, index) {
                PostModel model = _fundRaisingController.posts[index];
                return PostCard(
                  model: model,
                  removePostHandler: () {
                    _fundRaisingController.removePostFromList(model);
                  },
                  blockUserHandler: () {
                    _fundRaisingController.removeUsersAllPostFromList(model);
                  },
                );
              },
              separatorBuilder: (context, index) {
                return divider(
                  height: 10,
                ).vP8;
              })
          .addPullToRefresh(
              refreshController: _refreshController,
              enablePullUp: true,
              onRefresh: refreshData,
              onLoading: loadData,
              enablePullDown: true);
    });
  }
}
