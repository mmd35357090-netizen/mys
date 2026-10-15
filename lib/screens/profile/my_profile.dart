import 'package:foap/components/sm_tab_bar.dart';
import 'package:foap/controllers/notification/notifications_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/login_signup_imports.dart';
import 'package:foap/helper/imports/reel_imports.dart';
import 'package:foap/model/account.dart';
import 'package:foap/screens/profile/sliver_app_bar.dart';
import 'package:foap/screens/profile/update_profile.dart';
import 'package:foap/screens/profile/user_profile_stat.dart';
import 'package:foap/screens/settings_menu/notifications.dart';
import 'package:foap/screens/settings_menu/settings.dart';
import 'package:foap/util/shared_prefs.dart';
import '../../components/highlights_bar.dart';
import '../../components/post_card/post_card.dart';
import '../../controllers/story/highlights_controller.dart';
import '../../controllers/profile/profile_controller.dart';
import '../highlights/choose_stories.dart';
import '../highlights/hightlights_viewer.dart';
import '../settings_menu/settings_controller.dart';

class MyProfile extends StatefulWidget {
  final bool showBack;

  const MyProfile({super.key, required this.showBack});

  @override
  MyProfileState createState() => MyProfileState();
}

class MyProfileState extends State<MyProfile> {
  final ProfileController _profileController = Get.find();
  final HighlightsController _highlightsController = Get.find();
  final SettingsController _settingsController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();
  final NotificationController _notificationController = Get.find();

  List<String> tabs = [
    postsString.tr,
    reelsString.tr,
    mentionsString.tr,
    collaborationsString.tr
  ];

  @override
  void initState() {
    super.initState();
    _notificationController.getNotificationInfo();

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

    _profileController.getMentionPosts(_userProfileManager.user.value!.id);
    _profileController.getCollaborationsPosts();
    _profileController.getPosts(
        userId: _userProfileManager.user.value!.id, callback: () {});
    _profileController.getReels(_userProfileManager.user.value!.id);
    _highlightsController.getHighlights(
        userId: _userProfileManager.user.value!.id);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => AppScaffold(
          backgroundColor: AppColorConstants.backgroundColor,
          body: _profileController.user.value == null
              ? Container()
              : Column(
                  children: [
                    appBar(),
                    Expanded(
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
                              SliverPersistentHeader(
                                delegate: SliverAppBarDelegate(SizedBox(
                                    height: 50,
                                    child: SMTabBar(
                                        tabs: tabs, canScroll: false))),
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

    return 385 + categoryPortionHt + cityNamePortionHt;
  }

  Widget header() {
    return SizedBox(
      height: headerHeight(),
      child: Column(
        children: [
          addProfileView().bP16,
          addHighlightsView().bP16,
        ],
      ),
    );
  }

  Widget body() {
    return Column(
      children: [
        if (_settingsController.appearanceChanged!.value) Container(),
        Flexible(
          // Use Flexible to ensure proper layout
          child: TabBarView(
            children: [
              postsView(),
              reelsView(),
              mentionedView(),
              collaborationsView()
            ],
          ),
        ),
      ],
    );
  }

  Widget addProfileView() {
    return GetBuilder<ProfileController>(
        init: _profileController,
        builder: (ctx) {
          return _profileController.user.value != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                      UserAvatarView(
                          user: _profileController.user.value!,
                          size: 75,
                          onTapHandler: () {}),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          BodyLargeText(
                            _profileController.user.value!.userName,
                            weight: TextWeight.bold,
                          ),
                          if (_profileController.user.value!.isVerified)
                            verifiedUserTag()
                        ],
                      ).bP4,
                      if (_profileController
                              .user.value!.profileCategoryTypeId !=
                          0)
                        BodyMediumText(
                          _profileController
                              .user.value!.profileCategoryTypeName,
                          weight: TextWeight.medium,
                          color: AppColorConstants.mainTextColor,
                        ).bP4,
                      if (_profileController.user.value!.country != null)
                        BodyMediumText(
                          '${_profileController.user.value!.country}, ${_profileController.user.value!.city}',
                          color: AppColorConstants.mainTextColor,
                        ),
                      const SizedBox(
                        height: 20,
                      ),
                      UserProfileStatistics(
                        user: _profileController.user.value!,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      AppThemeButton(
                          height: 40,
                          text: editProfileString.tr,
                          onPress: () {
                            Get.to(() => const UpdateProfile())!
                                .then((value) {
                              loadData();
                            });
                          })
                    ]).p16
              : Container();
        });
  }

  Widget addHighlightsView() {
    return GetBuilder<HighlightsController>(
        init: _highlightsController,
        builder: (ctx) {
          return _highlightsController.isLoading.value == true
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

  Widget appBar() {
    return SizedBox(
      height: 100,
      width: double.infinity,
      child: Stack(
        children: [
          if (widget.showBack == false)
            Row(
              children: [
                Heading6Text(
                  _profileController.user.value!.userName,
                  weight: TextWeight.bold,
                ),
                const SizedBox(
                  width: 5,
                ),
                ThemeIconWidget(ThemeIcon.downArrow),
              ],
            ).ripple(() async {
              List<SayHiAppAccount> accounts =
                  await SharedPrefs().getAccounts();
              accounts = accounts
                  .where((e) =>
                      e.userId !=
                      _userProfileManager.user.value!.id.toString())
                  .toList();
              Get.bottomSheet(LinkedAccountsList(
                accounts: accounts,
              ));
            }),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widget.showBack == true
                  ? SizedBox(
                      width: 50,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: ThemeIconWidget(
                          ThemeIcon.backArrow,
                          size: 18,
                          color: AppColorConstants.iconColor,
                        ),
                      )).ripple(() {
                      Get.back();
                    })
                  : const SizedBox(width: 50),
              Row(
                children: [
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
                                ).circular)
                        ],
                      )),
                  const SizedBox(
                    width: 20,
                  ),
                  ThemeIconWidget(
                    ThemeIcon.setting,
                    size: 25,
                    color: AppColorConstants.themeColor,
                  ).ripple(() {
                    Get.to(() => const Settings());
                  })
                ],
              ),
            ],
          ),
        ],
      ).setPadding(
          left: DesignConstants.horizontalPadding,
          right: DesignConstants.horizontalPadding,
          top: 50),
    );
  }

  postsView() {
    ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        _profileController.getPosts(
            userId: _userProfileManager.user.value!.id, callback: () {});
      }
    });

    return GetBuilder<ProfileController>(
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
        _profileController.getReels(_userProfileManager.user.value!.id);
      }
    });

    return GetBuilder<ProfileController>(
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
        _profileController
            .getMentionPosts(_userProfileManager.user.value!.id);
      }
    });

    return GetBuilder<ProfileController>(
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

  collaborationsView() {
    ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        _profileController.getCollaborationsPosts();
      }
    });

    return GetBuilder<ProfileController>(
        init: _profileController,
        builder: (ctx) {
          List<PostModel> posts = _profileController.collaborations;

          return _profileController
                  .collaborationsDataWrapper.isLoading.value
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
}

class LinkedAccountsList extends StatelessWidget {
  final UserProfileManager _userProfileManager = Get.find();

  List<SayHiAppAccount> accounts;

  LinkedAccountsList({super.key, required this.accounts});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        color: AppColorConstants.backgroundColor,
        child: Column(
          children: [
            const SizedBox(
              height: 25,
            ),
            BodyLargeText(switchAccountString.tr),
            divider(height: 0.5).tP16,
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (SayHiAppAccount account in accounts)
                      Column(
                        children: [
                          SizedBox(
                            height: 55,
                            child: Row(
                              children: [
                                AvatarView(
                                  url: account.picture,
                                  name: account.username,
                                  size: 28,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                BodyLargeText(account.username),
                              ],
                            ),
                          ).ripple(() {
                            Get.back();
                            _userProfileManager.switchToAccount(account);
                          }),
                          divider(height: 0.5).vP8,
                        ],
                      ),
                  ],
                ).p(DesignConstants.horizontalPadding),
              ),
            ),
            AppThemeButton(
                text: addAccountString.tr,
                onPress: () {
                  Get.back();
                  Get.to(const LoginScreen(
                    showCloseBtn: true,
                  ));
                }).p(DesignConstants.horizontalPadding)
          ],
        ),
      ).topRounded(25),
    );
  }
}
