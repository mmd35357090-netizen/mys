import 'package:foap/helper/imports/club_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/post_imports.dart';
import 'package:foap/helper/number_extension.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../components/sm_tab_bar.dart';
import '../../controllers/chat_and_call/chat_detail_controller.dart';
import '../chat/chat_detail.dart';

class ClubDetail extends StatefulWidget {
  final ClubModel club;
  final VoidCallback needRefreshCallback;
  final Function(ClubModel) deleteCallback;

  const ClubDetail(
      {super.key,
      required this.club,
      required this.needRefreshCallback,
      required this.deleteCallback});

  @override
  ClubDetailState createState() => ClubDetailState();
}

class ClubDetailState extends State<ClubDetail> {
  final ClubDetailController _clubDetailController = ClubDetailController();
  final ChatDetailController _chatDetailController = Get.find();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<String> tabs = [aboutString.tr, postsString.tr];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clubDetailController.setClub(widget.club);
      refreshPosts();
      _clubDetailController.getClubJoinRequests(clubId: widget.club.id!);
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _clubDetailController.clear();
  }

  refreshPosts() {
    _clubDetailController.refreshPosts(
        clubId: widget.club.id!, callback: () {});
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      floatingActionButton: widget.club.createdByUser!.isMe
          ? Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [
                  AppColorConstants.themeColor,
                  AppColorConstants.themeColor.withValues(alpha: 0.78)
                ]),
                boxShadow: [
                  BoxShadow(
                      color: AppColorConstants.themeColor.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6))
                ],
              ),
              child: ThemeIconWidget(
                ThemeIcon.edit,
                size: 24,
                color: Colors.white,
              ),
            ).ripple(() {
              Future.delayed(
                Duration.zero,
                () => showGeneralDialog(
                    context: Get.context!,
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        AddPostScreen(
                            postType: PostCategory.club,
                            postCompletionHandler: () {
                              refreshPosts();
                            },
                            club: _clubDetailController.club.value!)),
              );
            })
          : null,
      body: DefaultTabController(
          length: tabs.length,
          child: Stack(
            children: [
              Column(
                children: [
                  Obx(() => SizedBox(
                      height: 350,
                      width: Get.width,
                      child: _clubDetailController.club.value == null
                          ? Container()
                          : CachedNetworkImage(
                              imageUrl:
                                  _clubDetailController.club.value!.image!,
                              fit: BoxFit.cover,
                            ))),
                  SMTabBar(
                    tabs: tabs,
                    canScroll: false,
                  ),
                  Expanded(
                    child: TabBarView(children: [
                      Obx(() {
                        return _clubDetailController.club.value == null
                            ? Container()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(
                                    height: 24,
                                  ),
                                  Heading5Text(
                                          _clubDetailController
                                              .club.value!.name!,
                                          weight: TextWeight.bold)
                                      .hp(DesignConstants.horizontalPadding),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Row(
                                    children: [
                                      ThemeIconWidget(ThemeIcon.userGroup),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      BodyMediumText(
                                        _clubDetailController
                                            .club.value!.groupType,
                                        weight: TextWeight.medium,
                                      ),
                                      ThemeIconWidget(
                                        ThemeIcon.circle,
                                        size: 8,
                                      ).hP8,
                                      BodyMediumText(
                                              '${_clubDetailController.club.value!.totalMembers!.formatNumber} ${clubMembersString.tr}',
                                              weight: TextWeight.regular)
                                          .ripple(() {
                                        Get.to(() => ClubMembers(
                                            club: _clubDetailController
                                                .club.value!));
                                      })
                                    ],
                                  ).hp(DesignConstants.horizontalPadding),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  buttonsWidget()
                                      .hp(DesignConstants.horizontalPadding),
                                ],
                              );
                      }),
                      postsView()
                    ]),
                  ),
                ],
              ),
              appBar()
            ],
          )),
    );
  }

  Widget postsView() {
    return Obx(() => ListView.separated(
            padding: const EdgeInsets.only(top: 25, bottom: 100),
            itemBuilder: (BuildContext context, index) {
              return PostCard(
                model: _clubDetailController.posts[index],
                removePostHandler: () {},
                blockUserHandler: () {},
              );
            },
            separatorBuilder: (BuildContext context, index) {
              return const SizedBox(
                height: 40,
              );
            },
            itemCount: _clubDetailController.posts.length)
        .addPullToRefresh(
            refreshController: _refreshController,
            onRefresh: () {
              _clubDetailController.refreshPosts(
                  clubId: widget.club.id!,
                  callback: () {
                    _refreshController.refreshCompleted();
                  });
            },
            onLoading: () {
              _clubDetailController.loadMorePosts(
                  clubId: widget.club.id!,
                  callback: () {
                    _refreshController.loadComplete();
                  });
            },
            enablePullUp: true,
            enablePullDown: true));
  }

  Widget buttonsWidget() {
    return Row(
      children: [
        if (_clubDetailController.club.value!.createdByUser!.isMe == false)
          Container(
                  height: 38,
                  color: AppColorConstants.themeColor.withValues(alpha: 0.14),
                  child: Row(
                    children: [
                      Icon(
                        _clubDetailController.club.value!.isJoined == true
                            ? Icons.exit_to_app
                            : Icons.add,
                        color: AppColorConstants.themeColor,
                        size: 17,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      BodyLargeText(_clubDetailController
                                  .club.value!.isJoined ==
                              true
                          ? joinedString.tr
                          : _clubDetailController.club.value!.isRequestBased ==
                                  true
                              ? _clubDetailController.club.value!.isRequested ==
                                      true
                                  ? requestedString.tr
                                  : requestJoinString.tr
                              : joinString.tr,
                      weight: TextWeight.semiBold)
                    ],
                  ).hP16)
              .round(19)
              .ripple(() {
            if (_clubDetailController.club.value!.isRequested == false) {
              if (_clubDetailController.club.value!.isJoined == true) {
                _clubDetailController.leaveClub();
              } else {
                _clubDetailController.joinClub();
              }
            }
          }).rP8,
        if (_clubDetailController.club.value!.enableChat == 1 &&
            _clubDetailController.club.value!.isJoined == true)
          Container(
                  // width: 40,
                  height: 38,
                  color: AppColorConstants.themeColor.withValues(alpha: 0.14),
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat,
                        size: 15,
                        color: AppColorConstants.themeColor,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      BodyLargeText(chatString.tr, weight: TextWeight.semiBold)
                    ],
                  ).hP16)
              .round(19)
              .ripple(() {
            Loader.show(status: loadingString.tr);
            _chatDetailController.getRoomDetail(
                _clubDetailController.club.value!.chatRoomId!, (room) {
              Loader.dismiss();
              Get.to(() => ChatDetail(chatRoom: room));
            });
          }).rP8,
        if (_clubDetailController.club.value!.createdByUser!.isMe)
          Container(
                  // width: 40,
                  height: 38,
                  color: AppColorConstants.themeColor.withValues(alpha: 0.14),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/request.png',
                        fit: BoxFit.contain,
                        color: AppColorConstants.iconColor,
                        height: 15,
                        width: 15,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      BodyLargeText(inviteString.tr, weight: TextWeight.semiBold)
                    ],
                  ).hP16)
              .round(19)
              .ripple(() {
            Get.to(() => InviteUsersToClub(
                  clubId: widget.club.id!,
                ));
          }),
      ],
    );
  }

  Widget appBar() {
    return Positioned(
      child: Container(
        height: 150.0,
        width: Get.width,
        decoration: BoxDecoration(
            color: Colors.white,
            gradient: LinearGradient(
                begin: FractionalOffset.topCenter,
                end: FractionalOffset.bottomCenter,
                colors: [
                  Colors.black,
                  Colors.black.withValues(alpha: 0.5),
                  Colors.grey.withValues(alpha: 0.0),
                ],
                stops: const [
                  0.0,
                  0.5,
                  1.0
                ])),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ThemeIconWidget(
              ThemeIcon.backArrow,
              size: 20,
              color: Colors.white,
            ).ripple(() {
              Get.back();
            }),
            widget.club.amIAdmin
                ? Row(
                    children: [
                      Obx(() => _clubDetailController.joinRequests.isEmpty
                          ? Container()
                          : Stack(
                              children: [
                                Container(
                                  color: AppColorConstants.themeColor
                                      .withValues(alpha: 0.2),
                                  child: ThemeIconWidget(
                                    ThemeIcon.request,
                                    size: 20,
                                    color: Colors.white,
                                  ).p8.ripple(() {
                                    Get.to(() => ClubJoinRequests(
                                          club: widget.club,
                                        ));
                                  }),
                                ).circular,
                                Positioned(
                                    right: 0,
                                    child: Container(
                                      height: 10,
                                      width: 10,
                                      color: AppColorConstants.red,
                                    ).circular)
                              ],
                            )),
                      const SizedBox(width: 10),
                      ThemeIconWidget(
                        ThemeIcon.setting,
                        size: 20,
                        color: Colors.white,
                      ).ripple(() {
                        Get.to(() => ClubSettings(
                              club: widget.club,
                              deleteClubCallback: (club) {
                                Get.back();
                                widget.deleteCallback(club);
                              },
                            ));
                      }),
                    ],
                  )
                : const SizedBox(
                    width: 20,
                  )
          ],
        ).hp(DesignConstants.horizontalPadding),
      ),
    );
  }
}
