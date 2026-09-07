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
  cameras = await availableCameras();
  HttpOverrides.global = MyHttpOverrides();


  await Firebase.initializeApp(
    name: AppConfigConstants.appName,
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler);
  DeviceInfoManager.collectDeviceInfo();

  String? token = await FlutterCallkitIncoming.getDevicePushTokenVoIP();
  if (token != null) {
    SharedPrefs().setVoipToken(token);
  }

  AutoOrientation.portraitAutoMode();

  isDarkMode = await SharedPrefs().isDarkMode();
  Get.changeThemeMode(isDarkMode ? ThemeMode.dark : ThemeMode.light);

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

  setupServiceLocator();

  final UserProfileManager userProfileManager = Get.find();
  final SettingsController settingsController = Get.find();

  // 🚀 [ম্যাজিক ফিক্স]: কোনো Future.wait এর ঝামেলা ছাড়া ব্যাকগ্রাউন্ড আইসোলেটেড এপিআই রান করা হলো
  // এটি মেইন ইউআই থ্রেডকে একটুও ব্লক না করে ব্যাকগ্রাউন্ডে স্বাধীনভাবে কাজ শেষ করবে।
  () async {
    try {
      String? authKey = await SharedPrefs().getAuthorizationKey();
      if (authKey != null) {
        userProfileManager.refreshProfile().catchError((e) => print("Profile refresh failed: $e"));
      }
    } catch (e) {
      print("Auth key read failed: $e");
    }
    
    settingsController.getSettings().catchError((e) => print("Settings fetch failed: $e"));
    getIt<DBManager>().createDatabase().catchError((e) => print("DB Creation failed: $e"));
  }(); // 👈 এই ব্র্যাকেটের মাধ্যমে ফাংশনটি সাথে সাথে ব্যাকগ্রাউন্ডে চালু হয়ে যাবে

  NotificationManager().initialize();
  
  if (userProfileManager.isLogin == true) {
    AuthApi.updateFcmToken();
  }

  dynamic data = await SharedPrefs().getCallNotificationData();

  if (data != null && userProfileManager.user.value != null) {
    isLaunchedFromCallNotification = true;
    getIt<SocketManager>().connect();
    performActionOnCallNotificationBanner(data, true, true);
  } else {
    // ⚡ এখন অ্যাপটি ১-২ সেকেন্ডের মধ্যে ইনস্ট্যান্ট ওপেন হবে এবং স্প্ল্যাশ স্ক্রিন চলে আসবে
    runApp(Phoenix(
        child: const SocialifiedApp(
      startScreen: SplashScreen(),
    )));
  }
}

class SocialifiedApp extends StatefulWidget {
  final Widget startScreen;

  const SocialifiedApp({Key? key, required this.startScreen})
      : super(key: key);

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
                  home: widget.startScreen,
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
Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  print('message.data ${message.data}');
  Get.put(DashboardController());
  Get.put(UserProfileManager());
  Get.put(SettingsController());
  Get.put(AgoraCallController());
  Get.put(VoipController());

  NotificationManager().parseNotificationMessage(message.data);
}
