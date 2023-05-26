import 'package:foap/apiHandler/apis/gift_api.dart';
import 'package:foap/apiHandler/apis/live_streaming_api.dart';
import 'package:foap/apiHandler/apis/post_api.dart';
import 'package:foap/apiHandler/apis/story_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/add_on/ui/dating/dating_dashboard.dart';
import 'package:foap/screens/add_on/ui/podcast/podcast_list_dashboard.dart';
import 'package:foap/screens/add_on/ui/reel/create_reel_video.dart';
import 'package:foap/screens/live/live_users_screen.dart';
import '../apiHandler/apis/misc_api.dart';
import '../model/gift_model.dart';
import '../model/post_gift_model.dart';
import '../screens/chatgpt/chat_gpt.dart';
import '../screens/tvs/tv_dashboard.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../screens/add_on/model/polls_model.dart';
import '../model/post_model.dart';
import '../screens/settings_menu/settings_controller.dart';
import 'dart:async';
import 'package:foap/manager/db_manager.dart';
import 'package:foap/model/story_model.dart';
import 'package:foap/model/post_gallery.dart';
import 'package:foap/model/post_search_query.dart';
import 'package:foap/screens/dashboard/posts.dart';
import 'package:foap/screens/highlights/choose_stories.dart';
import 'package:foap/screens/profile/other_user_profile.dart';
import 'package:foap/screens/story/choose_media_for_story.dart';
import 'package:foap/screens/home_feed/quick_links.dart';
import 'package:foap/screens/live/checking_feasibility.dart';
import 'package:foap/screens/competitions/competitions_screen.dart';

class HomeController extends GetxController {
  final SettingsController _settingsController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  RxList<PostModel> posts = <PostModel>[].obs;
  RxList<PollsQuestionModel> polls = <PollsQuestionModel>[].obs;
  RxList<StoryModel> stories = <StoryModel>[].obs;
  RxList<UserModel> liveUsers = <UserModel>[].obs;
  RxList<GiftModel> timelineGift = <GiftModel>[].obs;

  RxList<BannerAd> bannerAds = <BannerAd>[].obs;

  RxInt currentVisibleVideoId = 0.obs;
  Map<int, double> _mediaVisibilityInfo = {};
  PostSearchQuery postSearchQuery = PostSearchQuery();

  RxBool isRefreshingPosts = false.obs;
  RxBool isRefreshingStories = false.obs;

  RxInt categoryIndex = 0.obs;

  int _postsCurrentPage = 1;
  bool _canLoadMorePosts = true;

  RxBool openQuickLinks = false.obs;

  RxList<QuickLink> quickLinks = <QuickLink>[].obs;

  clear() {
    stories.clear();
    liveUsers.clear();
  }

  clearPosts() {
    _postsCurrentPage = 1;
    _canLoadMorePosts = true;
    posts.clear();
  }

  quickLinkSwitchToggle() {
    openQuickLinks.value = !openQuickLinks.value;

    if (openQuickLinks.value == true) {
      Get.bottomSheet(QuickLinkWidget(callback: () {
        closeQuickLinks();
        Get.back();
      })).then((value) {
        closeQuickLinks();
      });
    }
  }

  closeQuickLinks() {
    openQuickLinks.value = false;
  }

  loadQuickLinksAccordingToSettings() {
    quickLinks.clear();
    if (_settingsController.setting.value!.enableStories) {
      quickLinks.add(QuickLink(
          icon: 'assets/stories.png',
          heading: storyString.tr,
          subHeading: storyString.tr,
          linkType: QuickLinkType.story));
    }
    if (_settingsController.setting.value!.enableHighlights) {
      quickLinks.add(QuickLink(
          icon: 'assets/highlights.png',
          heading: highlightsString.tr,
          subHeading: highlightsString.tr,
          linkType: QuickLinkType.highlights));
    }

    // if(_settingsController.setting.value!.enableLiveUser){
    quickLinks.add(QuickLink(
        icon: 'assets/live_users.png',
        heading: liveUsersString.tr,
        subHeading: liveUsersString.tr,
        linkType: QuickLinkType.liveUsers));
    // }

    if (_settingsController.setting.value!.enableReel) {
      quickLinks.add(QuickLink(
          icon: 'assets/highlights.png',
          heading: reelsString.tr,
          subHeading: reelsString.tr,
          linkType: QuickLinkType.highlights));
    }
    if (_settingsController.setting.value!.enableLive) {
      quickLinks.add(QuickLink(
          icon: 'assets/live.png',
          heading: goLiveString.tr,
          subHeading: goLiveString.tr,
          linkType: QuickLinkType.goLive));
    }
    if (_settingsController.setting.value!.enableCompetitions) {
      quickLinks.add(QuickLink(
          icon: 'assets/competitions.png',
          heading: competitionString.tr,
          subHeading: joinCompetitionsToEarnString.tr,
          linkType: QuickLinkType.competition));
    }
    if (_settingsController.setting.value!.enableClubs) {
      quickLinks.add(QuickLink(
          icon: 'assets/club_colored.png',
          heading: clubsString.tr,
          subHeading: placeForPeopleOfCommonInterestString.tr,
          linkType: QuickLinkType.clubs));
    }

    if (_settingsController.setting.value!.enableStrangerChat) {
      quickLinks.add(QuickLink(
          icon: 'assets/chat_colored.png',
          heading: strangerChatString.tr,
          subHeading: haveFunByRandomChattingString.tr,
          linkType: QuickLinkType.randomChat));
    }
    // if (_settingsController.setting.value!.enableCompetitions) {
    //   quickLinks.add(QuickLink(
    //       icon: 'assets/competitions.png',
    //       heading: competition,
    //       subHeading: joinCompetitionsToEarn,
    //       linkType: QuickLinkType.competition));
    // }
    // if (_settingsController.setting.value!.enableReel) {

    // }
    if (_settingsController.setting.value!.enableWatchTv) {
      quickLinks.add(QuickLink(
          icon: 'assets/television.png',
          heading: tvsString.tr,
          subHeading: tvsString.tr,
          linkType: QuickLinkType.tv));
    }
    if (_settingsController.setting.value!.enablePodcasts) {
      quickLinks.add(QuickLink(
          icon: 'assets/podcast.png',
          heading: podcastString.tr,
          subHeading: podcastString.tr,
          linkType: QuickLinkType.podcast));
    }
    if (_settingsController.setting.value!.enableDating) {
      quickLinks.add(QuickLink(
          icon: 'assets/dating.png',
          heading: datingString.tr,
          subHeading: datingString.tr,
          linkType: QuickLinkType.dating));
    }
    // if (_settingsController.setting.value!.enableReel) {
    quickLinks.add(QuickLink(
        icon: 'assets/reel.png',
        heading: reelString.tr,
        subHeading: reelString.tr,
        linkType: QuickLinkType.reel));
    // }
    if (_settingsController.setting.value!.enableEvents) {
      quickLinks.add(QuickLink(
          icon: 'assets/event.png',
          heading: eventString.tr,
          subHeading: eventString.tr,
          linkType: QuickLinkType.event));
    }

    if (_settingsController.setting.value!.enableChatGPT) {
      quickLinks.add(QuickLink(
          icon: 'assets/chat.png',
          heading: chatGPT.tr,
          subHeading: eventString.tr,
          linkType: QuickLinkType.chatGPT));
    }
  }

  categoryIndexChanged({required int index, required VoidCallback callback}) {
    if (index != categoryIndex.value) {
      categoryIndex.value = index;
      clearPosts();
      postSearchQuery = PostSearchQuery();

      if (index == 1) {
        postSearchQuery.isFollowing = 1;
        postSearchQuery.isRecent = 1;
      }
      // else if (index == 2) {
      //   postSearchQuery.isPopular = 1;
      // }
      else if (index == 2) {
        postSearchQuery.isRecent = 1;
      } else if (index == 3) {
        postSearchQuery.isMine = 1;
        postSearchQuery.isRecent = 1;
      } else {
        postSearchQuery.isRecent = 1;
      }

      getPosts(isRecent: false, callback: callback);
    }
  }

  removePostFromList(PostModel post) {
    posts.removeWhere((element) => element.id == post.id);
    posts.refresh();
  }

  removeUsersAllPostFromList(PostModel post) {
    posts.removeWhere((element) => element.user.id == post.user.id);
    posts.refresh();
  }

  void addNewPost(PostModel post) {
    posts.insert(0, post);
    posts.refresh();
  }

  void getPolls() async {
    MiscApi.getPolls(resultCallback: (result) {
      polls.addAll(result);
    });
  }

  void postPollAnswer(
      int pollId, int pollQuestionId, int questionOptionId) async {
    MiscApi.postPollAnswer(
        pollId: pollId,
        pollQuestionId: pollQuestionId,
        questionOptionId: questionOptionId,
        resultCallback: (result) {
          polls.addAll(result);
        });
  }

  void getPosts(
      {required bool? isRecent, required VoidCallback callback}) async {
    if (_canLoadMorePosts == true) {
      if (isRecent == true) {
        postSearchQuery.isRecent = 1;
      }

      if (_postsCurrentPage == 1) {
        isRefreshingPosts.value = true;
      }

      PostApi.getPosts(
          userId: postSearchQuery.userId,
          isPopular: postSearchQuery.isPopular,
          isFollowing: postSearchQuery.isFollowing,
          isSold: postSearchQuery.isSold,
          isMine: postSearchQuery.isMine,
          isRecent: postSearchQuery.isRecent,
          title: postSearchQuery.title,
          hashtag: postSearchQuery.hashTag,
          clubId: postSearchQuery.clubId,
          page: _postsCurrentPage,
          resultCallback: (result, metadata) {
            posts.addAll(
                result.where((element) => element.gallery.isNotEmpty).toList());
            posts.sort((a, b) => b.createDate!.compareTo(a.createDate!));
            isRefreshingPosts.value = false;

            if (_postsCurrentPage >= metadata.pageCount) {
              _canLoadMorePosts = false;
            } else {
              _canLoadMorePosts = true;
            }
            _postsCurrentPage += 1;

            callback();
            update();
          });
    }
  }

  setCurrentVisibleVideo(
      {required PostGallery media, required double visibility}) {
    // print(visibility);
    if (visibility < 20) {
      currentVisibleVideoId.value = -1;
    }
    _mediaVisibilityInfo[media.id] = visibility;
    double maxVisibility =
        _mediaVisibilityInfo[_mediaVisibilityInfo.keys.first] ?? 0;
    int maxVisibilityMediaId = _mediaVisibilityInfo.keys.first;

    for (int key in _mediaVisibilityInfo.keys) {
      double visibility = _mediaVisibilityInfo[key] ?? 0;
      if (visibility >= maxVisibility) {
        maxVisibilityMediaId = key;
      }
    }

    if (currentVisibleVideoId.value != maxVisibilityMediaId &&
        visibility > 80) {
      currentVisibleVideoId.value = maxVisibilityMediaId;
      // update();
    }
  }

  void reportPost(int postId) {
    PostApi.reportPost(
        postId: postId,
        resultCallback: () {
          AppUtil.showToast(
              message: postReportedSuccessfullyString.tr, isSuccess: true);
        });
  }

  // void likeUnlikePost(PostModel post, BuildContext context) {
  //   post.isLike = !post.isLike;
  //   post.totalLike = post.isLike ? (post.totalLike) + 1 : (post.totalLike) - 1;
  //   AppUtil.checkInternet().then((value) async {
  //     if (value) {
  //       ApiController()
  //           .likeUnlike(post.isLike, post.id)
  //           .then((response) async {});
  //     } else {
  //       AppUtil.showToast(
  //
  //           message: noInternet,
  //           isSuccess: true);
  //     }
  //   });
  //
  //   posts.refresh();
  //   update();
  // }

  postTextTapHandler({required PostModel post, required String text}) {
    if (text.startsWith('#')) {
      Get.to(() => Posts(
                hashTag: text.replaceAll('#', ''),
              ))!
          .then((value) {
        getPosts(isRecent: false, callback: () {});
        getStories();
      });
    } else {
      String userTag = text.replaceAll('@', '');
      if (post.mentionedUsers
          .where((element) => element.userName == userTag)
          .isNotEmpty) {
        int mentionedUserId = post.mentionedUsers
            .where((element) => element.userName == userTag)
            .first
            .id;
        Get.to(() => OtherUserProfile(userId: mentionedUserId))!.then((value) {
          getPosts(isRecent: false, callback: () {});
          getStories();
        });
      }
    }
  }

// stories

  void getStories() async {
    isRefreshingStories.value = true;
    update();

    AppUtil.checkInternet().then((value) async {
      if (value) {
        var responses = await Future.wait([
          getCurrentActiveStories(),
          getFollowersStories(),
          getLiveUsers()
        ]).whenComplete(() {});
        stories.clear();

        StoryModel story = StoryModel(
            id: 1,
            name: '',
            userName: _userProfileManager.user.value!.userName,
            email: '',
            image: _userProfileManager.user.value!.picture,
            media: responses[0] as List<StoryMediaModel>);

        stories.add(story);
        stories.addAll(responses[1] as List<StoryModel>);
        liveUsers.value = responses[2] as List<UserModel>;
      }

      isRefreshingStories.value = false;
      update();
    });
  }

  Future<List<UserModel>> getLiveUsers() async {
    List<UserModel> currentLiveUsers = [];
    await LiveStreamingApi.getCurrentLiveUsers(resultCallback: (result) {
      currentLiveUsers = result;
    });
    return currentLiveUsers;
  }

  Future<List<StoryModel>> getFollowersStories() async {
    List<StoryModel> followersStories = [];
    List<StoryModel> viewedAllStories = [];
    List<StoryModel> notViewedStories = [];

    List<int> viewedStoryIds = await getIt<DBManager>().getAllViewedStories();

    await StoryApi.getStories(resultCallback: (result) {
      for (var story in result) {
        var allMedias = story.media;
        var notViewedStoryMedias = allMedias
            .where((element) => viewedStoryIds.contains(element.id) == false);

        if (notViewedStoryMedias.isEmpty) {
          story.isViewed = true;
          viewedAllStories.add(story);
        } else {
          notViewedStories.add(story);
        }
      }
    });

    followersStories.addAll(notViewedStories);
    followersStories.addAll(viewedAllStories);

    return followersStories;
  }

  Future<List<StoryMediaModel>> getCurrentActiveStories() async {
    List<StoryMediaModel> myActiveStories = [];

    await StoryApi.getMyCurrentActiveStories(resultCallback: (result) {
      myActiveStories = result;
      update();
    });

    return myActiveStories;
  }

  sendPostGift(GiftModel gift, int receiverId, int? postId) {
    GiftApi.sendStickerGift(
        gift: gift,
        liveId: null,
        postId: postId,
        receiverId: receiverId,
        resultCallback: () {
          // refresh profile to get updated wallet info
          AppUtil.showToast(message: giftSentString.tr, isSuccess: true);
          _userProfileManager.refreshProfile();
        });
  }

  liveUsersUpdated() {
    getStories();
  }
}
