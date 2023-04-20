import 'package:foap/apiHandler/api_controller.dart';
import 'package:foap/model/notification_modal.dart';
import 'package:get/get.dart';
class NotificationController extends GetxController {
  RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  getNotifications() {
    ApiController().getNotifications().then((response) {
      if (response.success == true) {
        notifications.value = response.notifications;
        update();
      }
    });
  }
}
