import 'package:foap/helper/common_import.dart';
import 'package:get/get.dart';

class LiveUserController extends GetxController {
  RxList<UserLiveCallDetail> liveStreamUser = <UserLiveCallDetail>[].obs;

  // fetch live users
  void getLiveUsers() async {
    AppUtil.checkInternet().then((value) {
      if (value) {
        EasyLoading.show(status: LocalizationString.loading);
        ApiController().getLiveUser().then((response) {
          print('getLiveUsers : ${response.toString()}');
          liveStreamUser.addAll(response.liveStreamUser);
          EasyLoading.dismiss();
        });
      }
    });
  }
}
