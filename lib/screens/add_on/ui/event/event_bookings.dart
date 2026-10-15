import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/segmentAndMenu/horizontal_menu.dart';
import 'package:foap/helper/imports/event_imports.dart';

class EventBookingScreen extends StatefulWidget {
  const EventBookingScreen({super.key});

  @override
  State<EventBookingScreen> createState() => _EventBookingScreenState();
}

class _EventBookingScreenState extends State<EventBookingScreen> {
  final EventBookingsController _eventBookingsController =
      EventBookingsController();

  @override
  void initState() {
    _eventBookingsController.changeSegment(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(children: [
          backNavigationBar(
            title: bookingsString.tr,
          ),
          const SizedBox(height: 10),
          segmentView(),
          Expanded(
              child: GetBuilder<EventBookingsController>(
                  init: _eventBookingsController,
                  builder: (ctx) {
                    List<EventBookingModel> bookings = [];

                    switch (_eventBookingsController.selectedSegment.value) {
                      case 0:
                        bookings = _eventBookingsController.upcomingBookings;
                        break;
                      case 1:
                        bookings = _eventBookingsController.completedBookings;
                        break;
                      case 2:
                        bookings = _eventBookingsController.cancelledBookings;
                        break;
                    }

                    return _eventBookingsController.isLoading.value
                        ? const EventBookingShimmerWidget()
                        : bookings.isEmpty
                            ? emptyData(
                                title: noBookingFoundString.tr,
                                subTitle: goToEventAndBookString.tr,
                              )
                            : ListView.separated(
                                padding:  EdgeInsets.only(
                                    top: 16, left: DesignConstants.horizontalPadding, right: DesignConstants.horizontalPadding, bottom: 16),
                                itemCount: bookings.length,
                                itemBuilder: (BuildContext ctx, int index) {
                                  return EventBookingCard(
                                          bookingModel: bookings[index])
                                      .ripple(() {
                                    Get.to(() => EventBookingDetail(
                                            booking: bookings[index]))!
                                        .then((value) {
                                      _eventBookingsController.reload();
                                    });
                                  });
                                },
                                separatorBuilder:
                                    (BuildContext ctx, int index) {
                                  return const SizedBox(
                                    height: 20,
                                  );
                                });
                  }))
        ]));
  }

  Widget segmentView() {
    return HorizontalSegmentBar(
        width: Get.width,
        hideHighlightIndicator: false,
        onSegmentChange: (segment) {
          _eventBookingsController.changeSegment(segment);
        },
        segments: [
          upcomingString.tr,
          completedString.tr,
          cancelledString.tr,
          // locations,
        ]);
  }
}
