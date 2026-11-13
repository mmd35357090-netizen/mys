import 'package:foap/api_handler/api_wrapper.dart';

/// Server side switch: when [enabled] the call media runs on our own
/// WebRTC / TURN server instead of Agora.
class RtcConfig {
  final bool enabled;
  final String signalingUrl;
  final List<Map<String, dynamic>> iceServers;

  RtcConfig(
      {required this.enabled,
      this.signalingUrl = '',
      this.iceServers = const []});
}

class RtcApi {
  /// Returns null when the server cannot be reached (caller falls back to
  /// the previous provider).
  static Future<RtcConfig?> getConfig({required bool isAudio}) async {
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final result = await ApiWrapper()
            .getApi(
                url:
                    '${NetworkConstantsUtil.rtcConfig}?type=${isAudio ? 'audio' : 'video'}')
            .timeout(const Duration(seconds: 4));
        if (result?.success == true && result!.data['rtc'] != null) {
          final rtc = result.data['rtc'];
          if (rtc['enabled'] != true) return RtcConfig(enabled: false);
          final servers = <Map<String, dynamic>>[];
          for (final s in (rtc['iceServers'] as List<dynamic>? ?? [])) {
            servers.add(Map<String, dynamic>.from(s as Map));
          }
          return RtcConfig(
              enabled: true,
              signalingUrl: (rtc['signalingUrl'] ?? '').toString(),
              iceServers: servers);
        }
      } catch (_) {}
    }
    return null;
  }
}

/// Own-server (LiveKit) access for one live stream.
class LiveRtcConfig {
  final bool enabled;
  final bool canPublish;
  final String url;
  final String token;

  LiveRtcConfig(
      {required this.enabled,
      this.canPublish = false,
      this.url = '',
      this.token = ''});
}

class LiveRtcApi {
  /// null = server unreachable (fall back to the previous provider).
  static Future<LiveRtcConfig?> getConfig(
      {required String channel, required bool wantHost}) async {
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final result = await ApiWrapper()
            .getApi(
                url:
                    '${NetworkConstantsUtil.rtcLiveToken}?channel=${Uri.encodeQueryComponent(channel)}&host=${wantHost ? 1 : 0}')
            .timeout(const Duration(seconds: 5));
        if (result?.success == true && result!.data['rtc'] != null) {
          final rtc = result.data['rtc'];
          if (rtc['enabled'] != true) return LiveRtcConfig(enabled: false);
          return LiveRtcConfig(
              enabled: true,
              canPublish: rtc['canPublish'] == true,
              url: (rtc['url'] ?? '').toString(),
              token: (rtc['token'] ?? '').toString());
        }
      } catch (_) {}
    }
    return null;
  }
}

