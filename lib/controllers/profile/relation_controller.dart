import 'package:foap/helper/imports/common_import.dart';
import '../../api_handler/apis/relation_api.dart';
import '../../model/relation_model.dart';

class RelationController extends GetxController {
  RxList<RelationTypeModel> relationTypes = <RelationTypeModel>[].obs;
  RxList<RelationInvitationModel> invitations = <RelationInvitationModel>[].obs;
  RxList<RelationInvitationModel> myRelations = <RelationInvitationModel>[].obs;
  RxBool isLoading = false.obs;

  loadRelationTypes() {
    if (relationTypes.isNotEmpty) return;
    RelationApi.getRelationTypes(resultCallback: (result) {
      relationTypes.value = result;
    });
  }

  loadAll() {
    isLoading.value = true;
    RelationApi.myInvitations(resultCallback: (result) {
      invitations.value = result;
      isLoading.value = false;
    });
    RelationApi.myRelations(resultCallback: (result) {
      myRelations.value = result;
    });
  }

  invite(RelationTypeModel type, int userId) {
    RelationApi.invite(
        relationId: type.id,
        userId: userId,
        resultCallback: (success, message) {
          AppUtil.showToast(
              message: success
                  ? invitationSentString.tr
                  : (message ?? ''),
              isSuccess: success);
        });
  }

  reply(RelationInvitationModel invitation, bool accept) {
    RelationApi.replyInvitation(
        id: invitation.id,
        status: accept ? 4 : 3,
        resultCallback: (success) {
          if (success) {
            invitations.removeWhere((e) => e.id == invitation.id);
            if (accept) loadAll();
          }
        });
  }

  cancel(RelationInvitationModel relation) {
    RelationApi.cancelInvitation(
        id: relation.id,
        resultCallback: (success) {
          if (success) {
            myRelations.removeWhere((e) => e.id == relation.id);
          }
        });
  }
}
