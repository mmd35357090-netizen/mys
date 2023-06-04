import 'package:foap/helper/imports/common_import.dart';
import '../../apiHandler/apis/users_api.dart';
import 'package:foap/helper/list_extension.dart';

class UsersController extends GetxController {
  RxList<UserModel> searchedUsers = <UserModel>[].obs;
  int accountsPage = 1;
  bool canLoadMoreAccounts = true;
  bool accountsIsLoading = false;
  String _searchText = '';

  clear() {
    accountsPage = 1;
    canLoadMoreAccounts = true;
    accountsIsLoading = false;
    searchedUsers.clear();
    _searchText = '';
  }

  // getSuggestedUsers() {
  //   if (canLoadMoreSuggestUser) {
  //     suggestUserIsLoading = true;
  //
  //     UsersApi.getSuggestedUsers(
  //         page: suggestUserPage,
  //         resultCallback: (result) {
  //           suggestUserIsLoading = false;
  //           suggestedUsers.value = result;
  //           // suggestUserPage += 1;
  //           // canLoadMoreSuggestUser = result.length >= metadata.perPage;
  //           update();
  //         });
  //   }
  // }

  searchUser(String text) {
    _searchText = text;
    loadUsers();
  }

  loadUsers() {
    if (canLoadMoreAccounts) {
      accountsIsLoading = true;

      UsersApi.searchUsers(
          page: accountsPage,
          isExactMatch: 0,
          searchText: _searchText,
          resultCallback: (result, metadata) {
            accountsIsLoading = false;
            searchedUsers.addAll(result);
            searchedUsers.unique((e)=> e.id);

            canLoadMoreAccounts = result.length >= metadata.perPage;
            accountsPage += 1;

            update();
          });
    }
  }

  followUser(UserModel user) {
    user.isFollowing = true;
    if (searchedUsers.where((e) => e.id == user.id).isNotEmpty) {
      searchedUsers[
          searchedUsers.indexWhere((element) => element.id == user.id)] = user;
    }
    // if (suggestedUsers.where((e) => e.id == user.id).isNotEmpty) {
    //   suggestedUsers[
    //   suggestedUsers.indexWhere((element) => element.id == user.id)] = user;
    // }
    update();

    UsersApi.followUnfollowUser(isFollowing: true, userId: user.id);
  }

  unFollowUser(UserModel user) {
    user.isFollowing = false;
    if (searchedUsers.where((e) => e.id == user.id).isNotEmpty) {
      searchedUsers[
          searchedUsers.indexWhere((element) => element.id == user.id)] = user;
    }
    // if (suggestedUsers.where((e) => e.id == user.id).isNotEmpty) {
    //   suggestedUsers[
    //   suggestedUsers.indexWhere((element) => element.id == user.id)] = user;
    // }
    update();
    UsersApi.followUnfollowUser(isFollowing: false, userId: user.id);
  }
}
