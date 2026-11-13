import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../api_handler/apis/rtc_api.dart';

/// One audio / video call carried by our own WebRTC stack.
/// Media goes peer-to-peer (or through our coturn when the network blocks
/// direct paths); the small signalling server only relays offer / answer / ICE.
class OwnCallSession {
  final RtcConfig config;
  final String room;
  final bool isCaller;
  final bool video;
  final String authToken;

  final VoidCallback onPeerPresent;
  final VoidCallback onPeerLeft;
  final VoidCallback onConnected;
  final VoidCallback onReconnecting;
  final VoidCallback onFailed;

  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  io.Socket? _socket;
  RTCPeerConnection? _pc;
  MediaStream? _localStream;

  bool _offered = false;
  bool _remoteDescriptionSet = false;
  bool _disposed = false;
  bool _usingFrontCamera = true;
  final List<RTCIceCandidate> _pendingCandidates = [];
  Timer? _disconnectTimer;

  OwnCallSession({
    required this.config,
    required this.room,
    required this.isCaller,
    required this.video,
    required this.authToken,
    required this.onPeerPresent,
    required this.onPeerLeft,
    required this.onConnected,
    required this.onReconnecting,
    required this.onFailed,
  });

  Future<void> start() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();

    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': {
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
      },
      'video': video
          ? {
              'facingMode': 'user',
              'width': {'ideal': 1280},
              'height': {'ideal': 720},
              'frameRate': {'ideal': 24},
            }
          : false,
    });
    localRenderer.srcObject = _localStream;

    _pc = await createPeerConnection({
      'iceServers': config.iceServers,
      'sdpSemantics': 'unified-plan',
    });

    for (final track in _localStream!.getTracks()) {
      await _pc!.addTrack(track, _localStream!);
    }

    _pc!.onIceCandidate = (candidate) {
      if (candidate.candidate == null) return;
      _send({'type': 'candidate', 'candidate': candidate.toMap()});
    };

    _pc!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        remoteRenderer.srcObject = event.streams[0];
      }
    };

    _pc!.onIceConnectionState = (state) {
      if (_disposed) return;
      switch (state) {
        case RTCIceConnectionState.RTCIceConnectionStateConnected:
        case RTCIceConnectionState.RTCIceConnectionStateCompleted:
          _disconnectTimer?.cancel();
          onConnected();
          break;
        case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
          onReconnecting();
          // give the network a few seconds to come back before restarting
          _disconnectTimer?.cancel();
          _disconnectTimer = Timer(const Duration(seconds: 6), () {
            if (!_disposed && isCaller) _restartIce();
          });
          break;
        case RTCIceConnectionState.RTCIceConnectionStateFailed:
          onReconnecting();
          if (isCaller) {
            _restartIce();
          } else {
            onFailed();
          }
          break;
        default:
          break;
      }
    };

    _connectSignaling();
  }

  void _connectSignaling() {
    final socket = io.io(
      config.signalingUrl,
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'reconnection': true,
        'auth': {'token': authToken},
        'query': {'token': authToken},
      },
    );
    _socket = socket;

    socket.onConnect((_) {
      socket.emit('join', {'room': room});
    });

    socket.on('joined', (data) async {
      if (_disposed) return;
      if (data is Map && data['ok'] == true) {
        final peers = ((data['peers'] ?? 0) as num).toInt();
        if (peers > 0) {
          onPeerPresent();
          if (isCaller) await _makeOffer();
        }
      } else {
        onFailed();
      }
    });

    socket.on('peer-joined', (_) async {
      if (_disposed) return;
      onPeerPresent();
      if (isCaller) await _makeOffer();
    });

    socket.on('peer-left', (_) {
      if (_disposed) return;
      onPeerLeft();
    });

    socket.on('signal', (data) async {
      if (_disposed || data is! Map) return;
      try {
        await _handleSignal(Map<String, dynamic>.from(data));
      } catch (e) {
        debugPrint('Own call signal error: $e');
      }
    });

    socket.onConnectError((e) {
      debugPrint('Own call signalling error: $e');
    });

    socket.connect();
  }

  void _send(Map<String, dynamic> data) {
    _socket?.emit('signal', data);
  }

  Future<void> _makeOffer({bool iceRestart = false}) async {
    final pc = _pc;
    if (pc == null || _disposed) return;
    if (_offered && !iceRestart) return;
    _offered = true;
    final offer = await pc.createOffer({
      'offerToReceiveAudio': true,
      'offerToReceiveVideo': video,
      if (iceRestart) 'iceRestart': true,
    });
    await pc.setLocalDescription(offer);
    _send({'type': 'offer', 'sdp': offer.sdp});
  }

  Future<void> _restartIce() async {
    if (_disposed || _pc == null) return;
    try {
      await _makeOffer(iceRestart: true);
    } catch (e) {
      debugPrint('ICE restart error: $e');
    }
  }

  Future<void> _handleSignal(Map<String, dynamic> data) async {
    final pc = _pc;
    if (pc == null) return;
    switch (data['type']) {
      case 'offer':
        await pc.setRemoteDescription(RTCSessionDescription(data['sdp'], 'offer'));
        _remoteDescriptionSet = true;
        await _flushCandidates();
        final answer = await pc.createAnswer({
          'offerToReceiveAudio': true,
          'offerToReceiveVideo': video,
        });
        await pc.setLocalDescription(answer);
        _send({'type': 'answer', 'sdp': answer.sdp});
        break;
      case 'answer':
        await pc.setRemoteDescription(RTCSessionDescription(data['sdp'], 'answer'));
        _remoteDescriptionSet = true;
        await _flushCandidates();
        break;
      case 'candidate':
        final c = data['candidate'];
        if (c == null) return;
        final candidate = RTCIceCandidate(
            c['candidate'], c['sdpMid'], (c['sdpMLineIndex'] as num?)?.toInt());
        if (_remoteDescriptionSet) {
          await pc.addCandidate(candidate);
        } else {
          _pendingCandidates.add(candidate);
        }
        break;
    }
  }

  Future<void> _flushCandidates() async {
    final pc = _pc;
    if (pc == null) return;
    for (final c in _pendingCandidates) {
      await pc.addCandidate(c);
    }
    _pendingCandidates.clear();
  }

  // ---------------- controls ----------------

  bool setMicMuted(bool muted) {
    for (final t in _localStream?.getAudioTracks() ?? <MediaStreamTrack>[]) {
      t.enabled = !muted;
    }
    return muted;
  }

  bool setCameraMuted(bool muted) {
    for (final t in _localStream?.getVideoTracks() ?? <MediaStreamTrack>[]) {
      t.enabled = !muted;
    }
    return muted;
  }

  Future<void> switchCamera() async {
    final tracks = _localStream?.getVideoTracks() ?? [];
    if (tracks.isEmpty) return;
    await Helper.switchCamera(tracks.first);
    _usingFrontCamera = !_usingFrontCamera;
  }

  bool get usingFrontCamera => _usingFrontCamera;

  Future<void> setSpeaker(bool on) async {
    await Helper.setSpeakerphoneOn(on);
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _disconnectTimer?.cancel();
    try {
      _socket?.dispose();
    } catch (_) {}
    try {
      for (final t in _localStream?.getTracks() ?? <MediaStreamTrack>[]) {
        await t.stop();
      }
      await _localStream?.dispose();
    } catch (_) {}
    try {
      await _pc?.close();
    } catch (_) {}
    try {
      await Helper.setSpeakerphoneOn(false);
    } catch (_) {}
    try {
      localRenderer.srcObject = null;
      remoteRenderer.srcObject = null;
      await localRenderer.dispose();
      await remoteRenderer.dispose();
    } catch (_) {}
    _pc = null;
    _localStream = null;
  }
}
