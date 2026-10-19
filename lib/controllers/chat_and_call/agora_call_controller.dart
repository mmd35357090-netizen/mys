
import 'dart:io';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:foap/controllers/chat_and_call/voip_controller.dart';
import 'package:foap/helper/imports/call_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/dashboard_imports.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../helper/permission_utils.dart';
import '../../main.dart';
import '../../manager/socket_manager.dart';
import '../../screens/settings_menu/settings_controller.dart';
import '../../util/ad_helper.dart';
import '../../util/constant_util.dart';
import '../../util/shared_prefs.dart';

class AgoraCallController extends GetxController {
  final UserProfileManager _userProfileManager = Get.find();
  final SettingsController _settingsController = Get.find();

  final AudioPlayer player = AudioPlayer();

  RtcEngine? engine;

  final RxInt remoteUserId = 0.obs;

  final RxBool isFront = false.obs;
  final RxBool reConnectingRemoteView = false.obs;
  final RxBool videoPaused = false.obs;
  final RxBool mutedAudio = false.obs;
  final RxBool mutedVideo = false.obs;
  final RxBool switchMainView = false.obs;
  final RxBool remoteJoined = false.obs;

  // Speaker ON/OFF state
  final RxBool speakerphoneEnabled = false.obs;

  late String localCallId;
  UserModel? opponent;

  bool _isEndingCall = false;
  int _callGeneration = 0;
  Future<void>? _cleanupFuture;

  void setIncomingCallId(int id) {}


  // --------------------------------------------------
  // CREATE CALL REQUEST
  // --------------------------------------------------

  Future<void> makeCallRequest({required Call call}) async {
    opponent = call.opponent;
    localCallId = randomId();

    getIt<SocketManager>().emit(
      SocketConstants.callCreate,
      {
        CallArgParams.senderId: _userProfileManager.user.value!.id,
        CallArgParams.receiverId: call.opponent.id,
        CallArgParams.callType: call.callType,
        CallArgParams.localCallId: localCallId,
      },
    );
  }

  // --------------------------------------------------
  // INITIALIZE CALL
  // --------------------------------------------------

  Future<void> initializeCalling({required Call call}) async {
    final appId =
        _settingsController.setting.value?.agoraApiKey ?? '';

    if (appId.isEmpty || _isEndingCall) {
      debugPrint('Agora App ID is empty or call is ending.');
      return;
    }

    final generation = ++_callGeneration;

    try {
      await _initAgoraRtcEngine(
        callType: call.callType == 1
            ? AgoraCallType.audio
            : AgoraCallType.video,
      );

      if (_isEndingCall || generation != _callGeneration) {
        await cleanupAgora();
        return;
      }

      final currentEngine = engine;
      if (currentEngine == null) return;

      _addAgoraEventHandlers(currentEngine);

      if (call.callType != 1) {
        const configuration = VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 1920, height: 1080),
          orientationMode: OrientationMode.orientationModeAdaptive,
        );

        await currentEngine.setVideoEncoderConfiguration(
          configuration,
        );
      }

      if (_isEndingCall || generation != _callGeneration) {
        await cleanupAgora();
        return;
      }

      await currentEngine.joinChannel(
        token: call.token,
        channelId: call.channelName,
        uid: _userProfileManager.user.value!.id,
        options: const ChannelMediaOptions(),
      );

      if (_isEndingCall || generation != _callGeneration) {
        await cleanupAgora();
        return;
      }

      if (call.callType == 1) {
        Get.to(() => AudioCallingScreen(call: call));
      } else {
        Get.to(() => VideoCallingScreen(call: call));
      }

      update();
    } catch (e, stackTrace) {
      debugPrint('Initialize calling error: $e');
      debugPrint('$stackTrace');
      await cleanupAgora();
    }
  }

  // --------------------------------------------------
  // CREATE AGORA ENGINE
  // --------------------------------------------------

  Future<void> _initAgoraRtcEngine({
    required AgoraCallType callType,
  }) async {
    final appId =
        _settingsController.setting.value?.agoraApiKey ?? '';

    if (appId.isEmpty) {
      throw Exception('Agora App ID is empty.');
    }

    if (engine != null) {
      await cleanupAgora();
    }

    final newEngine = createAgoraRtcEngine();
    engine = newEngine;

    await newEngine.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile:
            ChannelProfileType.channelProfileCommunication,
      ),
    );

    await newEngine.enableAudio();
    await newEngine.enableLocalAudio(true);

    if (callType == AgoraCallType.video) {
      await newEngine.enableVideo();
      await newEngine.enableLocalVideo(true);
      await newEngine.startPreview();
    }
  }

  // --------------------------------------------------
  // SWITCH CAMERA
  // --------------------------------------------------

  Future<void> onToggleCamera() async {
    final currentEngine = engine;

    if (currentEngine == null || _isEndingCall) return;

    try {
      await currentEngine.switchCamera();
      isFront.value = !isFront.value;
    } catch (e) {
      debugPrint('Switch camera error: $e');
    }
  }

  // --------------------------------------------------
  // SWITCH MAIN / REMOTE VIEW
  // --------------------------------------------------

  void toggleMainView() {
    switchMainView.value = !switchMainView.value;
    update();
  }

  // --------------------------------------------------
  // MICROPHONE ON / OFF
  // --------------------------------------------------

  Future<void> onToggleMuteAudio() async {
    final currentEngine = engine;

    if (currentEngine == null || _isEndingCall) return;

    final newMutedState = !mutedAudio.value;

    try {
      await currentEngine.enableLocalAudio(!newMutedState);
      await currentEngine.muteLocalAudioStream(newMutedState);

      mutedAudio.value = newMutedState;
      update();
    } catch (e) {
      debugPrint('Toggle microphone error: $e');
    }
  }

  // --------------------------------------------------
  // CAMERA ON / OFF
  // --------------------------------------------------

  Future<void> onToggleMuteVideo() async {
    final currentEngine = engine;

    if (currentEngine == null || _isEndingCall) return;

    final newMutedState = !mutedVideo.value;

    try {
      await currentEngine.muteLocalVideoStream(newMutedState);
      await currentEngine.enableLocalVideo(!newMutedState);

      if (newMutedState) {
        await currentEngine.stopPreview();
      } else {
        await currentEngine.startPreview();
      }

      mutedVideo.value = newMutedState;
      update();
    } catch (e) {
      debugPrint('Toggle camera error: $e');
    }
  }

  // --------------------------------------------------
  // AGORA EVENT HANDLERS
  // --------------------------------------------------

  void _addAgoraEventHandlers(RtcEngine currentEngine) {
    currentEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (
          RtcConnection connection,
          int elapsed,
        ) {
          debugPrint(
            'Local user ${connection.localUid} joined channel.',
          );
        },

        onUserJoined: (
          RtcConnection connection,
          int remoteUid,
          int elapsed,
        ) {
          debugPrint('Remote user $remoteUid joined.');

          remoteJoined.value = true;
          remoteUserId.value = remoteUid;

          update();
        },

        onUserOffline: (
          RtcConnection connection,
          int remoteUid,
          UserOfflineReasonType reason,
        ) {
          debugPrint('Remote user $remoteUid left channel.');

          if (remoteUserId.value == remoteUid) {
            remoteUserId.value = 0;
          }

          update();
        },

        onTokenPrivilegeWillExpire: (
          RtcConnection connection,
          String token,
        ) {
          debugPrint(
            'Agora token will expire: ${connection.toJson()}',
          );
        },

        onConnectionStateChanged: (
          RtcConnection connection,
          ConnectionStateType state,
          ConnectionChangedReasonType reason,
        ) {
          if (state ==
              ConnectionStateType.connectionStateConnected) {
            reConnectingRemoteView.value = false;
          } else if (state ==
              ConnectionStateType.connectionStateReconnecting) {
            reConnectingRemoteView.value = true;
          }

          update();
        },

        onRemoteVideoStateChanged: (
          RtcConnection connection,
          int remoteUid,
          RemoteVideoState state,
          RemoteVideoStateReason reason,
          int elapsed,
        ) {
          if (state == RemoteVideoState.remoteVideoStateStopped ||
              state == RemoteVideoState.remoteVideoStateFailed) {
            videoPaused.value = true;
          } else if (state ==
              RemoteVideoState.remoteVideoStateDecoding) {
            videoPaused.value = false;
          }

          update();
        },
      ),
    );
  }

  // --------------------------------------------------
  // CALL STATUS FROM SOCKET
  // --------------------------------------------------

  void callStatusUpdateReceived(
    Map<String, dynamic> updatedData,
  ) {
    final status = (updatedData['status'] as num).toInt();

    final call = Call(
      uuid: updatedData['uuid'],
      channelName: '',
      isOutGoing: false,
      opponent: UserModel(),
      token: '',
      callType: 0,
      callId: updatedData['id'],
    );

    if (status == 5 || status == 2) {
      if (Platform.isIOS) {
        getIt<VoipController>().endCall(call);
      }

      receivedEndCallNotification(call);
    } else if (status == 4) {
      player.stop();
    }
  }

  // --------------------------------------------------
  // OUTGOING CALL CONFIRMATION
  // --------------------------------------------------

  Future<void> outgoingCallConfirmationReceived(
    Map<String, dynamic> updatedData,
  ) async {
    final String uuid = updatedData['uuid'];
    final int id = updatedData['id'];
    final String confirmedLocalCallId = updatedData['localCallId'];
    final String? agoraToken = updatedData['token'];
    final String? channelName = updatedData['channelName'];
    final int callType = updatedData['callType'];

    if (this.localCallId != confirmedLocalCallId ||
        opponent == null ||
        agoraToken == null ||
        channelName == null ||
        _isEndingCall) {
      return;
    }

    final call = Call(
      uuid: uuid,
      channelName: channelName,
      isOutGoing: true,
      opponent: opponent!,
      token: agoraToken,
      callType: callType,
      callId: id,
    );

    if (Platform.isIOS) {
      getIt<VoipController>().outGoingCall(call);
    }

    await initializeCalling(call: call);

    if (!_isEndingCall) {
      try {
        await player.setAsset('assets/ringtone.mp3');
        await player.play();
      } catch (e) {
        debugPrint('Ringtone playback error: $e');
      }
    }
  }

  // --------------------------------------------------
  // INCOMING CALL
  // --------------------------------------------------

  void incomingCallReceived(
    Map<String, dynamic> updatedData,
  ) {
    final int callType = updatedData['callType'];
    final String userImage = updatedData['userImage'];
    final String username = updatedData['username'];
    final int callerId = updatedData['callerId'];

    final incomingOpponent = UserModel()
      ..id = callerId
      ..userName = username
      ..picture = userImage;

    // Incoming-call navigation remains controlled by your
    // existing incoming-call flow.
    debugPrint(
      'Incoming ${callType == 1 ? 'audio' : 'video'} call '
      'from ${incomingOpponent.userName}.',
    );
  }

  // --------------------------------------------------
  // ACCEPT CALL
  // --------------------------------------------------

  Future<void> acceptCall({required Call call}) async {
    if (_isEndingCall) return;

    getIt<SocketManager>().emit(
      SocketConstants.onAcceptCall,
      {
        'uuid': call.uuid,
        'userId': _userProfileManager.user.value!.id,
        'status': 4,
      },
    );

    remoteUserId.value = call.opponent.id;
    remoteJoined.value = true;

    try {
      await player.stop();
    } catch (e) {
      debugPrint('Stop ringtone error: $e');
    }

    await initializeCalling(call: call);
  }

  void initiateAcceptCall({required Call call}) {
    askForPermissionsForCall(call: call);
  }

  void askForPermissionsForCall({required Call call}) {
    PermissionUtils.requestPermission(
      call.callType == 1
          ? [Permission.microphone]
          : [Permission.camera, Permission.microphone],
      isOpenSettings: false,
      permissionGrant: () async {
        await acceptCall(call: call);
      },
      permissionDenied: () {
        declineCall(call: call);

        AppUtil.showToast(
          message: pleaseAllowAccessToMicrophoneForAudioCallString,
          isSuccess: false,
        );
      },
      permissionNotAskAgain: () {
        declineCall(call: call);

        AppUtil.showToast(
          message: pleaseAllowAccessToMicrophoneForAudioCallString,
          isSuccess: false,
        );
      },
    );
  }

  // --------------------------------------------------
  // STOP CAMERA / MICROPHONE / AGORA
  // --------------------------------------------------

  Future<void> cleanupAgora() async {
    final runningCleanup = _cleanupFuture;

    if (runningCleanup != null) {
      await runningCleanup;
      return;
    }

    final oldEngine = engine;
    engine = null;

    if (oldEngine == null) {
      remoteUserId.value = 0;
      clear();
      return;
    }

    final task = _performAgoraCleanup(oldEngine);
    _cleanupFuture = task;

    try {
      await task;
    } finally {
      _cleanupFuture = null;
      remoteUserId.value = 0;
      clear();
    }
  }

Future<void> _performAgoraCleanup(
  RtcEngine oldEngine,
) async {
  // Turn off speakerphone
  try {
    await oldEngine.setEnableSpeakerphone(false);
  } catch (e) {
    debugPrint('Disable speakerphone error: $e');
  } finally {
    speakerphoneEnabled.value = false;
  }

  // Mute microphone stream
  try {
    await oldEngine.muteLocalAudioStream(true);
  } catch (e) {
    debugPrint('Mute audio error: $e');
  }

  // Mute camera stream
  try {
    await oldEngine.muteLocalVideoStream(true);
  } catch (e) {
    debugPrint('Mute video error: $e');
  }

  // Disable microphone
  try {
    await oldEngine.enableLocalAudio(false);
  } catch (e) {
    debugPrint('Disable microphone error: $e');
  }

  // Disable camera
  try {
    await oldEngine.enableLocalVideo(false);
  } catch (e) {
    debugPrint('Disable camera error: $e');
  }

  // Stop camera preview
  try {
    await oldEngine.stopPreview();
  } catch (e) {
    debugPrint('Stop camera preview error: $e');
  }

  // Leave Agora channel
  try {
    await oldEngine.leaveChannel();
  } catch (e) {
    debugPrint('Leave channel error: $e');
  }

  // Release engine once
  try {
    await oldEngine.release();
  } catch (e) {
    debugPrint('Release Agora engine error: $e');
  }
}

    Future<void> toggleSpeakerphone() async {
    final currentEngine = engine;

    if (currentEngine == null || _isEndingCall) return;

    final newState = !speakerphoneEnabled.value;

    try {
      await currentEngine.setEnableSpeakerphone(newState);
      speakerphoneEnabled.value = newState;
      update();
    } catch (e) {
      debugPrint('Toggle speakerphone error: $e');
    }
    }
  
  // --------------------------------------------------
  // FINISH CALL UI
  // --------------------------------------------------

  Future<void> _finishCallUi({
    bool alreadyEnding = false,
  }) async {
    if (_isEndingCall && !alreadyEnding) return;

    if (!alreadyEnding) {
      _isEndingCall = true;
      _callGeneration++;
    }

    try {
      try {
        await player.stop();
      } catch (e) {
        debugPrint('Stop ringtone error: $e');
      }

      await cleanupAgora();

      await SharedPrefs().setCallNotificationData(null);

      if (isLaunchedFromCallNotification) {
        Get.offAll(() => const DashboardScreen());
      } else if (Get.key.currentState?.canPop() == true) {
        Get.back();
      }

      InterstitialAds().show();
    } catch (e) {
      debugPrint('Finish call UI error: $e');
    } finally {
      _isEndingCall = false;
    }
  }

  // --------------------------------------------------
  // REMOTE END CALL
  // --------------------------------------------------

  Future<void> receivedEndCallNotification(Call call) async {
    await _finishCallUi();
  }

  // --------------------------------------------------
  // LOCAL END CALL
  // --------------------------------------------------

  Future<void> onCallEnd(Call call) async {
    if (_isEndingCall) return;

    _isEndingCall = true;
    _callGeneration++;

    try {
      await player.stop();

      if (remoteJoined.value) {
        getIt<SocketManager>().emit(
          SocketConstants.onCompleteCall,
          {
            'uuid': call.uuid,
            'userId': _userProfileManager.user.value!.id,
            'status': 5,
          },
        );
      } else {
        getIt<SocketManager>().emit(
          SocketConstants.onRejectCall,
          {
            'uuid': call.uuid,
            'userId': _userProfileManager.user.value!.id,
            'status': 2,
          },
        );
      }

      if (Platform.isIOS) {
        getIt<VoipController>().endCall(call);
      }

      await _finishCallUi(alreadyEnding: true);
    } catch (e) {
      debugPrint('End call error: $e');
      await cleanupAgora();
    } finally {
      _isEndingCall = false;
    }
  }

  // --------------------------------------------------
  // DECLINE CALL
  // --------------------------------------------------

  Future<void> declineCall({required Call call}) async {
    if (_isEndingCall) return;

    _isEndingCall = true;
    _callGeneration++;

    try {
      getIt<SocketManager>().emit(
        SocketConstants.onRejectCall,
        {
          'uuid': call.uuid,
          'userId': _userProfileManager.user.value!.id,
          'status': 2,
        },
      );

      if (Platform.isIOS) {
        getIt<VoipController>().endCall(call);
      }

      await _finishCallUi(alreadyEnding: true);
    } catch (e) {
      debugPrint('Decline call error: $e');
      await cleanupAgora();
    } finally {
      _isEndingCall = false;
    }
  }

  // --------------------------------------------------
  // CALL TIMEOUT
  // --------------------------------------------------

  Future<void> timeOutCall({required Call call}) async {
    // Uses the existing reject flow because the exact timeout
    // SocketConstants name is not present in the supplied code.
    await declineCall(call: call);
  }

  // --------------------------------------------------
  // RESET OBSERVABLE STATE
  // --------------------------------------------------

void clear() {
  isFront.value = false;
  reConnectingRemoteView.value = false;
  videoPaused.value = false;
  mutedAudio.value = false;
  mutedVideo.value = false;
  switchMainView.value = false;
  remoteJoined.value = false;
  remoteUserId.value = 0;
  speakerphoneEnabled.value = false;

  update();
}
