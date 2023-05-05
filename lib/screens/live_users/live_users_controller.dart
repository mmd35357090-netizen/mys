import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';

import '../../apiHandler/api_controller.dart';

class LiveUserController extends GetxController {
  RxList<UserLiveCallDetail> liveStreamUser = <UserLiveCallDetail>[].obs;
  RxInt totalLiveUsers = 0.obs;

  // fetch live users
  void getLiveUsers() async {
    AppUtil.checkInternet().then((value) {
      if (value) {
        EasyLoading.show(status: LocalizationString.loading);
        ApiController().getLiveUser().then((response) {
          liveStreamUser.clear();
          totalLiveUsers.value = response.totalLiveUsers!;
          liveStreamUser.addAll(response.liveStreamingUser);
          EasyLoading.dismiss();
        });
      }
    });
  }
}
