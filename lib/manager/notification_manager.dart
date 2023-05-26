import 'dart:async';
import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:foap/apiHandler/apis/chat_api.dart';
import 'package:foap/apiHandler/apis/users_api.dart';
import 'package:foap/controllers/agora_call_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/call_model.dart';
import 'package:foap/screens/chat/chat_detail.dart';
import 'package:foap/screens/profile/other_user_profile.dart';
import 'package:overlay_support/overlay_support.dart';
import '../screens/home_feed/comments_screen.dart';
import '../util/shared_prefs.dart';
import 'package:logging/logging.dart';

final logger = Logger('ExampleLogger');
final file = File('${Directory.systemTemp.path}/najem_app.log');

class FCM {
  final _firebaseMessaging = FirebaseMessaging.instance;

  // final streamCtlr = StreamController<String>.broadcast();
  // final titleCtlr = StreamController<String>.broadcast();
  // final bodyCtlr = StreamController<String>.broadcast();

  setNotifications() async {
    FirebaseMessaging.onMessage.listen(
      (message) async {
        NotificationManager().parseNotificationMessage(message);
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) async {
        Future.delayed(const Duration(seconds: 0), () {
          // handle app opened from notification
          NotificationManager().parseNotificationMessage(message);
          // add your custom code here
        });
      },
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // With this token you can test it easily on your phone
    _firebaseMessaging.getToken().then((fcmToken) {
      if (fcmToken != null) {
        SharedPrefs().setFCMToken(fcmToken);
      }
    });

    _firebaseMessaging.onTokenRefresh.listen((fcmToken) {
      SharedPrefs().setFCMToken(fcmToken);
    }).onError((err) {});
  }

// dispose() {
//   streamCtlr.close();
//   bodyCtlr.close();
//   titleCtlr.close();
// }
}

@pragma("vm:entry-point")
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // await Firebase.initializeApp();
  NotificationManager().parseNotificationMessage(message);
}

class NotificationManager {
  static final NotificationManager _singleton = NotificationManager._internal();

  factory NotificationManager() {
    return _singleton;
  }

  NotificationManager._internal();

  String? voipToken;
  String? fcmToken;

  initialize() {
    // flutterLocalNotificationsPlugin.initialize(const InitializationSettings());
    AwesomeNotifications().setListeners(
        onActionReceivedMethod:
            AwesomeNotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:
            AwesomeNotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:
            AwesomeNotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
            AwesomeNotificationController.onDismissActionReceivedMethod);
    // AwesomeNotifications().actionStream.listen((action) {
    //   AwesomeNotifications().dismissAllNotifications();
    //
    //   if (action.buttonKeyPressed == "answer") {
    //     actionOnCall(action.payload!, true);
    //   } else if (action.buttonKeyPressed == "decline") {
    //     actionOnCall(action.payload!, false);
    //   }
    // });

    // notificationHandlers();
  }

  performActionOnCallNotificationBanner(
      Map<String, String?> data, bool accept) {
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

          if (accept) {
            agoraCallController.initiateAcceptCall(call: call);
          } else {
            agoraCallController.declineCall(call: call);
          }
        });
  }

  createNotificationBannerForAndroid(Map<String?, Object?> data) {
    String message = data['body'] as String;
    int notificationType = int.parse(data['notification_type'] as String);

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        //simple notification
        id: 123,
        channelKey: 'calls',
        //set configuration with key "basic"
        title: notificationType == 1
            ? 'New Follower'
            : notificationType == 2
                ? 'New comment'
                : notificationType == 4
                    ? 'New competition added'
                    : notificationType == 100
                        ? 'New message'
                        : notificationType == 101
                            ? 'Live'
                            : '',
        body: message,
        payload: {
          "reference_id": data['reference_id'] as String,
          "body": data['body'] as String,
          "notification_type": data['notification_type'] as String,
        },
        category: NotificationCategory.Event,
        displayOnBackground: true,
        wakeUpScreen: true,
        fullScreenIntent: true,
        displayOnForeground: true,
        autoDismissible: false,
      ),
    );
  }

  createNotificationBannerForCall(Map<String?, Object?> data) {
    int notificationType = int.parse(data['notification_type'] as String);

    if (notificationType == 104) {
      //call cancelled by caller
      AwesomeNotifications().dismissAllNotifications();
    } else {
      // new call, show the notification banner to user
      String channelName = data['channelName'] as String;
      String token = data['token'] as String;
      String id = data['callType'] as String;
      String uuid = data['uuid'] as String;
      String callerId = data['callerId'] as String;
      String username = data['username'] as String;
      String callType = data['callType'] as String;

      AwesomeNotifications().createNotification(
          content: NotificationContent(
            //simple notification
            id: 123,
            channelKey: 'calls',
            //set configuration wuth key "basic"
            title: callType == '1' ? 'Audio call' : 'Video call',
            body: 'Call from $username',
            payload: {
              "channelName": channelName,
              "token": token,
              "callerId": callerId.toString(),
              "callType": callType,
              "id": id,
              "uuid": uuid
            },
            category: NotificationCategory.Call,
            displayOnBackground: true,
            wakeUpScreen: true,
            fullScreenIntent: true,
            displayOnForeground: true,
            autoDismissible: false,
          ),
          actionButtons: [
            NotificationActionButton(
              key: "answer",
              label: "Answer",
            ),
            NotificationActionButton(
              key: "decline",
              label: "Decline",
            )
          ]);
    }
  }

  parseNotificationMessage(RemoteMessage message) {
    String? callType = message.data['callType'] as String?;

    file.writeAsStringSync('${message.data.toString()} \n',
        mode: FileMode.append);

    print('file path ${file.path}');

    if (callType != null) {
      createNotificationBannerForCall(message.data);
    } else {
      if (Platform.isAndroid) {
        createNotificationBannerForAndroid(message.data);
      } else {
        FGBGEvents.stream.listen((event) {
          parseAndSwitchToCorrespondingScreen(
              message.data, event == FGBGType.foreground ? true : false);
        });
      }
    }
  }

  parseAndSwitchToCorrespondingScreen(dynamic data, bool isInForeground) {
    int notificationType =
        int.parse(data['notification_type'] as String? ?? '0');

    if (isInForeground) {
      // show banner
      if (notificationType == 1) {
        int referenceId = int.parse(data['reference_id'] as String);
        String message = data['body'];

        // following notification
        UsersApi.getOtherUser(
            userId: referenceId,
            resultCallback: (user) {
              showOverlayNotification((context) {
                return Container(
                  color: Colors.transparent,
                  child: Card(
                    color: AppColorConstants.cardColor,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: ListTile(
                      leading: UserAvatarView(
                        size: 40,
                        user: user,
                      ),
                      title: Heading5Text(
                        newFollowerString,
                        weight: TextWeight.bold,
                        color: AppColorConstants.themeColor,
                      ),
                      subtitle: Heading6Text(
                        message,
                      ),
                    ).vp(12).ripple(() {
                      OverlaySupportEntry.of(context)!.dismiss();
                      Get.to(() => OtherUserProfile(userId: referenceId));
                    }),
                  ).setPadding(top: 50, left: 8, right: 8).round(10),
                );
              }, duration: const Duration(milliseconds: 4000));
            });
      } else if (notificationType == 2) {
        int referenceId = int.parse(data['reference_id'] as String);
        String message = data['title'];

        // comment notification
        showOverlayNotification((context) {
          return Container(
            color: Colors.transparent,
            child: Card(
              color: AppColorConstants.cardColor,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: ListTile(
                title: Heading5Text(
                  newCommentString,
                  weight: TextWeight.bold,
                  color: AppColorConstants.themeColor,
                ),
                subtitle: Heading6Text(
                  message,
                ),
              ).vp(12).ripple(() {
                OverlaySupportEntry.of(context)!.dismiss();
                Get.to(() => CommentsScreen(
                      postId: referenceId,
                      handler: () {},
                      commentPostedCallback: () {},
                    ));
              }),
            ).setPadding(top: 50, left: 8, right: 8).round(10),
          );
        }, duration: const Duration(milliseconds: 4000));
      } else if (notificationType == 4) {
        // new competition added notification
      } else if (notificationType == 100) {
      } else if (notificationType == 101) {
        // int liveId = int.parse(data['liveCallId'] as String);
        // String channelName = data['channelName'];
        // String agoraToken = data['token'];
        int userId = int.parse(data['userId'] as String);
        String body = data['body'];

        UsersApi.getOtherUser(
            userId: userId,
            resultCallback: (user) {
              showOverlayNotification((context) {
                return Container(
                  color: Colors.transparent,
                  child: Card(
                    color: AppColorConstants.cardColor,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: ListTile(
                      leading: UserAvatarView(
                        size: 40,
                        user: user,
                      ),
                      title: Heading5Text(
                        liveString,
                        weight: TextWeight.bold,
                        color: AppColorConstants.themeColor,
                      ),
                      subtitle: Heading6Text(
                        body,
                      ),
                    ).vp(12).ripple(() {
                      OverlaySupportEntry.of(context)!.dismiss();

                      // Live live = Live(
                      //     channelName: channelName,
                      //     isHosting: false,
                      //     host: response.user!,
                      //     token: agoraToken,
                      //     liveId: liveId);

                      // agoraLiveController.joinAsAudience(live: live);
                    }),
                  ).setPadding(top: 50, left: 8, right: 8).round(10),
                );
              }, duration: const Duration(milliseconds: 4000));
            });
      }
    } else {
      // go to screen
      if (notificationType == 1) {
        int referenceId = int.parse(data['reference_id'] as String);
        // following notification
        Get.to(() => OtherUserProfile(userId: referenceId));
      } else if (notificationType == 2) {
        int referenceId = int.parse(data['reference_id'] as String);
        // comment notification
        Get.to(() => CommentsScreen(
              postId: referenceId,
              handler: () {},
              commentPostedCallback: () {},
            ));
      } else if (notificationType == 4) {
        int referenceId = int.parse(data['reference_id'] as String);
        // new competition added notification
        // Get.to(() => CompetitionDetailsScreen(competitionId: referenceId));
      } else if (notificationType == 100) {
        // print(data);
        int? roomId = data['room'] as int?;
        if (roomId != null) {
          ChatApi.getChatRoomDetail(roomId, resultCallback: (room) {
            Get.to(() => ChatDetail(chatRoom: room));
          });
        }
      } else if (notificationType == 101) {
        // int liveId = int.parse(data['liveCallId'] as String);
        // String channelName = data['channelName'];
        // String agoraToken = data['token'];
        int userId = int.parse(data['userId'] as String);
      }
    }
  }
}

class AwesomeNotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Your code goes here
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Your code goes here

    // Navigate into pages, avoiding to open the notification details page over another details page already opened

    AwesomeNotifications().dismissAllNotifications();
    if (receivedAction.buttonKeyPressed == "answer") {
      NotificationManager()
          .performActionOnCallNotificationBanner(receivedAction.payload!, true);
    } else if (receivedAction.buttonKeyPressed == "decline") {
      NotificationManager().performActionOnCallNotificationBanner(
          receivedAction.payload!, false);
    }
  }
}
