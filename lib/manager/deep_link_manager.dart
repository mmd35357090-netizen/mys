import 'package:app_links/app_links.dart';
import 'package:foap/api_handler/apis/live_streaming_api.dart';
import 'package:foap/controllers/live/agora_live_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/event_imports.dart';
import 'package:foap/helper/imports/post_imports.dart';
import 'package:get/get.dart';

import '../model/live_model.dart';

class DeepLinkManager {
  static init() {
    final appLinks = AppLinks();

    // Subscribe to all events when app is started.
    // (Use allStringLinkStream to get it as [String])
    appLinks.uriLinkStream.listen((uri) {
      handleLink(uri);
    });
  }

  static handleLink(Uri uri) async {
    // when the app is started by the link, wait until the logged-in user is loaded
    for (var i = 0;
        i < 40 &&
            !(Get.isRegistered<UserProfileManager>() &&
                Get.find<UserProfileManager>().user.value != null);
        i++) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
    String urlString = uri.path;
    if (urlString.contains('share-live')) {
      String? channelName = uri.queryParameters['id'];

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
              if (result.isOngoing) {
                LiveModel live = LiveModel();
                live.channelName = result.channelName;
                live.mainHostUserDetail = result.host!.first;
                live.token = result.token;
                live.id = result.id;
                agoraLiveController.joinAsAudience(
                  live: live,
                );
              }
            });
      }
    } else if (urlString.contains('event')) {
      String? eventId = uri.queryParameters['id'];
      if (eventId != null) {
        // final EventDetailController eventDetailController = Get.find();
        // Get.to(() => EventDetail(postUniqueId: postUniqueId));
      }
    } else {
      String? postUniqueId = uri.queryParameters['pid'];

      if (postUniqueId != null) {
        Get.to(() => SinglePostDetail(postUniqueId: postUniqueId));
      }
    }
  }
}
