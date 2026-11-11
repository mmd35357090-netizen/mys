import 'dart:io';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/event_imports.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import 'package:path_provider/path_provider.dart';

class ETicket extends StatefulWidget {
  final EventBookingModel booking;
  final bool autoSendTicket;

  const ETicket({super.key, required this.booking, required this.autoSendTicket})
      ;

  @override
  State<ETicket> createState() => _ETicketState();
}

class _ETicketState extends State<ETicket> {
  final EventBookingDetailController _eventBookingDetailController =
  EventBookingDetailController();

  WidgetsToImageController controller = WidgetsToImageController();

  @override
  void initState() {
    if (widget.autoSendTicket) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          sendingTicket();
        });
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(children: [
          backNavigationBar(
            title: eTicketString.tr,
          ),
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: WidgetsToImage(
                      controller: controller,
                      child: Container(
                        color: AppColorConstants.backgroundColor,
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                    color: AppColorConstants.themeColor
                                        .withValues(alpha: 0.35),
                                    width: 1.4),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: 0.08),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6))
                                ],
                              ),
                              child: QrImageView(
                                data: "${widget.booking.id}",
                                version: QrVersions.auto,
                                size: Get.width * 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          eventInfoWidget(),
                          const SizedBox(
                            height: 20,
                          ),
                          bookingInfoWidget(),
                          const SizedBox(
                            height: 100,
                          ),
                        ],
                      ))),
                ),
                Positioned(
                    bottom: 20,
                    left: DesignConstants.horizontalPadding,
                    right: DesignConstants.horizontalPadding,
                    child: AppThemeButton(
                      text: saveETicketString.tr,
                      onPress: () {
                        saveTicket();
                      },
                    ))
              ],
            ),
          )
        ]));
  }

  Widget eventInfoWidget() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColorConstants.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: AppColorConstants.dividerColor.withValues(alpha: 0.5),
            width: 0.6),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodySmallText(eventString.tr, color: AppColorConstants.subHeadingTextColor, weight: TextWeight.medium),
              const SizedBox(
                height: 10,
              ),
              Text(
                widget.booking.event.name,
                style: TextStyle(
                  fontSize: FontSizes.b2,
                  fontWeight: TextWeight.bold,
                ),
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodySmallText(dateAndTimeString.tr, color: AppColorConstants.subHeadingTextColor, weight: TextWeight.medium),
              const SizedBox(
                height: 10,
              ),
              BodyLargeText(widget.booking.event.startAtDateTime,
                  weight: TextWeight.bold)
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodySmallText(eventLocationString.tr, color: AppColorConstants.subHeadingTextColor, weight: TextWeight.medium),
              const SizedBox(
                height: 10,
              ),
              BodyLargeText(
                  '${widget.booking.event.completeAddress}, ${widget.booking.event.placeName}',
                  weight: TextWeight.bold)
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          if (widget.booking.event.organizers.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodySmallText(eventOrganizerString.tr,
                    color: AppColorConstants.subHeadingTextColor,
                    weight: TextWeight.medium),
                const SizedBox(
                  height: 10,
                ),
                for (EventOrganizer sponsor in widget.booking.event.organizers)
                  Wrap(
                    children: [
                      BodyLargeText(sponsor.name, weight: TextWeight.bold)
                    ],
                  ),
              ],
            )
        ],
      ).setPadding(
          top: 25,
          bottom: 25,
          left: DesignConstants.horizontalPadding,
          right: DesignConstants.horizontalPadding),
    ).hp(DesignConstants.horizontalPadding);
  }

  Widget bookingInfoWidget() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColorConstants.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: AppColorConstants.dividerColor.withValues(alpha: 0.5),
            width: 0.6),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                  width: 120,
                  child: BodyMediumText(bookingIdString.tr,
                      weight: TextWeight.medium)),
              Container(
                height: 5,
                width: 5,
                color: AppColorConstants.themeColor,
              ).circular.rP16,
              BodySmallText(
                widget.booking.id.toString(),
              )
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                  width: 120,
                  child: BodyMediumText(bookingStatusString.tr,
                      weight: TextWeight.medium)),
              Container(
                height: 5,
                width: 5,
                color: AppColorConstants.themeColor,
              ).circular.rP16,
              Container(
                color: widget.booking.statusType == BookingStatus.cancelled
                    ? AppColorConstants.red
                    : AppColorConstants.green,
                child: BodySmallText(
                  widget.booking.statusType == BookingStatus.cancelled
                      ? cancelledString.tr
                      : confirmedString.tr,
                  color: Colors.white,
                  weight: TextWeight.semiBold,
                ).setPadding(left: 12, right: 12, top: 4, bottom: 4),
              ).round(12)
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                  width: 120,
                  child: BodyMediumText(bookingDateString.tr,
                      weight: TextWeight.medium)),
              Container(
                height: 5,
                width: 5,
                color: AppColorConstants.themeColor,
              ).circular.rP16,
              BodySmallText(
                widget.booking.bookingDatetime,
              )
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 120,
                child: BodyMediumText(ticketTypeString.tr,
                    weight: TextWeight.medium),
              ),
              Container(
                height: 5,
                width: 5,
                color: AppColorConstants.themeColor,
              ).circular.rP16,
              BodySmallText(widget.booking.ticketType.name,
                  weight: TextWeight.medium)
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                  width: 120,
                  child: BodyMediumText(priceString.tr,
                      weight: TextWeight.medium)),
              Container(
                height: 5,
                width: 5,
                color: AppColorConstants.themeColor,
              ).circular.rP16,
              BodySmallText(
                '\$${widget.booking.paidAmount}',
              )
            ],
          ),
        ],
      ).setPadding(
          top: 25,
          bottom: 25,
          left: DesignConstants.horizontalPadding,
          right: DesignConstants.horizontalPadding),
    ).hp(DesignConstants.horizontalPadding);
  }

  saveTicket() {
    Loader.show(status: loadingString.tr);
    controller.capture().then((bytes) async {
      final directory = await getApplicationDocumentsDirectory();
      final pathOfImage = await File('${directory.path}/ticket.png').create();
      await pathOfImage.writeAsBytes(bytes!);

      _eventBookingDetailController.saveETicket(pathOfImage);
      Loader.dismiss();
    });
  }

  sendingTicket() {
    // Loader.show(status: loadingString.tr);
    controller.capture().then((bytes) async {
      final directory = await getApplicationDocumentsDirectory();
      final pathOfImage = await File('${directory.path}/ticket.png').create();
      await pathOfImage.writeAsBytes(bytes!);

      _eventBookingDetailController.linkTicketToBooking(
          bookingId: widget.booking.id, file: pathOfImage);
    });
  }
}
