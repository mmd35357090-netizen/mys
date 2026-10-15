import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:foap/api_handler/apis/auth_api.dart';

// import 'package:foap/components/auto_orientation/auto_orientation.dart';
import 'package:foap/controllers/fund_raising/fund_raising_controller.dart';
import 'package:foap/controllers/job/job_controller.dart';
import 'package:foap/controllers/shop/shop_controller.dart';
import 'package:foap/controllers/story/highlights_controller.dart';
import 'package:foap/helper/device_info.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:foap/screens/add_on/controller/dating/dating_controller.dart';
import 'package:foap/screens/add_on/controller/event/checkout_controller.dart';
import 'package:foap/screens/add_on/controller/event/create_event/add_event_controller.dart';
import 'package:foap/screens/add_on/controller/event/create_event/my_event_detail_controller.dart';
import 'package:foap/screens/add_on/controller/event/create_event/my_events_controller.dart';
import 'package:foap/screens/add_on/controller/event/event_controller.dart';
import 'package:foap/controllers/live/live_users_controller.dart';
import 'package:foap/screens/content_creator_view.dart';
import 'package:foap/screens/dashboard/loading.dart';
import 'package:foap/screens/login_sign_up/ask_to_follow.dart';
import 'package:foap/screens/popups/ask_location_permission.dart';
import 'package:foap/screens/settings_menu/help_support_contorller.dart';
import 'package:giphy_get/l10n.dart';
import 'components/smart_text_field.dart';
import 'controllers/notification/notifications_controller.dart';
import 'controllers/clubs/clubs_controller.dart';
import 'controllers/coupons/near_by_offers.dart';
import 'controllers/misc/faq_controller.dart';
import 'package:foap/screens/add_on/controller/reel/create_reel_controller.dart';
import 'package:foap/screens/add_on/controller/reel/reels_controller.dart';
import 'package:foap/screens/dashboard/dashboard_screen.dart';
import 'package:foap/screens/settings_menu/settings_controller.dart';
import 'package:foap/util/constant_util.dart';
import 'package:foap/util/shared_prefs.dart';
import 'package:camera/camera.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:overlay_support/overlay_support.dart';

import 'components/post_card_controller.dart';
import 'controllers/misc/gift_controller.dart';
import 'controllers/misc/misc_controller.dart';
import 'controllers/misc/users_controller.dart';
import 'controllers/post/add_post_controller.dart';
import 'controllers/chat_and_call/agora_call_controller.dart';
import 'controllers/live/agora_live_controller.dart';
import 'controllers/chat_and_call/chat_detail_controller.dart';
import 'controllers/chat_and_call/chat_history_controller.dart';
import 'controllers/chat_and_call/chat_room_detail_controller.dart';
import 'controllers/chat_and_call/select_user_group_chat_controller.dart';
import 'controllers/home/home_controller.dart';
import 'controllers/live/live_history_controller.dart';
import 'controllers/post/promotion_controller.dart';
import 'controllers/post/saved_post_controller.dart';
import 'controllers/profile/other_user_profile_controller.dart';
import 'controllers/story/story_controller.dart';
import 'controllers/subscription/subscription_controller.dart';
import 'controllers/tv/live_tv_streaming_controller.dart';
import 'controllers/auth/login_controller.dart';
import 'controllers/misc/map_screen_controller.dart';
import 'controllers/podcast/podcast_streaming_controller.dart';
import 'controllers/post/post_controller.dart';
import 'controllers/profile/profile_controller.dart';
import 'controllers/misc/request_verification_controller.dart';
import 'controllers/misc/subscription_packages_controller.dart';
import 'helper/languages.dart';
import 'manager/db_manager_realm.dart';
import 'manager/deep_link_manager.dart';
import 'manager/location_manager.dart';
import 'manager/notification_manager.dart';
import 'manager/player_manager.dart';
import 'manager/socket_manager.dart';
import 'firebase_options.dart';

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
bool isPermissionsAsked = false;

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

  isPermissionsAsked = await SharedPrefs().getTutorialSeen();

  DeepLinkManager.init();

  isDarkMode = await SharedPrefs().isDarkMode();
  Get.changeThemeMode(isDarkMode ? ThemeMode.dark : ThemeMode.light);
  Get.put(PlayerManager());
  Get.put(UsersController());
  Get.put(EventsController());
  Get.put(ClubsController());
  Get.put(GiftController());
  Get.put(MiscController());
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
  Get.put(OtherUserProfileController());
  Get.put(ChatHistoryController());
  Get.put(ChatRoomDetailController());
  Get.put(TvStreamingController());
  Get.put(LocationManager());
  Get.put(MapScreenController());
  Get.put(LiveHistoryController());
  Get.put(RequestVerificationController());
  Get.put(FAQController());
  Get.put(DatingController());
  Get.put(LiveUserController());
  Get.put(HelpSupportController());
  Get.put(PodcastStreamingController());
  Get.put(ReelsController());
  Get.put(CreateReelController());
  Get.put(SelectUserForGroupChatController());
  Get.put(FundRaisingController());
  Get.put(NearByOffersController());
  Get.put(PromotionController());
  Get.put(AppStoryController());
  Get.put(SavedPostController());
  Get.put(ShopController());
  Get.put(JobController());
  Get.put(SmartTextFieldController());
  Get.put(CheckoutController());
  Get.put(CameraControllerService());
  Get.put(HighlightsController());
  Get.put(NotificationController());
  Get.put(UserSubscriptionController());
  Get.put(MyEventsController());
  Get.put(AddEventController());
  Get.put(MyEventDetailController());

  setupServiceLocator();

  final UserProfileManager userProfileManager = Get.find();
  await userProfileManager.refreshProfile();

  final SettingsController settingsController = Get.find();
  await settingsController.getSettings();

  await getIt<RealmDBManager>().openDatabase();

  NotificationManager().initialize();
  if (userProfileManager.isLogin == true) {
    AuthApi.updateFcmToken();
    final NotificationController notificationController = Get.find();
    notificationController.getNotificationInfo();
  }

  dynamic data = await SharedPrefs().getCallNotificationData();

  if (data != null && userProfileManager.user.value != null) {
    isLaunchedFromCallNotification = true;
    getIt<SocketManager>().connect();
    performActionOnCallNotificationBanner(data, true, true);
  } else {
    runApp(Phoenix(
        child: SocialifiedApp(
      startScreen: AppConfigConstants.askForFollow
          ? AskToFollow()
          : isPermissionsAsked == false
              ? const AskLocationPermission()
              : const LoadingScreen(),
    )));
  }
}

class SocialifiedApp extends StatefulWidget {
  final Widget startScreen;

  const SocialifiedApp({super.key, required this.startScreen});

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
                  builder: EasyLoading.init(),
                  locale: snapshot.data!,
                  fallbackLocale: const Locale('en', 'US'),
                  debugShowCheckedModeBanner: false,
                  home: widget.startScreen,
                  themeMode: ThemeMode.dark,
                  localizationsDelegates: [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
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
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  NotificationManager().parseForegroundNotificationMessage(message.data);
}
