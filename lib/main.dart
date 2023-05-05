import 'dart:io';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:foap/screens/add_on/controller/dating/dating_controller.dart';
import 'package:foap/screens/add_on/controller/relationship/relationship_controller.dart';
import 'package:foap/screens/add_on/controller/relationship/relationship_search_controller.dart';
import 'package:foap/screens/live_users/live_users_controller.dart';
import 'package:foap/screens/settings_menu/help_support_contorller.dart';
import 'package:foap/screens/settings_menu/mercadopago_payment_controller.dart';
import 'package:get/get.dart';
import 'package:giphy_get/l10n.dart';
import 'components/reply_chat_cells/post_gift_controller.dart';
import 'controllers/faq_controller.dart';
import 'package:foap/screens/add_on/controller/reel/create_reel_controller.dart';
import 'package:foap/screens/add_on/controller/reel/reels_controller.dart';
import 'package:foap/screens/dashboard/dashboard_screen.dart';
import 'package:foap/screens/login_sign_up/splash_screen.dart';
import 'package:foap/screens/settings_menu/settings_controller.dart';
import 'package:foap/util/constant_util.dart';
import 'package:foap/util/shared_prefs.dart';
import 'package:camera/camera.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:overlay_support/overlay_support.dart';

import 'apiHandler/api_controller.dart';
import 'components/post_card_controller.dart';
import 'controllers/add_post_controller.dart';
import 'controllers/agora_call_controller.dart';
import 'controllers/agora_live_controller.dart';
import 'controllers/chat_and_call/chat_detail_controller.dart';
import 'controllers/chat_and_call/chat_history_controller.dart';
import 'controllers/chat_and_call/chat_room_detail_controller.dart';
import 'controllers/chat_and_call/select_user_group_chat_controller.dart';
import 'controllers/gift_controller.dart';
import 'controllers/home_controller.dart';
import 'controllers/live_history_controller.dart';
import 'controllers/live_tv_streaming_controller.dart';
import 'controllers/login_controller.dart';
import 'controllers/map_screen_controller.dart';
import 'controllers/podcast_streaming_controller.dart';
import 'controllers/post_controller.dart';
import 'controllers/profile_controller.dart';
import 'controllers/request_verification_controller.dart';
import 'controllers/subscription_packages_controller.dart';
import 'helper/languages.dart';
import 'manager/db_manager.dart';
import 'manager/notification_manager.dart';
import 'manager/player_manager.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();

  await Firebase.initializeApp();
  // await EasyLocalization.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: true,
      // optional: set to false to disable printing logs to console (default: true)
      ignoreSsl:
          true // option: set to false to disable working with http links (default: false)
      );
  // await CustomGalleryPermissions.requestPermissionExtend();

  final firebaseMessaging = FCM();
  await firebaseMessaging.setNotifications();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  String? token = await FlutterCallkitIncoming.getDevicePushTokenVoIP();
  if (token != null) {
    SharedPrefs().setVoipToken(token);
  }

  AutoOrientation.portraitAutoMode();

  bool isDarkTheme = await SharedPrefs().isDarkMode();
  Get.changeThemeMode(isDarkTheme ? ThemeMode.dark : ThemeMode.light);
  // Get.changeThemeMode(ThemeMode.dark);

  Get.put(PlayerManager());

  isDarkMode = await SharedPrefs().isDarkMode();
  Get.changeThemeMode(isDarkMode ? ThemeMode.dark : ThemeMode.light);


  Get.put(DashboardController());
  Get.put(UserProfileManager());
  Get.put(PlayerManager());
  Get.put(SettingsController());
  Get.put(SubscriptionPackageController());
  Get.put(AgoraCallController());
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
  Get.put(MapScreenController());
  Get.put(GiftController());
  Get.put(LiveHistoryController());
  Get.put(RequestVerificationController());
  Get.put(FAQController());
  Get.put(DatingController());
  Get.put(RelationshipController());
  Get.put(RelationshipSearchController());
  Get.put(LiveUserController());
  Get.put(PostGiftController());
  Get.put(MercadappagoPaymentController());
  Get.put(HelpSupportController());
  Get.put(PodcastStreamingController());
  Get.put(ReelsController());
  Get.put(CreateReelController());
  Get.put(SelectUserForGroupChatController());

  setupServiceLocator();
  final UserProfileManager userProfileManager = Get.find();

  await userProfileManager.refreshProfile();

  final SettingsController settingsController = Get.find();
  await settingsController.getSettings();

  NotificationManager().initialize();

  await getIt<DBManager>().createDatabase();

  if (userProfileManager.isLogin == true) {
    ApiController().updateTokens();
  }

  AwesomeNotifications().initialize(
      'resource://drawable/ic_launcher',
      [
        NotificationChannel(
          channelGroupKey: 'Calls',
          channelKey: 'calls',
          channelName: 'Calls',
          channelDescription: 'Notification channel for calls',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          locked: true,
          enableVibration: true,
          playSound: true,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: 'calls', channelGroupName: 'Calls'),
      ],
      debug: true);

  runApp(Phoenix(child: const SocialifiedApp()));
}

class SocialifiedApp extends StatefulWidget {
  const SocialifiedApp({Key? key}) : super(key: key);

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
                  // locale: const Locale('pt',/ 'BR'),
                  fallbackLocale: const Locale('en', 'US'),
                  debugShowCheckedModeBanner: false,
                  // navigatorKey: navigationKey,
                  home: const SplashScreen(),
                  builder: EasyLoading.init(),
                  // theme: AppTheme.lightTheme,
                  // darkTheme: AppTheme.darkTheme,
                  themeMode: ThemeMode.dark,
                  // localizationsDelegates: context.localizationDelegates,
                  localizationsDelegates: [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    // GlobalCupertinoLocalizations.delegate,
                    // Add this line
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
                    Locale('pt', 'BR')
                  ],
                );
              } else {
                return Container();
              }
            }));
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // await Firebase.initializeApp();

  NotificationManager().parseNotificationMessage(message);
}
