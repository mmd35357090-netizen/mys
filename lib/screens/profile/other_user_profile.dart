import 'package:foap/controllers/subscription/subscription_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/profile/sliver_app_bar.dart';
import 'package:foap/screens/profile/user_profile_stat.dart';
import '../../components/highlights_bar.dart';
import '../../components/post_card/post_card.dart';
import '../../components/sm_tab_bar.dart';
import '../../controllers/chat_and_call/chat_detail_controller.dart';
import '../../controllers/profile/other_user_profile_controller.dart';
import '../../controllers/story/highlights_controller.dart';
import '../../model/post_model.dart';
import '../chat/chat_detail.dart';
import '../highlights/hightlights_viewer.dart';
import '../live/gifts_list.dart';
import '../settings_menu/settings_controller.dart';

class OtherUserProfile extends StatefulWidget {
  final int userId;
  final UserModel? user;

  const OtherUserProfile({super.key, required this.userId, this.user});

  @override
  OtherUserProfileState createState() => OtherUserProfileState();
}

class OtherUserProfileState extends State<OtherUserProfile>
    with SingleTickerProviderStateMixin {
  final OtherUserProfileController _profileController = Get.find();
  final HighlightsController _highlightsController = Get.find();
  final SettingsController _settingsController = Get.find();
  final ChatDetailController _chatDetailController = Get.find();
  final UserSubscriptionController _subscriptionController = Get.find();

  List<String> tabs = [postsString, reelsString, mentionsString];

  TabController? controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(vsync: this, length: tabs.length)
      ..addListener(() {});
    initialLoad();
  }

  initialLoad() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // if (widget.user != null) {
      //   _profileController.setUser(widget.user!);
      // }
      _profileController.clear();

      loadData();
    });
  }

  @override
  void didUpdateWidget(covariant OtherUserProfile oldWidget) {
    super.didUpdateWidget(oldWidget);
    loadData();
  }

  @override
  void dispose() {
    _profileController.clear();
    super.dispose();
  }

  loadData() {
    _profileController.getOtherUserDetail(
        userId: widget.userId,
        completionBlock: (user) {
          if (user.isPrivateProfile == false ||
              user.followingStatus == FollowingStatus.following) {
            _profileController.getMentionPosts(widget.userId);
            _profileController.getReels(widget.userId);
            _profileController.getPosts(
                userId: widget.userId, callback: () {});
            _highlightsController.getHighlights(userId: widget.userId);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => AppScaffold(
          backgroundColor: AppColorConstants.backgroundColor,
          body: Column(
            children: [
              appBar(),
              if (_profileController.user.value != null)
                _profileController.user.value!.isPrivateProfile &&
                        _profileController.user.value!.followingStatus ==
                            FollowingStatus.notFollowing
                    ? Column(
                        children: [header(), body()],
                      )
                    : Expanded(
                        child: DefaultTabController(
                          length: tabs.length,
                          child: NestedScrollView(
                            headerSliverBuilder: (BuildContext context,
                                bool innerBoxIsScrolled) {
                              return <Widget>[
                                SliverAppBar(
                                  backgroundColor:
                                      AppColorConstants.backgroundColor,
                                  pinned: false,
                                  automaticallyImplyLeading: false,
                                  expandedHeight: headerHeight(),
                                  toolbarHeight: 0,
                                  flexibleSpace: FlexibleSpaceBar(
                                    background: header(),
                                  ),
                                ),
                                if (_profileController.user.value!
                                            .isPrivateProfile ==
                                        false ||
                                    _profileController
                                            .user.value!.followingStatus ==
                                        FollowingStatus.following)
                                  SliverPersistentHeader(
                                    delegate: SliverAppBarDelegate(
                                        SizedBox(
                                            height: 50,
                                            child: SMTabBar(
                                                tabs: tabs,
                                                canScroll: false))),
                                    pinned: true,
                                    // floating: true,
                                  )
                              ];
                            },
                            body: body(),
                          ),
                        ),
                      ),
            ],
          ),
        ));
  }

  double headerHeight() {
    double categoryPortionHt =
        _profileController.user.value!.profileCategoryTypeId != 0 ? 20 : 0;
    double cityNamePortionHt =
        _profileController.user.value?.country != null ? 20 : 0;

    return (_profileController.user.value!.isPrivateProfile &&
                _profileController.user.value!.followingStatus !=
                    FollowingStatus.following
            ? 370
            : _highlightsController.highlights.isNotEmpty
                ? 415.0
                : 390) +
        categoryPortionHt +
        cityNamePortionHt;
  }

  Widget header() {
    return SizedBox(
      height: headerHeight(),
      child: Column(
        children: [
          addProfileView().bP16,
          if (_profileController.user.value!.isPrivateProfile == false ||
              _profileController.user.value!.followingStatus ==
                  FollowingStatus.following)
            addHighlightsView().bP16,
        ],
      ),
    );
  }

  Widget body() {
    return Column(
      children: [
        if (_settingsController.appearanceChanged!.value) Container(),
        _profileController.user.value!.isPrivateProfile
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  ThemeIconWidget(
                    ThemeIcon.lock,
                    size: 100,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Heading6Text(accountIsPrivateString.tr,
                      weight: TextWeight.medium),
                  const SizedBox(
                    height: 10,
                  ),
                  BodyLargeText(
                    followAccountToViewPostsString.tr,
                  ),
                ],
              )
            : Flexible(
                // Use Flexible to ensure proper layout
                child: TabBarView(
                  children: [
                    postsView(),
                    reelsView(),
                    mentionedView(),
                  ],
                ),
              ),
      ],
    );
  }

  Widget addProfileView() {
    return GetBuilder<OtherUserProfileController>(
        init: _profileController,
        builder: (ctx) {
          return _profileController.user.value != null
              ? Column(
                  children: [
                    Stack(
                      children: [coverImage(), imageAndNameView()],
                    ),
                    Column(
                      children: [
                        UserProfileStatistics(
                          user: _profileController.user.value!,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        actionButtonsView(),
                      ],
                    ).hp(DesignConstants.horizontalPadding)
                  ],
                )
              : Container();
        });
  }

  Widget imageAndNameView() {
    return Positioned(
      left: 0,
      right: 0,
      top: 40,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              UserAvatarView(
                  user: _profileController.user.value!,
                  size: 75,
                  onTapHandler: () {
                    //open live
                  }),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BodyLargeText(_profileController.user.value!.userName,
                      weight: TextWeight.medium),
                  if (_profileController.user.value!.isVerified)
                    verifiedUserTag()
                ],
              ).bP4,
              if (_profileController.user.value!.profileCategoryTypeId !=
                  0)
                BodyMediumText(
                        _profileController
                            .user.value!.profileCategoryTypeName,
                        weight: TextWeight.regular)
                    .bP4,
              if (_profileController.user.value?.country != null)
                BodyMediumText(
                  '${_profileController.user.value!.country},${_profileController.user.value!.city}',
                ),
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
                height: 250,
                fit: BoxFit.cover,
                imageUrl: _profileController.user.value!.coverImage!)
            .bottomRounded(20)
        : SizedBox(
            width: Get.width,
            height: 200,
          );
  }

  Widget actionButtonsView() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        runAlignment: WrapAlignment.start,
        alignment: WrapAlignment.center,
        runSpacing: 5,
        spacing: 5,
        children: [
          IntrinsicWidth(
            child: AppThemeButton(
              height: 40,
              text: _profileController.user.value!.followingStatus ==
                      FollowingStatus.following
                  ? unFollowString.tr
                  : _profileController.user.value!.followingStatus ==
                          FollowingStatus.requested
                      ? requestedString.tr
                      : _profileController.user.value!.isFollower
                          ? followBackString.tr
                          : followString.tr,
              onPress: () {
                _profileController.followUnFollowUser(
                    user: _profileController.user.value!);
              },
              backgroundColor:
                  _profileController.user.value!.followingStatus ==
                          FollowingStatus.following
                      ? AppColorConstants.themeColor
                      : AppColorConstants.cardColor,
            ),
          ),
          if (_profileController.user.value!.isVIPUser)
            IntrinsicWidth(
              child: AppThemeButton(
                height: 40,
                text: _profileController.user.value!.subscribedStatus ==
                        SubscribedStatus.subscribed
                    ? subscribedString.tr
                    : '${subscribeString.tr} (${_profileController.user.value!.subscriptionPlans.first.value!})',
                onPress: () {
                  subscribeUser();
                },
              ),
            ),
          if (_settingsController.setting.value!.enableChat)
            IntrinsicWidth(
              child: AppThemeButton(
                height: 40,
                text: chatString.tr,
                onPress: () {
                  Loader.show(status: loadingString.tr);
                  _chatDetailController.getChatRoomWithUser(
                      userId: _profileController.user.value!.id,
                      callback: (room) {
                        Loader.dismiss();
                        Get.to(() => ChatDetail(
                              chatRoom: room,
                            ));
                      });
                },
              ),
            ),
          if (_settingsController.setting.value!.enableGift)
            IntrinsicWidth(
              child: AppThemeButton(
                height: 40,
                text: sendGiftString.tr,
                onPress: () {
                  showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return FractionallySizedBox(
                            heightFactor: 0.8,
                            child: GiftsPageView(
                                giftSelectedCompletion: (gift) {
                              Get.back();
                              _profileController.sendGift(gift);
                            }));
                      });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget appBar() {
    return Container(
      height: 100,
      color: AppColorConstants.cardColor,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
              width: 50,
              child: Align(
                alignment: Alignment.centerLeft,
                child: ThemeIconWidget(
                  ThemeIcon.backArrow,
                  size: 18,
                ),
              )).ripple(() {
            Get.back();
          }),
          ThemeIconWidget(
            ThemeIcon.more,
          ).ripple(() {
            openActionPopup();
          }),
        ],
      ).setPadding(
          left: DesignConstants.horizontalPadding,
          right: DesignConstants.horizontalPadding,
          top: 40),
    );
  }

  void openActionPopup() {
    showModalBottomSheet(
        context: context,
        builder: (context) => Container(
              color: AppColorConstants.backgroundColor,
              child: Wrap(
                children: [
                  ListTile(
                      title: Center(child: BodyLargeText(reportString.tr)),
                      onTap: () async {
                        Get.back();
                        _profileController.reportUser();
                      }),
                  divider(),
                  ListTile(
                      title: Center(child: BodyLargeText(blockString.tr)),
                      onTap: () async {
                        Get.back();
                        _profileController.blockUser();
                      }),
                  divider(),
                  ListTile(
                      title: Center(child: BodyLargeText(cancelString.tr)),
                      onTap: () {
                        Get.back();
                      }),
                ],
              ),
            ));
  }

  Widget addHighlightsView() {
    return GetBuilder<HighlightsController>(
        init: _highlightsController,
        builder: (ctx) {
          return _highlightsController.isLoading.value == true
              ? const StoryAndHighlightsShimmer()
              : _highlightsController.highlights.isEmpty
                  ? Container()
                  : HighlightsBar(
                      highlights: _highlightsController.highlights,
                      viewHighlightCallback: (highlight) {
                        Get.to(() =>
                                HighlightViewer(highlight: highlight))!
                            .then((value) {
                          loadData();
                        });
                      },
                    );
        });
  }

  postsView() {
    ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        _profileController.getPosts(
            userId: widget.userId, callback: () {});
      }
    });

    return GetBuilder<OtherUserProfileController>(
        init: _profileController,
        builder: (ctx) {
          List<PostModel> posts = _profileController.posts;

          return _profileController.postDataWrapper.isLoading.value
              ? const HomeScreenShimmer()
              : posts.isEmpty
                  ? Center(child: BodyLargeText(noDataString.tr))
                  : ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(top: 10, bottom: 50),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        PostModel model = posts[index];
                        return PostCard(
                            model: model,
                            removePostHandler: () {
                              _profileController.removePostFromList(model);
                            },
                            blockUserHandler: () {
                              _profileController
                                  .removeUsersAllPostFromList(model);
                            });
                      },
                      separatorBuilder: (ctx, index) {
                        return const SizedBox(
                          height: 15,
                        );
                      },
                    );
        });
  }

  reelsView() {
    ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        _profileController.getReels(widget.userId);
      }
    });

    return GetBuilder<OtherUserProfileController>(
        init: _profileController,
        builder: (ctx) {
          List<PostModel> posts = _profileController.reels;

          return _profileController.reelsDataWrapper.isLoading.value
              ? const HomeScreenShimmer()
              : posts.isEmpty
                  ? Center(child: BodyLargeText(noDataString.tr))
                  : ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(top: 10, bottom: 50),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        PostModel model = posts[index];
                        return PostCard(
                            model: model,
                            removePostHandler: () {
                              _profileController.removePostFromList(model);
                            },
                            blockUserHandler: () {
                              _profileController
                                  .removeUsersAllPostFromList(model);
                            });
                      },
                      separatorBuilder: (ctx, index) {
                        return const SizedBox(
                          height: 15,
                        );
                      },
                    );
        });
  }

  mentionedView() {
    ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        _profileController.getMentionPosts(widget.userId);
      }
    });

    return GetBuilder<OtherUserProfileController>(
        init: _profileController,
        builder: (ctx) {
          List<PostModel> posts = _profileController.mentions;

          return _profileController
                  .mentionedPostDataWrapper.isLoading.value
              ? const HomeScreenShimmer()
              : posts.isEmpty
                  ? Center(child: BodyLargeText(noDataString.tr))
                  : ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(top: 10, bottom: 50),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        PostModel model = posts[index];
                        return PostCard(
                            model: model,
                            removePostHandler: () {
                              _profileController.removePostFromList(model);
                            },
                            blockUserHandler: () {
                              _profileController
                                  .removeUsersAllPostFromList(model);
                            });
                      },
                      separatorBuilder: (ctx, index) {
                        return const SizedBox(
                          height: 15,
                        );
                      },
                    );
        });
  }

  subscribeUser() {
    AppUtil.showNewConfirmationAlert(
        title:
            '${subscribeString.tr} ${_profileController.user.value!.userName}',
        subTitle:
            '${areYouSureToSubscribeString.tr} ${_profileController.user.value!.userName}',
        okHandler: () {
          _subscriptionController.subscribeUser(
              userPlanId: _profileController
                  .user.value!.subscriptionPlans.first.id,
              succesCalback: () {
                _profileController.getOtherUserDetail(
                    userId: widget.userId, completionBlock: (user) {});
              });
        },
        cancelHandler: () {});
  }
}
