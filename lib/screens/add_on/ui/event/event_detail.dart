import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foap/components/avatar_view.dart';
import 'package:foap/components/custom_texts.dart';
import 'package:foap/components/static_map_widget.dart';
import 'package:foap/helper/common_components.dart';
import 'package:foap/helper/extension.dart';
import 'package:foap/helper/localization_strings.dart';
import 'package:foap/helper/user_profile_manager.dart';
import 'package:foap/theme/theme_icon.dart';
import 'package:foap/universal_components/app_buttons.dart';
import 'package:foap/util/app_config_constants.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/event_imports.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:flutter/material.dart';

import 'buy_ticket.dart';
import 'event_gallery.dart';

class EventDetail extends StatefulWidget {
  final EventModel event;
  final VoidCallback needRefreshCallback;

  const EventDetail({
    Key? key,
    required this.event,
    required this.needRefreshCallback,
  }) : super(key: key);

  @override
  EventDetailState createState() => EventDetailState();
}

class EventDetailState extends State<EventDetail> {
  final EventDetailController _eventDetailController = EventDetailController();
  final UserProfileManager _userProfileManager = Get.find();

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
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: GetBuilder<EventDetailController>(
          init: _eventDetailController,
          builder: (ctx) {
            return Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverList(
                        delegate: SliverChildListDelegate([
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                              height: 280,
                              child: CachedNetworkImage(
                                imageUrl: widget.event.image,
                                fit: BoxFit.cover,
                              )),
                          const SizedBox(
                            height: 24,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Heading3Text(
                                widget.event.name,
                                weight: TextWeight.medium,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              attendingUsersList(),
                              divider().vp(20),
                              eventInfo(),
                              divider().vp(20),
                              eventOrganiserWidget(),
                              divider().vp(20),
                              eventGallery(),
                              const SizedBox(
                                height: 24,
                              ),
                              eventLocation(),
                              const SizedBox(
                                height: 150,
                              ),
                            ],
                          ).hP16,
                        ],
                      ),
                    ]))
                  ],
                ),
                appBar(),
                if (!widget.event.isFree)
                  Obx(() => _eventDetailController.isLoading.value == true
                      ? Container()
                      : _eventDetailController.event.value?.ticketsAdded == true
                          ? _eventDetailController.event.value?.isSoldOut ==
                                  true
                              ? soldOutWidget()
                              : buyTicketWidget()
                          : ticketNotAddedWidget())
              ],
            );
          }),
    );
  }

  Widget eventInfo() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                    color: AppColorConstants.themeColor.withOpacity(0.2),
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
                    color: AppColorConstants.themeColor.withOpacity(0.2),
                    child: ThemeIconWidget(ThemeIcon.location,
                            color: AppColorConstants.themeColor)
                        .p8)
                .circular,
            const SizedBox(
              width: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyLargeText(locationString.tr, weight: TextWeight.medium),
                const SizedBox(
                  height: 5,
                ),
                BodySmallText(
                    '${widget.event.placeName} ${widget.event.completeAddress}',
                    weight: TextWeight.regular)
              ],
            )
          ],
        ),
        if (!widget.event.isFree)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                      color: AppColorConstants.themeColor.withOpacity(0.2),
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
                      '\$${_eventDetailController.minTicketPrice} - \$${_eventDetailController.maxTicketPrice} ',
                      weight: TextWeight.regular)
                ],
              )
            ],
          ).tp(20),
      ],
    );
  }

  Widget eventOrganiserWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          return _eventDetailController.event.value?.organizers.isNotEmpty ==
                  true
              ? Column(
                  children: [
                    for (EventOrganizer sponsor
                        in _eventDetailController.event.value?.organizers ?? [])
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          UserAvatarView(
                            user: _userProfileManager.user.value!,
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
                )
              : Container();
        }),
        const SizedBox(
          height: 25,
        ),
        Heading6Text(aboutString.tr, weight: TextWeight.medium),
        const SizedBox(
          height: 10,
        ),
        BodyLargeText(widget.event.description, weight: TextWeight.regular),
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
                  child: Text(
                eventIsSoldOutString.tr,
                style: TextStyle(fontSize: FontSizes.b2),
              )),
            ],
          ).hP16,
        ));
  }

  Widget attendingUsersList() {
    return Row(
      children: [
        // SizedBox(
        //   height: 20,
        //   width: min(widget.event.gallery.length, 5) * 17,
        //   child: ListView.builder(
        //     scrollDirection: Axis.horizontal,
        //     itemBuilder: (ctx, index) {
        //       return Align(
        //         widthFactor: 0.6,
        //         child: CachedNetworkImage(
        //           imageUrl: widget.event.gallery[index],
        //           width: 20,
        //           height: 20,
        //           fit: BoxFit.cover,
        //         ).borderWithRadius( value: 1, radius: 10),
        //       );
        //     },
        //     itemCount: min(widget.event.gallery.length, 5),
        //   ),
        // ),
        BodySmallText(
            '${widget.event.totalMembers} ${goingString.tr.toLowerCase()}',
            weight: TextWeight.regular),
        const Spacer()
      ],
    );
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
          ).hP16,
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
                    ));
                  })).round(5),
              Text(
                orString.tr,
                style: TextStyle(fontSize: FontSizes.b2),
              ).hP16,
              SizedBox(
                height: 40,
                width: Get.width * 0.3,
                child: AppThemeButton(
                  text: buyTicketString.tr,
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
                Heading6Text(eventGalleryString.tr, weight: TextWeight.medium),
                BodyLargeText(
                  seeAllString.tr,
                  color: AppColorConstants.themeColor,
                ).ripple(() {
                  Get.to(() => EventGallery(event: widget.event));
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
                    leading: SvgPicture.asset(
                      map.icon,
                      height: 30.0,
                      width: 30.0,
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
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: Colors.white,
            gradient: LinearGradient(
                begin: FractionalOffset.topCenter,
                end: FractionalOffset.bottomCenter,
                colors: [
                  Colors.black,
                  Colors.black.withOpacity(0.5),
                  Colors.grey.withOpacity(0.0),
                ],
                stops: const [
                  0.0,
                  0.5,
                  1.0
                ])),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const ThemeIconWidget(
              ThemeIcon.backArrow,
              size: 20,
              color: Colors.white,
            ).ripple(() {
              Get.back();
            }),
          ],
        ).hP16,
      ),
    );
  }
}
