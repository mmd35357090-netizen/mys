// import 'package:foap/api_handler/apis/profile_api.dart';
// import 'package:foap/helper/imports/common_import.dart';
//
// class RelationshipSearchController extends GetxController {
//   // RxList<UserModel> searchedUsers = <UserModel>[].obs;
//   // RxString searchText = ''.obs;
//
//   // int accountsPage = 1;
//   // bool canLoadMoreAccounts = true;
//   // bool accountsIsLoading = false;
//
//   clear() {
//     // accountsPage = 1;
//     // canLoadMoreAccounts = true;
//     // accountsIsLoading = false;
//   }
//
//   closeSearch() {
//     clear();
//     // searchText.value = '';
//     update();
//   }
//
//   // searchTextChanged(String text) {
//   //   clear();
//   //   searchText.value = text;
//   //   searchData();
//   // }
//
//   // searchData() {
//   //   if (searchText.isNotEmpty) {
//   //     searchUser(searchText.value);
//   //     update();
//   //   } else {
//   //     closeSearch();
//   //   }
//   // }
//
//   // searchUser(String text) {
//   //   if (canLoadMoreAccounts) {
//   //     accountsIsLoading = true;
//   //
//   //     UsersApi.searchUsers(
//   //       page:accountsPage,
//   //         isExactMatch: 0,
//   //         searchText: text,
//   //         resultCallback: (result,metadata) {
//   //           accountsIsLoading = false;
//   //           searchedUsers.value = result;
//   //           canLoadMoreAccounts = result.length >= metadata.perPage;
//   //           accountsPage += 1;
//   //
//   //           update();
//   //         });
//   //   }
//   // }
//
//   inviteUser(int relationShipId, int userId, VoidCallback handler) {
//     update();
//     ProfileApi.postRelationInviteUnInvite(
//         relationShipId: relationShipId,
//         userId: userId,
//         resultCallback: () {
//           handler();
//         });
//   }
//
//   unInviteUser(int userId) {
//     update();
//     // ApiController().followUnFollowUser(false, userId).then((value) {});
//   }
// }
