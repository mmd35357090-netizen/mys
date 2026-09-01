import 'dart:io';
import 'package:foap/controllers/chat_and_call/voip_controller.dart';
import 'package:foap/helper/imports/call_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/dashboard_imports.dart';
import 'package:foap/screens/calling/not_answerd_call.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import '../../helper/permission_utils.dart';
import '../../main.dart';
import '../../manager/socket_manager.dart';
import '../../screens/settings_menu/settings_controller.dart';
import '../../util/ad_helper.dart';
import '../../util/constant_util.dart';
import '../../util/shared_prefs.dart';
import 'call_history_controller.dart';

class AgoraCallController extends GetxController {
  final UserProfileManager _userProfileManager = Get.find();

  RxInt remoteUserId = 0.obs;

  RtcEngine? engine;

  RxBool isFront = false.obs;
  RxBool reConnectingRemoteView = false.obs;
  RxBool videoPaused = false.obs;

  RxBool mutedAudio = false.obs;
  RxBool mutedVideo = false.obs;
  RxBool switchMainView = false.obs;
  RxBool remoteJoined = false.obs;

  final SettingsController _settingsController = Get.find();

  // int callId = 0;
  final player = AudioPlayer();

  late String localCallId;
  UserModel? opponent;

  //Initialize All The Setup For Agora Video Call

  setIncomingCallId(int id) {
    // callId = id;
  }

  clear() {
    isFront.value = false;
    reConnectingRemoteView.value = false;
    videoPaused.value = false;

    mutedAudio.value = false;
    mutedVideo.value = false;
    switchMainView.value = false;
    remoteJoined.value = false;
  }

  makeCallRequest({required Call call}) async {
    opponent = call.opponent;
    localCallId = randomId();

    getIt<SocketManager>().emit(
        SocketConstants.callCreate,
        ({
          CallArgParams.senderId: _userProfileManager.user.value!.id,
          CallArgParams.receiverId: call.opponent.id,
          CallArgParams.callType: call.callType,
          CallArgParams.localCallId: localCallId,
          // CallArgParams.channelName: channelName
        }));
  }

  Future<void> initializeCalling({
    required Call call,
  }) async {
    // logFile.writeAsStringSync('initializeCalling \n', mode: FileMode.append);
    if (_settingsController.setting.value!.agoraApiKey!.isEmpty) {
      // logFile.writeAsStringSync('initializeCalling agora key empty\n', mode: FileMode.append);
      update();
      return;
    }

    // logFile.writeAsStringSync('initializeCalling  agora key found1\n', mode: FileMode.append);
    Future.delayed(Duration.zero, () async {
      await _initAgoraRtcEngine(
          callType: call.callType == 1
              ? AgoraCallType.audio
              : AgoraCallType.video);
      _addAgoraEventHandlers();
      var configuration = const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 1920, height: 1080),
          orientationMode: OrientationMode.orientationModeAdaptive);

      await engine!.setVideoEncoderConfiguration(configuration);
      await engine!.leaveChannel();

      await engine!.joinChannel(
        token: call.token,
        channelId: call.channelName,
        uid: _userProfileManager.user.value!.id,
        options: const ChannelMediaOptions(),
      );

      if (call.callType == 1) {
        Get.to(() => AudioCallingScreen(call: call),
            transition: Transition.noTransition);
      } else {
        Get.to(() => VideoCallingScreen(call: call),
            transition: Transition.noTransition);
      }
      update();
    });
  }

  //Initialize Agora RTC Engine
  Future<void> _initAgoraRtcEngine(
      {required AgoraCallType callType}) async {
    // _engine = await RtcEngine.create(_settingsController.setting.value!.agoraApiKey!);

    engine = createAgoraRtcEngine();

    await engine!.initialize(RtcEngineContext(
      appId: _settingsController.setting.value!.agoraApiKey!,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    if (callType == AgoraCallType.video) {
      await engine!.enableVideo();
      await engine!.startPreview();
    }
  }

  //Switch Camera
  onToggleCamera() {
    engine!.switchCamera().then((value) {
      isFront.value = !isFront.value;
    }).catchError((err) {});
  }

  void toggleMainView() {
    switchMainView.value = !switchMainView.value;
    update();
  }

  //Audio On / Off
  void onToggleMuteAudio() {
    mutedAudio.value = !mutedAudio.value;
    engine!.muteLocalAudioStream(mutedAudio.value);
  }

  //Video On / Off
  void onToggleMuteVideo() {
    mutedVideo.value = !mutedVideo.value;
    engine!.muteLocalVideoStream(mutedVideo.value);
  }

  //Agora Events Handler To Implement Ui/UX Based On Your Requirements
  void _addAgoraEventHandlers() {
    engine!.registerEventHandler(
      RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            debugPrint("local user ${connection.localUid} joined");
          },
          onUserJoined:
              (RtcConnection connection, int remoteUid, int elapsed) {
            debugPrint("remote user $remoteUid joined");
            remoteJoined.value = true;
            remoteUserId.value = remoteUid;
            print('remoteJoined ${remoteJoined.value}');
            update();
          },
          onUserOffline: (RtcConnection connection, int remoteUid,
              UserOfflineReasonType reason) {
            debugPrint("remote user $remoteUid left channel");

            remoteUserId.value = 0;
            update();
          },
          onTokenPrivilegeWillExpire:
              (RtcConnection connection, String token) {
            debugPrint(
                '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
          },
          onConnectionStateChanged: (RtcConnection connection,
              ConnectionStateType state,
              ConnectionChangedReasonType reason) async {
            if (state == ConnectionStateType.connectionStateConnected) {
              reConnectingRemoteView.value = false;
            } else if (state ==
                ConnectionStateType.connectionStateReconnecting) {
              reConnectingRemoteView.value = true;
            }
          },
          onRemoteVideoStateChanged: (RtcConnection connection,
              int remoteUid,
              RemoteVideoState state,
              RemoteVideoStateReason reason,
              int elapsed) async {}),
    );
  }

  // call
  callStatusUpdateReceived(Map<String, dynamic> updatedData) {
    final VoipController voipController = Get.find();
    int callId = updatedData['id'];
    int status = updatedData['status'];
    int callerId = updatedData['callerId'];
    int myUserId = _userProfileManager.user.value!.id;

    final CallHistoryController callHistoryController =
        CallHistoryController();
    callHistoryController.callDetail(
        callId: callId,
        resultCallback: (result) {
          Call call = Call(
              uuid: updatedData['uuid'],
              channelName: '',
              isOutGoing: myUserId == callerId,
              opponent: myUserId == callerId
                  ? result.receiverDetail
                  : result.callerDetail,
              token: '',
              callType: result.callType,
              callId: updatedData['id']);

          if (status == 5 || status == 2) {
            // always called when action is performed by the opponent
            if (status == 2) {
              if (Platform.isIOS) {
                voipController.declinedByOpponent(call);
              }
              if (myUserId == callerId) {
                //show callback screen only if i am the caller
                receivedDeclinedCallNotification(call);
              }
            } else {
              if (Platform.isIOS) {
                voipController.endCallByOpponent(call);
              }
              receivedEndCallNotification(call);
            }
          } else if (status == 4) {
            player.stop();
          }
        });
  }

  outgoingCallConfirmationReceived(
      Map<String, dynamic> updatedData) async {
    final VoipController voipController = Get.find();

    String uuid = updatedData['uuid'];
    int id = updatedData['id'];
    String localCallId = updatedData['localCallId'];
    var agoraToken = updatedData['token'];
    var channelName = updatedData['channelName'];
    int callType = updatedData['callType'];

    Call call = Call(
        uuid: uuid,
        channelName: channelName!,
        isOutGoing: true,
        opponent: opponent!,
        token: agoraToken!,
        callType: callType,
        callId: id);

    if (this.localCallId == localCallId) {
      initializeCalling(call: call);
      if (Platform.isIOS) {
        voipController.outGoingCall(call);
      }
      await player.setAsset('assets/ringtone.mp3');
      player.play();
    }
  }

  void acceptCall({required Call call}) {
    getIt<SocketManager>().emit(SocketConstants.onAcceptCall, {
      'uuid': call.uuid,
      'userId': _userProfileManager.user.value!.id,
      'status': 4,
    });

    remoteUserId.value = call.opponent.id;
    remoteJoined.value = true;
    initializeCalling(
      call: call,
    );
    player.stop();
  }

  void initiateAcceptCall({required Call call}) async {
    askForPermissionsForCall(call: call);
  }

  askForPermissionsForCall({required Call call}) {
    // logFile.writeAsStringSync('askForPermissionsForCall 1\n', mode: FileMode.append);
    PermissionUtils.requestPermission(
        call.callType == 1
            ? [Permission.microphone]
            : [Permission.camera, Permission.microphone],
        isOpenSettings: false, permissionGrant: () async {
      // logFile.writeAsStringSync('permissionGranted 1\n', mode: FileMode.append);
      acceptCall(call: call);
    }, permissionDenied: () {
      declineIncomingCall(call: call);
      AppUtil.showToast(
          message: pleaseAllowAccessToMicrophoneForAudioCallString,
          isSuccess: false);
    }, permissionNotAskAgain: () {
      declineIncomingCall(call: call);
      AppUtil.showToast(
          message: pleaseAllowAccessToMicrophoneForAudioCallString,
          isSuccess: false);
    });
  }

  clearCall() {
    player.stop();
    if (remoteJoined.value == true) {
      engine?.leaveChannel();

      clear();
    }
    // callId = 0;
    remoteJoined.value = false;
  }

  void receivedDeclinedCallNotification(Call call) async {
    player.stop();
    Get.back();
    Get.to(
        () => NotAnsweredCall(
              call: call,
            ),
        transition: Transition.noTransition);
    update();
  }

  //Use This Method To End Call
  void receivedEndCallNotification(Call call) async {
    clearCall();
    Get.back();

    InterstitialAds().show();

    if (isLaunchedFromCallNotification) {
      Get.offAll(() => const DashboardScreen());
    }
    SharedPrefs().setCallNotificationData(null);
  }

  void onCallEnd(Call call) async {
    final VoipController voipController = Get.find();

    if (remoteJoined.value == true) {
      getIt<SocketManager>().emit(SocketConstants.onCompleteCall, {
        'uuid': call.uuid,
        'userId': _userProfileManager.user.value!.id,
        'status': 5,
        // 'channelName': call.channelName
      });
    } else {
      getIt<SocketManager>().emit(SocketConstants.onRejectCall, {
        'uuid': call.uuid,
        'userId': _userProfileManager.user.value!.id,
        'status': 2
      });
    }
    if (Platform.isIOS) {
      voipController.endCall(call);
    }
    clearCall();
    Get.back();

    if (isLaunchedFromCallNotification) {
      Get.offAll(() => const DashboardScreen());
    }
    SharedPrefs().setCallNotificationData(null);
  }

  void declineIncomingCall({required Call call}) async {
    getIt<SocketManager>().emit(SocketConstants.onRejectCall, {
      'uuid': call.uuid,
      'userId': _userProfileManager.user.value!.id,
      'status': 2
    });

    remoteJoined.value = false;

    if (isLaunchedFromCallNotification) {
      Get.offAll(() => const DashboardScreen());
    }
    SharedPrefs().setCallNotificationData(null);
  }

// void timeOutCall(Call call) async {
//   getIt<SocketManager>().emit(SocketConstants.onNotAnswered, {
//     'uuid': call.uuid,
//     'userId': _userProfileManager.user.value!.id,
//     'status': 3
//   });
//   if (Platform.isIOS) {
//     getIt<VoipController>().endCall(call);
//   }
//   // callId = 0;
//   remoteJoined.value = false;
//   Get.back();
// }
}
