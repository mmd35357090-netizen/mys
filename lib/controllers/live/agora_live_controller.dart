import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:foap/apiHandler/apis/gift_api.dart';
import 'package:foap/apiHandler/apis/users_api.dart';
import 'package:foap/controllers/subscription_packages_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/live_imports.dart';
import 'package:foap/helper/string_extension.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock/wakelock.dart';

import '../../helper/permission_utils.dart';
import '../../manager/socket_manager.dart';
import '../../model/call_model.dart';
import '../../model/chat_message_model.dart';
import '../../model/gift_model.dart';
import '../../model/package_model.dart';
import '../../screens/settings_menu/settings_controller.dart';
import '../../util/ad_helper.dart';
import '../../util/constant_util.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class AgoraLiveController extends GetxController {
  final SubscriptionPackageController packageController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  Rx<TextEditingController> messageTf = TextEditingController().obs;
  RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  RxList<ReceivedGiftModel> giftsReceived = <ReceivedGiftModel>[].obs;

  RxInt remoteUserId = 0.obs;
  Rx<GiftModel?> sendingGift = Rx<GiftModel?>(null);

  RxList<String> infoStrings = <String>[].obs;
  RtcEngine? engine;
  late int liveId;
  late String localLiveId;

  RxList<UserModel> currentJoinedUsers = <UserModel>[].obs;
  RxList<UserModel> allJoinedUsers = <UserModel>[].obs;

  UserModel? host;

  RxInt canLive = 0.obs;
  String? errorMessage;

  RxBool askLiveEndConformation = false.obs;

  RxBool isFront = false.obs;
  RxBool reConnectingRemoteView = false.obs;
  RxBool mutedAudio = false.obs;
  RxBool mutedVideo = false.obs;
  RxBool videoPaused = false.obs;
  RxBool liveEnd = false.obs;

  DateTime? liveStartTime;
  DateTime? liveEndTime;
  final SettingsController _settingsController = Get.find();

  int giftsPage = 1;
  bool canLoadMoreGifts = true;
  RxBool isLoadingGifts = false.obs;

  String get liveTime {
    int totalSeconds = liveEndTime!.difference(liveStartTime!).inSeconds;
    int h, m, s;

    h = totalSeconds ~/ 3600;

    m = ((totalSeconds - h * 3600)) ~/ 60;

    s = totalSeconds - (h * 3600) - (m * 60);

    if (h > 0) {
      return "${h}h:${m}m:${s}s";
    } else if (m > 0) {
      return "${m}m:${s}s";
    }

    return "$s sec";
  }

  int get totalCoinsEarned {
    if (giftsReceived.isNotEmpty) {
      return giftsReceived
          .map((element) => element.giftDetail.coins)
          .reduce((a, b) => a + b);
    } else {
      return 0;
    }
  }

  clear() {
    isFront.value = false;
    reConnectingRemoteView.value = false;
    mutedAudio.value = false;
    mutedVideo.value = false;
    videoPaused.value = false;
    liveEnd.value = false;
    canLive.value = 0;

    currentJoinedUsers.clear();
    allJoinedUsers.clear();
    messages.clear();
    giftsReceived.clear();

    askLiveEndConformation.value = false;

    giftsPage = 1;
    canLoadMoreGifts = true;
    isLoadingGifts.value = false;
  }

  checkFeasibilityToLive({required bool isOpenSettings}) {
    AppUtil.checkInternet().then((value) {
      Timer(const Duration(seconds: 2), () {
        if (value) {
          PermissionUtils.requestPermission(
              [Permission.camera, Permission.microphone],
              isOpenSettings: isOpenSettings, permissionGrant: () async {
            canLive.value = 1;
            errorMessage = null;
          }, permissionDenied: () {
            canLive.value = -1;
            errorMessage = pleaseAllowAccessToCameraForLiveString.tr;
          }, permissionNotAskAgain: () {
            canLive.value = -1;
            errorMessage = pleaseAllowAccessToCameraForLiveString.tr;
          });
        } else {
          canLive.value = value == true ? 1 : -1;
        }
      });
    });
  }

  closeLive() {
    clear();
    Get.close(2);
    // InterstitialAds().show();
  }

  //Initialize All The Setup For Agora Video Call
  Future<void> initializeLive() async {
    localLiveId = randomId();
    getIt<SocketManager>().emit(SocketConstants.goLive, {
      'userId': _userProfileManager.user.value!.id,
      'localCallId': localLiveId,
    });
  }

  joinAsAudience({required Live live}) async {
    liveEnd.value = false;
    // liveEnd.value = false;
    // if (live.host != null) {
    //   host = hostUser;
    // } else {

    await UsersApi.getOtherUser(
        userId: live.host.id,
        resultCallback: (result) {
          host = result;
        });

    liveId = live.liveId;
    remoteUserId.value = live.host.id;
    getIt<SocketManager>().emit(SocketConstants.joinLive, {
      'userId': _userProfileManager.user.value!.id,
      'liveCallId': liveId,
    });
    sendTextMessage('Joined');
    currentJoinedUsers.add(_userProfileManager.user.value!);
    _joinLive(live: live);
  }

  _joinLive({
    required Live live,
  }) {
    if (_settingsController.setting.value!.agoraApiKey!.isEmpty) {
      infoStrings.add(
        _settingsController.setting.value!.agoraApiKey!,
      );
      infoStrings.add('Agora Engine is not starting');
      update();
      return;
    }

    Future.delayed(Duration.zero, () async {
      await _initAgoraRtcEngine();
      _addAgoraEventHandlers();
      var configuration = const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 1920, height: 1080),
          orientationMode: OrientationMode.orientationModeAdaptive);
      engine?.leaveChannel();
      await engine?.setVideoEncoderConfiguration(configuration);
      await engine?.setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);

      live.isHosting
          ? await engine?.setClientRole(
              role: ClientRoleType.clientRoleBroadcaster)
          : await engine?.setClientRole(role: ClientRoleType.clientRoleAudience);
      await engine?.joinChannel(
        token: live.token,
        channelId: live.channelName,
        uid: _userProfileManager.user.value!.id,
        options: const ChannelMediaOptions(),
      );

      liveStartTime = DateTime.now();

      Get.to(() => LiveBroadcastScreen(
            live: live,
          ));
    });
  }

  //Initialize Agora RTC Engine
  Future<void> _initAgoraRtcEngine() async {
    engine = createAgoraRtcEngine();

    await engine?.initialize(RtcEngineContext(
      appId: _settingsController.setting.value!.agoraApiKey!,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));
    // engine =
    //     await RtcEngine.create(_settingsController.setting.value!.agoraApiKey!);
    await engine?.enableVideo();
  }

  //Switch Camera
  onToggleCamera() {
    engine?.switchCamera().then((value) {
      isFront.value = !isFront.value;
    }).catchError((err) {});
  }

  //Audio On / Off
  void onToggleMuteAudio() {
    mutedAudio.value = !mutedAudio.value;
    engine?.muteLocalAudioStream(mutedAudio.value);
  }

  //Video On / Off
  void onToggleMuteVideo() {
    mutedVideo.value = !mutedVideo.value;
    engine?.muteLocalVideoStream(mutedVideo.value);
  }

  //Agora Events Handler To Implement Ui/UX Based On Your Requirements
  void _addAgoraEventHandlers() {
    engine?.registerEventHandler(
      RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        debugPrint("local user ${connection.localUid} joined");
      }, onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        debugPrint("remote user $remoteUid joined");
        update();
      }, onUserOffline: (RtcConnection connection, int remoteUid,
              UserOfflineReasonType reason) {
        debugPrint("remote user $remoteUid left channel");
        // if (elapsed == UserOfflineReason.Dropped) {
        //   Wakelock.disable();
        // } else {
        // final info = 'userOffline: $uid';
        remoteUserId.value = 0;
        update();
        // _timerKey.currentState?.cancelTimer();
        // }
      }, onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
        debugPrint(
            '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
      }, onConnectionStateChanged: (RtcConnection connection,
              ConnectionStateType state,
              ConnectionChangedReasonType reason) async {
        if (state == ConnectionStateType.connectionStateConnected) {
          reConnectingRemoteView.value = false;
        } else if (state == ConnectionStateType.connectionStateReconnecting ||
            state == ConnectionStateType.connectionStateConnecting) {
          reConnectingRemoteView.value = true;
        }
      }, onRemoteVideoStateChanged: (RtcConnection connection,
              int remoteUid,
              RemoteVideoState state,
              RemoteVideoStateReason reason,
              int elapsed) async {
        if (state == RemoteVideoState.remoteVideoStateFailed ||
            state == RemoteVideoState.remoteVideoStateStopped ||
            state == RemoteVideoState.remoteVideoStateFrozen) {
          videoPaused.value = true;
        } else {
          videoPaused.value = false;
        }
      }),
    );
  }

  dontEndLiveCall() {
    askLiveEndConformation.value = false;
  }

  askConfirmationForEndCall() {
    askLiveEndConformation.value = true;
  }

  //Use This Method To End Call
  void onCallEnd({required bool isHost}) async {
    engine?.leaveChannel();
    // engine.destroy();
    Wakelock.disable(); // Turn off wakelock feature after call end
    // Emit End live Event Into Socket

    if (isHost) {
      getIt<SocketManager>().emit(
          SocketConstants.endLive,
          ({
            'userId': _userProfileManager.user.value!.id,
            'liveCallId': liveId
          }));
      liveEndTime = DateTime.now();
      liveEnd.value = true;

      // Get.back();
    } else {
      sendTextMessage('Left');
      getIt<SocketManager>().emit(
          SocketConstants.leaveLive,
          ({
            'userId': _userProfileManager.user.value!.id,
            'liveCallId': liveId
          }));
      clear();
      Get.back();
      InterstitialAds().show();
    }
  }

  messageChanges() {
    // getIt<SocketManager>().emit(SocketConstants.typing, {'room': chatRoomId});
    // messageTf.refresh();
    // update();
  }

  sendTextMessage(String messageText) {
    // if (messageTf.value.text.removeAllWhitespace.trim().isNotEmpty) {
    String localMessageId = randomId();
    String encrtyptedMessage = messageText.encrypted();
    var message = {
      'userId': _userProfileManager.user.value!.id,
      'liveCallId': liveId,
      'messageType': messageTypeId(MessageContentType.text),
      'message': encrtyptedMessage,
      'localMessageId': localMessageId,
      'picture': _userProfileManager.user.value!.picture,
      'username': _userProfileManager.user.value!.userName,
      'is_encrypted': 1,
      'created_at': (DateTime.now().millisecondsSinceEpoch / 1000).round()
    };

    //save message to socket server
    getIt<SocketManager>().emit(SocketConstants.sendMessageInLive, message);

    ChatMessageModel localMessageModel = ChatMessageModel();
    localMessageModel.localMessageId = localMessageId;
    localMessageModel.roomId = liveId;
    // localMessageModel.messageTime = justNow;
    localMessageModel.userName = youString.tr;
    // localMessageModel.userPicture = _userProfileManager.user.value!.picture;
    localMessageModel.senderId = _userProfileManager.user.value!.id;
    localMessageModel.messageType = messageTypeId(MessageContentType.text);
    localMessageModel.messageContent = messageText;

    localMessageModel.createdAt =
        (DateTime.now().millisecondsSinceEpoch / 1000).round();

    messages.add(localMessageModel);
    messageTf.value.text = '';
    update();
    // }
  }

  sendGiftMessage(String giftImage, int coins) {
    String localMessageId = randomId();
    var content = {'giftImage': giftImage, 'coins': coins.toString()};
    String encrtyptedMessage = json.encode(content).encrypted();

    var message = {
      'userId': _userProfileManager.user.value!.id,
      'liveCallId': liveId,
      'messageType': messageTypeId(MessageContentType.gift),
      'message': encrtyptedMessage,
      'localMessageId': localMessageId,
      'picture': _userProfileManager.user.value!.picture,
      'username': _userProfileManager.user.value!.userName,
      'is_encrypted': 1,
      'created_at': (DateTime.now().millisecondsSinceEpoch / 1000).round()
    };

    //save message to socket server
    getIt<SocketManager>().emit(SocketConstants.sendMessageInLive, message);

    ChatMessageModel localMessageModel = ChatMessageModel();
    localMessageModel.localMessageId = localMessageId;
    localMessageModel.roomId = liveId;
    // localMessageModel.messageTime = justNow;
    localMessageModel.userName = youString.tr;
    // localMessageModel.userPicture = _userProfileManager.user.value!.picture;
    localMessageModel.senderId = _userProfileManager.user.value!.id;
    localMessageModel.messageType = messageTypeId(MessageContentType.gift);
    localMessageModel.messageContent = json.encode(content);

    localMessageModel.createdAt =
        (DateTime.now().millisecondsSinceEpoch / 1000).round();

    messages.add(localMessageModel);
    messageTf.value.text = '';
    update();
  }

  sendGift(GiftModel gift) {
    if (_userProfileManager.user.value!.coins > gift.coins) {
      sendingGift.value = gift;

      GiftApi.sendStickerGift(
          gift: gift,
          liveId: liveId,
          postId: null,
          receiverId: host!.id,
          resultCallback: () {
            Timer(const Duration(seconds: 1), () {
              sendingGift.value = null;
            });

            //send gift message
            sendGiftMessage(gift.logo, gift.coins);

            // refresh profile to get updated wallet info
            _userProfileManager.refreshProfile();
          });
    } else {
      List<PackageModel> availablePackages = packageController.packages
          .where((package) => package.coin >= gift.coins)
          .toList();
      PackageModel package = availablePackages.first;
      buyPackage(package);
    }
  }

  buyPackage(PackageModel package) {
    if (AppConfigConstants.isDemoApp) {
      AppUtil.showDemoAppConfirmationAlert(
          title: 'Demo app',
          subTitle:
              'This is demo app so you can not make payment to test it, but still you will get some coins',
          okHandler: () {
            packageController.subscribeToDummyPackage(randomId());
          });
      return;
    }
    if (packageController.isAvailable.value) {
      // For production build
      packageController.selectedPurchaseId.value = Platform.isIOS
          ? package.inAppPurchaseIdIOS
          : package.inAppPurchaseIdAndroid;
      List<ProductDetails> matchedProductArr = packageController.products
          .where((element) =>
              element.id == packageController.selectedPurchaseId.value)
          .toList();
      if (matchedProductArr.isNotEmpty) {
        ProductDetails matchedProduct = matchedProductArr.first;
        PurchaseParam purchaseParam = PurchaseParam(
            productDetails: matchedProduct, applicationUserName: null);
        packageController.inAppPurchase.buyConsumable(
            purchaseParam: purchaseParam,
            autoConsume: packageController.kAutoConsume || Platform.isIOS);
      } else {
        AppUtil.showToast(
            message: noProductAvailableString.tr, isSuccess: false);
      }
    } else {
      AppUtil.showToast(
          message: storeIsNotAvailableString.tr, isSuccess: false);
    }
  }

  //*************** updates from socket *******************//

  onNewUserJoined(UserModel user) {
    currentJoinedUsers.add(user);
    if (!allJoinedUsers.contains(user)) {
      allJoinedUsers.add(user);
    }
    update();
  }

  onUserLeave(int userId) {
    currentJoinedUsers.removeWhere((element) => element.id == userId);
    update();
  }

  onLiveEnd(int liveId) {
    engine?.leaveChannel();
    // engine.destroy();
    Wakelock.disable();

    currentJoinedUsers.clear();
    messages.clear();
    update();
    if (this.liveId == liveId) {
      // Get.back();

      liveEnd.value = true;
    }
  }

  onNewMessageReceived(ChatMessageModel message) {
    if (host!.isMe == true &&
        message.messageContentType == MessageContentType.gift) {
      GiftModel gift = GiftModel(
          id: 1,
          name: '',
          logo: message.giftContent.image,
          coins: message.giftContent.coins);

      UserModel sender = UserModel();
      sender.id = message.senderId;
      sender.userName = message.userName;
      sender.picture = message.userPicture;
      ReceivedGiftModel receivedGiftDetail =
          ReceivedGiftModel(giftDetail: gift, sender: sender);

      sendingGift.value = gift;
      giftsReceived.add(receivedGiftDetail);

      Timer(const Duration(seconds: 1), () {
        sendingGift.value = null;
      });
    }
    messages.add(message);
    update();
  }

  liveCreatedConfirmation(dynamic data) {
    if (data['localCallId'] == localLiveId) {
      liveId = data['liveCallId'];
    }
    String agoraToken = data['token'];
    String channelName = data['channelName'];

    host = _userProfileManager.user.value!;
    Live live = Live(
        channelName: channelName,
        isHosting: true,
        host: host!,
        token: agoraToken,
        liveId: liveId);

    _joinLive(live: live);

    update();
  }

  // gifts

  loadGiftsReceived() {
    if (canLoadMoreGifts) {
      GiftApi.getReceivedStickerGifts(
          page: giftsPage,
          sendOnType: 1,
          postId: null,
          liveId: liveId,
          resultCallback: (result, metadata) {
            giftsReceived.addAll(result);
            canLoadMoreGifts = result.length >= metadata.perPage;
            giftsPage += 1;
            update();
          });
    }
  }
}
