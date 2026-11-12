import 'package:foap/controllers/notification/notifications_controller.dart';
import 'package:foap/screens/settings_menu/notifications.dart';
import 'package:flutter_polls/flutter_polls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/story_imports.dart';
import 'package:foap/model/live_model.dart';
import 'package:foap/screens/home_feed/story_uploader.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../components/post_card/post_card.dart';
import '../../components/feed_native_ad.dart';
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
  // tab bar hides while scrolling down and returns when scrolling up
  final RxBool _showFilterBar = true.obs;
  final NotificationController _notificationController = Get.find();


  String? selectedValue;
  int pollFrequencyIndex = 10;

@override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    loadData(); // 👈 'isRecent: true' কেটে দেওয়া হয়েছে
    _homeController.loadQuickLinksAccordingToSettings();
  });

  // এটি কাজ করবে যখন ওপরে কন্ট্রোলারটি ডিক্লেয়ার করবেন
  _notificationController.getNotificationInfo(); 

  _controller.addListener(() {
    if (_controller.hasClients) {
      final double pixels = _controller.position.pixels;
      final ScrollDirection dir =
          _controller.position.userScrollDirection;
      if (pixels <= 40) {
        _showFilterBar.value = true;
      } else if (dir == ScrollDirection.reverse) {
        _showFilterBar.value = false;
      } else if (dir == ScrollDirection.forward) {
        _showFilterBar.value = true;
      }
    }
    if (_controller.position.atEdge) {
      bool isTop = _controller.position.pixels == 0;
      if (isTop) {
        // এখানে কিছু করার প্রয়োজন নেই
      } else {
        loadData(); // 👈 'isRecent: false' কেটে দেওয়া হয়েছে
      }
    }
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
  return Scaffold(
    backgroundColor: AppColorConstants.backgroundColor,
    body: GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Column(
        children: [
          Container(
            color: AppColorConstants.backgroundColor,
            child: Column(
              children: [
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Heading4Text(
                          AppConfigConstants.appName,
                          weight: TextWeight.semiBold,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        ThemeIconWidget(
                          ThemeIcon.plus,
                          size: 25,
                        ).ripple(() {
                          Future.delayed(
                            Duration.zero,
                            () => showGeneralDialog(
                              context: Get.context!,
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  const ContentCreatorView(),
                            ),
                          );
                        }),
                        const SizedBox(width: 15), // Replaced the broken ternary snippet with a standard spacer
                        Obx(() => Stack(
                              children: [
                                ThemeIconWidget(
                                  ThemeIcon.notification,
                                  size: 25,
                                  color: AppColorConstants.themeColor,
                                )
                                    .rp(_notificationController
                                                .unreadNotificationCount.value >
                                            0
                                        ? 15
                                        : 0)
                                    .ripple(() {
                                  Get.to(() => const NotificationsScreen());
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
                                              color: Colors.white),
                                          textAlign: TextAlign.center,
                                        ).setPadding(
                                            top: 2,
                                            bottom: 2,
                                            left: 4,
                                            right: 4),
                                      ),
                                    ).circular,
                                  ),
                              ],
                            )),
                      ],
                    ),
                  ],
                ).hp(20),
              ],
            ),
          ),
          Obx(() => ClipRect(
                child: AnimatedAlign(
                  alignment: Alignment.topCenter,
                  heightFactor: _showFilterBar.value ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  child: feedFilterBar().vP8,
                ),
              )),
          Expanded(child: postsView()),
        ],
      ),
    ),
  );
}
  



Widget postsView() {
  final bool enableStories =
      _settingsController.setting.value!.enableStories;

  // Story (optional) + Posting status (filter bar is pinned above the list)
  final int offset = enableStories ? 2 : 1;

  return Obx(() {
    // A very short feed (new account, few followings) has no slot between
    // posts, so the first sponsored post is added after the last post.
    final bool ownOn =
        _settingsController.setting.value?.ownAdsOn ?? true;
    final bool trailingAd = ownOn &&
        _homeController.sponsoredPosts.isNotEmpty &&
        _homeController.posts.length < 3;

    return ListView.separated(
      controller: _controller,
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: _homeController.posts.length + offset + (trailingAd ? 1 : 0),

      itemBuilder: (context, index) {
        // 1. Stories
        if (enableStories && index == 0) {
          return Obx(
            () => _homeController.isRefreshingStories.value
                ? const StoryAndHighlightsShimmer()
                : storiesView(),
          );
        }

        // 3. Posting status
        if (index == offset - 1) {
          return postingView().hP16;
        }

        // 4. Posts
        final int postIndex = index - offset;
        if (postIndex >= _homeController.posts.length) {
          // trailing sponsored post (only when the feed is very short)
          return _sponsoredCard(_homeController.sponsoredPosts.first);
        }
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
        // index of the post just above this separator
        final int postAbove = index - offset;
        if (ownOn && postAbove >= 1 && (postAbove - 1) % 5 == 0) {
          final int adIndex = (postAbove - 1) ~/ 5;
          if (adIndex < _homeController.sponsoredPosts.length) {
            return _sponsoredCard(_homeController.sponsoredPosts[adIndex]);
          }
        }

        // Google AdMob native ad after every N posts (admin setting), on a different slot from the boosted posts
        final setting = _settingsController.setting.value;
        if (setting != null &&
            setting.googleAdsOn &&
            setting.feedNativeAdsEnabled) {
          final int every = setting.feedNativeAdEvery < 3
              ? 3
              : setting.feedNativeAdEvery;
          if (postAbove >= 3 &&
              postAbove % every == 3 % every &&
              postAbove < _homeController.posts.length) {
            final int hostId = _homeController.posts[postAbove].id;
            return FeedNativeAd(
                key: ValueKey('native_ad_$hostId'), hostPostId: hostId);
          }
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
  
  Widget _sponsoredCard(PostModel post) {
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

  Widget postingView() {
    return Obx(() {
      if (!_addPostController.isPosting.value) {
        return const SizedBox.shrink();
      }
      final failed = _addPostController.isErrorInPosting.value;
      final stage = _addPostController.postingStage.value;
      final progress = _addPostController.postingProgress.value;
      final media = _addPostController.postingMedia;
      final bool hasVideo = media.any((e) => e.mediaType == GalleryMediaType.video);

      String label;
      if (failed) {
        label = postFailedString.tr;
      } else if (stage == 1) {
        label = 'Preparing your video…';
      } else if (stage == 2) {
        label = hasVideo ? 'Uploading your video…' : 'Uploading…';
      } else if (stage == 3) {
        label = 'Publishing your post…';
      } else {
        label = postingString.tr;
      }
      final percent = (progress * 100).clamp(0, 100).toInt();

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColorConstants.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: failed
                  ? AppColorConstants.red.withValues(alpha: 0.6)
                  : AppColorConstants.dividerColor.withValues(alpha: 0.5),
              width: 0.8),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 5))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (media.isNotEmpty &&
                    media.first.mediaType != GalleryMediaType.gif)
                  media.first.thumbnail != null
                      ? Image.memory(
                          media.first.thumbnail!,
                          fit: BoxFit.cover,
                          width: 44,
                          height: 44,
                        ).round(10)
                      : media.first.mediaType == GalleryMediaType.photo &&
                              media.first.file != null
                          ? Image.file(
                              media.first.file!,
                              fit: BoxFit.cover,
                              width: 44,
                              height: 44,
                            ).round(10)
                          : const SizedBox.shrink(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BodyLargeText(label, weight: TextWeight.bold),
                      if (!failed)
                        BodySmallText(
                          stage == 3
                              ? 'Almost done'
                              : 'You can keep using the app, it continues in the background',
                          color: AppColorConstants.subHeadingTextColor,
                        ),
                    ],
                  ),
                ),
                if (!failed)
                  BodyMediumText('$percent%',
                      weight: TextWeight.bold,
                      color: AppColorConstants.themeColor),
              ],
            ),
            if (!failed) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: stage == 3 ? null : progress,
                  minHeight: 6,
                  backgroundColor:
                      AppColorConstants.themeColor.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      AppColorConstants.themeColor),
                ),
              ),
            ],
            if (failed) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  BodyMediumText(discardString.tr,
                          weight: TextWeight.semiBold,
                          color: AppColorConstants.subHeadingTextColor)
                      .ripple(() {
                    _addPostController.discardFailedPost();
                  }),
                  const SizedBox(width: 24),
                  BodyMediumText(retryString.tr,
                          weight: TextWeight.bold,
                          color: AppColorConstants.themeColor)
                      .ripple(() {
                    _addPostController.retryPublish();
                  }),
                ],
              ),
            ],
          ],
        ),
      ).bp(16);
    });
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
        ).vP16;
      },
    ),
  ).hp(DesignConstants.horizontalPadding);
}


Widget feedFilterBar() {
  return Obx(() {
    final selected = _homeController.selectedSegment.value;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 0,
      ),
      child: Row(
        children: [
          _filterButton('All', 0, selected),
          const SizedBox(width: 8),
          _filterButton('Following', 1, selected),
          const SizedBox(width: 8),
          _filterButton('Videos', 2, selected),
          const SizedBox(width: 8),
          _filterButton('Premium', 3, selected),
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
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColorConstants.mainTextColor
              : AppColorConstants.themeColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? AppColorConstants.backgroundColor
                : AppColorConstants.mainTextColor,
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
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
