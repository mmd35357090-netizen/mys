import 'dart:async'; // টাইমআউটের জন্য প্রয়োজন
import 'dart:io';    // ইন্টারনেট পিং করার জন্য প্রয়োজন
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';

import '../../controllers/misc/subscription_packages_controller.dart';
import '../../manager/socket_manager.dart';
import '../../util/shared_prefs.dart';
import '../login_sign_up/set_user_name.dart';
import '../login_sign_up/tutorial_screen.dart';
import 'dashboard_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final UserProfileManager _userProfileManager = Get.find();
  final SubscriptionPackageController packageController = Get.find();

  var localAuth = LocalAuthentication();
  // RxInt বাদ দিয়ে সাধারণ ইন্টিজার ও setState ব্যবহার করা ভালো যদি Obx না থাকে
  int bioMetricType = 0; 
  bool isLoading = true; // লোডিং ইন্ডিকেটর দেখানোর জন্য

  @override
  void initState() {
    super.initState();
    // স্ক্রিন ওপেন হওয়ামাত্রই ইন্টারনেট ও বায়োমেট্রিক চেক শুরু হবে
    initializeApp();
  }

  // ১. আসল ইন্টারনেট কানেকশন চেক করার ফাংশন (৫ সেকেন্ড টাইমআউট সহ)
  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5)); // ৫ সেকেন্ড পর কেটে যাবে
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on TimeoutException catch (_) {
      debugPrint("Internet check timeout");
    } catch (_) {
      debugPrint("No internet connection");
    }
    return false;
  }

  Future<void> initializeApp() async {
    // প্রথমে ইন্টারনেট আছে কিনা নিশ্চিত হোন
    bool internetAvailable = await hasInternetConnection();
    
    if (!internetAvailable) {
      setState(() { isLoading = false; });
      // ইন্টারনেট না থাকলে ইউজারকে জানানোর ব্যবস্থা করুন অথবা অফলাইন মোডে নিয়ে যান
      Get.snackbar(
        "Network Error", 
        "No internet connection. Please check your network.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white
      );
      // আপনি চাইলে এখানে ১-৬০ সেকেন্ড আটকে না রেখে সরাসরি টিউটোরিয়াল বা অফলাইন স্ক্রিনে পাঠাতে পারেন
      Get.offAll(() => const TutorialScreen());
      return;
    }

    // ইন্টারনেট থাকলে বায়োমেট্রিক চেক করবে
    await checkBiometric();
  }

  openNextScreen() {
    if (_userProfileManager.isLogin == true) {
      // এই ইনিশিয়েটগুলোর ভেতরেও এপিআই কল থাকলে টাইমআউট থাকা জরুরি
      packageController.initiate(); 
      if (_userProfileManager.user.value!.userName.isNotEmpty) {
        Get.offAll(() => const DashboardScreen());
        getIt<SocketManager>().connect();
      } else {
        Get.offAll(() => const SetUserName());
      }
    } else {
      Get.offAll(() => const TutorialScreen());
    }
  }

  Future<void> checkBiometric() async {
    bool bioMetricAuthStatus = await SharedPrefs().getBioMetricAuthStatus();
    if (bioMetricAuthStatus == true) {
      List<BiometricType> availableBiometrics = await localAuth.getAvailableBiometrics();

      setState(() {
        isLoading = false;
        if (availableBiometrics.contains(BiometricType.face)) {
          bioMetricType = 1; // Face ID
        } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
          bioMetricType = 2; // Touch ID
        } else {
          // কোনো বায়োমেট্রিক না মিললে সরাসরি পরের স্ক্রিনে যাবে
          openNextScreen();
        }
      });
    } else {
      openNextScreen();
    }
  }

  void biometricLogin() async {
    try {
      bool didAuthenticate = await localAuth.authenticate(
          localizedReason: 'Please authenticate to login into app');

      if (didAuthenticate == true) {
        openNextScreen();
      }
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
        openNextScreen(); // বায়োমেট্রিক কাজ না করলে অ্যাপ আটকে না রেখে রিডাইরেক্ট করুন
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      // FutureBuilder-এর বদলে সাধারণ লোডিং স্টেট ব্যবহার করা হয়েছে
      body: isLoading 
          ? const Center(child: CircularProgressIndicator()) // চেক করার সময় গোল লোডিং ঘুরবে
          : bioMetricType == 0
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        bioMetricType == 1
                            ? 'assets/face-id.png'
                            : 'assets/fingerprint.png',
                        height: 80,
                        width: 80,
                        color: AppColorConstants.themeColor,
                      ),
                      const SizedBox(height: 50),
                      Heading4Text(appLockedString.tr, weight: TextWeight.medium),
                      const SizedBox(height: 10),
                      Heading4Text(
                        bioMetricType == 1
                            ? unlockAppWithFaceIdString.tr
                            : unlockAppWithTouchIdString.tr,
                      ),
                      const SizedBox(height: 50),
                      Heading3Text(
                        bioMetricType == 1
                            ? useFaceIdString.tr
                            : useTouchIdString.tr,
                        color: AppColorConstants.themeColor,
                      ).ripple(() {
                        biometricLogin();
                      }),
                    ],
                  ),
                ),
    );
  }
}
