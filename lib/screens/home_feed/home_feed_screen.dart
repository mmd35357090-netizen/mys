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
          children: [
            Expanded(
              child: postsView(),
            ),
          ],
        ));
  }

  Widget _buildTopFilterTab({required String title, required bool isSelected, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColorConstants.themeColor : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              title,
              maxLines: 1,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
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
                            : Container()
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
            ).hp(DesignConstants.horizontalPadding / 2);
          }),
    );
  }
    postsView() {
    int baseOffset = _settingsController.setting.value!.enableStories ? 3 : 2;
    
    return Obx(() {
      return ListView.separated(
              controller: _controller,
              padding: const EdgeInsets.only(top: 50, bottom: 100),
              itemCount: _homeController.posts.length + baseOffset,
              itemBuilder: (context, index) {
                
                // ১. মেইন হেডার (অ্যাপ নেম ও আইকন)
                if (index == 0) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Heading3Text(
                          AppConfigConstants.appName,
                          weight: TextWeight.bold,
                          color: Colors.black,
                          maxLines: 1, 
                        ),
                      ),
                      Row(
                        children: [
                          SizedBox(
                              height: 35,
                              width: 35,
                              child: ThemeIconWidget(
                                ThemeIcon.plus,
                                size: 26,
                                color: Colors.black,
                              )).ripple(() {
                            Future.delayed(
                              Duration.zero,
                              () => showGeneralDialog(
                                  context: Get.context!,
                                  pageBuilder: (context, animation, secondaryAnimation) =>
                                      const ContentCreatorView()),
                            );
                          }),
                          const SizedBox(width: 15),
                          SizedBox(
                            height: 35,
                            width: 35,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ThemeIconWidget(
                                  ThemeIcon.notification,
                                  size: 26,
                                  color: AppColorConstants.themeColor,
                                ).ripple(() {
                                  // নোটিফিকেশন ক্লিক অ্যাকশন
                                }),
                                Obx(() => _dashboardController.unreadMsgCount.value == 0
                                    ? Container()
                                    : Positioned(
                                        top: 2,
                                        right: 2,
                                        child: Container(
                                          color: AppColorConstants.red,
                                          height: 9,
                                          width: 9,
                                        ).circular,
                                      ))
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ).hp(16);
                }
                
                // ২. স্টোরি সেকশন
                if (index == 1 && _settingsController.setting.value!.enableStories) {
                  return Obx(() => _homeController.isRefreshingStories.value == true
                      ? const Padding(
                          padding: EdgeInsets.only(top: 15),
                          child: StoryAndHighlightsShimmer(),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: storiesView(),
                        ));
                }
                
                // ৩. স্ক্রোলযোগ্য কাস্টম ট্যাব বার
                int tabIndex = _settingsController.setting.value!.enableStories ? 2 : 1;
                if (index == tabIndex) {
                  return Container(
                    height: 38,
                    margin: const EdgeInsets.symmetric(vertical: 15),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildTopFilterTab(
                          title: allString.tr,
                          isSelected: _homeController.selectedSegment.value == 0,
                          onTap: () => _homeController.selectSegment(0),
                        ),
                        _buildTopFilterTab(
                          title: followingString.tr,
                          isSelected: _homeController.selectedSegment.value == 1,
                          onTap: () => _homeController.selectSegment(1),
                        ),
                        _buildTopFilterTab(
                          title: "Videos",
                          isSelected: _homeController.selectedSegment.value == 2,
                          onTap: () => _homeController.selectSegment(2),
                        ),
                      ],
                    ),
                  );
                }
                
                // ৪. পোস্টিং প্রোগ্রেস ভিউ
                if (index == baseOffset - 1) {
                  return postingView().hP16;
                } 
                
                // ৫. সাধারণ পোস্ট কার্ড লিস্ট
                else {
                  PostModel model = _homeController.posts[index - baseOffset];
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
                if (index < baseOffset) {
                  return const SizedBox.shrink();
                }
                
                if (index > 0 &&
                    index % 5 == 0 &&
                    _homeController.sponsoredPosts.length >= index / 5) {
                  PostModel post = _homeController.sponsoredPosts[(index ~/ 5) - 1];
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: index > (baseOffset - 1) ? 16.0 : 8.0,
                    ),
                    child: Column(
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
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: divider(
                            height: index > (baseOffset - 1) ? 10 : 0,
                          ),
                        )
                      ],
                    ),
                  );
                } else {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: index > 1 ? 16.0 : 8.0,
                    ),
                    child: divider(
                      height: index > 1 ? 10 : 0,
                    ),
                  );
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
