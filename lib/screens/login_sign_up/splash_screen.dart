import 'dart:io';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:camera/camera.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:foap/api_handler/apis/auth_api.dart';

// আপনার প্রোজেক্টের বাকি ইমপোর্টগুলো (প্রয়োজন হলে এগুলো রাখবেন)
import '../../controllers/live/live_users_controller.dart';
import '../../helper/imports/reel_imports.dart';
import '../../screens/login_sign_up/ask_to_follow.dart';
import '../../screens/post/content_creator_view.dart';
import '../../screens/settings_menu/help_support_contorller.dart';
import '../../screens/settings_menu/mercadopago_payment_controller.dart';
import '../../util/constant_util.dart';
import 'components/giphy/src/l10n/l10n.dart';
import 'components/reply_chat_cells/post_gift_controller.dart';
import 'components/smart_text_field.dart';
import 'controllers/chat_and_call/voip_controller.dart';
import 'controllers/clubs/clubs_controller.dart';
import 'controllers/misc/faq_controller.dart';
import 'package:foap/screens/dashboard/dashboard_screen.dart';
import 'package:foap/screens/settings_menu/settings_controller.dart';
import 'package:foap/util/shared_prefs.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
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
import '../dashboard/loading.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  List<String> bgImages = [
    'assets/tutorial1.jpg',
    'assets/tutorial2.jpg',
    'assets/tutorial3.jpg',
    'assets/tutorial4.jpg'
  ];

  @override
  void initState() {
    super.initState();
    startAppInitialization();
  }

  Future<void> startAppInitialization() async {
    try {
      cameras = await availableCameras();
    } catch (e) {
      print("Camera hardware error: $e");
    }

    try {
      await Firebase.initializeApp(
        name: AppConfigConstants.appName,
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(const Duration(seconds: 5));
      
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } catch (e) {
      print("Firebase setup bypassed/timed out: $e");
    }

    DeviceInfoManager.collectDeviceInfo();
    String? token = await FlutterCallkitIncoming.getDevicePushTokenVoIP();
    if (token != null) {
      SharedPrefs().setVoipToken(token);
    }

    initializeAllControllers();
    setupServiceLocator();
    NotificationManager().initialize();

    final UserProfileManager userProfileManager = Get.find();
    final SettingsController settingsController = Get.find();

    bool hasInternet = await _quickInternetCheck();
    getIt<DBManager>().createDatabase().catchError((e) => print("DB Error: $e"));

    if (hasInternet) {
      String? authKey = await SharedPrefs().getAuthorizationKey();
      if (authKey != null) {
        userProfileManager.refreshProfile().catchError((e) => print(e));
      }
      settingsController.getSettings().catchError((e) => print(e));
      if (userProfileManager.isLogin == true) {
        AuthApi.updateFcmToken();
      }
    }

    dynamic data = await SharedPrefs().getCallNotificationData();
    
    // ক্যারোজেলটি মিনিমাম ৩ সেকেন্ড দেখাবে, এর মাঝে ব্যাকগ্রাউন্ড লোড শেষ হবে
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    if (data != null && userProfileManager.user.value != null && hasInternet) {
      isLaunchedFromCallNotification = true;
      getIt<SocketManager>().connect();
      performActionOnCallNotificationBanner(data, true, true);
    } else {
      Get.offAll(() => const LoadingScreen());
    }
  }

  Future<bool> _quickInternetCheck() async {
    try {
      final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void initializeAllControllers() {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Stack(
          children: [
            CarouselSlider(
              items: [
                for (String image in bgImages)
                  Image.asset(
                    image,
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                  )
              ],
              options: CarouselOptions(
                autoPlayInterval: const Duration(seconds: 1),
                autoPlay: true,
                enlargeCenterPage: false,
                enableInfiniteScroll: true,
                height: double.infinity,
                viewportFraction: 1,
                onPageChanged: (index, reason) {},
              ),
            ),
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  stops: const [0.1, 0.3, 0.6, 0.9],
                  colors: [
                    AppColorConstants.backgroundColor.withOpacity(0.9),
                    AppColorConstants.backgroundColor.lighten().withOpacity(0.9),
                    AppColorConstants.backgroundColor.lighten().withOpacity(0.5),
                    AppColorConstants.themeColor.withOpacity(0.5),
                  ],
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/spash_logo.png',
                    height: 120,
                    width: 120,
                  ),
                  const SizedBox(height: 10),
                  BodyLargeText(
                    AppConfigConstants.appName,
                    weight: TextWeight.medium
                  ),
                  Heading6Text(
                    AppConfigConstants.appTagline.tr,
                  ),
                ],
              ).bp(200),
            ),
          ],
        ));
  }
}
