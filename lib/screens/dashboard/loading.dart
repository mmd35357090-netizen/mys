import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foap/api_handler/apis/auth_api.dart';
import 'package:foap/helper/imports/common_import.dart';

import '../../controllers/misc/subscription_packages_controller.dart';
import '../../manager/db_manager.dart';
import '../../manager/socket_manager.dart';
import '../../screens/settings_menu/settings_controller.dart';
import '../../util/shared_prefs.dart';
import '../login_sign_up/set_user_name.dart';
import '../login_sign_up/tutorial_screen.dart';
import 'dashboard_screen.dart';
import 'no_internet_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late final UserProfileManager _userProfileManager;
  late final SubscriptionPackageController _packageController;

  bool _navigationStarted = false;
  bool _startupFinished = false;

  String? _savedAuthKey;

  @override
  void initState() {
    super.initState();

    _userProfileManager = Get.find<UserProfileManager>();
    _packageController = Get.find<SubscriptionPackageController>();

    _initializeApp();
  }

  // ============================================================
  // MAIN STARTUP
  // ============================================================

  Future<void> _initializeApp() async {
    debugPrint('========================================');
    debugPrint('FACE HUB STARTUP');
    debugPrint('Biometric startup check: DISABLED');
    debugPrint('Internet check: ENABLED');
    debugPrint('========================================');

    try {
      // --------------------------------------------------------
      // 1. CHECK INTERNET FIRST
      // --------------------------------------------------------

      final internetAvailable = await _checkInternet();

      if (!internetAvailable) {
        debugPrint(
          'No internet connection. Opening NoInternetScreen.',
        );

        await _openNoInternetScreen();

        return;
      }

      // --------------------------------------------------------
      // 2. Read saved login/session locally
      // --------------------------------------------------------

      _savedAuthKey = await _safeGetAuthKey();

      final bool hasSavedLogin =
          _savedAuthKey != null && _savedAuthKey!.isNotEmpty;

      debugPrint(
        'Saved login found: $hasSavedLogin',
      );

      // --------------------------------------------------------
      // 3. Start LOCAL services immediately
      //    These must NEVER control navigation.
      // --------------------------------------------------------

      unawaited(_initializeDatabase());

      // --------------------------------------------------------
      // 4. New user
      // --------------------------------------------------------

      if (!hasSavedLogin) {
        debugPrint(
          'No saved login. Opening Tutorial without waiting for server.',
        );

        _startupFinished = true;

        if (!mounted) return;

        await _openTutorial();

        // Settings can continue in background.
        unawaited(_retrySettingsInBackground());

        return;
      }

      // --------------------------------------------------------
      // 5. Existing user
      // --------------------------------------------------------

      debugPrint(
        'Existing user detected. Starting background sync...',
      );

      unawaited(_restoreProfileWithRetry());
      unawaited(_retrySettingsInBackground());

      // --------------------------------------------------------
      // 6. Give profile a short chance to restore
      // --------------------------------------------------------

      await _waitForProfileBriefly();

      // --------------------------------------------------------
      // 7. Continue startup
      // --------------------------------------------------------

      _startupFinished = true;

      if (!mounted) return;

      await _openLoggedInUser();
    } catch (e, stackTrace) {
      debugPrint(
        'Startup error: $e',
      );

      debugPrint(
        'Startup stack: $stackTrace',
      );

      _startupFinished = true;

      if (!mounted) return;

      final hasSavedLogin =
          _savedAuthKey != null && _savedAuthKey!.isNotEmpty;

      if (hasSavedLogin) {
        await _openLoggedInUser();
      } else {
        await _openTutorial();
      }
    }
  }

  // ============================================================
  // INTERNET CHECK
  // ============================================================

  Future<bool> _checkInternet() async {
    try {
      debugPrint(
        'Checking internet connection...',
      );

      final result = await InternetAddress.lookup('google.com')
          .timeout(
        const Duration(seconds: 5),
      );

      final connected =
          result.isNotEmpty &&
          result.first.rawAddress.isNotEmpty;

      debugPrint(
        'Internet available: $connected',
      );

      return connected;
    } on TimeoutException {
      debugPrint(
        'Internet check timeout.',
      );

      return false;
    } catch (e) {
      debugPrint(
        'Internet check failed: $e',
      );

      return false;
    }
  }

  // ============================================================
  // NO INTERNET SCREEN
  // ============================================================

  Future<void> _openNoInternetScreen() async {
    if (!mounted) return;

    final result = await Get.to<bool>(
      () => const NoInternetScreen(),
    );

    if (!mounted) return;

    debugPrint(
      'Returned from NoInternetScreen: $result',
    );

    // ----------------------------------------------------------
    // Check internet again after returning from Settings.
    // ----------------------------------------------------------

    final internetAvailable = await _checkInternet();

    if (internetAvailable) {
      debugPrint(
        'Internet connection restored.',
      );

      _navigationStarted = false;
      _startupFinished = false;

      await _initializeApp();

      return;
    }

    // ----------------------------------------------------------
    // Still offline.
    //
    // Keep the user on NoInternetScreen.
    // ----------------------------------------------------------

    debugPrint(
      'Internet is still unavailable.',
    );

    await _openNoInternetScreen();
  }

  // ============================================================
  // AUTH KEY
  // ============================================================

  Future<String?> _safeGetAuthKey() async {
    try {
      return await SharedPrefs()
          .getAuthorizationKey()
          .timeout(
            const Duration(seconds: 3),
            onTimeout: () {
              debugPrint(
                'Authorization key read timeout.',
              );

              return null;
            },
          );
    } catch (e) {
      debugPrint(
        'Authorization key error: $e',
      );

      return null;
    }
  }

  // ============================================================
  // DATABASE
  // ============================================================

  Future<void> _initializeDatabase() async {
    try {
      debugPrint(
        'Database initialization started...',
      );

      await getIt<DBManager>()
          .createDatabase()
          .timeout(
            const Duration(seconds: 8),
          );

      debugPrint(
        'Database initialization completed.',
      );
    } catch (e) {
      debugPrint(
        'Database initialization failed/timeout: $e',
      );
    }
  }

  // ============================================================
  // PROFILE RESTORE
  // ============================================================

  Future<bool> _refreshProfileOnce() async {
    try {
      debugPrint(
        'Profile sync started...',
      );

      await _userProfileManager
          .refreshProfile()
          .timeout(
            const Duration(seconds: 8),
          );

      debugPrint(
        'Profile sync completed. '
        'isLogin=${_userProfileManager.isLogin}',
      );

      return true;
    } on TimeoutException {
      debugPrint(
        'Profile sync timeout.',
      );

      return false;
    } catch (e) {
      debugPrint(
        'Profile sync failed: $e',
      );

      return false;
    }
  }

  // ============================================================
  // PROFILE RETRY
  // ============================================================

  Future<void> _restoreProfileWithRetry() async {
    const int maxStartupAttempts = 5;

    for (
      int attempt = 1;
      attempt <= maxStartupAttempts;
      attempt++
    ) {
      if (!mounted && _startupFinished) {
        return;
      }

      debugPrint(
        'Profile sync attempt $attempt/$maxStartupAttempts',
      );

      final success = await _refreshProfileOnce();

      if (success) {
        debugPrint(
          'Profile restored successfully.',
        );

        _onProfileRestored();

        return;
      }

      if (attempt < maxStartupAttempts) {
        final seconds = attempt * 2;

        debugPrint(
          'Profile retry in $seconds seconds...',
        );

        await Future.delayed(
          Duration(seconds: seconds),
        );
      }
    }

    debugPrint(
      'Profile startup retries finished. '
      'Background retry mode started.',
    );

    unawaited(
      _continueProfileBackgroundRetry(),
    );
  }

  // ============================================================
  // BACKGROUND PROFILE RETRY
  // ============================================================

  Future<void> _continueProfileBackgroundRetry() async {
    while (true) {
      await Future.delayed(
        const Duration(seconds: 30),
      );

      final success = await _refreshProfileOnce();

      if (success) {
        debugPrint(
          'Background profile sync successful.',
        );

        _onProfileRestored();

        return;
      }

      debugPrint(
        'Background profile sync failed. '
        'Will retry again.',
      );
    }
  }

  // ============================================================
  // PROFILE SUCCESS
  // ============================================================

  void _onProfileRestored() {
    try {
      if (_userProfileManager.isLogin == true) {
        debugPrint(
          'User session confirmed after profile sync.',
        );

        try {
          unawaited(
            AuthApi.updateFcmToken(),
          );
        } catch (e) {
          debugPrint(
            'FCM token update failed: $e',
          );
        }
      }
    } catch (e) {
      debugPrint(
        'Post profile-sync operation failed: $e',
      );
    }
  }

  // ============================================================
  // SHORT PROFILE WAIT
  // ============================================================

  Future<void> _waitForProfileBriefly() async {
    const Duration maxWait =
        Duration(seconds: 5);

    final start = DateTime.now();

    while (
        DateTime.now().difference(start) <
            maxWait) {
      if (_userProfileManager.isLogin == true) {
        debugPrint(
          'Profile became ready during short startup wait.',
        );

        return;
      }

      await Future.delayed(
        const Duration(milliseconds: 250),
      );
    }

    debugPrint(
      'Short profile wait finished. '
      'Startup will continue without waiting for server.',
    );
  }

  // ============================================================
  // SETTINGS
  // ============================================================

  Future<bool> _loadSettingsOnce() async {
    try {
      final settingsController =
          Get.find<SettingsController>();

      debugPrint(
        'Settings sync started...',
      );

      await settingsController
          .getSettings()
          .timeout(
            const Duration(seconds: 8),
          );

      debugPrint(
        'Settings sync completed.',
      );

      return true;
    } on TimeoutException {
      debugPrint(
        'Settings sync timeout.',
      );

      return false;
    } catch (e) {
      debugPrint(
        'Settings sync failed: $e',
      );

      return false;
    }
  }

  // ============================================================
  // SETTINGS RETRY
  // ============================================================

  Future<void> _retrySettingsInBackground() async {
    const int maxAttempts = 5;

    for (
      int attempt = 1;
      attempt <= maxAttempts;
      attempt++
    ) {
      debugPrint(
        'Settings sync attempt $attempt/$maxAttempts',
      );

      final success =
          await _loadSettingsOnce();

      if (success) {
        return;
      }

      if (attempt < maxAttempts) {
        final seconds = attempt * 2;

        await Future.delayed(
          Duration(seconds: seconds),
        );
      }
    }

    while (true) {
      await Future.delayed(
        const Duration(seconds: 30),
      );

      final success =
          await _loadSettingsOnce();

      if (success) {
        debugPrint(
          'Background settings sync successful.',
        );

        return;
      }

      debugPrint(
        'Background settings sync failed. '
        'Retrying...',
      );
    }
  }

  // ============================================================
  // OPEN LOGGED-IN USER
  // ============================================================

  Future<void> _openLoggedInUser() async {
    if (!mounted) return;

    if (_navigationStarted) {
      return;
    }

    _navigationStarted = true;

    debugPrint(
      'Opening logged-in user flow...',
    );

    // ----------------------------------------------------------
    // Package initialization
    // ----------------------------------------------------------

    try {
      unawaited(
        Future<void>(() async {
          try {
            _packageController.initiate();
          } catch (e) {
            debugPrint(
              'Package initialization failed: $e',
            );
          }
        }),
      );
    } catch (e) {
      debugPrint(
        'Package startup error: $e',
      );
    }

    // ----------------------------------------------------------
    // Dashboard / SetUserName
    // ----------------------------------------------------------

    try {
      final user =
          _userProfileManager.user.value;

      if (user != null &&
          user.userName.isNotEmpty) {
        debugPrint(
          'Profile found. Opening Dashboard.',
        );

        Get.offAll(
          () => const DashboardScreen(),
        );

        try {
          unawaited(
            Future<void>(() async {
              try {
                getIt<SocketManager>().connect();

                debugPrint(
                  'Socket connection started.',
                );
              } catch (e) {
                debugPrint(
                  'Socket connection failed: $e',
                );
              }
            }),
          );
        } catch (e) {
          debugPrint(
            'Socket startup error: $e',
          );
        }

        return;
      }

      // --------------------------------------------------------
      // Logged in but username missing
      // --------------------------------------------------------

      if (user != null) {
        debugPrint(
          'User logged in but username is missing.',
        );

        Get.offAll(
          () => const SetUserName(),
        );

        return;
      }

      // --------------------------------------------------------
      // Profile was not restored.
      //
      // Keep the saved session flow, as the original code did.
      // Dashboard will handle the next state.
      // --------------------------------------------------------

      debugPrint(
        'Profile not currently available. '
        'Opening Dashboard using saved session.',
      );

      Get.offAll(
        () => const DashboardScreen(),
      );

      try {
        unawaited(
          Future<void>(() async {
            try {
              getIt<SocketManager>().connect();

              debugPrint(
                'Socket connection started.',
              );
            } catch (e) {
              debugPrint(
                'Socket connection failed: $e',
              );
            }
          }),
        );
      } catch (e) {
        debugPrint(
          'Socket startup error: $e',
        );
      }
    } catch (e) {
      debugPrint(
        'Dashboard navigation failed: $e',
      );

      _navigationStarted = false;

      if (!mounted) return;

      await _openTutorial();
    }
  }

  // ============================================================
  // OPEN TUTORIAL
  // ============================================================

  Future<void> _openTutorial() async {
    if (!mounted) return;

    if (_navigationStarted) {
      return;
    }

    _navigationStarted = true;

    debugPrint(
      'Opening TutorialScreen.',
    );

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
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}