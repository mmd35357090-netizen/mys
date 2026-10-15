import 'dart:io';
import 'package:foap/api_handler/apis/events_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/event_imports.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../api_handler/apis/misc_api.dart';

enum ProcessingBookingStatus { inProcess, gifted, cancelled, failed }

class EventBookingDetailController extends GetxController {
  Rx<EventBookingModel?> eventBooking = Rx<EventBookingModel?>(null);
  RxList<EventCoupon> coupons = <EventCoupon>[].obs;
  double? minTicketPrice;
  double? maxTicketPrice;

  Rx<ProcessingBookingStatus?> processingBooking =
      Rx<ProcessingBookingStatus?>(null);

  setEventBooking(EventBookingModel eventBooking) {
    this.eventBooking.value = eventBooking;
    this.eventBooking.refresh();
    update();
  }

  saveETicket(File file) async {
    Share.shareXFiles([XFile(file.path)]).then((result) {
      if (result.status == ShareResultStatus.success) {
        AppUtil.showToast(message: ticketSavedString.tr, isSuccess: true);
      } else {
        AppUtil.showToast(message: errorMessageString.tr, isSuccess: false);
      }
    });
  }

  giftToUser(UserModel user) {
    processingBooking.value = ProcessingBookingStatus.inProcess;
    update();
    EventApi.giftEventTicket(
        ticketId: eventBooking.value!.id,
        toUserId: user.id,
        resultCallback: (status) {
          if (status) {
            processingBooking.value = ProcessingBookingStatus.gifted;
          } else {
            processingBooking.value = ProcessingBookingStatus.failed;
          }
          update();
        });
  }

  cancelBooking(BuildContext context) {
    processingBooking.value = ProcessingBookingStatus.inProcess;
    update();

    EventApi.cancelEventBooking(
        bookingId: eventBooking.value!.id,
        resultCallback: (status) {
          Loader.dismiss();
          if (status) {
            processingBooking.value = ProcessingBookingStatus.cancelled;
          } else {
            processingBooking.value = ProcessingBookingStatus.failed;
          }
          update();
        });
  }

  linkTicketToBooking({required int bookingId, required File file}) {
    MiscApi.uploadFile(file.path,
        type: UploadMediaType.event, mediaType: GalleryMediaType.photo,
        resultCallback: (filename, filepath) {
          EventApi.linkTicketToEventBooking(
              bookingId: bookingId, ticketName: filename);
        });
  }
}
