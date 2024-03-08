import 'package:foap/api_handler/apis/live_streaming_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/list_extension.dart';
import 'package:foap/model/live_model.dart';

import '../../model/data_wrapper.dart';

class LiveUserController extends GetxController {
  RxList<UserLiveCallDetail> liveStreamUser = <UserLiveCallDetail>[].obs;

  DataWrapper liveUserDataWrapper = DataWrapper();

  clear() {
    liveStreamUser.clear();
    liveUserDataWrapper = DataWrapper();
  }

  loadMore(VoidCallback callback) {
    if (liveUserDataWrapper.haveMoreData.value) {
      getLiveUsers(callback);
    } else {
      callback();
    }
  }

  // fetch live users
  void getLiveUsers(VoidCallback callback) async {
    liveUserDataWrapper.isLoading.value = true;

    LiveStreamingApi.getAllLiveUsers(
        page: liveUserDataWrapper.page,
        resultCallback: (result, metadata) {
          liveStreamUser.addAll(result);
          liveStreamUser.unique((e) => e.id);
          liveUserDataWrapper.processCompletedWithData(metadata);

          callback();
        });
  }

  getLiveDetail(
      {required String channelName,
        required Function(LiveModel) resultCallback}) {
    LiveStreamingApi.getLiveDetail(
        channelName: channelName,
        resultCallback: (result) {
          resultCallback(result);
        });
  }
}
