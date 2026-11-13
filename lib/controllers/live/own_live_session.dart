import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart';

/// One live stream carried by our own LiveKit server (no Agora).
/// Hosts publish camera + microphone, everybody else only watches.
class OwnLiveSession {
  final String url;
  final String token;
  final bool isHost;

  /// Called whenever the set of remote videos / paused videos changed.
  final VoidCallback onRemoteChanged;
  final VoidCallback onLocalReady;
  final VoidCallback onDisconnected;

  final Room room = Room(
    roomOptions: const RoomOptions(adaptiveStream: true, dynacast: true),
  );

  /// user id -> video track of a remote host
  final Map<int, VideoTrack> remoteVideos = {};
  final Set<int> pausedVideos = {};
  LocalVideoTrack? localVideo;

  EventsListener<RoomEvent>? _listener;
  bool _disposed = false;
  bool _front = true;

  OwnLiveSession({
    required this.url,
    required this.token,
    required this.isHost,
    required this.onRemoteChanged,
    required this.onLocalReady,
    required this.onDisconnected,
  });

  int? _id(Participant p) => int.tryParse(p.identity);

  Future<void> connect() async {
    _listener = room.createListener();
    _listener!
      ..on<TrackSubscribedEvent>((e) {
        final id = _id(e.participant);
        if (id != null && e.track is VideoTrack) {
          remoteVideos[id] = e.track as VideoTrack;
          pausedVideos.remove(id);
          onRemoteChanged();
        }
      })
      ..on<TrackUnsubscribedEvent>((e) {
        final id = _id(e.participant);
        if (id != null && e.track is VideoTrack) {
          remoteVideos.remove(id);
          pausedVideos.remove(id);
          onRemoteChanged();
        }
      })
      ..on<ParticipantDisconnectedEvent>((e) {
        final id = _id(e.participant);
        if (id != null) {
          remoteVideos.remove(id);
          pausedVideos.remove(id);
          onRemoteChanged();
        }
      })
      ..on<TrackMutedEvent>((e) {
        final id = _id(e.participant);
        if (id != null &&
            e.participant is RemoteParticipant &&
            e.publication.kind == TrackType.VIDEO) {
          pausedVideos.add(id);
          onRemoteChanged();
        }
      })
      ..on<TrackUnmutedEvent>((e) {
        final id = _id(e.participant);
        if (id != null &&
            e.participant is RemoteParticipant &&
            e.publication.kind == TrackType.VIDEO) {
          pausedVideos.remove(id);
          onRemoteChanged();
        }
      })
      ..on<LocalTrackPublishedEvent>((e) {
        final track = e.publication.track;
        if (track is LocalVideoTrack) {
          localVideo = track;
          onLocalReady();
        }
      })
      ..on<RoomDisconnectedEvent>((_) {
        if (!_disposed) onDisconnected();
      });

    await room.connect(url, token);

    // people already in the room before us
    for (final p in room.remoteParticipants.values) {
      final id = _id(p);
      if (id == null) continue;
      for (final pub in p.videoTrackPublications) {
        final t = pub.track;
        if (t != null) {
          remoteVideos[id] = t;
          if (pub.muted) pausedVideos.add(id);
        }
      }
    }
    onRemoteChanged();

    if (isHost) {
      await room.localParticipant?.setCameraEnabled(true);
      await room.localParticipant?.setMicrophoneEnabled(true);
    }
  }

  Future<void> setMicEnabled(bool enabled) async {
    await room.localParticipant?.setMicrophoneEnabled(enabled);
  }

  Future<void> setCameraEnabled(bool enabled) async {
    await room.localParticipant?.setCameraEnabled(enabled);
  }

  Future<void> switchCamera() async {
    final track = localVideo;
    if (track == null) return;
    _front = !_front;
    await track.setCameraPosition(
        _front ? CameraPosition.front : CameraPosition.back);
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    try {
      await _listener?.dispose();
    } catch (_) {}
    try {
      await room.disconnect();
    } catch (e) {
      debugPrint('Own live disconnect error: $e');
    }
    try {
      await room.dispose();
    } catch (_) {}
    remoteVideos.clear();
    pausedVideos.clear();
    localVideo = null;
  }
}
