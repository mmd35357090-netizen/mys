import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:foap/api_handler/apis/chat_api.dart';
import 'package:foap/api_handler/apis/users_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/post_imports.dart';
import 'package:foap/model/account.dart';
import 'package:foap/model/call_model.dart';
import 'package:foap/screens/chat/chat_detail.dart';
import 'package:foap/screens/profile/other_user_profile.dart';
import 'package:overlay_support/overlay_support.dart';
import '../controllers/chat_and_call/agora_call_controller.dart';
import '../controllers/live/agora_live_controller.dart';
import '../main.dart';
import '../model/live_model.dart';
import '../screens/calling/accept_call.dart';
import '../screens/competitions/competition_detail_screen.dart';
import '../screens/home_feed/comments_screen.dart';
import '../screens/profile/follow_requests.dart';
import '../screens/settings_menu/notifications.dart';
import '../util/shared_prefs.dart';

class NotificationManager {
  static final NotificationManager _singleton =
      NotificationManager._internal();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final _firebaseMessaging = FirebaseMessaging.instance;

  factory NotificationManager() {
    return _singleton;
  }

  NotificationManager._internal();

  initializeFCM() async {
    await FirebaseMessaging.instance.requestPermission();

    FirebaseMessaging.onMessage.listen(
      (message) async {
        parseForegroundNotificationMessage(message.data);
      },
    );
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) async {
        handleNotificationTap(message.data, false);
      },
    );
    // With this token you can test it easily on your phone
    _firebaseMessaging.getToken().then((fcmToken) {
      if (fcmToken != null) {
        SharedPrefs().setFCMToken(fcmToken);
      }
    });

    _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    _firebaseMessaging.onTokenRefresh.listen((fcmToken) {
      SharedPrefs().setFCMToken(fcmToken);
    }).onError((err) {});
  }

  initialize() async {
    initializeFCM();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    var initializationSettings = const InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin
        .initialize(initializationSettings,
            onDidReceiveNotificationResponse: (response) {
      handleNotificationActionFromAndroidLocalNotifications(response);
    },
            onDidReceiveBackgroundNotificationResponse:
                notificationTapBackground);
  }

  parseForegroundNotificationMessage(Map<String?, Object?> message) {
    String? callType = message['callType'] as String?;

    if (callType != null) {
      showHideCallNotificationsOnAndroid(message);
    } else if (!Get.isRegistered<UserProfileManager>()) {
      // Running in the background isolate (app closed / in background): GetX and the UI
      // do not exist there. The system already shows the notification, so do nothing.
      return;
    } else {
      // if (Platform.isAndroid) {
      //   // handleAndroidNotifications(message);
      // } else {
      //   FGBGEvents.stream.listen((event) {
      //     handleSimpleNotificationBannerTap(
      //         message, event == FGBGType.foreground ? true : false);
      //   });
      // }
      handleForegroundNotifications(message);
    }
  }

  showHideCallNotificationsOnAndroid(Map<String?, Object?> data) async {
    int notificationType = int.parse(data['notification_type'] as String);

    if (notificationType == 104) {
      flutterLocalNotificationsPlugin.cancelAll();
    } else {
      // new call
      String channelName = data['channelName'] as String;
      String token = data['token'] as String;
      String id = data['callType'] as String;
      String uuid = data['uuid'] as String;
      String callerId = data['callerId'] as String;
      String username = data['username'] as String;
      String callType = data['callType'] as String;

      var acceptAction = const AndroidNotificationAction(
        'accept_action', // ID of the action
        'Accept', // Title of the action
        showsUserInterface: true,
        // icon: 'accept_icon', // Optional: Icon name for Android (located in the drawable folder)
        // onPressed: _acceptCall, // Callback when the action is pressed
      );

      var declineAction = const AndroidNotificationAction(
        'decline_action',
        'Decline',
        showsUserInterface: true,
        // icon: 'decline_icon', // Optional: Icon name for Android (located in the drawable folder)
        // onPressed: _declineCall,
      );

      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'call_channel_id', 'call_notification',
        priority: Priority.max,
        category: AndroidNotificationCategory.call,
        importance: Importance.max,
        fullScreenIntent: true,

        actions: [
          acceptAction,
          declineAction
        ], // Add the actions to the notification
      );
      NotificationDetails notificationDetails =
          NotificationDetails(android: androidNotificationDetails);
      await flutterLocalNotificationsPlugin.show(
          0,
          callType == '1' ? 'Audio call' : 'Video call',
          'Call from $username',
          notificationDetails,
          payload: jsonEncode({
            "channelName": channelName,
            "token": token,
            "callerId": callerId.toString(),
            "callType": callType,
            "id": id,
            "uuid": uuid
          }));
    }
  }

  handleNotificationActionFromAndroidLocalNotifications(
      NotificationResponse response) {
    var payload = jsonDecode(response.payload!);
    String? callType = payload['callType'] as String?;
    if (callType != null) {
      if (response.actionId == 'accept_action') {
        performActionOnCallNotificationBanner(
            jsonDecode(response.payload!), true, false);
      } else if (response.actionId == 'decline_action') {
        performActionOnCallNotificationBanner(
            jsonDecode(response.payload!), false, false);
      } else {
        performActionOnCallNotificationBanner(
            jsonDecode(response.payload!), false, true);
      }
    } else {
      // handle this tap once. (Listening forever made every earlier tap run
      // again on each return from the background.)
      final dynamic tapData = jsonDecode(response.payload!);
      handleNotificationTap(tapData, false);
    }
  }

  /// Notification that started the app from the closed state. It is handled once the
  /// home screen is ready (see [handleLaunchNotification]).
  static Map<String, dynamic>? launchData;

  /// Waits (max ~25 s) until the user is logged in and the first screen is shown,
  /// then opens the page the notification points to.
  Future<void> handleLaunchNotification(Map<String, dynamic> data) async {
    // Wait (max ~60 s: biometric / slow network) until the Dashboard is really on top.
    // The loading screen does Get.offAll(Dashboard), which would wipe a page opened earlier.
    bool ready = false;
    for (int i = 0; i < 120; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      try {
        if (Get.isRegistered<UserProfileManager>() &&
            Get.find<UserProfileManager>().user.value != null &&
            Get.key.currentState != null &&
            Get.currentRoute.contains('DashboardScreen')) {
          ready = true;
          break;
        }
      } catch (_) {}
    }
    if (!ready) return;
    await Future.delayed(const Duration(milliseconds: 800));
    await handleNotificationTap(data, false);
  }

  handleNotificationTap(dynamic data, bool isInForeground) async {
    try {
      await _handleNotificationTap(data, isInForeground);
    } catch (e) {
      // a bad / incomplete notification must never crash or close the app
      debugPrint('Notification tap error: $e');
    }
  }

  _handleNotificationTap(dynamic data, bool isInForeground) async {
    if (!Get.isRegistered<AgoraLiveController>()) return;
    final AgoraLiveController agoraLiveController = Get.find();

    int notificationType =
        int.tryParse((data['notification_type'] ?? '0').toString()) ?? 0;
    // chat push always carries a room id: open that chat even if the type is missing
    if (notificationType == 0 && data['room'] != null) notificationType = 100;
    String accountId = (data['receiver_id'] ?? '').toString();
    SayHiAppAccount? account = await SharedPrefs().getAccount(accountId);

    if (isInForeground) {
      // show banner
      handleForegroundNotifications(data);
    } else {
      // go to screen
      if (notificationType == 1) {
        int referenceId = int.parse(data['reference_id'] as String);
        // following notification

        navigateFromNotification(
            widget: OtherUserProfile(userId: referenceId),
            account: account);
      } else if (notificationType == 2) {
        int referenceId = int.parse(data['reference_id'] as String);

        // comment notification
        navigateFromNotification(
            widget: CommentsScreen(
              postId: referenceId,
              handler: () {},
              commentPostedCallback: () {},
            ),
            account: account);
      } else if (notificationType == 3) {
        int referenceId = int.parse(data['reference_id'] as String);
        // comment notification

        navigateFromNotification(
            widget: SinglePostDetail(
              postId: referenceId,
            ),
            account: account);
      } else if (notificationType == 4) {
        int referenceId = int.parse(data['reference_id'] as String);
        // new competition added notification

        navigateFromNotification(
            widget: CompetitionDetailScreen(
              competitionId: referenceId,
              refreshPreviousScreen: () {},
            ),
            account: account);
      } else if (notificationType == 100) {
        int? roomId = int.tryParse((data['room'] ?? '').toString());
        if (roomId != null) {
          ChatApi.getChatRoomDetail(roomId, resultCallback: (result) {
            navigateFromNotification(
                widget: ChatDetail(chatRoom: result), account: account);
          });
        }
      } else if (notificationType == 101) {
        int liveId = int.parse(data['liveCallId'] as String);
        String channelName = data['channelName'];
        String agoraToken = data['token'];
        int userId = int.parse(data['userId'] as String);

        UsersApi.getOtherUser(
            userId: userId,
            resultCallback: (result) {
              UserProfileManager manager = Get.find();
              if (manager.user.value!.id.toString() == account?.userId) {
                LiveModel live = LiveModel();
                live.channelName = channelName;
                live.mainHostUserDetail = result;
                live.token = agoraToken;
                live.id = liveId;
                agoraLiveController.joinAsAudience(live: live);
              } else {
                if (account != null) {
                  manager.switchToAccountSilently(account, null, () {
                    LiveModel live = LiveModel();
                    live.channelName = channelName;
                    live.mainHostUserDetail = result;
                    live.token = agoraToken;
                    live.id = liveId;
                    agoraLiveController.joinAsAudience(live: live);
                  });
                }
              }
            });
      } else {
        // every other type: open its page, or the notification list as a safe default
        final Widget? page = _pageForType(notificationType, data);
        navigateFromNotification(
            widget: page ?? const NotificationsScreen(), account: account);
      }
    }
  }

  /// Page for the simple "reference_id" notification types. null = no special page.
  Widget? _pageForType(int type, dynamic data) {
    final int? ref = int.tryParse((data['reference_id'] ?? '').toString());
    switch (type) {
      case 5: // won competition
        if (ref == null) return null;
        return CompetitionDetailScreen(
            competitionId: ref, refreshPreviousScreen: () {});
      case 7: // mentioned in a post
        if (ref == null) return null;
        return SinglePostDetail(postId: ref);
      case 14: // your profile was liked
      case 16: // follow request accepted
        if (ref == null) return null;
        return OtherUserProfile(userId: ref);
      case 15: // new follow request
        return const FollowRequestList();
      default:
        return null;
    }
  }

  handleForegroundNotifications(dynamic data) async {
    try {
      await _handleForegroundNotifications(data);
    } catch (e) {
      debugPrint('Foreground notification error: $e');
    }
  }

  _handleForegroundNotifications(dynamic data) async {
    if (!Get.isRegistered<AgoraLiveController>()) return;
    int notificationType =
        int.tryParse((data['notification_type'] ?? '0').toString()) ?? 0;
    String accountId = (data['receiver_id'] ?? '').toString();
    SayHiAppAccount? account = await SharedPrefs().getAccount(accountId);
    final AgoraLiveController agoraLiveController = Get.find();

    if (notificationType == 1) {
      int referenceId = int.parse(data['reference_id'] as String);

      String message = (data['body'] ?? data['title'] ?? '').toString();

      // following notification
      UsersApi.getOtherUser(
          userId: referenceId,
          resultCallback: (result) async {
            showNotificationBanner(
                title: newFollowerString.tr,
                message: message,
                account: account,
                fromUser: result,
                navigateTo: OtherUserProfile(userId: referenceId));
          });
    } else if (notificationType == 2) {
      int referenceId = int.parse(data['reference_id'] as String);
      String message = (data['title'] ?? data['body'] ?? '').toString();
      // comment notification

      showNotificationBanner(
          title: newCommentString.tr,
          message: message,
          account: account,
          navigateTo: CommentsScreen(
            postId: referenceId,
            handler: () {},
            commentPostedCallback: () {},
          ));
    } else if (notificationType == 3) {
      // liked post notification

      int referenceId = int.parse(data['reference_id'] as String);
      String message = (data['title'] ?? data['body'] ?? '').toString();

      showNotificationBanner(
          title: newLikeString.tr,
          message: message,
          account: account,
          navigateTo: SinglePostDetail(
            postId: referenceId,
          ));
    } else if (notificationType == 4) {
      // new competition added notification
    } else if (notificationType == 100) {
    } else if (notificationType == 101) {
      int liveId = int.parse(data['liveCallId'] as String);
      String channelName = data['channelName'];
      String agoraToken = data['token'];
      int userId = int.parse(data['userId'] as String);
      String message = (data['body'] ?? data['title'] ?? '').toString();

      UsersApi.getOtherUser(
          userId: userId,
          resultCallback: (result) {
            showNotificationBanner(
                title: liveString.tr,
                message: message,
                account: account,
                callback: () {
                  LiveModel live = LiveModel();
                  live.channelName = channelName;
                  live.mainHostUserDetail = result;
                  live.token = agoraToken;
                  live.id = liveId;

                  agoraLiveController.joinAsAudience(live: live);
                });
          });
    } else if (notificationType != 100) {
      // all other types: simple banner; tap opens the page (or the notification list)
      final String title = (data['title'] ?? '').toString();
      final String message = (data['body'] ?? '').toString();
      showNotificationBanner(
          title: title,
          message: message,
          account: account,
          navigateTo:
              _pageForType(notificationType, data) ?? const NotificationsScreen());
    }
  }

  navigateFromNotification(
      {required Widget widget, required SayHiAppAccount? account}) {
    // OverlaySupportEntry.of(Get.context!)!.dismiss();
    UserProfileManager manager = Get.find();
    if (manager.user.value == null) return;
    // (account == null happens when the notification has no receiver id: just open the page)
    if (account == null || manager.user.value!.id.toString() == account.userId) {
      Get.to(() => widget);
    } else {
      if (account != null) {
        manager.switchToAccountSilently(account, widget, () {});
      }
    }
  }

  showNotificationBanner(
      {required String title,
      required String message,
      required SayHiAppAccount? account,
      UserModel? fromUser,
      Widget? navigateTo,
      VoidCallback? callback}) async {
    showOverlayNotification((context) {
      return Container(
        color: Colors.transparent,
        child: Container(
          color: AppColorConstants.cardColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (account != null)
                BodyLargeText(
                  account.username,
                  weight: TextWeight.bold,
                  color: AppColorConstants.themeColor,
                ),
              Row(
                children: [
                  if (fromUser != null)
                    Row(
                      children: [
                        UserAvatarView(
                          size: 30,
                          user: fromUser,
                        ),
                        const SizedBox(width: 10)
                      ],
                    ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BodyLargeText(
                          title,
                          weight: TextWeight.bold,
                          // color: AppColorConstants.themeColor,
                        ),
                        BodySmallText(
                          message,
                        )
                      ])
                ],
              )
            ],
          ).setPadding(top: 10, left: 8, right: 8, bottom: 10),
        )
            .round(10)
            .setPadding(top: 50, left: 8, right: 8)
            .ripple(() async {
          if (callback != null) {
            callback();
          } else {
            navigateFromNotification(
                widget: navigateTo!, account: account);
          }
        }),
      );
    }, duration: const Duration(milliseconds: 4000));
  }
}

performActionOnCallNotificationBanner(
    Map<String, dynamic> data, bool accept, bool askConfirmation) {
  final AgoraCallController agoraCallController = Get.find();
  String channelName = data['channelName'] as String;
  String token = data['token'] as String;
  String callType = data['callType'] as String;
  String id = data['id'] as String;
  String uuid = data['uuid'] as String;
  String callerId = data['callerId'] as String;

  UsersApi.getOtherUser(
      userId: int.parse(callerId),
      resultCallback: (user) {
        Call call = Call(
            uuid: uuid,
            channelName: channelName,
            isOutGoing: true,
            opponent: user,
            token: token,
            callType: int.parse(callType),
            callId: int.parse(id));

        if (askConfirmation) {
          if (Get.context == null) {
            // app was closed: after this call ends, go to the home screen (nothing is behind it)
            isLaunchedFromCallNotification = true;
            runApp(Phoenix(
                child: SocialifiedApp(
              startScreen: AcceptCallScreen(
                call: call,
              ),
            )));
          } else {
            Get.to(() => AcceptCallScreen(
                  call: call,
                ));
          }
        } else {
          if (accept) {
            agoraCallController.initiateAcceptCall(call: call);
          } else {
            agoraCallController.declineCall(call: call);
          }
        }
      });
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // handle action

  if (notificationResponse.actionId == 'accept_action') {
    performActionOnCallNotificationBanner(
        jsonDecode(notificationResponse.payload!), true, false);
  } else if (notificationResponse.actionId == 'decline_action') {
    performActionOnCallNotificationBanner(
        jsonDecode(notificationResponse.payload!), false, false);
  } else {
    performActionOnCallNotificationBanner(
        jsonDecode(notificationResponse.payload!), false, true);
  }
}
