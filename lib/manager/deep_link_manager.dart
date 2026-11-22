import 'package:app_links/app_links.dart';
import 'package:foap/api_handler/apis/live_streaming_api.dart';
import 'package:foap/controllers/live/agora_live_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/event_imports.dart';
import 'package:foap/helper/imports/post_imports.dart';
import 'package:get/get.dart';

import '../model/live_model.dart';

class DeepLinkManager {
  // A link that started the app is kept until the home screen is on the screen
  // (splash / login would otherwise cover or replace the opened post).
  static Uri? _pending;
  static bool _dashboardReady = false;
  static String _lastKey = '';
  static DateTime _lastAt = DateTime.fromMillisecondsSinceEpoch(0);

  static init() {
    final appLinks = AppLinks();

    // links that arrive while the app is running (and, in newer app_links versions, the first link too)
    appLinks.uriLinkStream.listen((uri) {
      handleLink(uri);
    });

    // the link that started the app (older app_links versions only give it here)
    _loadInitial(appLinks);
  }

  static Future<void> _loadInitial(AppLinks appLinks) async {
    try {
      final dynamic r = await (appLinks as dynamic).getInitialLink();
      if (r is Uri) handleLink(r);
    } catch (_) {}
  }

  /// called by the home (dashboard) screen once it is shown
  static void onDashboardReady() {
    _dashboardReady = true;
    final p = _pending;
    if (p != null) {
      _pending = null;
      Future.delayed(const Duration(milliseconds: 700), () => _open(p));
    }
  }

  static handleLink(Uri uri) {
    // the same link can arrive twice (stream + initial link)
    final key = uri.toString();
    final now = DateTime.now();
    if (key == _lastKey && now.difference(_lastAt).inSeconds < 5) return;
    _lastKey = key;
    _lastAt = now;

    if (!_dashboardReady) {
      _pending = uri;
      return;
    }
    _open(uri);
  }

  /// value that follows a path word:  /username/p/<id>  ->  _after(uri, 'p') = <id>
  static String? _after(Uri uri, String word) {
    final s = uri.pathSegments;
    final i = s.indexOf(word);
    return (i >= 0 && i + 1 < s.length && s[i + 1].isNotEmpty) ? s[i + 1] : null;
  }

  static _open(Uri uri) {
    String urlString = uri.path;
    if (urlString.contains('share-live') || urlString.contains('/live/')) {
      String? channelName = uri.queryParameters['id'] ?? _after(uri, 'live');

      if (channelName != null) {
        AgoraLiveController agoraLiveController = Get.find();
        LiveStreamingApi.getLiveDetail(
            channelName: channelName,
            resultCallback: (result) {
              if (!result.isOngoing) {
                AppUtil.showToast(
                    message: 'This live has ended', isSuccess: false);
                return;
              }
              LiveModel live = LiveModel();
              live.channelName = result.channelName;
              live.mainHostUserDetail = result.host!.first;
              live.token = result.token;
              live.id = result.id;
              agoraLiveController.joinAsAudience(
                live: live,
              );
            });
      }
    } else if (urlString.contains('event')) {
      String? eventId = uri.queryParameters['id'];
      if (eventId != null) {
        // final EventDetailController eventDetailController = Get.find();
        // Get.to(() => EventDetail(postUniqueId: postUniqueId));
      }
    } else {
      String? postUniqueId = uri.queryParameters['pid'] ?? _after(uri, 'p');

      if (postUniqueId != null) {
        Get.to(() => SinglePostDetail(postUniqueId: postUniqueId));
      }
    }
  }
}
