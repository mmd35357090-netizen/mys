import 'dart:math';
import 'package:foap/components/post_card/post_card.dart';
import 'package:foap/components/sm_tab_bar.dart';
import 'package:foap/helper/imports/event_imports.dart';
import 'package:foap/helper/imports/profile_imports.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share_plus/share_plus.dart';
import '../../../post/add_post_screen.dart';

class EventDetail extends StatefulWidget {
  final EventModel event;
  final VoidCallback needRefreshCallback;

  const EventDetail({
    super.key,
    required this.event,
    required this.needRefreshCallback,
  });

  @override
  EventDetailState createState() => EventDetailState();
}

class EventDetailState extends State<EventDetail> {
  final EventDetailController _eventDetailController =
      EventDetailController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<String> tabs = [aboutString.tr, postsString.tr];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _eventDetailController.setEvent(widget.event);
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: DefaultTabController(
          length: tabs.length,
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                      height: 280,
                      width: Get.width,
                      child: CachedNetworkImage(
                        imageUrl: widget.event.image,
                        fit: BoxFit.cover,
                      )),
                  appBar(),
                  actionButtons()
                ],
              ),
              SMTabBar(tabs: tabs, canScroll: false),
              Expanded(
                child: TabBarView(children: [about(), postsView()]),
              )
            ],
          )),
    );
  }

  Widget about() {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              Heading4Text(
                widget.event.name,
                weight: TextWeight.semiBold,
              ),
              const SizedBox(
                height: 10,
              ),
              attendingUsersList(),
              const SizedBox(
                height: 10,
              ),
              if (widget.event.shareLink != null)
                IntrinsicHeight(
                  child: IntrinsicWidth(
                    child: Container(
                      color: AppColorConstants.themeColor,
                      child: Row(
                        children: [
                          ThemeIconWidget(
                            ThemeIcon.share,
                            color: Colors.white,
                            size: 15,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          BodySmallText(
                            shareEventString.tr,
                            color: Colors.white,
                          )
                        ],
                      ).p8,
                    ).circular,
                  ),
                ).ripple(() {
                  Share.share(widget.event.shareLink!);
                }),
              divider().vp(20),
              eventInfo(),
              divider().vp(20),
              eventOrganiserWidget(),
              divider().vp(20),
              eventGallery(),
              const SizedBox(
                height: 24,
              ),
              if (widget.event.latitude.isNotEmpty &&
                  widget.event.longitude.isNotEmpty)
                eventLocation(),
              const SizedBox(
                height: 150,
              ),
            ],
          ).hp(DesignConstants.horizontalPadding),
        ),
        if (!widget.event.isFree)
          Obx(() => _eventDetailController.isLoading.value == true
              ? Container()
              : _eventDetailController.event.value?.isCompleted == true
                  ? eventClosedWidget()
                  : _eventDetailController.event.value?.ticketsAdded ==
                          true
                      ? _eventDetailController.event.value?.isSoldOut ==
                              true
                          ? soldOutWidget()
                          : buyTicketWidget()
                      : ticketNotAddedWidget())
      ],
    );
  }

  Widget eventInfo() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                    color: AppColorConstants.themeColor
                        .withValues(alpha: 0.2),
                    child: ThemeIconWidget(ThemeIcon.calendar,
                            color: AppColorConstants.themeColor)
                        .p8)
                .circular,
            const SizedBox(
              width: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyLargeText(widget.event.startAtFullDate,
                    weight: TextWeight.medium),
                const SizedBox(
                  height: 5,
                ),
                BodySmallText(widget.event.startAtTime,
                    weight: TextWeight.regular)
              ],
            )
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                    color: AppColorConstants.themeColor
                        .withValues(alpha: 0.2),
                    child: ThemeIconWidget(ThemeIcon.location,
                            color: AppColorConstants.themeColor)
                        .p8)
                .circular,
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BodyLargeText(locationString.tr,
                      weight: TextWeight.medium),
                  const SizedBox(
                    height: 5,
                  ),
                  BodySmallText(
                      '${widget.event.placeName} ${widget.event.completeAddress}',
                      weight: TextWeight.regular)
                ],
              ),
            )
          ],
        ),
        if (!widget.event.isFree && widget.event.minTicketPrice != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                      color: AppColorConstants.themeColor
                          .withValues(alpha: 0.2),
                      child: ThemeIconWidget(ThemeIcon.calendar,
                              color: AppColorConstants.themeColor)
                          .p8)
                  .circular,
              const SizedBox(
                width: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BodyLargeText(priceString.tr, weight: TextWeight.medium),
                  const SizedBox(
                    height: 5,
                  ),
                  BodySmallText(
                      '\$${widget.event.minTicketPrice} - \$${widget.event.maxTicketPrice} ',
                      weight: TextWeight.regular)
                ],
              )
            ],
          ).tp(20),
      ],
    );
  }

  Widget postsView() {
    return Obx(() => ListView.separated(
            padding: const EdgeInsets.only(top: 25, bottom: 100),
            itemBuilder: (BuildContext context, index) {
              return PostCard(
                model: _eventDetailController.posts[index],
                removePostHandler: () {},
                blockUserHandler: () {},
              );
            },
            separatorBuilder: (BuildContext context, index) {
              return const SizedBox(
                height: 40,
              );
            },
            itemCount: _eventDetailController.posts.length)
        .addPullToRefresh(
            refreshController: _refreshController,
            onRefresh: () {
              _eventDetailController.refreshPosts(
                  id: widget.event.id,
                  callback: () {
                    _refreshController.refreshCompleted();
                  });
            },
            onLoading: () {
              _eventDetailController.loadMorePosts(
                  id: widget.event.id,
                  callback: () {
                    _refreshController.loadComplete();
                  });
            },
            enablePullUp: true,
            enablePullDown: true));
  }

  Widget eventOrganiserWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          return _eventDetailController
                      .event.value?.organizers.isNotEmpty ==
                  true
              ? Container(
                  color: AppColorConstants.cardColor,
                  child: Column(
                    children: [
                      for (EventOrganizer sponsor in _eventDetailController
                              .event.value?.organizers ??
                          [])
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AvatarView(
                              name: sponsor.name,
                              size: 30,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BodyLargeText(sponsor.name,
                                    weight: TextWeight.regular),
                                BodySmallText(organizerString.tr,
                                    weight: TextWeight.regular),
                              ],
                            )
                          ],
                        ).bP16,
                    ],
                  ).p16,
                ).round(20)
              : _eventDetailController.event.value?.createdByUser != null
                  ? Container(
                      color: AppColorConstants.cardColor,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          UserAvatarView(
                            user: _eventDetailController
                                .event.value!.createdByUser,
                            size: 30,
                            hideLiveIndicator: true,
                            hideOnlineIndicator: true,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BodyLargeText(
                                  _eventDetailController
                                      .event.value!.createdByUser.userName,
                                  weight: TextWeight.regular),
                              BodySmallText(organizerString.tr,
                                  weight: TextWeight.regular),
                            ],
                          )
                        ],
                      ).p16,
                    ).round(20).ripple(() {
                      Get.to(() => OtherUserProfile(
                          userId: _eventDetailController
                              .event.value!.createdByUser.id));
                    })
                  : Container();
        }),
        const SizedBox(
          height: 25,
        ),
        Heading6Text(aboutString.tr, weight: TextWeight.medium),
        const SizedBox(
          height: 10,
        ),
        BodyLargeText(widget.event.description,
            weight: TextWeight.regular),
        const SizedBox(
          height: 40,
        ),
      ],
    );
  }

  Widget eventLocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Heading6Text(locationString.tr, weight: TextWeight.medium),
        const SizedBox(
          height: 10,
        ),
        StaticMapWidget(
          latitude: double.parse(widget.event.latitude),
          longitude: double.parse(widget.event.longitude),
          height: 250,
          width: Get.width.toInt(),
          apiKey: AppConfigConstants.googleMapApiKey,
        ).ripple(() {
          openDirections();
        }),
        const SizedBox(
          height: 40,
        ),
      ],
    );
  }

  Widget soldOutWidget() {
    return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          color: AppColorConstants.cardColor,
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/out_of_stock.png',
                height: 20,
                width: 20,
                color: AppColorConstants.themeColor,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  child: BodyLargeText(
                eventIsSoldOutString.tr,
              )),
            ],
          ).hp(DesignConstants.horizontalPadding),
        ));
  }

  Widget eventClosedWidget() {
    return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          color: AppColorConstants.cardColor,
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/out_of_stock.png',
                height: 20,
                width: 20,
                color: AppColorConstants.themeColor,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  child: BodyLargeText(
                eventClosedString.tr,
              )),
            ],
          ).hp(DesignConstants.horizontalPadding),
        ));
  }

  Widget attendingUsersList() {
    return BodyLargeText(
        '${widget.event.totalMembers} ${goingString.tr.toLowerCase()}',
        weight: TextWeight.regular);
  }

  Widget ticketNotAddedWidget() {
    return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          color: AppColorConstants.cardColor,
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/tickets.png',
                height: 20,
                width: 20,
                color: AppColorConstants.themeColor,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  ticketWillBeAvailableSoonString.tr,
                  style: TextStyle(fontSize: FontSizes.b2),
                ),
              ),
            ],
          ).hp(DesignConstants.horizontalPadding),
        ));
  }

  Widget buyTicketWidget() {
    return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          color: AppColorConstants.cardColor,
          height: 90,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                  height: 40,
                  width: Get.width * 0.4,
                  // color: ColorConstants.themeColor,
                  child: Row(
                    children: [
                      ThemeIconWidget(
                        ThemeIcon.gift,
                        color: AppColorConstants.themeColor,
                        size: 28,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Heading6Text(
                        giftTicketString.tr,
                        color: AppColorConstants.themeColor,
                      )
                    ],
                  ).hP8.ripple(() {
                    Get.bottomSheet(SelectUserToGiftEventTicket(
                      event: _eventDetailController.event.value!,
                      isAlreadyBooked: false,
                    ).topRounded(40));
                  })).round(5),
              BodyLargeText(
                orString.tr,
                // style: TextStyle(fontSize: FontSizes.b2),
              ).hp(DesignConstants.horizontalPadding),
              SizedBox(
                height: 40,
                child: AppThemeButton(
                  text: _eventDetailController.event.value!.isTicketBooked
                      ? buyMoreTicketString.tr
                      : buyTicketString.tr,
                  onPress: () {
                    Get.to(() => BuyTicket(
                          event: _eventDetailController.event.value!,
                        ));
                  },
                ),
              )
            ],
          ).p16,
        ));
  }

  Widget eventGallery() {
    return widget.event.gallery.isNotEmpty
        ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Heading6Text(eventGalleryString.tr,
                    weight: TextWeight.medium),
                BodyLargeText(
                  seeAllString.tr,
                  color: AppColorConstants.themeColor,
                ).ripple(() {
                  Get.to(() =>
                      EventGallery(eventGallery: widget.event.gallery));
                }),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (ctx, index) {
                  return CachedNetworkImage(
                    imageUrl: widget.event.gallery[index],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ).round(10);
                },
                separatorBuilder: (ctx, index) {
                  return const SizedBox(
                    width: 10,
                  );
                },
                itemCount: min(widget.event.gallery.length, 4),
              ),
            )
          ])
        : Container();
  }

  openDirections() async {
    final availableMaps = await MapLauncher.installedMaps;

    showModalBottomSheet(
      context: Get.context!,
      builder: (BuildContext context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Wrap(
              children: <Widget>[
                for (var map in availableMaps)
                  ListTile(
                    onTap: () {
                      map.showMarker(
                        coords: Coords(double.parse(widget.event.latitude),
                            double.parse(widget.event.longitude)),
                        title: widget.event.completeAddress,
                      );
                    },
                    title: Heading5Text(
                      '${openInString.tr} ${map.mapName}',
                    ),
                  ),
              ],
            ),
          ),
        );
      },
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
            if (widget.event.isTicketBooked || widget.event.isFree)
              ThemeIconWidget(
                ThemeIcon.plus,
                size: 25,
                color: Colors.white,
              ).ripple(() {
                Future.delayed(
                  Duration.zero,
                  () => showGeneralDialog(
                      context: Get.context!,
                      pageBuilder:
                          (context, animation, secondaryAnimation) =>
                              AddPostScreen(
                                postType: PostCategory.event,
                                event: widget.event,
                                postCompletionHandler: () {
                                  _eventDetailController.refreshPosts(
                                      id: widget.event.id,
                                      callback: () {});
                                },
                              )),
                );
              }),
          ],
        ).hp(DesignConstants.horizontalPadding),
      ),
    );
  }

  Widget actionButtons() {
    return Positioned(
      bottom: 10,
      left: DesignConstants.horizontalPadding,
      right: DesignConstants.horizontalPadding,
      child: Obx(() => Row(
            children: [
              Container(
                color: AppColorConstants.green,
                child: Row(
                  children: [
                    ThemeIconWidget(ThemeIcon.thumbsUp,
                        color: Colors.white),
                    const SizedBox(
                      width: 5,
                    ),
                    BodyMediumText(goingString.tr, color: Colors.white),
                    const SizedBox(
                      width: 5,
                    ),
                    _eventDetailController.event.value?.reaction ==
                            ReactionOnEvent.interested
                        ? ThemeIconWidget(ThemeIcon.checkMark,
                            color: Colors.white)
                        : Container(),
                  ],
                ).p8,
              ).round(10).ripple(() {
                _eventDetailController.joinEvent();
              }),
              const SizedBox(
                width: 10,
              ),
              _eventDetailController.event.value?.isTicketBooked == false
                  ? Container(
                      color: AppColorConstants.red,
                      child: Row(
                        children: [
                          ThemeIconWidget(ThemeIcon.thumbsDown,
                              color: Colors.white),
                          const SizedBox(
                            width: 5,
                          ),
                          BodyMediumText(
                            notInterestedString.tr,
                            color: Colors.white,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          _eventDetailController.event.value?.reaction ==
                                  ReactionOnEvent.notInterested
                              ? ThemeIconWidget(ThemeIcon.checkMark,
                                  color: Colors.white)
                              : Container(),
                        ],
                      ).p8,
                    ).round(10).ripple(() {
                      _eventDetailController.leaveEvent();
                    })
                  : Container()
            ],
          )),
    );
  }
}
