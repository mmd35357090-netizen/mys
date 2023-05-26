import 'package:foap/apiHandler/apis/live_streaming_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';

import '../../apiHandler/api_controller.dart';

class LiveUserController extends GetxController {
  RxList<UserLiveCallDetail> liveStreamUser = <UserLiveCallDetail>[].obs;
  RxInt totalLiveUsers = 0.obs;

  // fetch live users
  void getLiveUsers() async {
    LiveStreamingApi.getAllLiveUsers(resultCallback: (result) {
      liveStreamUser.addAll(result);
    });
  }
}
