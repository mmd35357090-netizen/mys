import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';

import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/manager/socket_manager.dart';
import 'package:foap/util/shared_prefs.dart';

import '../../controllers/misc/subscription_packages_controller.dart';
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
  bool biometricEnabled = false;
  bool biometricAuthenticated = false;
  bool profileReady = false;
  bool settingsReady = false;
  bool databaseReady = false;
  bool hasFinishedNavigation = false;

  Future<void>? profileFuture;
  Future<void>? settingsFuture;
  Future<void>? databaseFuture;

  @override
  void initState() {
    super.initState();

    initializeApp();
  }

  // ============================================================
  // INITIALIZATION
  // ============================================================

  Future<void> initializeApp() async {
    try {
      final authKey =
          await SharedPrefs().getAuthorizationKey();

      final bool isOldUser =
          authKey != null && authKey.isNotEmpty;

      // --------------------------------------------------------
      // NEW USER
      // --------------------------------------------------------

      if (!isOldUser) {
        debugPrint('New user detected.');

        await _initializeLocalServices();

        if (!mounted) return;

        openNextScreen();

        return;
      }

      // --------------------------------------------------------
      // OLD USER
      // --------------------------------------------------------

      debugPrint('Existing user detected.');

      // --------------------------------------------------------
      // Start profile refresh immediately.
      //
      // This DOES NOT wait for biometric preparation.
      // --------------------------------------------------------

      profileFuture = _refreshProfile();

      // --------------------------------------------------------
      // Start settings and database at the same time.
      // --------------------------------------------------------

      settingsFuture = _loadSettings();
      databaseFuture = _createDatabase();

      // --------------------------------------------------------
      // Prepare biometric at the same time.
      // --------------------------------------------------------

      await _prepareBiometric();

      // --------------------------------------------------------
      // If biometric is enabled, show fingerprint screen.
      //
      // Profile/settings/database continue running in background.
      // --------------------------------------------------------

      if (biometricEnabled) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
        });

        return;
      }

      // --------------------------------------------------------
      // Biometric is not enabled.
      //
      // Wait for required startup operations.
      // --------------------------------------------------------

      await Future.wait([
        if (profileFuture != null) profileFuture!,
        if (settingsFuture != null) settingsFuture!,
        if (databaseFuture != null) databaseFuture!,
      ]);

      profileReady = true;
      settingsReady = true;
      databaseReady = true;

      if (!mounted) return;

      openNextScreen();
    } catch (e) {
      debugPrint('App initialization error: $e');

      if (!mounted) return;

      openNextScreen();
    }
  }

  // ============================================================
  // PROFILE
  // ============================================================

  Future<void> _refreshProfile() async {
    try {
      await _userProfileManager.refreshProfile();

      profileReady = true;

      debugPrint(
        'Profile restored. '
        'isLogin: ${_userProfileManager.isLogin}',
      );
    } catch (e) {
      debugPrint(
        'Profile refresh failed: $e',
      );

      // Do not crash the application.
      profileReady = true;
    }
  }

  // ============================================================
  // SETTINGS
  // ============================================================

  Future<void> _loadSettings() async {
    try {
      final settingsController =
          Get.find<SettingsController>();

      await settingsController.getSettings();

      settingsReady = true;
    } catch (e) {
      debugPrint(
        'Settings loading failed: $e',
      );

      settingsReady = true;
    }
  }

  // ============================================================
  // DATABASE
  // ============================================================

  Future<void> _createDatabase() async {
    try {
      await getIt<DBManager>().createDatabase();

      databaseReady = true;
    } catch (e) {
      debugPrint(
        'Database initialization failed: $e',
      );

      databaseReady = true;
    }
  }

  // ============================================================
  // LOCAL SERVICES
  // ============================================================

  Future<void> _initializeLocalServices() async {
    await Future.wait([
      _loadSettings(),
      _createDatabase(),
    ]);
  }

  // ============================================================
  // BIOMETRIC PREPARATION
  // ============================================================

  Future<void> _prepareBiometric() async {
    try {
      biometricEnabled =
          await SharedPrefs().getBioMetricAuthStatus();

      if (!biometricEnabled) {
        debugPrint(
          'Biometric lock is disabled.',
        );

        return;
      }

      final availableBiometrics =
          await localAuth.getAvailableBiometrics();

      if (availableBiometrics.contains(
        BiometricType.face,
      )) {
        bioMetricType = 1;
      } else if (availableBiometrics.contains(
        BiometricType.fingerprint,
      )) {
        bioMetricType = 2;
      } else {
        biometricEnabled = false;
        bioMetricType = 0;
      }

      debugPrint(
        'Biometric enabled: $biometricEnabled',
      );
    } catch (e) {
      debugPrint(
        'Biometric preparation failed: $e',
      );

      biometricEnabled = false;
      bioMetricType = 0;
    }
  }

  // ============================================================
  // BIOMETRIC LOGIN
  // ============================================================

  Future<void> biometricLogin() async {
    if (!biometricEnabled) {
      openNextScreen();
      return;
    }

    try {
      final didAuthenticate =
          await localAuth.authenticate(
        localizedReason:
            'Please authenticate to login into app',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (!didAuthenticate) {
        debugPrint(
          'Biometric authentication cancelled.',
        );

        return;
      }

      biometricAuthenticated = true;

      // --------------------------------------------------------
      // Profile/settings/database may already be finished
      // while user was authenticating.
      // --------------------------------------------------------

      await Future.wait([
        if (profileFuture != null) profileFuture!,
        if (settingsFuture != null) settingsFuture!,
        if (databaseFuture != null) databaseFuture!,
      ]);

      profileReady = true;
      settingsReady = true;
      databaseReady = true;

      if (!mounted) return;

      openNextScreen();
    } on PlatformException catch (e) {
      debugPrint(
        'Biometric authentication error: ${e.code}',
      );

      if (e.code == auth_error.notAvailable ||
          e.code == auth_error.notEnrolled ||
          e.code == auth_error.passcodeNotSet) {
        biometricEnabled = false;

        await Future.wait([
          if (profileFuture != null) profileFuture!,
          if (settingsFuture != null) settingsFuture!,
          if (databaseFuture != null) databaseFuture!,
        ]);

        if (!mounted) return;

        openNextScreen();
      }
    } catch (e) {
      debugPrint(
        'Biometric authentication failed: $e',
      );
    }
  }

  // ============================================================
  // NEXT SCREEN
  // ============================================================

  Future<void> openNextScreen() async {
    if (hasFinishedNavigation) {
      return;
    }

    hasFinishedNavigation = true;

    // ----------------------------------------------------------
    // LOGIN USER
    // ----------------------------------------------------------

    if (_userProfileManager.isLogin == true) {
      packageController.initiate();

      final user =
          _userProfileManager.user.value;

      if (user != null &&
          user.userName.isNotEmpty) {
        Get.offAll(
          () => const DashboardScreen(),
        );

        // ------------------------------------------------------
        // Socket should NOT block Dashboard.
        // ------------------------------------------------------

        try {
          getIt<SocketManager>().connect();
        } catch (e) {
          debugPrint(
            'Socket connection failed: $e',
          );
        }

        return;
      }

      // --------------------------------------------------------
      // Logged in but username missing
      // --------------------------------------------------------

      Get.offAll(
        () => const SetUserName(),
      );

      return;
    }

    // ----------------------------------------------------------
    // NEW / LOGGED OUT USER
    // ----------------------------------------------------------

    Get.offAll(
      () => const TutorialScreen(),
    );
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColorConstants.backgroundColor,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // ----------------------------------------------------------
    // Normal startup
    // ----------------------------------------------------------

    if (isLoading && !biometricEnabled) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // ----------------------------------------------------------
    // Fingerprint / Face lock
    // ----------------------------------------------------------

    if (biometricEnabled) {
      return Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Image.asset(
              bioMetricType == 1
                  ? 'assets/face-id.png'
                  : 'assets/fingerprint.png',
              height: 80,
              width: 80,
              color:
                  AppColorConstants.themeColor,
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
              color:
                  AppColorConstants.themeColor,
            ).ripple(() {
              biometricLogin();
            }),
          ],
        ),
      );
    }

    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}