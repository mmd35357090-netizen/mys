import 'package:foap/apiHandler/api_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/user_model.dart';
import 'package:get/get.dart';

class LiveJoinedUserController extends GetxController {
  RxList<UserModel> users = <UserModel>[].obs;

  loadUsers(int liveId) {
    ApiController().getFollowerUsers().then((value) {
      users.value = value.users;
      update();
    });
  }
}
