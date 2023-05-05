import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';
import '../../apiHandler/api_controller.dart';
import '../../model/support_request_response.dart';

class HelpSupportController extends GetxController {
  RxList<Items> list = <Items>[].obs;

  void getSupportRequests() {
    AppUtil.checkInternet().then((value) {
      ApiController().getSupportMessages().then((response) {
        ApiResponseModel model = response;
        if (model.supportRequestReponse?.supportRequest?.items != null) {
          list.value.clear();
          list.addAll(model.supportRequestReponse!.supportRequest!.items!);
        }
      });
    });
  }

  void submitSupportRequest(
      {String? name, String? email, String? phone, String? message}) {
    AppUtil.checkInternet().then((value) {
      if (name!.isNotEmpty &&
          email!.isNotEmpty &&
          phone!.isNotEmpty &&
          message!.isNotEmpty) {
        ApiController()
            .sendSupportRequest(name, email, phone, message)
            .then((response) {
          AppUtil.showToast(
              message: LocalizationString.supportRequests, isSuccess: true);
        });
      } else {
        AppUtil.showToast(
            message: LocalizationString.fillForm, isSuccess: false);
      }
    });
  }

  void getSupportRequestView(int id) {
    AppUtil.checkInternet().then((value) {
      ApiController().getSupportMessageView(id).then((response) {
        print('getSupportRequestView : $response');
      });
    });
  }
}
