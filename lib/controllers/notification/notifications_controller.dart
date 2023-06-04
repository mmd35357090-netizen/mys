import 'package:foap/apiHandler/apis/misc_api.dart';
import 'package:foap/model/notification_modal.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  getNotifications() {
    MiscApi.getNotifications(resultCallback: (result, metadata) {
      notifications.value = result;
      update();
    });
  }
}
