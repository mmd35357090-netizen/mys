import 'package:flutter/services.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/login_signup_imports.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';
import '../../controllers/misc/subscription_packages_controller.dart';
import '../../manager/socket_manager.dart';
import '../../util/shared_prefs.dart';
import 'dashboard_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key}) ;

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final UserProfileManager _userProfileManager = Get.find();
  final SubscriptionPackageController packageController = Get.find();

  late bool haveBiometricLogin = false;
  var localAuth = LocalAuthentication();
  RxInt bioMetricType = 0.obs;

  @override
  void initState() {
    super.initState();

  }

  openNextScreen() {
    if (_userProfileManager.isLogin == true) {
      packageController.initiate();
      Get.offAll(() => const DashboardScreen());
      getIt<SocketManager>().connect();
    } else {
      Get.offAll(() => const LoginScreen());
    }
  }

  Future checkBiometric() async {
    if (_userProfileManager.isLogin == false) {
      Future.delayed(const Duration(milliseconds: 100), () {
        openNextScreen();
      });
      return;
    }
    bool bioMetricAuthStatus = await SharedPrefs().getBioMetricAuthStatus();
    if (bioMetricAuthStatus == true) {
      List<BiometricType> availableBiometrics =
          await localAuth.getAvailableBiometrics();

      if (availableBiometrics.contains(BiometricType.face)) {
        // Face ID.
        bioMetricType.value = 1;
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        // Touch ID.
        bioMetricType.value = 2;
      }
    } else {
      openNextScreen();
    }
    return;
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
        // Handle this exception here.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: FutureBuilder<void>(
            future: checkBiometric(),
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              return bioMetricType.value == 0
                  ? Container()
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            bioMetricType.value == 1
                                ? 'assets/face-id.png'
                                : 'assets/fingerprint.png',
                            height: 80,
                            width: 80,
                            color: AppColorConstants.themeColor,
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          Heading4Text(appLockedString.tr,
                              weight: TextWeight.medium),
                          const SizedBox(
                            height: 10,
                          ),
                          Heading4Text(
                            bioMetricType.value == 1
                                ? unlockAppWithFaceIdString.tr
                                : unlockAppWithTouchIdString.tr,
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          Heading3Text(
                            bioMetricType.value == 1
                                ? useFaceIdString.tr
                                : useTouchIdString.tr,
                            color: AppColorConstants.themeColor,
                          ).ripple(() {
                            biometricLogin();
                          }),
                        ],
                      ),
                    );
            }));
  }
}
