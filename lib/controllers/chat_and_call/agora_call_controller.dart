
import 'dart:async';
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
  final SettingsController _settingsController = Get.find();

  RtcEngine? engine;

  final RxInt remoteUserId = 0.obs;

  final RxBool isFront = false.obs;
  final RxBool reConnectingRemoteView = false.obs;
  final RxBool videoPaused = false.obs;
  final RxBool mutedAudio = false.obs;
  final RxBool mutedVideo = false.obs;
  final RxBool switchMainView = false.obs;
  final RxBool remoteJoined = false.obs;

  final AudioPlayer player = AudioPlayer();

  late String localCallId;
  UserModel? opponent;

  bool _isInitializingCall = false;
  bool _isCleaningCall = false;

  int _callGeneration = 0;
  Future<void>? _cleanupFuture;

  // Prevent duplicate end-call ads on this device.
  final Set<String> _shownCallEndAds = <String>{};

  // --------------------------------------------------
  // Call-end advertisement
  // --------------------------------------------------

  void _showCallEndAdOnce(Call call) {
    final String adKey = call.uuid.isNotEmpty
        ? call.uuid
        : 'call-${call.callId}';

    if (!_shownCallEndAds.add(adKey)) {
      debugPrint('Call-end ad already requested for $adKey');
      return;
    }

    debugPrint('Requesting call-end interstitial for $adKey');

    try {
      InterstitialAds().show();
    } catch (e) {
      debugPrint('Call-end interstitial error: $e');
    }
  }

  // --------------------------------------------------
  // Reset call UI state
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
  }

  void setIncomingCallId(int id) {
    // Reserved for incoming call ID.
  }

  // --------------------------------------------------
  // Create outgoing call request
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
  // Initialize Audio / Video call
  // --------------------------------------------------

  Future<void> initializeCalling({required Call call}) async {
    final String appId =
        _settingsController.setting.value?.agoraApiKey ?? '';

    if (appId.isEmpty) {
      debugPrint('Agora App ID is empty.');

      AppUtil.showToast(
        message: 'Calling service is not configured.',
        isSuccess: false,
      );
      return;
    }

    if (_isInitializingCall || _isCleaningCall) {
      debugPrint('Call initialization or cleanup is in progress.');
      return;
    }

    _isInitializingCall = true;

    try {
      // Release any engine left from an earlier call.
      if (engine != null) {
        await clearCall();
      }

      if (_isCleaningCall) return;

      final int generation = ++_callGeneration;

      final AgoraCallType callType = call.callType == 1
          ? AgoraCallType.audio
          : AgoraCallType.video;

      await _initAgoraRtcEngine(
        callType: callType,
        appId: appId,
      );

      if (generation != _callGeneration) return;

      final RtcEngine? callEngine = engine;

      if (callEngine == null) {
        throw StateError('Agora engine was not created.');
      }

      _addAgoraEventHandlers(callEngine);

      if (callType == AgoraCallType.video) {
        const VideoEncoderConfiguration configuration =
            VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 1280, height: 720),
          orientationMode: OrientationMode.orientationModeAdaptive,
        );

        await callEngine.setVideoEncoderConfiguration(configuration);

        if (generation != _callGeneration) return;
      }

      await callEngine.joinChannel(
        token: call.token,
        channelId: call.channelName,
        uid: _userProfileManager.user.value!.id,
        options: const ChannelMediaOptions(),
      );

      if (generation != _callGeneration) return;

      if (call.callType == 1) {
        Get.to(
          () => AudioCallingScreen(call: call),
          transition: Transition.noTransition,
        );
      } else {
        Get.to(
          () => VideoCallingScreen(call: call),
          transition: Transition.noTransition,
        );
      }

      update();
    } catch (e, stackTrace) {
      debugPrint('initializeCalling error: $e');
      debugPrintStack(stackTrace: stackTrace);

      AppUtil.showToast(
        message: 'Unable to start the call. Please try again.',
        isSuccess: false,
      );

      await clearCall();
    } finally {
      _isInitializingCall = false;
    }
  }

  // --------------------------------------------------
  // Initialize Agora engine
  // --------------------------------------------------

  Future<void> _initAgoraRtcEngine({
    required AgoraCallType callType,
    required String appId,
  }) async {
    final RtcEngine callEngine = createAgoraRtcEngine();

    engine = callEngine;

    await callEngine.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    if (callType == AgoraCallType.video) {
      await callEngine.enableVideo();
      await callEngine.startPreview();
    } else {
      await callEngine.enableAudio();
    }
  }

  // --------------------------------------------------
  // Switch camera
  // --------------------------------------------------

  Future<void> onToggleCamera() async {
    final RtcEngine? callEngine = engine;

    if (callEngine == null || _isCleaningCall) return;

    try {
      await callEngine.switchCamera();

      isFront.value = !isFront.value;
      update();
    } catch (e) {
      debugPrint('Switch camera error: $e');
    }
  }

  // --------------------------------------------------
  // Switch main video view
  // --------------------------------------------------

  void toggleMainView() {
    switchMainView.value = !switchMainView.value;
    update();
  }

  // --------------------------------------------------
  // Toggle microphone
  // --------------------------------------------------

  Future<void> onToggleMuteAudio() async {
    final RtcEngine? callEngine = engine;

    if (callEngine == null || _isCleaningCall) return;

    final bool nextValue = !mutedAudio.value;

    try {
      await callEngine.muteLocalAudioStream(nextValue);

      mutedAudio.value = nextValue;
      update();
    } catch (e) {
      debugPrint('Microphone mute error: $e');
    }
  }

  // --------------------------------------------------
  // Toggle video
  // --------------------------------------------------

  Future<void> onToggleMuteVideo() async {
    final RtcEngine? callEngine = engine;

    if (callEngine == null || _isCleaningCall) return;

    final bool nextValue = !mutedVideo.value;

    try {
      await callEngine.muteLocalVideoStream(nextValue);

      mutedVideo.value = nextValue;
      update();
    } catch (e) {
      debugPrint('Video mute error: $e');
    }
  }

  // --------------------------------------------------
  // Agora event handlers
  // --------------------------------------------------

  void _addAgoraEventHandlers(RtcEngine callEngine) {
    callEngine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (
          RtcConnection connection,
          int elapsed,
        ) {
          debugPrint('Local user ${connection.localUid} joined.');
        },

        onUserJoined: (
          RtcConnection connection,
          int remoteUid,
          int elapsed,
        ) {
          if (!identical(engine, callEngine) || _isCleaningCall) {
            return;
          }

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
          if (!identical(engine, callEngine)) return;

          debugPrint('Remote user $remoteUid left.');

          if (remoteUserId.value == remoteUid) {
            remoteUserId.value = 0;
          }

          update();
        },

        onTokenPrivilegeWillExpire: (
          RtcConnection connection,
          String token,
        ) {
          debugPrint('Agora token is about to expire.');
        },

        onConnectionStateChanged: (
          RtcConnection connection,
          ConnectionStateType state,
          ConnectionChangedReasonType reason,
        ) {
          if (!identical(engine, callEngine)) return;

          reConnectingRemoteView.value =
              state == ConnectionStateType.connectionStateReconnecting;

          update();
        },

        onRemoteVideoStateChanged: (
          RtcConnection connection,
          int remoteUid,
          RemoteVideoState state,
          RemoteVideoStateReason reason,
          int elapsed,
        ) {
          debugPrint(
            'Remote video state changed: $remoteUid, $state',
          );
        },
      ),
    );
  }

  // --------------------------------------------------
  // Call status received from server
  // --------------------------------------------------

  void callStatusUpdateReceived(
    Map<String, dynamic> updatedData,
  ) {
    final VoipController voipController = Get.find();

    final int callId = updatedData['id'] as int;
    final int status = updatedData['status'] as int;
    final int callerId = updatedData['callerId'] as int;
    final int myUserId = _userProfileManager.user.value!.id;

    final CallHistoryController callHistoryController =
        CallHistoryController();

    callHistoryController.callDetail(
      callId: callId,
      resultCallback: (result) {
        final Call call = Call(
          uuid: updatedData['uuid'],
          channelName: '',
          isOutGoing: myUserId == callerId,
          opponent: myUserId == callerId
              ? result.receiverDetail
              : result.callerDetail,
          token: '',
          callType: result.callType,
          callId: callId,
        );

        if (status == 2) {
          if (Platform.isIOS) {
            voipController.declinedByOpponent(call);
          }

          if (myUserId == callerId) {
            receivedDeclinedCallNotification(call);
          }
        } else if (status == 5) {
          if (Platform.isIOS) {
            voipController.endCallByOpponent(call);
          }

          receivedEndCallNotification(call);
        } else if (status == 4) {
          player.stop();
        }
      },
    );
  }

  // --------------------------------------------------
  // Outgoing call confirmation
  // --------------------------------------------------

  Future<void> outgoingCallConfirmationReceived(
    Map<String, dynamic> updatedData,
  ) async {
    final VoipController voipController = Get.find();

    final String uuid = updatedData['uuid'];
    final int id = updatedData['id'];
    final String confirmedLocalCallId = updatedData['localCallId'];
    final String agoraToken = updatedData['token'];
    final String channelName = updatedData['channelName'];
    final int callType = updatedData['callType'];

    if (opponent == null || localCallId != confirmedLocalCallId) {
      return;
    }

    final Call call = Call(
      uuid: uuid,
      channelName: channelName,
      isOutGoing: true,
      opponent: opponent!,
      token: agoraToken,
      callType: callType,
      callId: id,
    );

    if (Platform.isIOS) {
      voipController.outGoingCall(call);
    }

    await initializeCalling(call: call);

    if (engine != null) {
      try {
        await player.setAsset('assets/ringtone.mp3');
        await player.play();
      } catch (e) {
        debugPrint('Outgoing ringtone error: $e');
      }
    }
  }

  // --------------------------------------------------
  // Accept incoming call
  // --------------------------------------------------

  Future<void> acceptCall({required Call call}) async {
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

    await initializeCalling(call: call);

    await player.stop();
  }

  void initiateAcceptCall({required Call call}) {
    askForPermissionsForCall(call: call);
  }

  // --------------------------------------------------
  // Call permissions
  // --------------------------------------------------

  void askForPermissionsForCall({required Call call}) {
    final bool isVideoCall = call.callType != 1;

    PermissionUtils.requestPermission(
      isVideoCall
          ? [Permission.camera, Permission.microphone]
          : [Permission.microphone],
      isOpenSettings: false,
      permissionGrant: () async {
        await acceptCall(call: call);
      },
      permissionDenied: () {
        declineIncomingCall(call: call);

        AppUtil.showToast(
          message: isVideoCall
              ? 'Please allow camera and microphone access.'
              : pleaseAllowAccessToMicrophoneForAudioCallString,
          isSuccess: false,
        );
      },
      permissionNotAskAgain: () {
        declineIncomingCall(call: call);

        AppUtil.showToast(
          message: isVideoCall
              ? 'Please allow camera and microphone access in settings.'
              : pleaseAllowAccessToMicrophoneForAudioCallString,
          isSuccess: false,
        );
      },
    );
  }

  // --------------------------------------------------
  // Release Agora engine
  // --------------------------------------------------

  Future<void> _releaseAgoraEngine(RtcEngine callEngine) async {
    try {
      await callEngine.muteLocalAudioStream(true);
    } catch (e) {
      debugPrint('Mute audio error: $e');
    }

    try {
      await callEngine.muteLocalVideoStream(true);
    } catch (e) {
      debugPrint('Mute video error: $e');
    }

    try {
      await callEngine.enableLocalAudio(false);
    } catch (e) {
      debugPrint('Disable local audio error: $e');
    }

    try {
      await callEngine.enableLocalVideo(false);
    } catch (e) {
      debugPrint('Disable local video error: $e');
    }

    try {
      await callEngine.stopPreview();
    } catch (e) {
      debugPrint('Stop preview error: $e');
    }

    try {
      await callEngine.leaveChannel();
    } catch (e) {
      debugPrint('Leave channel error: $e');
    }

    try {
      await callEngine.release();
    } catch (e) {
      debugPrint('Release Agora engine error: $e');
    }

    if (identical(engine, callEngine)) {
      engine = null;
    }
  }

  // --------------------------------------------------
  // Clear call and release resources
  // --------------------------------------------------

  Future<void> clearCall() {
    final Future<void>? existingCleanup = _cleanupFuture;

    if (existingCleanup != null) {
      return existingCleanup;
    }

    final Future<void> cleanup = _performClearCall();

    _cleanupFuture = cleanup;

    return cleanup.whenComplete(() {
      if (identical(_cleanupFuture, cleanup)) {
        _cleanupFuture = null;
      }
    });
  }

  Future<void> _performClearCall() async {
    _isCleaningCall = true;
    _callGeneration++;
    _isInitializingCall = false;

    try {
      try {
        await player.stop();
      } catch (e) {
        debugPrint('Stop ringtone error: $e');
      }

      final RtcEngine? callEngine = engine;

      if (callEngine != null) {
        await _releaseAgoraEngine(callEngine);
      }
    } finally {
      clear();
      update();
      _isCleaningCall = false;
    }
  }

  // --------------------------------------------------
  // Opponent declined call
  // --------------------------------------------------

  Future<void> receivedDeclinedCallNotification(Call call) async {
    await player.stop();

    Get.back();

    Get.to(
      () => NotAnsweredCall(call: call),
      transition: Transition.noTransition,
    );

    update();
  }

  // --------------------------------------------------
  // Opponent ended call
  // --------------------------------------------------

  Future<void> receivedEndCallNotification(Call call) async {
    await clearCall();

    Get.back();

    // Show an interstitial once for this call on this device.
    _showCallEndAdOnce(call);

    if (isLaunchedFromCallNotification) {
      Get.offAll(() => const DashboardScreen());
    }

    SharedPrefs().setCallNotificationData(null);
  }

  // --------------------------------------------------
  // Current user ends call
  // --------------------------------------------------

  Future<void> onCallEnd(Call call) async {
    final VoipController voipController = Get.find();

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
      voipController.endCall(call);
    }

    await clearCall();

    Get.back();

    // Show an interstitial for the user ending the call too.
    // The UUID guard prevents duplicate ads if a socket event arrives.
    _showCallEndAdOnce(call);

    if (isLaunchedFromCallNotification) {
      Get.offAll(() => const DashboardScreen());
    }

    SharedPrefs().setCallNotificationData(null);
  }

  // --------------------------------------------------
  // Decline incoming call
  // --------------------------------------------------

  Future<void> declineIncomingCall({required Call call}) async {
    getIt<SocketManager>().emit(
      SocketConstants.onRejectCall,
      {
        'uuid': call.uuid,
        'userId': _userProfileManager.user.value!.id,
        'status': 2,
      },
    );

    await clearCall();

    if (isLaunchedFromCallNotification) {
      Get.offAll(() => const DashboardScreen());
    }

    SharedPrefs().setCallNotificationData(null);
  }
}
