import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../apiHandler/api_controller.dart';
import '../../helper/permission_utils.dart';
import '../../model/call_history_model.dart';
import '../../model/call_model.dart';
import '../agora_call_controller.dart';

class CallHistoryController extends GetxController {
  RxList<CallHistoryModel> calls = <CallHistoryModel>[].obs;
  final AgoraCallController agoraCallController = Get.find();

  int callHistoryPage = 1;
  bool canLoadMoreCalls = true;
  bool isLoading = false;

  clear() {
    isLoading = false;
    calls.value = [];
    callHistoryPage = 1;
    canLoadMoreCalls = true;
  }

  callHistory() {
    if (canLoadMoreCalls) {
      isLoading = true;
      ApiController().getCallHistory(page: callHistoryPage).then((response) {
        calls.addAll(response.callHistory);
        isLoading = false;

        callHistoryPage += 1;
        if (response.callHistory.length == response.metaData?.perPage) {
          canLoadMoreCalls = true;
        } else {
          canLoadMoreCalls = false;
        }
        update();
      });
    }
  }

  void reInitiateCall({required CallHistoryModel call}) {
    if (call.callType == 1) {
      initiateAudioCall(opponent: call.opponent);
    } else {
      initiateVideoCall(opponent: call.opponent);
    }
  }

  void initiateVideoCall({required UserModel opponent}) {
    PermissionUtils.requestPermission(
        [Permission.camera, Permission.microphone], Get.context!,
        isOpenSettings: false, permissionGrant: () async {
      Call call = Call(
          uuid: '',
          callId: 0,
          channelName: '',
          token: '',
          isOutGoing: true,
          callType: 2,
          opponent: opponent);

      agoraCallController.makeCallRequest(call: call);
    }, permissionDenied: () {
      AppUtil.showToast(
          message: LocalizationString.pleaseAllowAccessToCameraForVideoCall,
          isSuccess: false);
    }, permissionNotAskAgain: () {
      AppUtil.showToast(
          message: LocalizationString.pleaseAllowAccessToCameraForVideoCall,
          isSuccess: false);
    });
  }

  void initiateAudioCall({required UserModel opponent}) {
    PermissionUtils.requestPermission([Permission.microphone], Get.context!,
        isOpenSettings: false, permissionGrant: () async {
      Call call = Call(
          uuid: '',
          callId: 0,
          channelName: '',
          token: '',
          isOutGoing: true,
          callType: 1,
          opponent: opponent);

      agoraCallController.makeCallRequest(call: call);
    }, permissionDenied: () {
      AppUtil.showToast(
          message: LocalizationString.pleaseAllowAccessToMicrophoneForAudioCall,
          isSuccess: false);
    }, permissionNotAskAgain: () {
      AppUtil.showToast(
          message: LocalizationString.pleaseAllowAccessToMicrophoneForAudioCall,
          isSuccess: false);
    });
  }
}
