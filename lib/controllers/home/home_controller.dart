import 'package:foap/api_handler/apis/gift_api.dart';
import 'package:foap/api_handler/apis/live_streaming_api.dart';
import 'package:foap/api_handler/apis/post_api.dart';
import 'package:foap/api_handler/apis/story_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/data_wrapper.dart';
import '../../api_handler/apis/misc_api.dart';
import '../../manager/db_manager_realm.dart';
import '../../model/gift_model.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../screens/add_on/model/polls_model.dart';
import '../../model/post_model.dart';
import '../../screens/settings_menu/settings_controller.dart';
import 'dart:async';
import 'package:foap/model/story_model.dart';
import 'package:foap/model/post_gallery.dart';
import 'package:foap/model/post_search_query.dart';
import 'package:foap/screens/home_feed/quick_links.dart';
import 'package:foap/helper/list_extension.dart';

class HomeController extends GetxController {
  final SettingsController _settingsController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  RxList<PostModel> posts = <PostModel>[].obs;
  RxList<PollModel> polls = <PollModel>[].obs;
  RxList<StoryModel> stories = <StoryModel>[].obs;
  RxList<UserModel> liveUsers = <UserModel>[].obs;
  RxList<GiftModel> timelineGift = <GiftModel>[].obs;
  RxList<int> positions = <int>[].obs;
  RxList<PostModel> sponsoredPosts = <PostModel>[].obs;

  RxList<BannerAd> bannerAds = <BannerAd>[].obs;

  RxInt currentVisibleVideoId = 0.obs;
  final Map<int, double> _mediaVisibilityInfo = {};
  PostSearchQuery postSearchQuery = PostSearchQuery();

  RxBool isRefreshingPosts = false.obs;
  RxBool isRefreshingStories = false.obs;

  RxInt categoryIndex = 0.obs;
  RxInt selectedSegment = 0.obs;

  DataWrapper postsDataWrapper = DataWrapper();
  RxBool openQuickLinks = false.obs;

  RxList<QuickLink> quickLinks = <QuickLink>[].obs;

  clear() {
    stories.clear();
    liveUsers.clear();
  }

  clearPosts() {
    postsDataWrapper = DataWrapper();
    sponsoredPosts.clear();
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

  selectSegment(int index) {
    if (selectedSegment.value != index) {
      selectedSegment.value = index;
      if (index == 0) {
        postSearchQuery.isFollowing = 0;
      } else {
        postSearchQuery.isFollowing = 1;
      }
      clearPosts();
      getPosts(callback: () {});
    }
  }

  closeQuickLinks() {
    openQuickLinks.value = false;
  }

  loadQuickLinksAccordingToSettings() {
    quickLinks.clear();
    if (_settingsController.setting.value!.enableStories) {
      quickLinks.add(QuickLink(
          icon: 'assets/explore/story.png',
          heading: storyString.tr,
          subHeading: storyString.tr,
          linkType: QuickLinkType.story));
    }
    if (_settingsController.setting.value!.enableHighlights) {
      quickLinks.add(QuickLink(
          icon: 'assets/explore/highlight.png',
          heading: highlightsString.tr,
          subHeading: highlightsString.tr,
          linkType: QuickLinkType.highlights));
    }
    if (_settingsController.setting.value!.enableLiveUserListing) {
      quickLinks.add(QuickLink(
          icon: 'assets/explore/live_users.png',
          heading: liveUsersString.tr,
          subHeading: liveUsersString.tr,
          linkType: QuickLinkType.liveUsers));
    }
    if (_settingsController.setting.value!.enableCompetitions) {
      quickLinks.add(QuickLink(
          icon: 'assets/explore/competition.png',
          heading: competitionString.tr,
          subHeading: joinCompetitionsToEarnString.tr,
          linkType: QuickLinkType.competition));
    }
    if (_settingsController.setting.value!.enableClubs) {
      quickLinks.add(QuickLink(
          icon: 'assets/explore/group.png',
          heading: clubsString.tr,
          subHeading: placeForPeopleOfCommonInterestString.tr,
          linkType: QuickLinkType.clubs));
    }
    if (_settingsController.setting.value!.enableStrangerChat) {
      quickLinks.add(QuickLink(
          icon: 'assets/explore/chat_colored.png',
          heading: strangerChatString.tr,
          subHeading: haveFunByRandomChattingString.tr,
          linkType: QuickLinkType.randomChat));
    }
    if (_settingsController.setting.value!.enableWatchTv) {
      quickLinks.add(QuickLink(
          icon: 'assets/explore/movie.png',
          heading: tvsString.tr,
          subHeading: tvsString.tr,
          linkType: QuickLinkType.tv));
    }
    if (_settingsController.setting.value!.enablePodcasts) {
      quickLinks.add(QuickLink(
          icon: 'assets/explore/podcast.png',
          heading: podcastString.tr,
          subHeading: podcastString.tr,
          linkType: QuickLinkType.podcast));
    }
    if (_settingsController.setting.value!.enableReel) {
      quickLinks.add(QuickLink(
          icon: 'assets/explore/reel.png',
          heading: reelString.tr,
          subHeading: reelString.tr,
          linkType: QuickLinkType.reel));
    }
    if (_settingsController.setting.value!.enableEvents) {
      quickLinks.add(QuickLink(
          icon: 'assets/explore/event.png',
          heading: eventString.tr,
          subHeading: eventString.tr,
          linkType: QuickLinkType.event));
    }
    if (_settingsController.setting.value!.enableDating) {
      quickLinks.add(QuickLink(
          icon: 'assets/explore/dating.png',
          heading: datingString.tr,
          subHeading: datingString.tr,
          linkType: QuickLinkType.dating));
    }
    if (!_settingsController.setting.value!.enableChatGPT) {
      quickLinks.add(QuickLink(
          icon: 'assets/explore/chatGPT.png',
          heading: chatGPT.tr,
          subHeading: eventString.tr,
          linkType: QuickLinkType.chatGPT));
    }
    if (_settingsController.setting.value!.enableFundRaising) {
      quickLinks.add(QuickLink(
          icon: 'assets/explore/donation.png',
          heading: fundRaisingString.tr,
          subHeading: fundRaisingString.tr,
          linkType: QuickLinkType.fundRaising));
    }
    if (_settingsController.setting.value!.enableOffers) {
      quickLinks.add(QuickLink(
          icon: 'assets/explore/offers.png',
          heading: offers.tr,
          subHeading: offers.tr,
          linkType: QuickLinkType.offers));
    }
    if (_settingsController.setting.value!.enableShop) {
      quickLinks.add(QuickLink(
          icon: 'assets/explore/shop.png',
          heading: shopString.tr,
          subHeading: shopString.tr,
          linkType: QuickLinkType.shop));
    }
    if (_settingsController.setting.value!.enableJobs) {
      quickLinks.add(QuickLink(
          icon: 'assets/explore/job.png',
          heading: jobsString.tr,
          subHeading: jobsString.tr,
          linkType: QuickLinkType.job));
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
      polls.unique((e) => e.id);
    });
  }

  void postPollAnswer(int pollId, int questionOptionId) async {
    MiscApi.postPollAnswer(
        pollId: pollId,
        questionOptionId: questionOptionId,
        resultCallback: (result) {
          polls.addAll(result);
          polls.unique((e) => e.id);
        });
  }

  setSourceFilter(int isFollowing) {
    postSearchQuery.isFollowing = isFollowing;
  }

  void getPosts({required VoidCallback callback}) async {
    if (postsDataWrapper.haveMoreData.value == true) {
      postSearchQuery.isRecent = 1;
      postSearchQuery.isMine = 1;

      if (postsDataWrapper.page == 1) {
        isRefreshingPosts.value = true;
      }

      PostApi.getPosts(
          isFollowing: postSearchQuery.isFollowing,
          isRecent: postSearchQuery.isRecent,
          page: postsDataWrapper.page,
          resultCallback: (result, metadata) {
            posts.addAll(result);
            posts.sort((a, b) => b.createDate!.compareTo(a.createDate!));
            posts.unique((e) => e.id);

            isRefreshingPosts.value = false;
            postsDataWrapper.processCompletedWithData(metadata);

            callback();
            update();
          });
    } else {
      callback();
    }
  }

  postEdited(PostModel post) {
    int oldPostIndex =
        posts.indexWhere((element) => element.id == post.id);
    posts.removeAt(oldPostIndex);
    posts.insert(oldPostIndex, post);
    posts.refresh();
  }

  void getPromotionalPosts() async {
    PostApi.getPromotionalPosts(
        page: 0,
        resultCallback: (result, metadata) {
          sponsoredPosts.addAll(result);
          sponsoredPosts.unique((e) => e.id);

          update();
        });
  }

  setCurrentVisibleVideo(
      {required PostGallery media, required double visibility}) {
    _mediaVisibilityInfo[media.id] = visibility;
    double maxVisibility =
        _mediaVisibilityInfo[_mediaVisibilityInfo.keys.first] ?? 0;
    int maxVisibilityMediaId = _mediaVisibilityInfo.keys.first;

    for (int key in _mediaVisibilityInfo.keys) {
      double visibility = _mediaVisibilityInfo[key] ?? 0;

      if (visibility >= maxVisibility && visibility > 20) {
        maxVisibility = visibility;
        maxVisibilityMediaId = key;
      }
    }

    if (currentVisibleVideoId.value != maxVisibilityMediaId &&
        maxVisibility > 20) {
      currentVisibleVideoId.value = maxVisibilityMediaId;
    } else if (maxVisibility <= 20) {
      currentVisibleVideoId.value = -1;
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

  // stories
  void getStories() async {
    isRefreshingStories.value = true;
    update();

    var responses = await Future.wait([
      getCurrentActiveStories(),
      getLiveUsers(),
      getFollowersStories(),
    ]).whenComplete(() {});
    stories.clear();

    StoryModel story = StoryModel(
        id: 1,
        name: '',
        userName: _userProfileManager.user.value!.userName,
        userImage: _userProfileManager.user.value!.picture,
        media: responses[0] as List<StoryMediaModel>);

    List<StoryModel> liveUserStories =
        (responses[1] as List<UserModel>).map((e) {
      StoryModel story = StoryModel(
          id: 1,
          name: '',
          userName: _userProfileManager.user.value!.userName,
          userImage: _userProfileManager.user.value!.picture,
          media: responses[0] as List<StoryMediaModel>);
      story.isLive = true;
      story.user = e;
      return story;
    }).toList();

    if ((responses[0] as List<StoryMediaModel>).isNotEmpty) {
      stories.add(story);
      stories.addAll(liveUserStories);
      stories.addAll(responses[2] as List<StoryModel>);
    } else {
      stories.addAll(liveUserStories);
      stories.addAll(responses[2] as List<StoryModel>);
    }
    // Remove duplicates, keeping the version where isLive = true
    stories.value = stories
        .fold<Map<int, StoryModel>>({}, (map, item) {
          // If the user id is not in the map or if the current item has isLive = true,
          // replace the entry in the map for that user id
          if (!map.containsKey(item.id) || item.isLive == true) {
            map[item.id] = item;
          }
          return map;
        })
        .values
        .toList();
    isRefreshingStories.value = false;
    update();
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

    List<int> viewedStoryIds =
        await getIt<RealmDBManager>().getAllViewedStories();

    await StoryApi.getStories(resultCallback: (result) {
      for (var story in result) {
        var allMedias = story.media;
        var notViewedStoryMedias = allMedias.where(
            (element) => viewedStoryIds.contains(element.id) == false);

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
    followersStories.unique((e) => e.id);

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
          AppUtil.showToast(
              message: giftSentSuccessfullyString.tr, isSuccess: true);
          _userProfileManager.refreshProfile();
        });
  }

  liveUsersUpdated() {
    getStories();
  }
}
