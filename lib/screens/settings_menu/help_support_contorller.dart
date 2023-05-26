import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';
import '../../apiHandler/api_controller.dart';
import '../../apiHandler/apis/misc_api.dart';
import '../../model/support_request_response.dart';

class HelpSupportController extends GetxController {
  RxList<SupportRequest> list = <SupportRequest>[].obs;

  void getSupportRequests() {
    AppUtil.checkInternet().then((value) {
      MiscApi.getSupportMessages(resultCallback: (result, metadata) {
        list.clear();
        list.addAll(result);
      });
    });
  }

  void submitSupportRequest(
      {required String? name,
      required String? email,
      required String? phone,
      required String? message}) {
    if (name!.isNotEmpty &&
        email!.isNotEmpty &&
        phone!.isNotEmpty &&
        message!.isNotEmpty) {
      MiscApi.sendSupportRequest(
          name: name, email: email, phone: phone, message: message);
    }
  }

  void getSupportRequestView(int id) {
    MiscApi.getSupportMessageView(id);
  }
}
