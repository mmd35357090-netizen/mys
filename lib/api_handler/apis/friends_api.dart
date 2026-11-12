import 'package:foap/api_handler/api_wrapper.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../model/api_meta_data.dart';

class FriendsApi {
  /// People who follow me and whom I follow too (mutual follow).
  static getFriends(
      {required int page,
      required Function(List<UserModel>, APIMetaData) resultCallback}) async {
    var url = '${NetworkConstantsUtil.myFriends}&page=$page';

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = (result!.data['friends']['items'] as List<dynamic>)
            .map((e) => e['followerUserDetail'])
            .where((e) => e != null)
            .toList();
        resultCallback(
            List<UserModel>.from(items.map((x) => UserModel.fromJson(x))),
            APIMetaData.fromJson(result.data['friends']['_meta']));
      }
    });
  }

  /// Follow requests I have sent to private profiles and that are pending.
  static getSentRequests(
      {required int page,
      required Function(List<UserModel>, APIMetaData) resultCallback}) async {
    var url = '${NetworkConstantsUtil.mySentFollowRequests}&page=$page';

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = (result!.data['followingRequest']['items'] as List<dynamic>)
            .map((e) => e['followingUserDetail'])
            .where((e) => e != null)
            .toList();
        resultCallback(
            List<UserModel>.from(items.map((x) => UserModel.fromJson(x))),
            APIMetaData.fromJson(result.data['followingRequest']['_meta']));
      }
    });
  }

  static cancelSentRequest(
      {required int userId, required Function(bool) resultCallback}) async {
    await ApiWrapper().postApi(
        url: NetworkConstantsUtil.cancelSentFollowRequest,
        param: {"user_id": userId.toString()}).then((result) {
      resultCallback(result?.success == true);
    });
  }
}
