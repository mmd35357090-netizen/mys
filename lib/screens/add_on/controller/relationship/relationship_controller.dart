// import 'package:foap/api_handler/apis/profile_api.dart';
// import 'package:foap/controllers/profile/profile_controller.dart';
// import 'package:foap/helper/imports/common_import.dart';
// import '../../model/get_relationship_model.dart';
// import '../../model/my_invitation_model.dart';
// import '../../model/my_relations_model.dart';
//
// class RelationshipController extends GetxController {
//   RxList<RelationshipName> relationshipNames = <RelationshipName>[].obs;
//
//   // RxList<MyRelationsModel> myRelationships = <MyRelationsModel>[].obs;
//   RxList<MyInvitationsModel> myInvitations = <MyInvitationsModel>[].obs;
//   RxList<MyRelationsModel> relationships = <MyRelationsModel>[].obs;
//
//   final ProfileController _profileController = Get.find();
//
//   clear() {
//     relationshipNames.clear();
//     myInvitations.clear();
//     relationships.clear();
//   }
//
//   getRelationships() {
//     ProfileApi.getRelationshipNames(resultCallback: (result) {
//       relationshipNames.value = result;
//       relationshipNames.refresh();
//
//       update();
//     });
//   }
//
//   getUsersRelationships({required int userId}) {
//     ProfileApi.getUsersRelationships(
//         userId: userId,
//         resultCallback: (result) {
//           relationships.value = result;
//           relationships.refresh();
//           update();
//         });
//   }
//
//   getMyRelationships() {
//     Loader.show(status: loadingString.tr);
//     ProfileApi.getMyRelations(resultCallback: (result) {
//       relationships.value = result;
//       relationships.refresh();
//       Loader.dismiss();
//       update();
//     });
//   }
//
//   getMyInvitations() {
//     ProfileApi.getMyInvitations(resultCallback: (result, metaData) {
//       myInvitations.value = result;
//       myInvitations.refresh();
//       update();
//     });
//   }
//
//   acceptRejectInvitation(int invitationId, int status, VoidCallback handler) {
//     update();
//     Loader.show(status: loadingString.tr);
//     ProfileApi.acceptRejectInvitation(
//         invitationId: invitationId,
//         status: status,
//         resultCallback: () {
//           handler();
//           Loader.dismiss();
//         });
//   }
//
//   postRelationshipSettings(int relationSetting) {
//     update();
//     Loader.show(status: loadingString.tr);
//     ProfileApi.postRelationshipSettings(
//         relationSetting: relationSetting,
//         resultCallback: () async {
//           await _profileController.getMyProfile();
//           update();
//           Loader.dismiss();
//         });
//   }
// }
