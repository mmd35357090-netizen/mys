import 'package:flutter/cupertino.dart';
import 'package:flutter_polls/flutter_polls.dart';
import 'package:foap/controllers/notification/notifications_controller.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/story_imports.dart';
import 'package:foap/helper/imports/setting_imports.dart';
import 'package:foap/model/live_model.dart';
import 'package:foap/model/post_model.dart';
import 'package:foap/screens/home_feed/story_uploader.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../components/post_card/post_card.dart';
import '../../controllers/post/add_post_controller.dart';
import '../../controllers/live/agora_live_controller.dart';
import '../../controllers/home/home_controller.dart';
import '../../segmentAndMenu/horizontal_menu.dart';
import '../post/content_creator_view.dart';
import '../story/story_updates_bar.dart';
import '../story/story_viewer.dart';
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
  final SettingsController _settingsController = Get.find();
  final NotificationController _notificationController = Get.find();

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  final ScrollController _controller = ScrollController();

  bool _isLoadingMore = false;
  bool _isDisposed = false;

  int pollFrequencyIndex = 10;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      loadData();
      _homeController.loadQuickLinksAccordingToSettings();
      _notificationController.getNotificationInfo();
    });

    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_controller.hasClients || _isLoadingMore) return;

    final position = _controller.position;

    if (position.pixels >= position.maxScrollExtent - 300) {
      if (_homeController.postsDataWrapper.haveMoreData.value) {
        loadMore();
      }
    }
  }

  void loadData() {
    loadPosts();

    if (_settingsController.setting.value?.enablePolls ?? false) {
      _homeController.getPolls();
    }

    if (_settingsController.setting.value?.enableStories ?? false) {
      _homeController.getStories();
    }

    _homeController.getPromotionalPosts();
  }

  void loadPosts() {
    _homeController.getPosts(callback: () {
      if (_isDisposed) return;

      _refreshController.refreshCompleted();
      _refreshController.loadComplete();

      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    });
  }

  void loadMore() {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    loadPosts();
  }

  void refreshData() {
    _homeController.clearPosts();

    setState(() {
      _isLoadingMore = false;
    });

    loadData();
  }

  void _onSegmentChanged(int segment) {
    _homeController.categoryIndexChanged(
      index: segment,
      callback: () {
        if (_isDisposed) return;

        _refreshController.refreshCompleted();
        _refreshController.loadComplete();

        if (mounted) {
          setState(() {
            _isLoadingMore = false;
          });
        }
      },
    );
  }

  @override
  void didUpdateWidget(covariant HomeFeedScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    loadData();
  }

  @override
  void dispose() {
    _isDisposed = true;

    _controller.removeListener(_onScroll);
    _controller.dispose();
    _refreshController.dispose();

    _homeController.clear();
    _homeController.closeQuickLinks();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Container(
              color: AppColorConstants.backgroundColor,
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  Row(
                    children: [
                      Heading4Text(
                        AppConfigConstants.appName,
                        weight: TextWeight.semiBold,
                      ),
                      const Spacer(),
                      const ThemeIconWidget(
                        ThemeIcon.plus,
                        size: 25,
                      ).ripple(() {
                        showGeneralDialog(
                          context: Get.context!,
                          pageBuilder: (
                            context,
                            animation,
                            secondaryAnimation,
                          ) =>
                              const ContentCreatorView(),
                        );
                      }),
                      const SizedBox(width: 20),
                      Obx(
                        () => Stack(
                          children: [
                            ThemeIconWidget(
                              ThemeIcon.notification,
                              size: 25,
                              color: AppColorConstants.themeColor,
                            )
                                .rp(
                                  _notificationController
                                              .unreadNotificationCount.value >
                                          0
                                      ? 15
                                      : 0,
                                )
                                .ripple(() {
                              Get.to(
                                () => const NotificationsScreen(),
                              );
                            }),
                            if (_notificationController
                                    .unreadNotificationCount.value >
                                0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  color: AppColorConstants.themeColor,
                                  child: Center(
                                    child: Text(
                                      _notificationController
                                          .unreadNotificationCount.value
                                          .toString(),
                                      style: const TextStyle(
                                        fontSize: 8,
                                        color: Colors.white,
                                      ),
                                    ).setPadding(
                                      top: 2,
                                      bottom: 2,
                                      left: 4,
                                      right: 4,
                                    ),
                                  ),
                                ).circular,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ).hp(20),
                ],
              ),
            ),
            Expanded(child: postsView()),
          ],
        ),
      ),
    );
  }


Widget postsView() {
  final bool enableStories =
      _settingsController.setting.value!.enableStories;

  // Story (optional) + Filter bar + Posting status
  final int offset = enableStories ? 3 : 2;

  return Obx(() {
    return ListView.separated(
      controller: _controller,
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: _homeController.posts.length + offset,

      itemBuilder: (context, index) {
        // 1. Stories
        if (enableStories && index == 0) {
          return Obx(
            () => _homeController.isRefreshingStories.value
                ? const StoryAndHighlightsShimmer()
                : storiesView(),
          );
        }

        // 2. All | Following buttons
        if (index == (enableStories ? 1 : 0)) {
          return feedFilterBar();
        }

        // 3. Posting status
        if (index == offset - 1) {
          return postingView().hP16;
        }

        // 4. Posts
        final int postIndex = index - offset;
        final PostModel model = _homeController.posts[postIndex];

        return PostCard(
          model: model,
          removePostHandler: () {
            _homeController.removePostFromList(model);
          },
          blockUserHandler: () {
            _homeController.removeUsersAllPostFromList(model);
          },
        );
      },

      separatorBuilder: (context, index) {
        if (index > 0 &&
            index % 5 == 0 &&
            _homeController.sponsoredPosts.length >= index / 5) {
          final PostModel post =
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
              divider(height: 10).tP16,
            ],
          ).vp(16);
        }

        return divider(height: index > 1 ? 10 : 0)
            .vp(index > 1 ? 16 : 8);
      },
    ).addPullToRefresh(
      refreshController: _refreshController,
      enablePullUp: true,
      onRefresh: refreshData,
      onLoading: loadMore,
      enablePullDown: true,
    );
  });
}
  
  Widget postingView() {
    return Obx(
      () => _addPostController.isPosting.value
          ? Container(
              height: 55,
              color: AppColorConstants.cardColor,
              child: Row(
                children: [
                  if (_addPostController.postingMedia.isNotEmpty &&
                      _addPostController.postingMedia.first.mediaType !=
                          GalleryMediaType.gif)
                    _addPostController.postingMedia.first.thumbnail != null
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
                            : const SizedBox.shrink(),
                  const SizedBox(width: 10),
                  Heading5Text(
                    _addPostController.isErrorInPosting.value
                        ? postFailedString.tr
                        : postingString.tr,
                  ),
                  const Spacer(),
                  if (_addPostController.isErrorInPosting.value)
                    Row(
                      children: [
                        Heading5Text(
                          discardString.tr,
                          weight: TextWeight.medium,
                        ).ripple(() {
                          _addPostController.discardFailedPost();
                        }),
                        const SizedBox(width: 20),
                        Heading5Text(
                          retryString.tr,
                          weight: TextWeight.medium,
                        ).ripple(() {
                          _addPostController.retryPublish();
                        }),
                      ],
                    ),
                ],
              ).hP8,
            ).backgroundCard(radius: 10).bp(20)
          : const SizedBox.shrink(),
    );
  }


  
  Widget storiesView() {
    return SizedBox(
      height: 110,
      child: GetBuilder<HomeController>(
        init: _homeController,
        builder: (ctx) {
          return StoryUpdatesBar(
            stories: _homeController.stories,
            addStoryCallback: openStoryUploader,
            viewStoryCallback: (story) {
              if (story.isLive) {
                final LiveModel live = LiveModel();
                live.channelName =
                    story.user!.liveCallDetail!.channelName;
                live.mainHostUserDetail = story.user;
                live.token = story.user!.liveCallDetail!.token;
                live.id = story.user!.liveCallDetail!.id;

                _agoraLiveController.joinAsAudience(live: live);
              } else {
                Get.to(
                  () => StoryViewer(
                    story: story,
                    storyDeleted: _homeController.getStories,
                  ),
                  fullscreenDialog: true,
                );
              }
            },
          ).hp(DesignConstants.horizontalPadding);
        },
      ),
    );
  }


  Widget feedFilterBar() {
  return Obx(() {
    final selected = _homeController.selectedSegment.value;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),
      child: Row(
        children: [
          _filterButton('All', 0, selected),
          const SizedBox(width: 12),
          _filterButton('Following', 1, selected),
        ],
      ),
    );
  });
}

Widget _filterButton(String title, int index, int selected) {
  final isSelected = selected == index;

  return Expanded(
    child: GestureDetector(
      onTap: () => _homeController.selectSegment(index),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColorConstants.themeColor
              : const Color(0xFFCBD5D9),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 15,
          ),
        ),
      ),
    ),
  );
}
  
  Widget polls(int index) {
    final int postIndex = index > 2 ? index - 3 : 0;

    if (postIndex % pollFrequencyIndex != 0 || postIndex == 0) {
      return const SizedBox.shrink();
    }

    final int pollIndex = (postIndex ~/ pollFrequencyIndex) - 1;

    if (_homeController.polls.length <= pollIndex) {
      return const SizedBox.shrink();
    }

    final poll = _homeController.polls[pollIndex];
    final int vote = poll.isVote ?? 0;

    return Container(
      color: AppColorConstants.cardColor,
      child: FlutterPolls(
        pollId: poll.id.toString(),
        hasVoted: vote > 0,
        userVotedOptionId: vote > 0 ? vote.toString() : null,
        onVoted: (PollOption pollOption, int newTotalVotes) async {
          await Future.delayed(const Duration(seconds: 1));

          if (poll.id != null && pollOption.id != null) {
            _homeController.postPollAnswer(
              poll.id!,
              int.parse(pollOption.id!),
            );
          }

          return true;
        },
        pollEnded: false,
        pollOptionsSplashColor: Colors.white,
        votedProgressColor: Colors.grey.withOpacity(0.3),
        votedBackgroundColor: Colors.grey.withOpacity(0.2),
        votesTextStyle: TextStyle(fontSize: FontSizes.b2),
        votedPercentageTextStyle: TextStyle(
          fontSize: FontSizes.b2,
          color: Colors.black,
        ),
        votedCheckmark: const Icon(
          Icons.check_circle,
          color: Colors.black,
        ),
        pollTitle: Align(
          alignment: Alignment.centerLeft,
          child: BodyLargeText(
            poll.title ?? '',
            weight: TextWeight.medium,
          ),
        ),
        pollOptions: List<PollOption>.from(
          (poll.pollOptions ?? []).map(
            (option) => PollOption(
              id: option.id.toString(),
              title: BodyLargeText(
                option.title ?? '',
                weight: TextWeight.medium,
              ),
              votes: option.totalOptionVoteCount ?? 0,
            ),
          ),
        ),
      ).p16,
    ).round(15).p16;
  }
}