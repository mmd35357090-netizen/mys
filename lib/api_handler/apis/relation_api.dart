import 'package:foap/api_handler/api_wrapper.dart';
import '../../model/relation_model.dart';

class RelationApi {
  static getRelationTypes(
      {required Function(List<RelationTypeModel>) resultCallback}) async {
    await ApiWrapper()
        .getApi(url: NetworkConstantsUtil.relationTypes)
        .then((result) {
      if (result?.success == true) {
        var items = result!.data['relations'];
        if (items is List) {
          resultCallback(
              items.map((x) => RelationTypeModel.fromJson(x)).toList());
        }
      }
    });
  }

  static invite(
      {required int relationId,
      required int userId,
      required Function(bool, String?) resultCallback}) async {
    await ApiWrapper().postApi(url: NetworkConstantsUtil.relationInvite, param: {
      "relation_ship_id": relationId.toString(),
      "user_id": userId.toString()
    }).then((result) {
      resultCallback(result?.success == true, result?.message);
    });
  }

  static myInvitations(
      {required Function(List<RelationInvitationModel>) resultCallback}) async {
    await ApiWrapper()
        .getApi(url: NetworkConstantsUtil.myRelationInvitations)
        .then((result) {
      if (result?.success == true) {
        var items = result!.data['invitation']['items'] as List;
        resultCallback(items
            .map((x) => RelationInvitationModel.fromJson(x, isIncoming: true))
            .toList());
      }
    });
  }

  static myRelations(
      {required Function(List<RelationInvitationModel>) resultCallback}) async {
    await ApiWrapper()
        .getApi(url: NetworkConstantsUtil.myRelations)
        .then((result) {
      if (result?.success == true) {
        var items = result!.data['relations']['items'] as List;
        resultCallback(items
            .map((x) => RelationInvitationModel.fromJson(x, isIncoming: false))
            .toList());
      }
    });
  }

  /// Accept (4) or reject (3) an invitation sent to me.
  static replyInvitation(
      {required int id,
      required int status,
      required Function(bool) resultCallback}) async {
    await ApiWrapper().putApi(
        url: NetworkConstantsUtil.updateRelationInvitation,
        param: {"id": id.toString(), "status": status.toString()}).then((result) {
      resultCallback(result?.success == true);
    });
  }

  /// Cancel an invitation / relation I created (status 2).
  static cancelInvitation(
      {required int id, required Function(bool) resultCallback}) async {
    await ApiWrapper().postApi(
        url: NetworkConstantsUtil.relationInvite,
        param: {"id": id.toString(), "status": "2"}).then((result) {
      resultCallback(result?.success == true);
    });
  }
}
