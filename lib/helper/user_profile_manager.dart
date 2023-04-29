import 'dart:async';

import 'package:foap/apiHandler/api_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/manager/db_manager.dart';
import 'package:foap/manager/socket_manager.dart';
import 'package:foap/screens/dashboard/dashboard_screen.dart';
import 'package:foap/screens/login_sign_up/login_screen.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../util/shared_prefs.dart';

class UserProfileManager extends GetxController{
  final DashboardController _dashboardController = Get.find();

  Rx<UserModel?> user = Rx<UserModel?>(null);

  bool get isLogin {
    return user.value != null;
  }

  logout() {
    user.value = null;
    SharedPrefs().clearPreferences();
    Get.offAll(() => const LoginScreen());
    getIt<SocketManager>().disconnect();
    getIt<DBManager>().clearAllUnreadCount();
    getIt<DBManager>().deleteAllChatHistory();

    GoogleSignIn googleSignIn = GoogleSignIn();
    googleSignIn.disconnect();

    Future.delayed(const Duration(seconds: 2), () {
      _dashboardController.indexChanged(0);
    });
  }

  Future refreshProfile() async {
    String? authKey = await SharedPrefs().getAuthorizationKey();

    print('refreshProfile $authKey');
    if (authKey != null) {
      await ApiController().getMyProfile().then((value) {
        user.value = value.user;

        if (user.value != null) {
          setupSocketServiceLocator1();
        }
        return;
      });
    } else {
      return;
      // print('no auth token found');
    }
  }
}
