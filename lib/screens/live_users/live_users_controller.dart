import 'package:foap/helper/common_import.dart';
import 'package:get/get.dart';

class LiveUserController extends GetxController {
  RxList<UserLiveCallDetail> liveStreamUser = <UserLiveCallDetail>[].obs;
  RxString totalLiveUsers = "0".obs;

  // fetch live users
  void getLiveUsers() async {
    AppUtil.checkInternet().then((value) {
      if (value) {
        EasyLoading.show(status: LocalizationString.loading);
        ApiController().getLiveUser().then((response) {
          print('getLiveUsers : ${response.toString()}');
          print('getliveUsers total live users count: ${response.totalLiveUsers}');
          // print('getliveUsers userDetails: ${response.liveStreamUser[0].userdetails?[0].name}');
          liveStreamUser.value.clear();
          totalLiveUsers.value = response.totalLiveUsers!;
          liveStreamUser.addAll(response.liveStreamUser);
          EasyLoading.dismiss();
        });
      }
    });
  }
}
