import 'dart:math';
import 'package:foap/screens/add_on/controller/event/create_event/my_event_detail_controller.dart';
import 'package:foap/screens/add_on/ui/event/create_event/attending_users_list.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../../controller/event/create_event/my_events_controller.dart';
import '../../../model/create_event_model.dart';
import '../event_gallery.dart';

class ProviderEventDetail extends StatefulWidget {
  final CreateEventModel event;
  final VoidCallback needRefreshCallback;

  const ProviderEventDetail({
    super.key,
    required this.event,
    required this.needRefreshCallback,
  });

  @override
  ProviderEventDetailState createState() => ProviderEventDetailState();
}

class ProviderEventDetailState extends State<ProviderEventDetail> {
  final MyEventsController _eventsController = Get.find();

  @override
  void initState() {
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
      body: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                  height: 280,
                  width: Get.width,
                  child: CachedNetworkImage(
                    imageUrl: widget.event.image!,
                    fit: BoxFit.cover,
                  )),
              appBar(),
            ],
          ),
          Expanded(child: about())
        ],
      ),
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
                widget.event.name!,
                weight: TextWeight.semiBold,
              ),
              const SizedBox(
                height: 20,
              ),
              attendingUsersList(),
              divider().vp(20),
              eventInfo(),
              divider().vp(20),
              eventGallery(),
              const SizedBox(
                height: 24,
              ),
              if ((widget.event.latitude ?? '').isNotEmpty &&
                  (widget.event.longitude ?? '').isNotEmpty)
                eventLocation(),
              const SizedBox(
                height: 150,
              ),
            ],
          ).hp(DesignConstants.horizontalPadding),
        ),
        if (!(widget.event.isFree ?? false))
          widget.event.isCompleted == true
              ? eventClosedWidget()
              : Container(),
        if (widget.event.isCompleted != true) cancelEvent()
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
                BodyLargeText(widget.event.startAtFullDateSting!,
                    weight: TextWeight.medium),
                const SizedBox(
                  height: 5,
                ),
                BodySmallText(widget.event.startAtTimeString!,
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
        if (!(widget.event.isFree ?? false))
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
            ],
          ).tp(20),
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
          apiKey: AppConfigConstants.googleMapApiKey,
          latitude: double.parse(widget.event.latitude!),
          longitude: double.parse(widget.event.longitude!),
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
                weight: TextWeight.regular)
            .ripple(() {
          MyEventDetailController controller = Get.find();
          controller.loadUsers(eventId: widget.event.id!, callback: () {});
          Get.to(() => EventAttendingUsersList(
                eventId: widget.event.id!,
              ));
        }),
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
          ).hp(DesignConstants.horizontalPadding),
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
                        coords: Coords(
                            double.parse(widget.event.latitude!),
                            double.parse(widget.event.longitude!)),
                        title: widget.event.completeAddress!,
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
          ],
        ).hp(DesignConstants.horizontalPadding),
      ),
    );
  }

  Widget cancelEvent() {
    return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
            color: AppColorConstants.cardColor,
            height: 100,
            child: Center(
              child: AppThemeButton(
                  text: cancelEventString.tr,
                  onPress: () {
                    AppUtil.showNewConfirmationAlert(
                        title: cancelEventString.tr,
                        subTitle: areYouSureToCancelEventString.tr,
                        okHandler: () {
                          _eventsController.cancelEvent(
                              eventId: widget.event.id!,
                              successHandler: () {
                                Get.back(result: true);
                              });
                        },
                        cancelHandler: () {});
                  }).hp(DesignConstants.horizontalPadding),
            )));
  }
}
