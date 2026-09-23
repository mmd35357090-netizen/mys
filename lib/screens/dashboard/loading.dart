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
    debugPrint('========================================');

    try {
      // --------------------------------------------------------
      // 1. Read saved login/session locally
      // --------------------------------------------------------

      _savedAuthKey = await _safeGetAuthKey();

      final bool hasSavedLogin =
          _savedAuthKey != null && _savedAuthKey!.isNotEmpty;

      debugPrint(
        'Saved login found: $hasSavedLogin',
      );

      // --------------------------------------------------------
      // 2. Start LOCAL services immediately
      //    These must NEVER control navigation.
      // --------------------------------------------------------

      unawaited(_initializeDatabase());

      // --------------------------------------------------------
      // 3. New user
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
      // 4. Existing user
      //
      // Profile and settings are started in background.
      // They are NOT allowed to permanently block startup.
      // --------------------------------------------------------

      debugPrint(
        'Existing user detected. Starting background sync...',
      );

      unawaited(_restoreProfileWithRetry());
      unawaited(_retrySettingsInBackground());

      // --------------------------------------------------------
      // 5. Give profile a SHORT chance to restore.
      //
      // This is only to make normal startup smoother.
      // It cannot keep the app on loading forever.
      // --------------------------------------------------------

      await _waitForProfileBriefly();

      // --------------------------------------------------------
      // 6. IMPORTANT:
      // Saved auth key exists, therefore do not keep the user
      // trapped on LoadingScreen just because server is slow.
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

      // --------------------------------------------------------
      // Emergency fallback
      // Even if something unexpected happens, do not remain
      // permanently on LoadingScreen.
      // --------------------------------------------------------

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
  //
  // Server slow/down হলেও retry করবে।
  // প্রতিটি request-এর timeout আছে।
  // ============================================================

  Future<void> _restoreProfileWithRetry() async {
    const int maxStartupAttempts = 5;

    for (int attempt = 1;
        attempt <= maxStartupAttempts;
        attempt++) {
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

    // ----------------------------------------------------------
    // Startup attempts finished.
    //
    // Continue retrying in background, but NEVER block UI.
    // ----------------------------------------------------------

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

        // FCM update must not block UI.
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
  //
  // Normal fast internet:
  // profile may finish before navigation.
  //
  // Slow internet:
  // after limited time we continue anyway.
  // ============================================================

  Future<void> _waitForProfileBriefly() async {
    const Duration maxWait =
        Duration(seconds: 5);

    final start = DateTime.now();

    while (DateTime.now()
            .difference(start) <
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

    for (int attempt = 1;
        attempt <= maxAttempts;
        attempt++) {
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

    // Continue in background.
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
    // Package initialization must never block navigation.
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
    // If profile has already loaded and username is available,
    // go Dashboard.
    //
    // If profile has not loaded because server is slow,
    // saved auth session still allows Dashboard.
    // Background profile retry will continue.
    // ----------------------------------------------------------

    try {
      final user =
          _userProfileManager.user.value;

      if (user != null &&
          user.userName.isNotEmpty) {
        debugPrint(
          'Cached/loaded profile found. Opening Dashboard.',
        );
      } else {
        debugPrint(
          'Profile not currently available. '
          'Opening Dashboard using saved session.',
        );
      }

      Get.offAll(
        () => const DashboardScreen(),
      );

      // --------------------------------------------------------
      // Socket MUST NOT block navigation.
      // --------------------------------------------------------

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

      // Safe fallback.
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
  // BUILD
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