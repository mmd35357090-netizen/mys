
import 'package:foap/controllers/notification/notifications_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/setting_imports.dart';
import 'package:foap/screens/home_feed/story_uploader.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_polls/flutter_polls.dart';

import '../../components/post_card/post_card.dart';
import '../../controllers/post/add_post_controller.dart';
import '../../controllers/live/agora_live_controller.dart';
import '../../controllers/home/home_controller.dart';
import '../../model/live_model.dart';
import '../../model/post_model.dart';
import '../../segmentAndMenu/horizontal_menu.dart';
import '../post/content_creator_view.dart';
import '../story/story_updates_bar.dart';
import '../story/story_viewer.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  HomeFeedState createState() => HomeFeedState();
}

class HomeFeedState extends State<HomeFeedScreen> {
  final HomeController _homeController = Get.find();
  final AddPostController _addPostController = Get.find();
  final AgoraLiveController _agoraLiveController = Get.find();
  final NotificationController _notificationController = Get.find();
  final SettingsController _settingsController = Get.find();

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  final ScrollController _controller = ScrollController();

  static const int _headerItemCount = 3;
  static const int _pollFrequency = 10;

  bool _isLoadingMore = false;
  bool _isRefreshing = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();

    _controller.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed) return;

      _loadInitialData();
    });

    _notificationController.getNotificationInfo();
  }

  void _loadInitialData() {
    _homeController.loadQuickLinksAccordingToSettings();

    _homeController.getPolls();
    _homeController.getStories();

    _loadPosts(isRecent: true);
  }

  void _onScroll() {
    if (!_controller.hasClients ||
        _isLoadingMore ||
        _isRefreshing ||
        _isDisposed) {
      return;
    }

    // Load more when the user is close to the bottom.
    final position = _controller.position;

    if (position.pixels >= position.maxScrollExtent - 250) {
      _loadMorePosts();
    }
  }

  void _loadMorePosts() {
    if (_isLoadingMore || _isRefreshing || _isDisposed) {
      return;
    }

    _isLoadingMore = true;

    _homeController.getPosts(
      isRecent: false,
      callback: () {
        if (!mounted || _isDisposed) return;

        _isLoadingMore = false;
        _refreshController.loadComplete();

        setState(() {});
      },
    );
  }

  void _loadPosts({required bool isRecent}) {
    _homeController.getPosts(
      isRecent: isRecent,
      callback: () {
        if (!mounted || _isDisposed) return;

        _isLoadingMore = false;
        _isRefreshing = false;

        _refreshController.refreshCompleted();
        _refreshController.loadComplete();

        setState(() {});
      },
    );
  }

  Future<void> _refreshData() async {
    if (_isRefreshing || _isDisposed) return;

    _isRefreshing = true;
    _isLoadingMore = false;

    _homeController.getPolls();
    _homeController.getStories();

    _loadPosts(isRecent: true);
  }

  void _changeCategory(int index) {
    if (_isDisposed) return;

    _homeController.categoryIndexChanged(
      index: index,
      callback: () {
        if (!mounted || _isDisposed) return;

        _isLoadingMore = false;
        _refreshController.refreshCompleted();
        _refreshController.loadComplete();

        setState(() {});
      },
    );
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
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: postsView()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColorConstants.backgroundColor,
      padding: const EdgeInsets.only(top: 50),
      child: Row(
        children: [
          Expanded(
            child: Heading4Text(
              AppConfigConstants.appName,
              weight: TextWeight.semiBold,
            ),
          ),
          SizedBox(
            width: 44,
            height: 44,
            child: const Center(
              child: ThemeIconWidget(
                ThemeIcon.plus,
                size: 25,
              ),
            ),
          ).ripple(() {
            showGeneralDialog(
              context: context,
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const ContentCreatorView(),
            );
          }),
          const SizedBox(width: 12),
          Obx(() {
            final count =
                _notificationController.unreadNotificationCount.value;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: ThemeIconWidget(
                      ThemeIcon.notification,
                      size: 25,
                      color: AppColorConstants.themeColor,
                    ),
                  ),
                ).ripple(() {
                  Get.to(() => const NotificationsScreen());
                }),
                if (count > 0)
                  Positioned(
                    top: 2,
                    right: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColorConstants.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      constraints: const BoxConstraints(minWidth: 16),
                      child: Text(
                        count > 99 ? '99+' : count.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ).hp(20),
    );
  }

  Widget postsView() {
    return Obx(() {
      final posts = _homeController.posts;

      return ListView.separated(
        controller: _controller,
        padding: const EdgeInsets.only(top: 25, bottom: 100),
        itemCount: posts.length + _headerItemCount,
        itemBuilder: (context, index) {
          // 1. Stories
          if (index == 0) {
            return Obx(() {
              return _homeController.isRefreshingStories.value
                  ? const StoryAndHighlightsShimmer()
                  : storiesView();
            });
          }

          // 2. Posting progress
          if (index == 1) {
            return postingView().hp(
              DesignConstants.horizontalPadding,
            );
          }

          // 3. Category filters and empty/loading state
          if (index == 2) {
            return _buildCategorySection();
          }

          // 4. Posts
          final postIndex = index - _headerItemCount;

          if (postIndex < 0 || postIndex >= posts.length) {
            return const SizedBox.shrink();
          }

          final PostModel model = posts[postIndex];

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
          if (_settingsController.setting.value?.enablePolls != true) {
            return const SizedBox.shrink();
          }

          return polls(index);
        },
      ).addPullToRefresh(
        refreshController: _refreshController,
        enablePullUp: false,
        enablePullDown: true,
        onRefresh: _refreshData,
        onLoading: () {},
      );
    });
  }

  Widget _buildCategorySection() {
    return Obx(() {
      final isRefreshing = _homeController.isRefreshingPosts.value;
      final isEmpty = _homeController.posts.isEmpty;

      return Column(
        children: [
          HorizontalMenuBar(
            padding: EdgeInsets.only(
              left: DesignConstants.horizontalPadding,
              right: DesignConstants.horizontalPadding,
            ),
            onSegmentChange: _changeCategory,
            selectedIndex: _homeController.categoryIndex.value,
            menus: [
              allString.tr,
              followingString.tr,
              videosString.tr,
            ],
          ),
          if (isRefreshing)
            SizedBox(
              height: Get.height * 0.5,
              child: const HomeScreenShimmer(),
            )
          else if (isEmpty)
            SizedBox(
              height: Get.height * 0.4,
              child: emptyPost(
                title: noPostFoundString.tr,
                subTitle: followFriendsToSeeUpdatesString.tr,
              ),
            ),
        ],
      );
    });
  }

  Widget postingView() {
    return Obx(() {
      if (_addPostController.postingStatus.value != PostingStatus.posting) {
        return const SizedBox.shrink();
      }

      final media = _addPostController.postingMedia;
      final hasMedia = media.isNotEmpty &&
          media.first.mediaType != GalleryMediaType.gif;

      Widget preview = const SizedBox.shrink();

      if (hasMedia) {
        final firstMedia = media.first;

        if (firstMedia.thumbnail != null) {
          preview = Image.memory(
            firstMedia.thumbnail!,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ).round(5);
        } else if (firstMedia.mediaType == GalleryMediaType.photo &&
            firstMedia.file != null) {
          preview = Image.file(
            firstMedia.file!,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ).round(5);
        }
      }

      return Container(
        height: 55,
        color: AppColorConstants.cardColor,
        child: Row(
          children: [
            preview,
            const SizedBox(width: 10),
            Expanded(
              child: Heading5Text(
                _addPostController.isErrorInPosting.value
                    ? postFailedString.tr
                    : postingString.tr,
              ),
            ),
            if (_addPostController.isErrorInPosting.value) ...[
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
          ],
        ).hP8,
      ).backgroundCard(radius: 10).bp(20);
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
            liveUsers: _homeController.liveUsers,
            addStoryCallback: () {
              openStoryUploader();
            },
            viewStoryCallback: (story) {
              Get.to(
                () => StoryViewer(
                  story: story,
                  storyDeleted: () {
                    _homeController.getStories();
                  },
                ),
              );
            },
            joinLiveUserCallback: (user) {
              final live = LiveModel();

              live.channelName = user.liveCallDetail!.channelName;
              live.mainHostUserDetail = user;
              live.token = user.liveCallDetail!.token;
              live.id = user.liveCallDetail!.id;

              _agoraLiveController.joinAsAudience(live: live);
            },
          ).vP16;
        },
      ),
    ).hp(DesignConstants.horizontalPadding);
  }

  Widget polls(int index) {
    // Header items do not count as posts.
    if (index < _headerItemCount - 1) {
      return const SizedBox.shrink();
    }

    // A separator after each tenth post.
    final postCount = index - (_headerItemCount - 2);

    if (postCount <= 0 || postCount % _pollFrequency != 0) {
      return const SizedBox.shrink();
    }

    final pollIndex = (postCount ~/ _pollFrequency) - 1;

    if (pollIndex < 0 || pollIndex >= _homeController.polls.length) {
      return const SizedBox.shrink();
    }

    final poll = _homeController.polls[pollIndex];
    final voteValue = poll.isVote ?? 0;

    return Container(
      color: AppColorConstants.cardColor,
      child: FlutterPolls(
        pollId: poll.id.toString(),
        hasVoted: voteValue > 0,
        userVotedOptionId:
            voteValue > 0 ? voteValue.toString() : null,
        onVoted: (PollOption option, int newTotalVotes) async {
          final pollId = poll.id;
          final optionId = int.tryParse(option.id ?? '');

          if (pollId == null || optionId == null) {
            return false;
          }

          try {
            await _homeController.postPollAnswer(pollId, optionId);
            return true;
          } catch (_) {
            return false;
          }
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
          (poll.pollOptions ?? []).map((option) {
            return PollOption(
              id: option.id.toString(),
              title: BodyLargeText(
                option.title ?? '',
                weight: TextWeight.medium,
              ),
              votes: option.totalOptionVoteCount ?? 0,
            );
          }),
        ),
      ).p16,
    ).round(15).p16;
  }
}
