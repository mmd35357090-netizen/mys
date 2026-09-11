import 'dart:io';
import 'dart:async'; 
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
import 'package:foap/screens/dashboard/loading.dart';
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

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

late List<CameraDescription> cameras = [];

bool isLaunchedFromCallNotification = false;
bool isAnyPageInStack = false;

// ------------------------------------------------------------
// Quick Internet Check
// ------------------------------------------------------------

Future<bool> checkInternetQuickly() async {
  try {
    final result = await InternetAddress.lookup('google.com')
        .timeout(const Duration(seconds: 3));

    return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
}

// ------------------------------------------------------------
// Main
// ------------------------------------------------------------

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Allow HTTPS certificates
  HttpOverrides.global = MyHttpOverrides();

  // ----------------------------------------------------------
  // Camera
  // ----------------------------------------------------------

  availableCameras().then((value) {
    cameras = value;
  }).catchError((e) {
    debugPrint('Camera Error: $e');
  });

  // ----------------------------------------------------------
  // Firebase
  // ----------------------------------------------------------

  try {
    await Firebase.initializeApp(
      name: AppConfigConstants.appName,
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 5));

    FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler,
    );
  } catch (e) {
    debugPrint('Firebase init bypassed/timeout: $e');
  }

  // ----------------------------------------------------------
  // Device Info
  // ----------------------------------------------------------

  DeviceInfoManager.collectDeviceInfo();

  // ----------------------------------------------------------
  // VoIP Token
  // ----------------------------------------------------------

  FlutterCallkitIncoming.getDevicePushTokenVoIP().then((token) {
    if (token != null) {
      SharedPrefs().setVoipToken(token);
    }
  }).catchError((e) {
    debugPrint('VoIP Token Error: $e');
  });

  // ----------------------------------------------------------
  // Orientation
  // ----------------------------------------------------------

  AutoOrientation.portraitAutoMode();

  // ----------------------------------------------------------
  // Theme
  // ----------------------------------------------------------

  isDarkMode = await SharedPrefs().isDarkMode();

  Get.changeThemeMode(
    isDarkMode ? ThemeMode.dark : ThemeMode.light,
  );

  // ----------------------------------------------------------
  // Controllers Registration
  // ----------------------------------------------------------

  Get.put(UsersController());
  Get.put(GiftController());
  Get.put(MiscController());
  Get.put(DashboardController());
  Get.put(UserProfileManager());
  Get.put(ClubsController());
  Get.put(PlayerManager());
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
  // Service Locator
  // ----------------------------------------------------------

  setupServiceLocator();

  final UserProfileManager userProfileManager = Get.find();
  final SettingsController settingsController = Get.find();

  // ----------------------------------------------------------
  // Background Startup Tasks
  //
  // IMPORTANT:
  // Login/profile restore is now handled by LoadingScreen.
  // This prevents race condition with isLogin.
  // ----------------------------------------------------------

  () async {
    final hasInternet = await checkInternetQuickly();

    // Database
    try {
      await getIt<DBManager>().createDatabase();
    } catch (e) {
      debugPrint('DB Creation failed: $e');
    }

    if (!hasInternet) {
      return;
    }

    // App Settings
    try {
      await settingsController.getSettings();
    } catch (e) {
      debugPrint('Settings fetch failed: $e');
    }
  }();

  // ----------------------------------------------------------
  // Notification Manager
  // ----------------------------------------------------------

  NotificationManager().initialize();

  // ----------------------------------------------------------
  // Call Notification
  // ----------------------------------------------------------

  final dynamic data =
      await SharedPrefs().getCallNotificationData();

  final bool hasNetworkForSocket =
      await checkInternetQuickly();

  if (data != null &&
      userProfileManager.user.value != null &&
      hasNetworkForSocket) {
    isLaunchedFromCallNotification = true;

    getIt<SocketManager>().connect();

    performActionOnCallNotificationBanner(
      data,
      true,
      true,
    );
  } else {
    // --------------------------------------------------------
    // Start App
    // --------------------------------------------------------

    runApp(
      Phoenix(
        child: const SocialifiedApp(
          startScreen: LoadingScreen(),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// Firebase Background Notification Handler
// ------------------------------------------------------------

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  debugPrint(
    'Handling a background message: ${message.messageId}',
  );
}

// ------------------------------------------------------------
// Socialified App
// ------------------------------------------------------------

class SocialifiedApp extends StatefulWidget {
  final Widget startScreen;

  const SocialifiedApp({
    Key? key,
    required this.startScreen,
  }) : super(key: key);

  @override
  State<SocialifiedApp> createState() => _SocialifiedAppState();
}

class _SocialifiedAppState extends State<SocialifiedApp> {
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
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GetMaterialApp(
              translations: Languages(),
              locale: snapshot.data!,
              home: widget.startScreen,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
