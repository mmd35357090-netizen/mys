import 'dart:io';
import 'dart:async'; // 👈 টাইমআউট সেফটির জন্য যুক্ত করা হলো
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

late List<CameraDescription> cameras = []; // 👈 ইনিশিয়ালি খালি লিস্ট দিয়ে ক্র্যাশ আটকাতে হবে
bool isLaunchedFromCallNotification = false;
bool isAnyPageInStack = false;

// ⚡ নেটওয়ার্ক জ্যামের জন্য ৩ সেকেন্ডের ফাস্ট ইন্টারনেট চেকার
Future<bool> checkInternetQuickly() async {
  try {
    final result = await InternetAddress.lookup('google.com')
        .timeout(const Duration(seconds: 3));
    return result.isNotEmpty && result.rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
}

Future<void> main() async {
  // নিশ্চিত করুন ফ্লাটার ইঞ্জিন রেডি
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  // 1️⃣ ক্যামেরা হার্ডওয়্যারকে ব্যাকগ্রাউন্ডে ঠেলে দেওয়া হলো, মেইন থ্রেড ব্লক হবে না
  availableCameras().then((val) => cameras = val).catchError((e) => print("Camera Error: $e"));

  // 2️⃣ ফায়ারবেসকে মেইন থ্রেড ব্লক করা থেকে আটকাতে ৫ সেকেন্ডের সেফটি টাইমআউট দেওয়া হলো
  try {
    await Firebase.initializeApp(
      name: AppConfigConstants.appName,
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 5));
    
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    print("Firebase init bypassed due to network/timeout: $e");
  }

  DeviceInfoManager.collectDeviceInfo();

  // ৩. নোটিফিকেশন টোকেন প্রসেস
  FlutterCallkitIncoming.getDevicePushTokenVoIP().then((token) {
    if (token != null) SharedPrefs().setVoipToken(token);
  }).catchError((e) => print("VoIP Token Error: $e"));

  AutoOrientation.portraitAutoMode();

  isDarkMode = await SharedPrefs().isDarkMode();
  Get.changeThemeMode(isDarkMode ? ThemeMode.dark : ThemeMode.light);

  // 🔹 GetX Controllers ডিপেন্ডেন্সি ইনজেকশন (সিনক্রোনাস, ইনস্ট্যান্ট রান হয়)
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

  // 4️⃣ এপিআই কলগুলোকে গার্ড (Guard) ক্লজ দিয়ে প্রোটেক্ট করা হলো যাতে অফলাইনে অ্যাপ না ঝোলে
  () async {
    bool hasInternet = await checkInternetQuickly();
    
    // লোকাল ডাটাবেজ ক্রিয়েশন (ইন্টারনেট লাগে না)
    getIt<DBManager>().createDatabase().catchError((e) => print("DB Creation failed: $e"));

    if (hasInternet) {
      try {
        String? authKey = await SharedPrefs().getAuthorizationKey();
        if (authKey != null) {
          userProfileManager.refreshProfile().catchError((e) => print("Profile refresh failed: $e"));
        }
      } catch (e) {
        print("Auth key read failed: $e");
      }
      
      settingsController.getSettings().catchError((e) => print("Settings fetch failed: $e"));
      
      if (userProfileManager.isLogin == true) {
        AuthApi.updateFcmToken();
      }
    } else {
      print("Offline mode detected. Skipping background network requests.");
    }
  }();

  NotificationManager().initialize();

  // ৫. নোটিফিকেশন থেকে অ্যাপ ওপেন হয়েছে কি না চেক
  dynamic data = await SharedPrefs().getCallNotificationData();
  bool hasNetworkForSocket = await checkInternetQuickly();

  if (data != null && userProfileManager.user.value != null && hasNetworkForSocket) {
    isLaunchedFromCallNotification = true;
    getIt<SocketManager>().connect();
    performActionOnCallNotificationBanner(data, true, true);
  } else {
    // ⚡ [ম্যাজিক লাইন]: সব কাজ ব্যাকগ্রাউন্ড আইসোলেশনে দিয়ে সাথে সাথে UI চালু করে দেওয়া হলো!
    runApp(Phoenix(
        child: const SocialifiedApp(
      startScreen: SplashScreen(),
    )));
  }
}

class SocialifiedApp extends StatefulWidget {
  final Widget startScreen;
  const SocialifiedApp({Key? key, required this.startScreen}) : super(key: key);

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
            }));
  }
}
