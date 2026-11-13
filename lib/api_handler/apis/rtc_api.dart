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
  static Future<RtcConfig?> getConfig() async {
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final result = await ApiWrapper()
            .getApi(url: NetworkConstantsUtil.rtcConfig)
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
