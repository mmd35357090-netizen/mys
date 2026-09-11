import 'dart:async';
import 'dart:io';

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

  final LocalAuthentication localAuth = LocalAuthentication();

  int bioMetricType = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  // ------------------------------------------------------------
  // Internet Check
  // ------------------------------------------------------------

  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));

      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on TimeoutException {
      debugPrint('Internet check timeout');
      return false;
    } catch (e) {
      debugPrint('Internet check failed: $e');
      return false;
    }
  }

  // ------------------------------------------------------------
  // App Initialization
  // ------------------------------------------------------------

  Future<void> initializeApp() async {
    try {
      // 1. Check internet
      final internetAvailable = await hasInternetConnection();

      if (!internetAvailable) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }

        Get.snackbar(
          'Network Error',
          'No internet connection. Please check your network.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );

        Get.offAll(() => const TutorialScreen());
        return;
      }

      // --------------------------------------------------------
      // 2. Restore previous login session
      // --------------------------------------------------------

      try {
        final authKey = await SharedPrefs().getAuthorizationKey();

        if (authKey != null && authKey.isNotEmpty) {
          debugPrint('Saved authorization key found.');

          // IMPORTANT:
          // Wait until profile refresh is completed before
          // checking isLogin.
          await _userProfileManager.refreshProfile();

          debugPrint(
            'Profile restored. isLogin: ${_userProfileManager.isLogin}',
          );
        } else {
          debugPrint('No saved authorization key found.');
        }
      } catch (e) {
        debugPrint('Login session restore failed: $e');
      }

      // --------------------------------------------------------
      // 3. Check biometric lock
      // --------------------------------------------------------

      await checkBiometric();
    } catch (e) {
      debugPrint('App initialization error: $e');

      // Never leave the user stuck on the loading screen.
      openNextScreen();
    }
  }

  // ------------------------------------------------------------
  // Biometric Check
  // ------------------------------------------------------------

  Future<void> checkBiometric() async {
    try {
      final biometricEnabled =
          await SharedPrefs().getBioMetricAuthStatus();

      if (!biometricEnabled) {
        openNextScreen();
        return;
      }

      final availableBiometrics =
          await localAuth.getAvailableBiometrics();

      if (!mounted) {
        return;
      }

      if (availableBiometrics.contains(BiometricType.face)) {
        setState(() {
          isLoading = false;
          bioMetricType = 1;
        });
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        setState(() {
          isLoading = false;
          bioMetricType = 2;
        });
      } else {
        openNextScreen();
      }
    } catch (e) {
      debugPrint('Biometric check failed: $e');
      openNextScreen();
    }
  }

  // ------------------------------------------------------------
  // Navigate to Correct Screen
  // ------------------------------------------------------------

  void openNextScreen() {
    if (_userProfileManager.isLogin == true) {
      packageController.initiate();

      final user = _userProfileManager.user.value;

      if (user != null && user.userName.isNotEmpty) {
        Get.offAll(() => const DashboardScreen());

        try {
          getIt<SocketManager>().connect();
        } catch (e) {
          debugPrint('Socket connection failed: $e');
        }
      } else {
        Get.offAll(() => const SetUserName());
      }
    } else {
      Get.offAll(() => const TutorialScreen());
    }
  }

  // ------------------------------------------------------------
  // Biometric Login
  // ------------------------------------------------------------

  Future<void> biometricLogin() async {
    try {
      final didAuthenticate = await localAuth.authenticate(
        localizedReason: 'Please authenticate to login into app',
      );

      if (didAuthenticate) {
        openNextScreen();
      }
    } on PlatformException catch (e) {
      debugPrint('Biometric authentication error: ${e.code}');

      if (e.code == auth_error.notAvailable ||
          e.code == auth_error.notEnrolled ||
          e.code == auth_error.passcodeNotSet) {
        openNextScreen();
      }
    } catch (e) {
      debugPrint('Biometric authentication failed: $e');
    }
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Normal app startup loading
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Biometric disabled/unavailable
    if (bioMetricType == 0) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Biometric lock screen
    return Center(
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

          Heading4Text(
            appLockedString.tr,
            weight: TextWeight.medium,
          ),

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
    );
  }
}