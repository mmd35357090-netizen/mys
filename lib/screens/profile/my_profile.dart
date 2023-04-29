import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/add_on/ui/reel/reels_list.dart';
import 'package:foap/screens/profile/update_profile.dart';
import 'package:get/get.dart';

import '../../components/highlights_bar.dart';
import '../../controllers/highlights_controller.dart';
import '../../controllers/profile_controller.dart';
import '../../model/post_model.dart';
import '../../segmentAndMenu/horizontal_menu.dart';
import '../dashboard/posts.dart';
import '../highlights/choose_stories.dart';
import '../highlights/hightlights_viewer.dart';
import '../settings_menu/notifications.dart';
import '../settings_menu/settings_controller.dart';
import 'follower_following_list.dart';

class MyProfile extends StatefulWidget {
  final bool showBack;

  const MyProfile({Key? key, required this.showBack}) : super(key: key);

  @override
  MyProfileState createState() => MyProfileState();
}

class MyProfileState extends State<MyProfile> {
  final ProfileController _profileController = Get.find();
  final HighlightsController _highlightsController = HighlightsController();
  final SettingsController _settingsController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  @override
  void initState() {
    super.initState();
    initialLoad();
  }

  initialLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _profileController.clear();
      loadData();
    });
  }

  @override
  void didUpdateWidget(covariant MyProfile oldWidget) {
    super.didUpdateWidget(oldWidget);
    loadData();
  }

  @override
  void dispose() {
    _profileController.clear();
    super.dispose();
  }

  loadData() {
    _profileController.getMyProfile();
    _profileController.getMyMentions(_userProfileManager.user.value!.id);
    _profileController.getPosts(_userProfileManager.user.value!.id);
    _profileController.getReels(_userProfileManager.user.value!.id);

    _highlightsController.getHighlights(
        userId: _userProfileManager.user.value!.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 10),
                children: [
                  addProfileView(),
                  if (_settingsController.setting.value!.enableHighlights)
                    const SizedBox(height: 20),
                  if (_settingsController.setting.value!.enableHighlights)
                    addHighlightsView(),
                  const SizedBox(height: 40),
                  segmentView(),
                  Obx(() => _profileController.selectedSegment.value == 1
                      ? addReelsGrid()
                      : addPhotoGrid()),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ));
  }

  addProfileView() {
    return SizedBox(
      height: 430,
      child: GetBuilder<ProfileController>(
          init: _profileController,
          builder: (ctx) {
            return _profileController.user.value != null
                ? Stack(
                    children: [
                      _profileController.user.value!.coverImage != null
                          ? CachedNetworkImage(
                                  width: Get.width,
                                  height: 225,
                                  fit: BoxFit.cover,
                                  imageUrl: _profileController
                                      .user.value!.coverImage!)
                              .overlay(Colors.black26)
                              .bottomRounded(20)
                          : Container(
                              width: Get.width,
                              height: 200,
                              color:
                                  AppColorConstants.themeColor.withOpacity(0.2),
                            ).bottomRounded(20),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 70,
                        child: Column(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              UserAvatarView(
                                  user: _profileController.user.value!,
                                  size: 65,
                                  onTapHandler: () {}),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Heading6Text(
                                    _profileController.user.value!.userName,
                                    weight: TextWeight.medium,
                                  ),
                                  if (_profileController.user.value!.isVerified)
                                    Row(
                                      children: [
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Image.asset(
                                          'assets/verified.png',
                                          height: 15,
                                          width: 15,
                                        )
                                      ],
                                    ),
                                ],
                              ).bP4,
                              if (_profileController
                                      .user.value!.profileCategoryTypeId !=
                                  0)
                                BodyLargeText(
                                        _profileController.user.value!
                                            .profileCategoryTypeName,
                                        weight: TextWeight.medium)
                                    .bP4,
                              _profileController.user.value!.country != null
                                  ? BodyMediumText(
                                      '${_profileController.user.value!.country}, ${_profileController.user.value!.city}',
                                      color: AppColorConstants.themeColor,
                                    )
                                  : Container(),
                              const SizedBox(
                                height: 40,
                              ),
                              Container(
                                color: AppColorConstants.cardColor.darken(),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Heading4Text(
                                          _profileController
                                              .user.value!.totalPost
                                              .toString(),
                                          weight: TextWeight.medium,
                                        ).bP8,
                                        BodySmallText(
                                          LocalizationString.posts,
                                        ),
                                      ],
                                    ),
                                    // const Spacer(),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Heading4Text(
                                          '${_profileController.user.value!.totalFollower}',
                                          weight: TextWeight.medium,
                                        ).bP8,
                                        BodySmallText(
                                          LocalizationString.followers,
                                        ),
                                      ],
                                    ).ripple(() {
                                      if (_profileController
                                              .user.value!.totalFollower >
                                          0) {
                                        Get.to(() => FollowerFollowingList(
                                                  isFollowersList: true,
                                                  userId: getIt<
                                                          UserProfileManager>()
                                                      .user
                                                      .value!
                                                      .id,
                                                ))!
                                            .then((value) {
                                          loadData();
                                        });
                                      }
                                    }),
                                    // const Spacer(),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Heading4Text(
                                          '${_profileController.user.value!.totalFollowing}',
                                          weight: TextWeight.medium,
                                        ).bP8,
                                        BodySmallText(
                                          LocalizationString.following,
                                        ),
                                      ],
                                    ).ripple(() {
                                      if (_profileController
                                              .user.value!.totalFollowing >
                                          0) {
                                        Get.to(() => FollowerFollowingList(
                                                isFollowersList: false,
                                                userId: _userProfileManager
                                                    .user.value!.id))!
                                            .then((value) {
                                          loadData();
                                        });
                                      }
                                    }),
                                  ],
                                ).p16,
                              ).round(15),
                              const SizedBox(
                                height: 40,
                              ),
                              AppThemeBorderButton(
                                  height: 40,
                                  textStyle: TextStyle(
                                      fontSize: FontSizes.h6,
                                      color: AppColorConstants.grayscale900,
                                      fontWeight: TextWeight.semiBold),
                                  text: LocalizationString.editProfile,
                                  onPress: () {
                                    Get.to(() => const UpdateProfile())!
                                        .then((value) {
                                      loadData();
                                    });
                                  })
                            ]).p16,
                      ),
                      Positioned(top: 30, left: 0, right: 0, child: appBar())
                    ],
                  )
                : Container();
          }),
    );
  }

  Widget appBar() {
    return widget.showBack == true
        ? Obx(() => backNavigationBarWithIcon(
            context: context,
            title: _profileController.user.value?.userName ??
                LocalizationString.loading,
            icon: ThemeIcon.notification,
            iconBtnClicked: () {
              Get.to(() => const NotificationsScreen());
            }))
        : Obx(() => titleNavigationBarWithIcon(
            context: context,
            title: _profileController.user.value?.userName ??
                LocalizationString.loading,
            icon: ThemeIcon.notification,
            completion: () {
              Get.to(() => const NotificationsScreen());
            }));
  }

  Widget segmentView() {
    return HorizontalSegmentBar(
        textStyle: TextStyle(fontSize: FontSizes.b2),
        hideHighlightIndicator: false,
        selectedTextStyle: TextStyle(
            fontSize: FontSizes.b2,
            fontWeight: TextWeight.bold,
            color: AppColorConstants.themeColor),
        width: MediaQuery.of(context).size.width,
        onSegmentChange: (segment) {
          _profileController.segmentChanged(segment);
        },
        segments: [
          LocalizationString.posts,
          LocalizationString.reels,
          LocalizationString.mentions,
        ]);
  }

  addHighlightsView() {
    return GetBuilder<HighlightsController>(
        init: _highlightsController,
        builder: (ctx) {
          return _highlightsController.isLoading == true
              ? const StoryAndHighlightsShimmer()
              : HighlightsBar(
                  highlights: _highlightsController.highlights,
                  addHighlightCallback: () {
                    Get.to(() => const ChooseStoryForHighlights());
                  },
                  viewHighlightCallback: (highlight) {
                    Get.to(() => HighlightViewer(highlight: highlight))!
                        .then((value) {
                      loadData();
                    });
                  },
                );
        });
  }

  addPhotoGrid() {
    return GetBuilder<ProfileController>(
        init: _profileController,
        builder: (ctx) {
          ScrollController scrollController = ScrollController();
          scrollController.addListener(() {
            if (scrollController.position.maxScrollExtent ==
                scrollController.position.pixels) {
              if (_profileController.selectedSegment.value == 0) {
                if (!_profileController.isLoadingPosts) {
                  _profileController
                      .getPosts(_userProfileManager.user.value!.id);
                }
              } else {
                if (!_profileController.mentionsPostsIsLoading) {
                  _profileController
                      .getMyMentions(_userProfileManager.user.value!.id);
                }
              }
            }
          });

          List<PostModel> posts = _profileController.selectedSegment.value == 0
              ? _profileController.posts
              : _profileController.mentions;

          return _profileController.isLoadingPosts
              ? const PostBoxShimmer()
              : GridView.builder(
                  controller: scrollController,
                  itemCount: posts.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  // You won't see infinite size error
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      mainAxisExtent: 100),
                  itemBuilder: (BuildContext context, int index) =>
                      Stack(children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: CachedNetworkImage(
                        imageUrl: posts[index].gallery.first.thumbnail,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            AppUtil.addProgressIndicator(size: 100),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.error,
                        ),
                      ).round(10),
                    ).ripple(() {
                      Get.to(() => Posts(
                          posts: List.from(posts),
                          index: index,
                          userId: _userProfileManager.user.value!.id,
                          source: _profileController.selectedSegment.value == 0
                              ? PostSource.posts
                              : PostSource.mentions,
                          page: _profileController.selectedSegment.value == 0
                              ? _profileController.postsCurrentPage
                              : _profileController.mentionsPostPage,
                          totalPages: _profileController.totalPages));
                    }),
                    posts[index].gallery.length == 1
                        ? posts[index].gallery.first.isVideoPost == true
                            ? const Positioned(
                                right: 5,
                                top: 5,
                                child: ThemeIconWidget(
                                  ThemeIcon.videoPost,
                                  size: 30,
                                  color: Colors.white,
                                ),
                              )
                            : Container()
                        : const Positioned(
                            right: 5,
                            top: 5,
                            child: ThemeIconWidget(
                              ThemeIcon.multiplePosts,
                              color: Colors.white,
                              size: 30,
                            ))
                  ]),
                ).hP16;
        });
  }

  addReelsGrid() {
    return GetBuilder<ProfileController>(
        init: _profileController,
        builder: (ctx) {
          ScrollController scrollController = ScrollController();
          scrollController.addListener(() {
            if (scrollController.position.maxScrollExtent ==
                scrollController.position.pixels) {
              if (!_profileController.isLoadingReels) {
                _profileController.getReels(_userProfileManager.user.value!.id);
              }
            }
          });

          List<PostModel> posts = _profileController.reels;

          return _profileController.isLoadingReels
              ? const PostBoxShimmer()
              : GridView.builder(
                  controller: scrollController,
                  itemCount: posts.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  // You won't see infinite size error
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemBuilder: (BuildContext context, int index) =>
                      Stack(children: [
                    AspectRatio(
                      aspectRatio: 0.7,
                      child: CachedNetworkImage(
                        imageUrl: posts[index].gallery.first.thumbnail,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            AppUtil.addProgressIndicator(size: 100),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.error,
                        ),
                      ).round(10),
                    ).ripple(() {
                      Get.to(() => ReelsList(
                            reels: List.from(posts),
                            index: index,
                            userId: _userProfileManager.user.value!.id,
                            page: _profileController.reelsCurrentPage,
                          ));
                    }),
                    const Positioned(
                      right: 5,
                      top: 5,
                      child: ThemeIconWidget(
                        ThemeIcon.videoPost,
                        size: 30,
                        color: Colors.white,
                      ),
                    )
                  ]),
                ).hP16;
        });
  }
}
