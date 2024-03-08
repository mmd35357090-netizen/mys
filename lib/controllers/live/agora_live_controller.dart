import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/live_imports.dart';
import 'package:foap/helper/list_extension.dart';
import 'package:foap/helper/string_extension.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../api_handler/apis/gift_api.dart';
import '../../api_handler/apis/live_streaming_api.dart';
import '../../helper/enum_linking.dart';
import '../../manager/socket_manager.dart';
import '../../model/call_model.dart';
import '../../model/chat_message_model.dart';
import '../../model/data_wrapper.dart';
import '../../model/gift_model.dart';
import '../../model/package_model.dart';
import '../../screens/live/components.dart';
import '../../screens/settings_menu/settings_controller.dart';
import '../../util/ad_helper.dart';
import '../../util/constant_util.dart';
import '../misc/subscription_packages_controller.dart';

class AgoraLiveController extends GetxController {
  final SubscriptionPackageController packageController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();
  final ScrollController scrollController = ScrollController();
  final SettingsController _settingsController = Get.find();

  Rx<TextEditingController> messageTf = TextEditingController().obs;
  RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  RxList<ReceivedGiftModel> giftsReceived = <ReceivedGiftModel>[].obs;
  Rx<ReceivedGiftModel?> populateGift = Rx<ReceivedGiftModel?>(null);

  RxInt remoteUserId = 0.obs;
  Rx<GiftModel?> sendingGift = Rx<GiftModel?>(null);

  RtcEngine? engine;

  Rx<LiveModel?> live = Rx<LiveModel?>(null);

  // late int liveId;
  late String localLiveId;

  RxList<LiveViewer> bannedUsers = <LiveViewer>[].obs;
  RxList<LiveViewer> moderatorUsers = <LiveViewer>[].obs;
  RxList<LiveViewer> liveViewers = <LiveViewer>[].obs;

  DataWrapper liveViewersDataWrapper = DataWrapper();
  DataWrapper moderatorsDataWrapper = DataWrapper();
  DataWrapper bannedUsersDataWrapper = DataWrapper();
  RxInt totalViewers = 0.obs;

  // RxInt canLive = 0.obs;
  Rx<LiveStreamingStatus> startLiveStreaming = LiveStreamingStatus.none.obs;

  String? errorMessage;

  RxBool askLiveEndConformation = false.obs;
  RxBool askBattleEndConformation = false.obs;

  RxBool isFront = false.obs;
  RxBool reConnectingRemoteView = false.obs;
  RxBool mutedAudio = false.obs;
  RxBool mutedVideo = false.obs;
  RxBool videoPaused = false.obs;
  RxBool liveEnd = false.obs;

  DateTime? liveStartTime;
  DateTime? liveEndTime;

  int giftsPage = 1;
  bool canLoadMoreGifts = true;
  RxBool isLoadingGifts = false.obs;
  String channelName = '';

  RxBool messageTextFocus = false.obs;

  List<int> battleTimeArray = [30, 60, 120, 300, 600, 900, 1800, 2700, 3600];

  bool cameraInitiated = false;
  RxList<int> remoteJoinedUsers = <int>[].obs;
  RxList<int> videoPausedUsers = <int>[].obs;

  clear() {
    unregisterEventHandler();
    remoteJoinedUsers.clear();

    engine = null;
    isFront.value = false;
    messageTextFocus.value = false;
    reConnectingRemoteView.value = false;
    mutedAudio.value = false;
    mutedVideo.value = false;
    videoPaused.value = false;
    liveEnd.value = false;
    // canLive.value = 0;
    totalViewers.value = 0;
    messages.clear();
    giftsReceived.clear();

    askLiveEndConformation.value = false;
    askBattleEndConformation.value = false;

    giftsPage = 1;
    canLoadMoreGifts = true;
    isLoadingGifts.value = false;
    live.value = null;

    liveViewersDataWrapper = DataWrapper();
    moderatorsDataWrapper = DataWrapper();
    bannedUsersDataWrapper = DataWrapper();

    bannedUsers.clear();
    moderatorUsers.clear();
    liveViewers.clear();

    startLiveStreaming.value = LiveStreamingStatus.none;
  }

  clearGiftData() {
    giftsPage = 1;
    canLoadMoreGifts = true;
    isLoadingGifts.value = false;
    giftsReceived.clear();
  }

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

  String get liveDurationLength {
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

  checkFeasibilityToLive(
      {required bool isOpenSettings,
      required LiveModel? battle,
      required VoidCallback successCallbackHandler}) async {
    startLiveStreaming.value = LiveStreamingStatus.checking;
    startLiveStreaming.refresh();

    AppUtil.checkInternet().then((value) {
      if (value) {
        Future.delayed(const Duration(seconds: 2), () {
          startLiveStreaming.value = LiveStreamingStatus.preparing;

          errorMessage = null;
          prepareLive(
              battle: battle, successCallbackHandler: successCallbackHandler);
        });
      } else {
        Future.delayed(const Duration(seconds: 2), () {
          startLiveStreaming.value = LiveStreamingStatus.failed;
        });
      }
    });
  }

  prepareLive(
      {required LiveModel? battle,
      required VoidCallback successCallbackHandler}) {
    if (battle != null) {
      // join a battle
      Future.delayed(const Duration(seconds: 3), () {
        successCallbackHandler();
        initializeLiveBattle(battle);
      });
    } else {
      // start new live
      initializeLive();
    }
  }

  //Initialize All The Setup For Agora Video Call
  Future<void> initializeLive() async {
    // clear();
    localLiveId = randomId();
    getIt<SocketManager>().emit(SocketConstants.goLive, {
      'userId': _userProfileManager.user.value!.id,
      'localCallId': localLiveId,
    });
  }

  Future<void> initializeLiveBattle(LiveModel live) async {
    _joinLive(live: live);
  }

  joinAsAudience({required LiveModel live}) async {
    this.live.value = live;

    getIt<SocketManager>().emit(SocketConstants.joinLive, {
      'userId': _userProfileManager.user.value!.id,
      'liveCallId': this.live.value!.id,
    });

    _joinLive(live: live);
    Get.to(() => const LiveBroadcastScreen());
  }

  _joinLive({required LiveModel live}) {
    print(
        'joining live ==== ${_settingsController.setting.value!.agoraApiKey!.isEmpty}');
    if (_settingsController.setting.value!.agoraApiKey!.isEmpty) {
      update();
      return;
    }
    print('its joined ');
    this.live.value = live;
    this.live.refresh();
    sendTextMessage('Joined');

    Future.delayed(Duration.zero, () async {
      await _initAgoraRtcEngine(live: live);
      _addAgoraEventHandlers();
      var configuration = const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 1920, height: 1080),
          orientationMode: OrientationMode.orientationModeAdaptive);
      engine?.leaveChannel();
      await engine?.setVideoEncoderConfiguration(configuration);
      await engine?.setChannelProfile(
          ChannelProfileType.channelProfileLiveBroadcasting);

      live.amIHostInLive
          ? await engine?.setClientRole(
              role: ClientRoleType.clientRoleBroadcaster)
          : await engine?.setClientRole(
              role: ClientRoleType.clientRoleAudience);

      await engine?.joinChannel(
        token: live.token,
        channelId: live.channelName,
        uid: _userProfileManager.user.value!.id,
        options: const ChannelMediaOptions(),
      );
      await engine?.enableVideo();

      if (cameraInitiated == false && live.amIHostInLive) {
        onToggleCamera();
        Future.delayed(const Duration(seconds: 2), () {
          onToggleCamera();
        });
        // onToggleCamera();
      } else {}

      liveStartTime = DateTime.now();
      channelName = live.channelName;
    });

    LiveStreamingApi.getLiveDetail(
        channelName: live.channelName,
        resultCallback: (result) {
          print('here is share link = ${result.shareLink}');
          this.live.value!.shareLink = result.shareLink;
        });
  }

  //Initialize Agora RTC Engine
  Future<void> _initAgoraRtcEngine({required LiveModel live}) async {
    engine = createAgoraRtcEngine();

    await engine?.initialize(RtcEngineContext(
      appId: _settingsController.setting.value!.agoraApiKey!,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));
  }

  void unregisterEventHandler() {
    engine?.unregisterEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) async {},
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {},
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {},
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {},
        onConnectionStateChanged: (RtcConnection connection,
            ConnectionStateType state,
            ConnectionChangedReasonType reason) async {},
        onRemoteVideoStateChanged: (RtcConnection connection,
            int remoteUid,
            RemoteVideoState state,
            RemoteVideoStateReason reason,
            int elapsed) async {}));
  }

  //Agora Events Handler To Implement Ui/UX Based On Your Requirements
  void _addAgoraEventHandlers() {
    engine?.registerEventHandler(
      RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) async {
            debugPrint(
                "local user ${connection.localUid} joined , on channel ${connection.channelId}");
            update();
            // startLiveStreaming.value = LiveStreamingStatus.streaming;
          },
          onLeaveChannel: (RtcConnection connection, RtcStats status) {},
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            debugPrint("remote user $remoteUid joined");
            remoteJoinedUsers.add(remoteUid);
            update();
          },
          onUserOffline: (RtcConnection connection, int remoteUid,
              UserOfflineReasonType reason) {
            debugPrint("remote user $remoteUid left channel");
            remoteJoinedUsers.remove(remoteUid);

            update();
          },
          onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
            debugPrint(
                '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
          },
          onConnectionStateChanged: (RtcConnection connection,
              ConnectionStateType state,
              ConnectionChangedReasonType reason) async {
            if (state == ConnectionStateType.connectionStateConnected) {
            } else if (state ==
                    ConnectionStateType.connectionStateReconnecting ||
                state == ConnectionStateType.connectionStateConnecting) {
              // reConnectingRemoteView.value = true;
            }
          },
          onFirstRemoteVideoFrame: (RtcConnection connection, int remoteUid,
              int width, int height, int elapsed) {},
          onRemoteVideoStateChanged: (RtcConnection connection,
              int remoteUid,
              RemoteVideoState state,
              RemoteVideoStateReason reason,
              int elapsed) async {
            if ((state == RemoteVideoState.remoteVideoStateFailed ||
                    state == RemoteVideoState.remoteVideoStateStopped ||
                    state == RemoteVideoState.remoteVideoStateFrozen) &&
                reason ==
                    RemoteVideoStateReason.remoteVideoStateReasonRemoteMuted) {
              videoPaused.value = true;
              videoPausedUsers.add(remoteUid);
            } else {
              videoPaused.value = false;
              videoPausedUsers.remove(remoteUid);
            }
          },
          onLocalVideoStateChanged: (VideoSourceType source,
              LocalVideoStreamState state, LocalVideoStreamError error) {},
          onCameraReady: () {},
          onVideoDeviceStateChanged: (String deviceId,
              MediaDeviceType deviceType, MediaDeviceStateType deviceState) {},
          onLocalVideoStats:
              (VideoSourceType sourceType, LocalVideoStats stats) {
            // print('onLocalVideoStats $stats');
          },
          onFirstLocalVideoFrame:
              (VideoSourceType source, int width, int height, int elapsed) {
            cameraInitiated = true;
          },
          onFirstLocalVideoFramePublished:
              (VideoSourceType sourceType, int elapsed) {}),
    );
  }

  //Use This Method To End Call
  void onCallEnd({required bool isHost}) async {
    engine?.leaveChannel();
    WakelockPlus.disable(); // Turn off wakelock feature after call end

    if (isHost) {
      leaveFromLiveAsHost();
      clearGiftData();
      loadGiftsReceived(liveId: live.value!.id);
    } else {
      leaveFromLiveAsAudience();
    }

    liveEndTime = DateTime.now();
    liveEnd.value = true;
  }

  closeLive() {
    Get.back();
    Timer(const Duration(seconds: 1), () {
      clear();
    });
  }

  leaveFromLiveAsHost() {
    // leave from battle
    // if (live.value?.battleDetail?.battleStatus == BattleStatus.started) {
    // getIt<SocketManager>().emit(SocketConstants.endLiveBattle, {
    //   'battleId': live.value?.battleDetail!.id,
    // });
    // }

    //end live
    getIt<SocketManager>().emit(
        SocketConstants.endLive,
        ({
          'userId': _userProfileManager.user.value!.id,
          'liveCallId': live.value?.id
        }));

    liveEndTime = DateTime.now();
    liveEnd.value = true;
    live.refresh();
  }

  leaveFromLiveAsAudience() {
    sendTextMessage('Left');
    getIt<SocketManager>().emit(
        SocketConstants.leaveLive,
        ({
          'userId': _userProfileManager.user.value!.id,
          'liveCallId': live.value?.id
        }));

    clear();
    Get.back();
    InterstitialAds().show();
  }

  sendTextMessage(String messageText) {
    // if (messageTf.value.text.removeAllWhitespace.trim().isNotEmpty) {
    String localMessageId = randomId();
    String encrtyptedMessage = messageText.encrypted();
    var message = {
      'userId': _userProfileManager.user.value!.id,
      'liveCallId': live.value!.id,
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
    localMessageModel.roomId = live.value!.id;
    // localMessageModel.messageTime = justNow;
    localMessageModel.userName = youString;
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
      'liveCallId': live.value!.id,
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
    localMessageModel.roomId = live.value!.id;
    // localMessageModel.messageTime = justNow;
    localMessageModel.userName = youString;
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

  sendGift({required GiftModel gift, LiveCallHostUser? host}) {
    if (_userProfileManager.user.value!.coins > gift.coins) {
      populateGift.value = ReceivedGiftModel(
          giftDetail: gift, sender: _userProfileManager.user.value!);

      getIt<SocketManager>().emit(SocketConstants.sendGiftLiveCall, {
        'userId': host == null
            ? live.value!.mainHostUserDetail!.id
            : host.userDetail.id,
        'liveCallId': live.value!.id,
        'battleId': live.value!.battleDetail == null
            ? '0'
            : live.value!.battleDetail?.id,
        'giftId': gift.id
      });
      Timer(const Duration(seconds: 2), () {
        populateGift.value = null;
      });
      _userProfileManager.refreshProfile();
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
        AppUtil.showToast(message: noProductAvailableString, isSuccess: false);
      }
    } else {
      AppUtil.showToast(message: storeIsNotAvailableString, isSuccess: false);
    }
  }

  // *************** actions by host ***************//

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

  void dontEndLiveCall() {
    askLiveEndConformation.value = false;
  }

  void askConfirmationForEndCall() {
    askLiveEndConformation.value = true;
  }

  void dontEndLiveBattle() {
    askBattleEndConformation.value = false;
  }

  void askConfirmationForEndBattle() {
    askBattleEndConformation.value = true;
  }

  void liveBattleCompleted() {
    if (live.value?.battleStatus == BattleStatus.started) {
      getIt<SocketManager>().emit(SocketConstants.endLiveBattle, {
        'battleId': live.value!.battleDetail!.id,
      });
      showBattleResultAndClearData();
    }
    askBattleEndConformation.value = false;
  }

  void showBattleResultAndClearData() async {
    live.value?.battleDetail?.battleStatus = BattleStatus.completed;
    live.refresh();

    if (live.value!.battleDetail!.opponentHost.userDetail.isMe) {
      await engine?.setClientRole(role: ClientRoleType.clientRoleAudience);
    }
  }

  void closeWinnerInfo() {
    live.value!.clearBattleData();
    live.refresh();
  }

  void messageTextFocusToggle() {
    messageTextFocus.value = !messageTextFocus.value;
  }

  //*************** updates from socket *******************//

  inviteUserToLive(
      {required UserModel user,
      required int battleTime,
      required VoidCallback alreadyInvitedHandler}) {
    if (live.value?.canInvite == true) {
      getIt<SocketManager>().emit(SocketConstants.inviteInLive, {
        'userId': user.id,
        'liveCallId': live.value!.id,
        'totalAllowedTime': battleTime
      });

      live.value!.invitedUserDetail = user;
      live.refresh();

      Timer(
          const Duration(
              seconds: AppConfigConstants.liveBattleConfirmationWaitTime + 5),
          () {
        if (live.value != null &&
            live.value?.battleDetail == null &&
            live.value?.invitedUserDetail != null) {
          noResponseLiveBattle(
            liveId: live.value!.id,
          );
        }
      });
    } else {
      alreadyInvitedHandler();
    }
  }

  invitedForLiveBattle(LiveModel live) {
    // const STATUS_LIVE_CALL_HOST_PENDING = 1;
    // const STATUS_LIVE_CALL_HOST_ACCEPTED = 2;
    // const STATUS_LIVE_CALL_HOST_REJECTED = 3;
    // const STATUS_LIVE_CALL_HOST_ONGOING = 4;
    // const STATUS_LIVE_CALL_HOST_COMPLETED = 10;

    showModalBottomSheet<void>(
        context: Get.context!,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return FractionallySizedBox(
            heightFactor: 0.7,
            child: BattleInvitation(
              live: live,
              okHandler: () {
                acceptBattleInvite(
                    live: live, battleDetail: live.battleDetail!);
              },
              cancelHandler: () {
                declineInvite(live.battleDetail!);
              },
            ),
          );
        }).then((value) {});
  }

  acceptBattleInvite(
      {required LiveModel live, required BattleDetail battleDetail}) {
    battleDetail.battleStatus = BattleStatus.accepted;

    Timer(const Duration(seconds: 1), () {
      if (this.live.value?.id == live.id) {
        engine?.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
        this.live.value!.battleDetail = battleDetail;
        this.live.value!.battleDetail!.battleUsers.add(LiveCallHostUser(
            userDetail: live.mainHostUserDetail!,
            // battleId: battleDetail.id,
            totalCoins: 0,
            totalGifts: 0,
            isMainHost: true));

        this.live.value!.battleDetail!.battleUsers.add(LiveCallHostUser(
            userDetail: _userProfileManager.user.value!,
            // battleId: battleDetail.id,
            totalCoins: 0,
            totalGifts: 0,
            isMainHost: false));

        this.live.refresh();

        startLive(battleDetail: battleDetail);
      } else {
        live.battleDetail = battleDetail;
        live.battleDetail!.battleUsers.add(LiveCallHostUser(
            userDetail: live.mainHostUserDetail!,
            // battleId: battleDetail.id,
            totalCoins: 0,
            totalGifts: 0,
            isMainHost: true));
        live.battleDetail!.battleUsers.add(LiveCallHostUser(
            userDetail: _userProfileManager.user.value!,
            // battleId: battleDetail.id,
            totalCoins: 0,
            totalGifts: 0,
            isMainHost: false));
        // _joinLive(live: live);

        Get.to(() => CheckingLiveFeasibility(
              battle: live,
              successCallbackHandler: () {
                startLive(battleDetail: battleDetail);
              },
            ));
      }
    });
  }

  startLive({required BattleDetail battleDetail}) {
    Timer(const Duration(seconds: 2), () {
      live.value!.battleDetail!.battleStatus = BattleStatus.started;
      live.refresh();
    });

    getIt<SocketManager>().emit(SocketConstants.replyInvitationInLive, {
      'battleId': battleDetail.id,
      'status': 2,
    });
  }

  declineInvite(BattleDetail battleDetail) {
    getIt<SocketManager>().emit(SocketConstants.replyInvitationInLive, {
      'battleId': battleDetail.id,
      'status': 3,
    });
  }

  userAcceptedLiveBattle({
    required int liveId,
    required BattleDetail battleDetail,
    // required UserModel user
  }) {
    live.value!.invitedUserDetail = null;

    if (live.value?.id == liveId) {
      onNewUserJoined(
          battleDetail.opponentHost.userDetail, liveId, totalViewers.value);
      live.value!.battleDetail = battleDetail;
      live.value!.battleDetail!.battleStatus = BattleStatus.accepted;

      Timer(const Duration(seconds: 2), () {
        live.value!.battleDetail!.battleStatus = BattleStatus.started;
        live.refresh();
      });

      live.refresh();
    }
  }

  userDeclinedLiveBattle({
    required int liveId,
    // required UserModel user
  }) {
    if (live.value?.id == liveId) {
      Future.delayed(const Duration(milliseconds: 500), () {
        live.value!.invitedUserDetail = null;
        live.refresh();
      });

      showModalBottomSheet<void>(
          context: Get.context!,
          backgroundColor: Colors.transparent,
          builder: (BuildContext context) {
            return FractionallySizedBox(
              heightFactor: 0.55,
              child: InvitationDeclinedView(
                user: live.value!.invitedUserDetail!,
              ),
            );
          }).then((value) {});
    }
  }

  noResponseLiveBattle({
    required int liveId,
  }) {
    if (live.value?.id == liveId) {
      showModalBottomSheet<void>(
          context: Get.context!,
          backgroundColor: Colors.transparent,
          builder: (BuildContext context) {
            return FractionallySizedBox(
              heightFactor: 0.55,
              child: NoResponseOnInvitationView(
                user: live.value!.invitedUserDetail!,
              ),
            );
          }).then((value) {
        live.value!.invitedUserDetail = null;
        live.refresh();
      });
    }
  }

  liveCallHostsUpdated(
      {required int liveId,
      required BattleDetail? battleDetail,
      required List<LiveCallHostUser> hosts}) {
    if (live.value?.id == liveId) {
      if (live.value?.battleDetail != null && hosts.isEmpty) {
        liveBattleEnded(
            liveId: live.value!.id, battleId: live.value!.battleDetail!.id);
        live.refresh();
        return;
      }
      if (hosts.isEmpty &&
          (live.value!.battleDetail?.amIMainHostInLive == false)) {
      } else {
        if (live.value!.battleDetail == null) {
          live.value!.battleDetail = battleDetail;
        }
        live.value!.battleDetail?.battleUsers = hosts;
      }

      live.refresh();
    }
  }

  liveBattleEnded({required int liveId, required int battleId}) {
    clearGiftData();
    loadGiftsReceived(liveId: live.value!.id, battleId: battleId);
    showBattleResultAndClearData();
  }

  onGiftReceived(
      {required int liveId,
      required GiftModel gift,
      required UserModel sentBy,
      required int sentToUserId}) {
    if (live.value?.id == liveId) {
      if (sentToUserId == _userProfileManager.user.value!.id) {
        populateGift.value =
            ReceivedGiftModel(giftDetail: gift, sender: sentBy);
        Timer(const Duration(seconds: 2), () {
          populateGift.value = null;
        });
      }
    }
  }

  onNewUserJoined(UserModel user, int liveId, int totalUsers) {
    if (liveId == live.value?.id && user.isMe) {
      _joinLive(live: live.value!);
      print('going from here');
      Get.to(() => const LiveBroadcastScreen());
    } else {
      // currentJoinedUsers.add(user);
      // if (!allJoinedUsers.contains(user)) {
      //   allJoinedUsers.add(user);
      // }
      update();
    }
    totalViewers.value = totalUsers;
  }

  onUserLeave(
      {required int userId, required int liveId, required int totalUsers}) {
    totalViewers.value = totalUsers;
    if (userId == _userProfileManager.user.value!.id) {
      // remove me, i might be banned by host
      clear();
      Get.back();
    } else if (live.value?.id == liveId) {
      liveViewers.removeWhere((element) => element.user.id == userId);
      moderatorUsers.removeWhere((element) => element.user.id == userId);
      bannedUsers.removeWhere((element) => element.user.id == userId);

      update();
    }
  }

  onLiveEndMessageReceived(int liveId) {
    engine?.leaveChannel();

    WakelockPlus.disable();

    messages.clear();
    if (live.value?.id == liveId) {
      liveEndTime = DateTime.now();
      liveEnd.value = true;
      live.value!.clearBattleData();
    }
    update();
  }

  onNewMessageReceived(ChatMessageModel message) {
    if (live.value?.battleDetail?.amIHostInLive == true &&
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

      populateGift.value = ReceivedGiftModel(giftDetail: gift, sender: sender);
      giftsReceived.add(receivedGiftDetail);

      Timer(const Duration(seconds: 2), () {
        populateGift.value = null;
      });
    }
    messages.add(message);
    update();
  }

  liveCreatedConfirmation(dynamic data) {
    if (data['localCallId'] == localLiveId) {
      int liveId = data['liveCallId'];

      String agoraToken = data['token'];
      String channelName = data['channelName'];

      LiveModel live = LiveModel();

      live.channelName = channelName;
      live.mainHostUserDetail = _userProfileManager.user.value!;
      live.token = agoraToken;
      live.id = liveId;
      _joinLive(live: live);

      update();
    }
  }

  showLiveStreaming() {
    startLiveStreaming.value = LiveStreamingStatus.streaming;
    startLiveStreaming.refresh();
  }

  // gifts

  loadGiftsReceived({required int liveId, int? battleId}) {
    if (canLoadMoreGifts) {
      GiftApi.getLiveCallReceivedStickerGifts(
          page: giftsPage,
          liveId: liveId,
          battleId: battleId,
          resultCallback: (gifts, users, metadata) {
            live.value!.battleDetail?.battleUsers = users;
            giftsReceived.addAll(gifts);

            if (metadata != null) {
              canLoadMoreGifts = gifts.length >= metadata.perPage;
            }

            giftsPage += 1;
            update();
          });
    }
  }

  banUser(UserModel user, int? time) {
    getIt<SocketManager>().emit(
        SocketConstants.actionOnUserInLive,
        ({
          'actionUserId': user.id,
          'liveCallId': live.value?.id,
          'actionType': '1',
          'totalExpelTime': time ?? 0,
          'role': '',
        }));
  }

  unbanUser(UserModel user) {
    getIt<SocketManager>().emit(
        SocketConstants.actionOnUserInLive,
        ({
          'actionUserId': user.id,
          'liveCallId': live.value?.id,
          'actionType': '2',
          'totalExpelTime': '',
          'role': '',
        }));
  }

  makeModerator(UserModel user) {
    getIt<SocketManager>().emit(
        SocketConstants.actionOnUserInLive,
        ({
          'actionUserId': user.id,
          'liveCallId': live.value?.id,
          'actionType': '3',
          'totalExpelTime': '',
          'role': '3',
        }));

    sendTextMessage('${user.userName} ${isModeratorNowString.tr}');
  }

  removeAsModerator(UserModel user) {
    getIt<SocketManager>().emit(
        SocketConstants.actionOnUserInLive,
        ({
          'actionUserId': user.id,
          'liveCallId': live.value?.id,
          'actionType': '3',
          'totalExpelTime': '',
          'role': '2',
        }));
    sendTextMessage('${user.userName} ${isRemovedFromModeratorString.tr}');
  }

  loadMoreLiveViewers(VoidCallback callback) {
    if (liveViewersDataWrapper.haveMoreData.value) {
      getLiveViewers(callback);
    } else {
      callback();
    }
  }

  refreshLiveViewers() {
    liveViewers.clear();
    liveViewersDataWrapper = DataWrapper();
    getLiveViewers(() {});
  }

  getLiveViewers(VoidCallback callback) {
    liveViewers.clear();
    LiveStreamingApi.getLiveViewers(
        liveId: live.value!.id,
        resultCallback: (result, metaData) {
          liveViewers.addAll(result);
          liveViewers.unique((e) => e.id);
          liveViewersDataWrapper.processCompletedWithData(metaData);
          totalViewers.value = metaData.totalCount;
          callback();
        });
  }

  loadMoreModerators(VoidCallback callback) {
    if (moderatorsDataWrapper.haveMoreData.value) {
      getModerator(callback);
    } else {
      callback();
    }
  }

  refreshModerators() {
    moderatorUsers.clear();
    moderatorsDataWrapper = DataWrapper();
    getModerator(() {});
  }

  getModerator(VoidCallback callback) {
    LiveStreamingApi.getLiveViewers(
        liveId: live.value!.id,
        role: liveViewerRole(LiveUserRole.moderator),
        resultCallback: (result, metaData) {
          moderatorUsers.addAll(result);
          moderatorUsers.unique((e) => e.id);

          moderatorsDataWrapper.processCompletedWithData(metaData);
          callback();
        });
  }

  loadMoreBannedUsers(VoidCallback callback) {
    if (bannedUsersDataWrapper.haveMoreData.value) {
      getBannedUser(callback);
    } else {
      callback();
    }
  }

  refreshBannedViewers() {
    bannedUsers.clear();
    bannedUsersDataWrapper = DataWrapper();
    getBannedUser(() {});
  }

  getBannedUser(VoidCallback callback) {
    LiveStreamingApi.getLiveViewers(
        liveId: live.value!.id,
        isBanned: true,
        resultCallback: (result, metaData) {
          bannedUsers.addAll(result);
          bannedUsers.unique((e) => e.id);

          bannedUsersDataWrapper.processCompletedWithData(metaData);

          callback();
        });
  }

  userRoleChange(
      {required int actionOnUserId,
      required int liveId,
      required LiveUserRole role}) {
    refreshBannedViewers();
    refreshLiveViewers();
    refreshModerators();
  }

  bool get amIModeratorInLive {
    List<LiveViewer> myRecordsAsModerator =
        moderatorUsers.where((e) => e.user.isMe).toList();
    return myRecordsAsModerator.isNotEmpty;
  }
}
