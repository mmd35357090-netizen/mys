import 'package:foap/helper/imports/common_import.dart';
import '../../apiHandler/apis/users_api.dart';
import 'package:foap/helper/list_extension.dart';

import '../../model/search_model.dart';

class UsersController extends GetxController {
  RxList<UserModel> searchedUsers = <UserModel>[].obs;
  int accountsPage = 1;
  bool canLoadMoreAccounts = true;
  bool accountsIsLoading = false;
  String searchText = '';

  UserSearchModel searchModel = UserSearchModel();

  clear() {
    searchModel = UserSearchModel();
    clearPagingInfo();
    searchText = '';
  }

  setIsOnlineFilter() {
    searchModel.isOnline = 1;
    loadUsers();
  }

  setSearchFromParam(SearchFrom source) {
    searchModel.searchFrom = source;
    loadUsers();
  }

  setIsExactMatchFilter() {
    searchModel.isExactMatch = 1;
    loadUsers();
  }

  setSearchTextFilter(String text) {
    if (text != searchText) {
      searchText = text;
      searchModel.searchText = text;

      clearPagingInfo();
      loadUsers();
    }
  }

  clearPagingInfo() {
    searchedUsers.clear();
    accountsPage = 1;
    canLoadMoreAccounts = true;
    accountsIsLoading = false;
  }

  loadUsers() {
    if (canLoadMoreAccounts) {
      accountsIsLoading = true;

      UsersApi.searchUsers(
        searchModel: searchModel,
          page: accountsPage,
          // isExactMatch: 0,
          // searchText: searchText,
          resultCallback: (result, metadata) {
            accountsIsLoading = false;
            searchedUsers.addAll(result);
            searchedUsers.unique((e) => e.id);

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
