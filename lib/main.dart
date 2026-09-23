import 'dart:io';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:foap/api_handler/apis/auth_api.dart';
import 'package:foap/controllers/story/story_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:foap/controllers/live/live_users_controller.dart';
import 'package:foap/helper/imports/reel_imports.dart';
import 'package:foap/screens/login_sign_up/ask_to_follow.dart';
import 'package:foap/screens/post/content_creator_view.dart';
import 'package:foap/screens/settings_menu/help_support_contorller.dart';
import 'package:foap/screens/settings_menu/mercadopago_payment_controller.dart';
import 'package:foap/util/constant_util.dart';

import 'components/giphy/src/l10n/l10n.dart';
import 'components/reply_chat_cells/post_gift_controller.dart';
import 'components/smart_text_field.dart';
import 'controllers/chat_and_call/voip_controller.dart';
import 'controllers/clubs/clubs_controller.dart';
import 'controllers/misc/faq_controller.dart';
import 'package:foap/screens/dashboard/dashboard_screen.dart';
import 'package:foap/screens/login_sign_up/splash_screen.dart';
import 'package:foap/screens/settings_menu/settings_controller.dart';
import 'package:foap/util/shared_prefs.dart';
import 'package:camera/camera.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:overlay_support/overlay_support.dart';

import 'components/post_card_controller.dart';
import 'controllers/misc/gift_controller.dart';
import 'controllers/misc/misc_controller.dart';
import 'controllers/misc/users_controller.dart';
import 'controllers/notification/notifications_controller.dart';
import 'controllers/post/add_post_controller.dart';
import 'controllers/chat_and_call/agora_call_controller.dart';
import 'controllers/live/agora_live_controller.dart';
import 'controllers/chat_and_call/chat_detail_controller.dart';
import 'controllers/chat_and_call/chat_history_controller.dart';
import 'controllers/chat_and_call/chat_room_detail_controller.dart';
import 'controllers/chat_and_call/select_user_group_chat_controller.dart';
import 'controllers/home/home_controller.dart';
import 'controllers/live/live_history_controller.dart';
import 'controllers/story/highlights_controller.dart';
import 'controllers/tv/live_tv_streaming_controller.dart';
import 'controllers/auth/login_controller.dart';
import 'controllers/misc/map_screen_controller.dart';
import 'controllers/podcast/podcast_streaming_controller.dart';
import 'controllers/post/post_controller.dart';
import 'controllers/profile/profile_controller.dart';
import 'controllers/misc/request_verification_controller.dart';
import 'controllers/misc/subscription_packages_controller.dart';
import 'helper/device_info.dart';
import 'helper/languages.dart';
import 'manager/db_manager.dart';
import 'manager/location_manager.dart';
import 'manager/notification_manager.dart';
import 'manager/player_manager.dart';
import 'manager/socket_manager.dart';
import 'firebase_options.dart';
import 'dart:convert';


// ============================================================
// HTTP OVERRIDES
// ============================================================

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(
    SecurityContext? context,
  ) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (
        X509Certificate cert,
        String host,
        int port,
      ) =>
              true;
  }
}


// ============================================================
// GLOBAL VARIABLES
// ============================================================

late List<CameraDescription> cameras;

bool isLaunchedFromCallNotification = false;
bool isAnyPageInStack = false;


// ============================================================
// MAIN
// ============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HttpOverrides.global = MyHttpOverrides();

  // ----------------------------------------------------------
  // IMPORTANT
  //
  // UI startup should NOT wait for internet/network/plugin
  // operations.
  // ----------------------------------------------------------

  // Safe default.
  cameras = <CameraDescription>[];

  // ----------------------------------------------------------
  // Orientation
  // ----------------------------------------------------------

  try {
    AutoOrientation.portraitAutoMode();

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  } catch (e) {
    debugPrint(
      'Orientation initialization failed: $e',
    );
  }

  // ----------------------------------------------------------
  // Theme
  //
  // Local operation only.
  // Small timeout so it cannot hold startup.
  // ----------------------------------------------------------

  try {
    isDarkMode = await SharedPrefs()
        .isDarkMode()
        .timeout(
          const Duration(seconds: 2),
        );

    Get.changeThemeMode(
      isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light,
    );
  } catch (e) {
    debugPrint(
      'Theme initialization failed: $e',
    );
  }

  // ----------------------------------------------------------
  // CONTROLLERS
  // ----------------------------------------------------------

  Get.put(PlayerManager());
  Get.put(UsersController());
  Get.put(GiftController());
  Get.put(MiscController());
  Get.put(DashboardController());
  Get.put(UserProfileManager());
  Get.put(ClubsController());

  Get.put(SettingsController());
  Get.put(SubscriptionPackageController());
  Get.put(AgoraCallController());
  Get.put(VoipController());

  Get.put(AgoraLiveController());
  Get.put(LoginController());
  Get.put(HomeController());
  Get.put(PostController());
  Get.put(PostCardController());
  Get.put(AddPostController());
  Get.put(ChatDetailController());
  Get.put(ProfileController());
  Get.put(ChatHistoryController());
  Get.put(ChatRoomDetailController());
  Get.put(TvStreamingController());
  Get.put(LocationManager());
  Get.put(MapScreenController());
  Get.put(LiveHistoryController());
  Get.put(RequestVerificationController());
  Get.put(FAQController());
  Get.put(LiveUserController());
  Get.put(PostGiftController());
  Get.put(MercadappagoPaymentController());
  Get.put(HelpSupportController());
  Get.put(PodcastStreamingController());
  Get.put(SelectUserForGroupChatController());
  Get.put(AppStoryController());
  Get.put(SmartTextFieldController());
  Get.put(ReelsController());
  Get.put(CreateReelController());
  Get.put(CameraControllerService());
  Get.put(HighlightsController());
  Get.put(NotificationController());

  // ----------------------------------------------------------
  // SERVICE LOCATOR
  // ----------------------------------------------------------

  setupServiceLocator();

  // ----------------------------------------------------------
  // RUN APP FIRST
  //
  // THIS IS THE IMPORTANT PART.
  //
  // No Firebase await
  // No Camera await
  // No VoIP await
  // No server await
  //
  // Therefore internet না থাকলেও UI start হবে।
  // ----------------------------------------------------------

  runApp(
    Phoenix(
      child: const SocialifiedApp(
        startScreen: LoadingScreen(),
      ),
    ),
  );

  // ----------------------------------------------------------
  // BACKGROUND INITIALIZATION
  // ----------------------------------------------------------
  //
  // Everything below runs AFTER UI has started.
  // ----------------------------------------------------------

  unawaited(
    _initializeFirebaseInBackground(),
  );

  unawaited(
    _initializeCameraInBackground(),
  );

  unawaited(
    _initializeVoipInBackground(),
  );

  unawaited(
    _initializeDeviceInfoInBackground(),
  );

  unawaited(
    _initializeNotificationManagerInBackground(),
  );
}


// ============================================================
// FIREBASE BACKGROUND INITIALIZATION
// ============================================================

Future<void> _initializeFirebaseInBackground() async {
  try {
    debugPrint(
      'Firebase background initialization started.',
    );

    await Firebase.initializeApp(
      name: AppConfigConstants.appName,
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(
      const Duration(seconds: 10),
    );

    debugPrint(
      'Firebase initialization completed.',
    );

    FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler,
    );

    debugPrint(
      'Firebase Messaging background handler registered.',
    );
  } on TimeoutException {
    debugPrint(
      'Firebase initialization timeout. '
      'App will continue normally.',
    );

    // Retry later.
    await Future.delayed(
      const Duration(seconds: 15),
    );

    await _retryFirebaseInitialization();
  } catch (e) {
    debugPrint(
      'Firebase initialization failed: $e',
    );

    // Retry later.
    await Future.delayed(
      const Duration(seconds: 15),
    );

    await _retryFirebaseInitialization();
  }
}


// ============================================================
// FIREBASE RETRY
// ============================================================

Future<void> _retryFirebaseInitialization() async {
  try {
    debugPrint(
      'Retrying Firebase initialization...',
    );

    // Check whether Firebase is already initialized.
    if (Firebase.apps.isNotEmpty) {
      debugPrint(
        'Firebase already initialized.',
      );

      return;
    }

    await Firebase.initializeApp(
      name: AppConfigConstants.appName,
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(
      const Duration(seconds: 10),
    );

    FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler,
    );

    debugPrint(
      'Firebase retry successful.',
    );
  } catch (e) {
    debugPrint(
      'Firebase retry failed: $e',
    );
  }
}


// ============================================================
// CAMERA BACKGROUND INITIALIZATION
// ============================================================

Future<void> _initializeCameraInBackground() async {
  try {
    debugPrint(
      'Camera background initialization started.',
    );

    final result =
        await availableCameras().timeout(
      const Duration(seconds: 5),
    );

    cameras = result;

    debugPrint(
      'Camera initialized: ${cameras.length} camera(s).',
    );
  } on TimeoutException {
    debugPrint(
      'Camera initialization timeout.',
    );
  } catch (e) {
    debugPrint(
      'Camera initialization failed: $e',
    );
  }
}


// ============================================================
// VOIP BACKGROUND INITIALIZATION
// ============================================================

Future<void> _initializeVoipInBackground() async {
  try {
    debugPrint(
      'VoIP token initialization started.',
    );

    final token =
        await FlutterCallkitIncoming
            .getDevicePushTokenVoIP()
            .timeout(
      const Duration(seconds: 5),
    );

    if (token != null && token.isNotEmpty) {
      SharedPrefs().setVoipToken(token);

      debugPrint(
        'VoIP token saved.',
      );
    }
  } on TimeoutException {
    debugPrint(
      'VoIP token timeout.',
    );
  } catch (e) {
    debugPrint(
      'VoIP token initialization failed: $e',
    );
  }
}


// ============================================================
// DEVICE INFO
// ============================================================

Future<void> _initializeDeviceInfoInBackground() async {
  try {
    DeviceInfoManager.collectDeviceInfo();

    debugPrint(
      'Device information initialization started.',
    );
  } catch (e) {
    debugPrint(
      'Device information initialization failed: $e',
    );
  }
}


// ============================================================
// NOTIFICATION MANAGER
// ============================================================

Future<void> _initializeNotificationManagerInBackground() async {
  try {
    NotificationManager().initialize();

    debugPrint(
      'Notification manager initialized.',
    );
  } catch (e) {
    debugPrint(
      'Notification manager initialization failed: $e',
    );
  }
}


// ============================================================
// APP
// ============================================================

class SocialifiedApp extends StatefulWidget {
  final Widget startScreen;

  const SocialifiedApp({
    Key? key,
    required this.startScreen,
  }) : super(key: key);

  @override
  State<SocialifiedApp> createState() =>
      _SocialifiedAppState();
}


class _SocialifiedAppState
    extends State<SocialifiedApp> {

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: FutureBuilder<Locale>(
        future: SharedPrefs().getLocale(),
        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.hasData) {
            return GetMaterialApp(
              translations: Languages(),

              locale: snapshot.data!,

              fallbackLocale:
                  const Locale(
                'en',
                'US',
              ),

              debugShowCheckedModeBanner: false,

              home: widget.startScreen,

              builder:
                  EasyLoading.init(),

              // Use saved theme.
              themeMode:
                  isDarkMode
                      ? ThemeMode.dark
                      : ThemeMode.light,

           //   localizationsDelegates: const [
             //   GlobalMaterialLocalizations.delegate,
             //   GlobalWidgetsLocalizations.delegate,
             //   GiphyGetUILocalizations.delegate,
            //  ],

              supportedLocales:
                  const <Locale>[
                Locale('hi', 'US'),
                Locale('en', 'SA'),
                Locale('ar', 'SA'),
                Locale('tr', 'SA'),
                Locale('ru', 'SA'),
                Locale('es', 'SA'),
                Locale('fr', 'SA'),
                Locale('pt', 'BR'),
              ],
            );
          }

          // ----------------------------------------------------
          // Locale is still loading.
          //
          // DO NOT show a completely blank screen.
          // ----------------------------------------------------

          return const Material(
            child: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        },
      ),
    );
  }
}


// ============================================================
// FIREBASE BACKGROUND MESSAGE HANDLER
// ============================================================

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  try {
    debugPrint(
      'Firebase background message: ${message.data}',
    );

    // Firebase may not be initialized in the background
    // isolate, so initialize it safely if necessary.

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options:
            DefaultFirebaseOptions.currentPlatform,
      );
    }

    NotificationManager()
        .parseNotificationMessage(
      message.data,
    );
  } catch (e) {
    debugPrint(
      'Background notification error: $e',
    );
  }
}