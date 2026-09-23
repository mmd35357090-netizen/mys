import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:foap/api_handler/apis/auth_api.dart';
import 'package:foap/controllers/auth/login_controller.dart';
import 'package:foap/controllers/chat_and_call/agora_call_controller.dart';
import 'package:foap/controllers/chat_and_call/chat_detail_controller.dart';
import 'package:foap/controllers/chat_and_call/chat_history_controller.dart';
import 'package:foap/controllers/chat_and_call/chat_room_detail_controller.dart';
import 'package:foap/controllers/chat_and_call/select_user_group_chat_controller.dart';
import 'package:foap/controllers/clubs/clubs_controller.dart';
import 'package:foap/controllers/home/home_controller.dart';
import 'package:foap/controllers/live/agora_live_controller.dart';
import 'package:foap/controllers/live/live_history_controller.dart';
import 'package:foap/controllers/live/live_users_controller.dart';
import 'package:foap/controllers/misc/faq_controller.dart';
import 'package:foap/controllers/misc/gift_controller.dart';
import 'package:foap/controllers/misc/map_screen_controller.dart';
import 'package:foap/controllers/misc/misc_controller.dart';
import 'package:foap/controllers/misc/request_verification_controller.dart';
import 'package:foap/controllers/misc/subscription_packages_controller.dart';
import 'package:foap/controllers/misc/users_controller.dart';
import 'package:foap/controllers/notification/notifications_controller.dart';
import 'package:foap/controllers/podcast/podcast_streaming_controller.dart';
import 'package:foap/controllers/post/add_post_controller.dart';
import 'package:foap/controllers/post/post_controller.dart';
import 'package:foap/controllers/profile/profile_controller.dart';
import 'package:foap/controllers/story/highlights_controller.dart';
import 'package:foap/controllers/story/story_controller.dart';
import 'package:foap/controllers/tv/live_tv_streaming_controller.dart';
import 'package:foap/helper/device_info.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/reel_imports.dart';
import 'package:foap/helper/languages.dart';
import 'package:foap/manager/db_manager.dart';
import 'package:foap/manager/location_manager.dart';
import 'package:foap/manager/notification_manager.dart';
import 'package:foap/manager/player_manager.dart';
import 'package:foap/manager/socket_manager.dart';
import 'package:foap/screens/dashboard/loading.dart';
import 'package:foap/util/constant_util.dart';
import 'package:foap/util/shared_prefs.dart';
import 'package:foap/screens/settings_menu/settings_controller.dart';
import 'package:overlay_support/overlay_support.dart';

import 'components/giphy/src/l10n/l10n.dart';
import 'components/post_card_controller.dart';
import 'components/reply_chat_cells/post_gift_controller.dart';
import 'components/smart_text_field.dart';
import 'components/post_gift_controller.dart';
import 'components/reply_chat_cells/post_gift_controller.dart';
import 'components/smart_text_field.dart';
import 'controllers/chat_and_call/voip_controller.dart';
import 'firebase_options.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/login_sign_up/ask_to_follow.dart';
import 'screens/post/content_creator_view.dart';
import 'screens/settings_menu/help_support_contorller.dart';
import 'screens/settings_menu/mercadopago_payment_controller.dart';
import 'screens/settings_menu/settings_controller.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

late List<CameraDescription> cameras;

bool isLaunchedFromCallNotification = false;
bool isAnyPageInStack = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HttpOverrides.global = MyHttpOverrides();

  // ----------------------------------------------------------
  // Camera
  // ----------------------------------------------------------

  cameras = await availableCameras();

  // ----------------------------------------------------------
  // Firebase
  // ----------------------------------------------------------

  await Firebase.initializeApp(
    name: AppConfigConstants.appName,
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  // ----------------------------------------------------------
  // Device information
  // ----------------------------------------------------------

  DeviceInfoManager.collectDeviceInfo();
// ----------------------------------------------------------
// VoIP token
// ----------------------------------------------------------

try {
  final token =
      await FlutterCallkitIncoming.getDevicePushTokenVoIP();

  if (token != null && token.isNotEmpty) {
    SharedPrefs().setVoipToken(token);
  }
} catch (e) {
  debugPrint('VoIP token error: $e');
}
  // ----------------------------------------------------------
  // Orientation
  // ----------------------------------------------------------

  AutoOrientation.portraitAutoMode();

  // ----------------------------------------------------------
  // Theme
  // ----------------------------------------------------------

  try {
    isDarkMode = await SharedPrefs().isDarkMode();

    Get.changeThemeMode(
      isDarkMode ? ThemeMode.dark : ThemeMode.light,
    );
  } catch (e) {
    debugPrint('Theme initialization failed: $e');
  }

  // ----------------------------------------------------------
  // Controllers
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
  // Service locator
  // ----------------------------------------------------------

  setupServiceLocator();

  // ----------------------------------------------------------
  // Notification manager
  // ----------------------------------------------------------

  NotificationManager().initialize();

  // ----------------------------------------------------------
  // IMPORTANT:
  // Do NOT refresh profile here.
  // Do NOT load settings here.
  // Do NOT create database here.
  //
  // LoadingScreen will handle those operations.
  // ----------------------------------------------------------

  runApp(
    Phoenix(
      child: const SocialifiedApp(
        startScreen: LoadingScreen(),
      ),
    ),
  );
}

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
              fallbackLocale: const Locale('en', 'US'),
              debugShowCheckedModeBanner: false,
              home: widget.startScreen,
              builder: EasyLoading.init(),
              themeMode: ThemeMode.dark,
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GiphyGetUILocalizations.delegate,
              ],
              supportedLocales: const <Locale>[
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

          return const Material(
            child: SizedBox.expand(),
          );
        },
      ),
    );
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {
  debugPrint('message.data ${message.data}');

  NotificationManager().parseNotificationMessage(
    message.data,
  );
}