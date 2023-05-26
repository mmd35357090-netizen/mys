import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/add_on/controller/event/booking_detail_controller.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/event_imports.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class ETicket extends StatefulWidget {
  final EventBookingModel booking;

  const ETicket({Key? key, required this.booking}) : super(key: key);

  @override
  State<ETicket> createState() => _ETicketState();
}

class _ETicketState extends State<ETicket> {
  final EventBookingDetailController _eventBookingDetailController =
      EventBookingDetailController();

  WidgetsToImageController controller = WidgetsToImageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(children: [
          backNavigationBar(
            title: eTicketString.tr,
          ),
          divider().tP8,
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: WidgetsToImage(
                      controller: controller,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Center(
                            child: Container(
                              color: Colors.white,
                              child: QrImage(
                                data: "${widget.booking.id}",
                                version: QrVersions.auto,
                                size: Get.width * 0.7,
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
                      )),
                ),
                Positioned(
                    bottom: 20,
                    left: 16,
                    right: 16,
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
      color: AppColorConstants.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodySmallText(eventString.tr, weight: TextWeight.medium),
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
              BodySmallText(dateAndTimeString.tr, weight: TextWeight.medium),
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
              BodySmallText(eventLocationString.tr, weight: TextWeight.medium),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodySmallText(eventOrganizerString.tr, weight: TextWeight.medium),
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
      ).setPadding(top: 25, bottom: 25, left: 16, right: 16),
    ).round(20).hP16;
  }

  Widget bookingInfoWidget() {
    return Container(
      width: double.infinity,
      color: AppColorConstants.cardColor,
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
                    ? AppColorConstants.red.withOpacity(0.7)
                    : AppColorConstants.themeColor.withOpacity(0.7),
                child: BodySmallText(
                  widget.booking.statusType == BookingStatus.cancelled
                      ? cancelledString.tr
                      : confirmedString.tr,
                ).p4,
              ).round(5)
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
      ).setPadding(top: 25, bottom: 25, left: 16, right: 16),
    ).round(20).hP16;
  }

  saveTicket() {
    EasyLoading.show(status: loadingString.tr);
    controller.capture().then((bytes) {
      _eventBookingDetailController.saveETicket(bytes!, context);
      EasyLoading.dismiss();
    });
  }
}
