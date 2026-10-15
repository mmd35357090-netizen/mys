import 'dart:async';
import 'package:foap/api_handler/apis/auth_api.dart';
import 'package:foap/api_handler/apis/profile_api.dart';
import 'package:foap/controllers/auth/login_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/manager/socket_manager.dart';
import 'package:foap/screens/dashboard/dashboard_screen.dart';
import 'package:foap/screens/login_sign_up/login_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../model/account.dart';
import '../util/shared_prefs.dart';

class UserProfileManager extends GetxController {
  final DashboardController _dashboardController = Get.find();

  Rx<UserModel?> user = Rx<UserModel?>(null);

  bool get isLogin {
    return user.value != null;
  }

  logout() async {
    await AuthApi.logout();

    // SharedPrefs().clearPreferences();
    logoutAccount(user.value!.id);
    Get.offAll(() => const LoginScreen());
    getIt<SocketManager>().logout();
    // getIt<RealmDBManager>().clearAllUnreadCount();
    // getIt<RealmDBManager>().deleteAllChatHistory();
    GoogleSignIn googleSignIn = GoogleSignIn();
    googleSignIn.disconnect();
    Future.delayed(const Duration(seconds: 2), () {
      _dashboardController.indexChanged(0);
    });
    SharedPrefs().setBioMetricAuthStatus(false);
    user.value = null;
  }

  Future<void> logoutAccount(int userId) async {
    List<SayHiAppAccount> accounts = await SharedPrefs().getAccounts();

    for (SayHiAppAccount account in accounts) {
      if (account.userId == userId.toString()) {
        account.authToken = null;
        account.isLoggedIn = false;
        await SharedPrefs().saveAccount(account);
        break;
      }
    }
  }

  // Function to set a specific account as logged in and mark others as logged out
  Future<void> loginAccount(SayHiAppAccount account) async {
    List<SayHiAppAccount> accounts = await SharedPrefs().getAccounts();

    // Check if the account is already in the list
    int index = accounts.indexWhere((acc) => acc.userId == account.userId);

    if (index != -1) {
      // If account exists, update it
      accounts[index].isLoggedIn = true;
      accounts[index].authToken = account.authToken;
    } else {
      // If account is logging in for the first time, add it to the list with isLoggedIn set to true
      account.isLoggedIn = true;
      accounts.add(account);
    }

    // Save all accounts to SharedPreferences
    for (var acc in accounts) {
      await SharedPrefs().saveAccount(acc);
    }
  }

  switchToAccount(SayHiAppAccount account) {
    if (account.authToken != null) {
      LoginController loginController = Get.find();
      loginController.loginSuccess(account.authToken!);
    } else {
      Get.to(() => const LoginScreen(
            showCloseBtn: true,
          ));
    }
  }

  switchToAccountSilently(
      SayHiAppAccount account, Widget? widget, VoidCallback? callback) {
    if (account.authToken != null) {
      LoginController loginController = Get.find();
      loginController.loginSilently(account.authToken!, () {
        Get.to(() => widget!);
      });
    } else {
      Get.to(() => const LoginScreen(
            showCloseBtn: true,
          ));
    }
    if (callback != null) {
      callback();
    }
  }

  Future refreshProfile() async {
    String? authKey = await SharedPrefs().getAuthorizationKey();

    if (authKey != null) {
      await ProfileApi.getMyProfile(resultCallback: (result) {
        user.value = result;
        // if (user.value != null) {
        //   setupSocketServiceLocator1();
        // }
        return;
      });
    } else {
      return;
      // print('no auth token found');
    }
  }
}
