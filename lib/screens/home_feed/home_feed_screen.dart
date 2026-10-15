import 'package:flutter/cupertino.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/story_imports.dart';
import 'package:foap/model/live_model.dart';
import 'package:foap/screens/home_feed/story_uploader.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../components/post_card/post_card.dart';
import '../../controllers/post/add_post_controller.dart';
import '../../controllers/live/agora_live_controller.dart';
import '../../controllers/home/home_controller.dart';
import '../../model/post_model.dart';
import '../content_creator_view.dart';
import '../dashboard/dashboard_screen.dart';
import '../dashboard/map_screen.dart';
import '../settings_menu/settings_controller.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  HomeFeedState createState() => HomeFeedState();
}

class HomeFeedState extends State<HomeFeedScreen> {
  final HomeController _homeController = Get.find();
  final AddPostController _addPostController = Get.find();
  final AgoraLiveController _agoraLiveController = Get.find();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final SettingsController _settingsController = Get.find();
  final DashboardController _dashboardController = Get.find();
  final _controller = ScrollController();

  String? selectedValue;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
      _homeController.loadQuickLinksAccordingToSettings();
    });
  }

  loadMore() {
    loadPosts();
  }

  refreshData() {
    _homeController.clearPosts();
    loadData();
  }

  @override
  void dispose() {
    super.dispose();
    _homeController.clear();
    _homeController.closeQuickLinks();
  }

  loadPosts() {
    _homeController.getPosts(callback: () {
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
    });

    _homeController.getPromotionalPosts();
  }

  void loadData() {
    loadPosts();
    if (_settingsController.setting.value!.enableStories) {
      _homeController.getStories();
    }
  }

  @override
  void didUpdateWidget(covariant HomeFeedScreen oldWidget) {
    loadData();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 55,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Heading4Text(
                  AppConfigConstants.appName,
                  weight: TextWeight.semiBold,
                  color: AppColorConstants.themeColor,
                ),
                const Spacer(),
                Obx(() => CupertinoSegmentedControl(
                    groupValue: _homeController.selectedSegment.value,
                    children: <int, Widget>{
                      0: BodySmallText(
                        allString.tr,
                        color: _homeController.selectedSegment.value == 0
                            ? Colors.white
                            : null,
                      ).hP4,
                      1: BodySmallText(followingString.tr,
                              color:
                                  _homeController.selectedSegment.value ==
                                          1
                                      ? Colors.white
                                      : null)
                          .hP4,
                    },
                    unselectedColor: AppColorConstants.backgroundColor,
                    selectedColor: AppColorConstants.themeColor,
                    onValueChanged: (value) {
                      _homeController.selectSegment(value! as int);
                    })),
                const Spacer(),
                SizedBox(
                    height: 30,
                    width: 30,
                    child: ThemeIconWidget(
                      ThemeIcon.plus,
                      size: 25,
                    )).ripple(() {
                  Future.delayed(
                    Duration.zero,
                    () => showGeneralDialog(
                        context: Get.context!,
                        pageBuilder:
                            (context, animation, secondaryAnimation) =>
                                const ContentCreatorView()),
                  );
                }),
                const SizedBox(
                  width: 5,
                ),
                // SizedBox(
                //     height: 30,
                //     width: 30,
                //     child: ThemeIconWidget(
                //       ThemeIcon.map,
                //       size: 25,
                //     )).ripple(() {
                //   Get.to(() => MapsUsersScreen());
                // }),
                // const SizedBox(
                //   width: 5,
                // ),
                SizedBox(
                  height: 30,
                  width: 30,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ThemeIconWidget(
                        ThemeIcon.chat,
                        size: 25,
                      ).ripple(() {
                        Get.to(() => const ChatHistory());
                      }),
                      Obx(() =>
                          _dashboardController.unreadMsgCount.value == 0
                              ? Container()
                              : Positioned(
                                  top: 0,
                                  right: 5,
                                  child: Container(
                                    color: AppColorConstants.red,
                                    height: 10,
                                    width: 10,
                                  ).circular,
                                ))
                    ],
                  ),
                ),
              ],
            ).hp(10),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: postsView(),
            ),
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
                    ? _addPostController.postingMedia.first.thumbnail !=
                            null
                        ? Image.memory(
                            _addPostController
                                .postingMedia.first.thumbnail!,
                            fit: BoxFit.cover,
                            width: 40,
                            height: 40,
                          ).round(5)
                        : _addPostController
                                    .postingMedia.first.mediaType ==
                                GalleryMediaType.photo
                            ? Image.file(
                                _addPostController
                                    .postingMedia.first.file!,
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

  Widget storiesView() {
    return SizedBox(
      height: storyCircleSize + (storyCircleSize / 2),
      child: GetBuilder<HomeController>(
          init: _homeController,
          builder: (ctx) {
            return StoryUpdatesBar(
              stories: _homeController.stories,
              // liveUsers: _homeController.liveUsers,
              addStoryCallback: () {
                openStoryUploader();
              },
              viewStoryCallback: (story) {
                if (story.isLive) {
                  LiveModel live = LiveModel();
                  live.channelName =
                      story.user!.liveCallDetail!.channelName;
                  live.mainHostUserDetail = story.user;
                  live.token = story.user!.liveCallDetail!.token;
                  live.id = story.user!.liveCallDetail!.id;
                  _agoraLiveController.joinAsAudience(
                    live: live,
                  );
                } else {
                  Get.to(
                      () => StoryViewer(
                            story: story,
                            storyDeleted: () {
                              _homeController.getStories();
                            },
                          ),
                      fullscreenDialog: true);
                }
              },
              // joinLiveUserCallback: (user) {
              //
              // },
            ).hp(DesignConstants.horizontalPadding / 2);
          }),
    );
  }

  postsView() {
    int offset = _settingsController.setting.value!.enableStories ? 2 : 1;
    return Obx(() {
      return ListView.separated(
              controller: _controller,
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: _homeController.posts.length + offset,
              itemBuilder: (context, index) {
                if (index == 0 &&
                    _settingsController.setting.value!.enableStories) {
                  return Obx(() =>
                      _homeController.isRefreshingStories.value == true
                          ? const StoryAndHighlightsShimmer()
                          : storiesView());
                } else if (index == offset - 1) {
                  return postingView().hP16;
                } else {
                  PostModel model = _homeController.posts[index - offset];
                  return PostCard(
                    model: model,
                    removePostHandler: () {
                      _homeController.removePostFromList(model);
                    },
                    blockUserHandler: () {
                      _homeController.removeUsersAllPostFromList(model);
                    },
                  );
                }
              },
              separatorBuilder: (context, index) {
                if (index > 0 &&
                    index % 5 == 0 &&
                    _homeController.sponsoredPosts.length >= index / 5) {
                  PostModel post =
                      _homeController.sponsoredPosts[(index ~/ 5) - 1];
                  return Column(
                    children: [
                      PostCard(
                        model: post,
                        removePostHandler: () {
                          _homeController.removePostFromList(post);
                        },
                        blockUserHandler: () {
                          _homeController.removeUsersAllPostFromList(post);
                        },
                      ),
                      divider(
                        height: index > (offset - 1) ? 10 : 0,
                      ).tP16
                    ],
                  ).vp(index > (offset - 1) ? 16 : 8);
                } else {
                  return divider(
                    height: index > 1 ? 10 : 0,
                  ).vp(index > 1 ? 16 : 8);
                }
              })
          .addPullToRefresh(
              refreshController: _refreshController,
              enablePullUp: true,
              onRefresh: refreshData,
              onLoading: loadMore,
              enablePullDown: true);
    });
  }
}
