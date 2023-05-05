import 'package:animate_do/animate_do.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/add_on/ui/reel/reels_list.dart';
import 'package:get/get.dart';
import '../../components/highlights_bar.dart';
import '../../components/profile/relationship_card.dart';
import '../../controllers/chat_and_call/chat_detail_controller.dart';
import '../../controllers/highlights_controller.dart';
import '../../controllers/profile_controller.dart';
import '../add_on/controller/relationship/relationship_controller.dart';
import '../add_on/model/my_relations_model.dart';
import '../../model/post_model.dart';
import '../../segmentAndMenu/horizontal_menu.dart';
import '../chat/chat_detail.dart';
import '../dashboard/posts.dart';
import '../highlights/choose_stories.dart';
import '../highlights/hightlights_viewer.dart';
import '../live/gifts_list.dart';
import '../settings_menu/settings_controller.dart';
import 'follower_following_list.dart';
import 'my_profile.dart';

class OtherUserProfile extends StatefulWidget {
  final int userId;

  const OtherUserProfile({Key? key, required this.userId}) : super(key: key);

  @override
  OtherUserProfileState createState() => OtherUserProfileState();
}

class OtherUserProfileState extends State<OtherUserProfile> {
  final ProfileController _profileController = Get.find();
  final HighlightsController _highlightsController = HighlightsController();
  final ChatDetailController _chatDetailController = Get.find();
  final SettingsController _settingsController = Get.find();
  final RelationshipController _relationshipController =
      RelationshipController();
  final UserProfileManager _userProfileManager = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _profileController.clear();
      initialLoad();
    });
  }

  initialLoad() {
    _profileController.getMyMentions(widget.userId);
    _profileController.getPosts(widget.userId);
    _profileController.getOtherUserDetail(userId: widget.userId);
    _highlightsController.getHighlights(userId: widget.userId);
    _profileController.getReels(widget.userId);
    _relationshipController.getUsersRelationships(userId: widget.userId);
  }

  @override
  void didUpdateWidget(covariant OtherUserProfile oldWidget) {
    super.didUpdateWidget(oldWidget);
    initialLoad();
  }

  @override
  void dispose() {
    _profileController.clear();
    _relationshipController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Stack(
          children: [profileInfoView(), giftSendingOverlay()],
        ));
  }

  Widget profileInfoView() {
    return Column(
      children: [
        Obx(() => _profileController.noDataFound.value == false
            ? Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 10),
                  children: [
                    addProfileView(),
                    const SizedBox(height: 10),
                    if (_settingsController.setting.value!.enableHighlights)
                      const SizedBox(height: 20),
                    if (_settingsController.setting.value!.enableHighlights)
                      addHighlightsView(),
                    const SizedBox(height: 20),
                    segmentView(),
                    Obx(() => _profileController.selectedSegment.value == 1
                        ? addReelsGrid()
                        : _profileController.selectedSegment.value == 3
                            ? addFamilyRelationGrid()
                            : addPhotoGrid()),
                    const SizedBox(height: 50),
                  ],
                ),
              )
            : Expanded(child: noUserFound(context))),
      ],
    );
  }

  Widget appBar() {
    return Positioned(
        left: 16,
        right: 16,
        top: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ThemeIconWidget(
              ThemeIcon.backArrow,
              size: 20,
              color: AppColorConstants.iconColor,
            ).ripple(() {
              Get.back();
            }),
            Obx(() => _profileController.user.value != null
                ? BodyLargeText(_profileController.user.value!.userName,
                    weight: TextWeight.medium)
                : Container()),
            Obx(() => _profileController.user.value?.isMe == false
                ? SizedBox(
                    height: 25,
                    width: 20,
                    child: ThemeIconWidget(
                      ThemeIcon.more,
                      color: AppColorConstants.iconColor,
                      size: 20,
                    ).ripple(() {
                      openActionPopup();
                    }),
                  )
                : Container())
          ],
        ));
  }

  Widget giftSendingOverlay() {
    return Obx(() => _profileController.sendingGift.value == null
        ? Container()
        : Positioned(
            left: 0,
            top: 0,
            right: 0,
            bottom: 0,
            child: Pulse(
              duration: const Duration(milliseconds: 500),
              child: Center(
                child: Image.network(
                  _profileController.sendingGift.value!.logo,
                  height: 80,
                  width: 80,
                  fit: BoxFit.contain,
                ),
              ),
            )));
  }

  addProfileView() {
    return GetBuilder<ProfileController>(
        init: _profileController,
        builder: (ctx) {
          return _profileController.user.value != null
              ? Column(
                  children: [
                    Stack(
                      children: [coverImage(), imageAndNameView(), appBar()],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    statsView().hP16,
                    const SizedBox(
                      height: 40,
                    ),
                    buttonsView().hP16
                  ],
                )
              : Container();
        });
  }

  Widget imageAndNameView() {
    return Positioned(
      left: 0,
      right: 0,
      top: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              UserAvatarView(
                  user: _profileController.user.value!,
                  size: 65,
                  onTapHandler: () {
                    //open live
                  }),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Heading6Text(_profileController.user.value!.userName,
                      weight: TextWeight.medium),
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
              if (_profileController.user.value!.profileCategoryTypeId != 0)
                BodyLargeText(
                        _profileController.user.value!.profileCategoryTypeName,
                        weight: TextWeight.regular)
                    .bP4,
              _profileController.user.value?.country != null
                  ? BodyMediumText(
                      '${_profileController.user.value!.country},${_profileController.user.value!.city}',
                    )
                  : Container(),
            ],
          ),
        ],
      ),
    );
  }

  Widget coverImage() {
    return _profileController.user.value!.coverImage != null
        ? CachedNetworkImage(
                width: Get.width,
                height: 225,
                fit: BoxFit.cover,
                imageUrl: _profileController.user.value!.coverImage!)
            // .overlay(Colors.black26)
            .bottomRounded(20)
        : SizedBox(
            width: Get.width,
            height: 225,
            // color: AppColorConstants.themeColor.withOpacity(0.2),
          );
  }

  Widget buttonsView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // const Spacer(),
        Expanded(
          child: AppThemeButton(
              height: 35,
              enabledBackgroundColor: _profileController.user.value!.isFollowing
                  ? AppColorConstants.themeColor
                  : AppColorConstants.themeColor.lighten(0.1),
              text: _profileController.user.value!.isFollowing
                  ? LocalizationString.unFollow
                  : _profileController.user.value!.isFollower
                      ? LocalizationString.followBack
                      : LocalizationString.follow.toUpperCase(),
              onPress: () {
                _profileController.followUnFollowUserApi(
                    context: context,
                    isFollowing: !_profileController.user.value!.isFollowing);
              }),
        ),

        if (_settingsController.setting.value!.enableChat)
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.25,
              child: AppThemeButton(
                  height: 35,
                  enabledBackgroundColor: AppColorConstants.disabledColor,
                  text: LocalizationString.chat,
                  onPress: () {
                    EasyLoading.show(status: LocalizationString.loading);
                    _chatDetailController.getChatRoomWithUser(
                        userId: _profileController.user.value!.id,
                        callback: (room) {
                          EasyLoading.dismiss();
                          Get.to(() => ChatDetail(
                                chatRoom: room,
                              ));
                        });
                  })).lP8,
        if (_settingsController.setting.value!.enableGift)
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.30,
              child: AppThemeButton(
                  height: 35,
                  enabledBackgroundColor: AppColorConstants.disabledColor,
                  text: LocalizationString.sendGift,
                  onPress: () {
                    showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return FractionallySizedBox(
                              heightFactor: 0.8,
                              child:
                                  GiftsPageView(giftSelectedCompletion: (gift) {
                                Get.back();
                                _profileController.sendGift(gift);
                              }));
                        });
                  })).lP8,
      ],
    );
  }

  Widget statsView() {
    return Container(
      color: AppColorConstants.cardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Heading4Text(
                _profileController.user.value!.totalPost.toString(),
              ).bP8,
              BodySmallText(
                LocalizationString.posts,
              ),
            ],
          ),
          // const SizedBox(
          //   width: 20,
          // ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Heading4Text(
                '${_profileController.user.value!.totalFollower}',
              ).bP8,
              BodySmallText(
                LocalizationString.followers,
              ),
            ],
          ).ripple(() {
            if (_profileController.user.value!.totalFollower > 0) {
              Get.to(() => FollowerFollowingList(
                        isFollowersList: true,
                        userId: widget.userId,
                      ))!
                  .then((value) {
                initialLoad();
              });
            }
          }),
          // const SizedBox(
          //   width: 20,
          // ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Heading4Text(
                '${_profileController.user.value!.totalFollowing}',
              ).bP8,
              BodySmallText(
                LocalizationString.following,
              ),
            ],
          ).ripple(() {
            if (_profileController.user.value!.totalFollowing > 0) {
              Get.to(() => FollowerFollowingList(
                        isFollowersList: false,
                        userId: widget.userId,
                      ))!
                  .then((value) {
                initialLoad();
              });
            }
          }),
        ],
      ).p16,
    ).round(15);
  }

  addHighlightsView() {
    return GetBuilder<HighlightsController>(
      init: _highlightsController,
      builder: (ctx) {
        return _highlightsController.isLoading
            ? const StoryAndHighlightsShimmer().vP25
            : _highlightsController.highlights.isNotEmpty
                ? HighlightsBar(
                    highlights: _highlightsController.highlights,
                    addHighlightCallback: () {
                      Get.to(() => const ChooseStoryForHighlights());
                    },
                    viewHighlightCallback: (highlight) {
                      Get.to(() => HighlightViewer(highlight: highlight));
                    },
                  ).vP25
                : Container();
      },
    );
  }

  Widget segmentView() {
    return HorizontalSegmentBar(
        textStyle: TextStyle(fontSize: FontSizes.b2),
        selectedTextStyle: TextStyle(
            fontSize: FontSizes.b2,
            fontWeight: TextWeight.bold,
            color: AppColorConstants.themeColor),
        width: MediaQuery.of(context).size.width,
        onSegmentChange: (segment) {
          _profileController.segmentChanged(segment);
        },
        hideHighlightIndicator: false,
        segments: (_profileController.user.value?.canViewRelations == true)
            ? [
                LocalizationString.posts,
                LocalizationString.reels,
                LocalizationString.mentions,
                LocalizationString.myFamily,
              ]
            : [
                LocalizationString.posts,
                LocalizationString.reels,
                LocalizationString.mentions,
              ]);
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
                  _profileController.getPosts(widget.userId);
                }
              } else {
                if (!_profileController.mentionsPostsIsLoading) {
                  _profileController.getMyMentions(widget.userId);
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
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 20.0,
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
                                source:
                                    _profileController.selectedSegment.value ==
                                            0
                                        ? PostSource.posts
                                        : PostSource.mentions,
                                page:
                                    _profileController.selectedSegment.value ==
                                            0
                                        ? _profileController.postsCurrentPage
                                        : _profileController.mentionsPostPage,
                                totalPages: _profileController.totalPages,
                              ))!
                          .then((value) {
                        initialLoad();
                      });
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
                _profileController
                    .getReels(_userProfileManager.user.value!.id);
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
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 20.0,
                      mainAxisExtent: 100),
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

  addFamilyRelationGrid() {
    return GetBuilder<RelationshipController>(
        init: _relationshipController,
        builder: (ctx) {
          ScrollController scrollController = ScrollController();
          scrollController.addListener(() {
            if (scrollController.position.maxScrollExtent ==
                scrollController.position.pixels) {
              _relationshipController.getUsersRelationships(
                  userId: widget.userId);
            }
          });

          List<MyRelationsModel> relationships =
              _relationshipController.relationships;

          return GridView.builder(
            controller: scrollController,
            itemCount: relationships.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 20.0,
                mainAxisExtent: 100),
            itemBuilder: (BuildContext context, int index) {
              return RelationshipCard(relationship: relationships[index])
                  .ripple(() {
                if (relationships[index].userId ==
                    _userProfileManager.user.value!.id) {
                  Get.to(() => const MyProfile(showBack: true))!.then((value) {
                    _relationshipController.getUsersRelationships(
                        userId: widget.userId);
                  });
                } else {
                  Get.to(() => OtherUserProfile(
                          userId: relationships[index].userId!))!
                      .then((value) {
                    _relationshipController.getUsersRelationships(
                        userId: widget.userId);
                  });
                }
              });
            },
          ).hP16;
        });
  }

  void openActionPopup() {
    showModalBottomSheet(
        context: context,
        builder: (context) => Wrap(
              children: [
                ListTile(
                    title:
                        Center(child: BodyLargeText(LocalizationString.report)),
                    onTap: () async {
                      Get.back();

                      _profileController.reportUser(context);
                    }),
                divider(context: context),
                ListTile(
                    title:
                        Center(child: BodyLargeText(LocalizationString.block)),
                    onTap: () async {
                      Get.back();

                      _profileController.blockUser(context);
                    }),
                divider(context: context),
                ListTile(
                    title:
                        Center(child: BodyLargeText(LocalizationString.cancel)),
                    onTap: () {
                      Get.back();
                    }),
              ],
            ));
  }
}
