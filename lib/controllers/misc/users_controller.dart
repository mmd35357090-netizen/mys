import 'package:foap/helper/imports/common_import.dart';
import '../../api_handler/apis/users_api.dart';
import 'package:foap/helper/list_extension.dart';

import '../../model/data_wrapper.dart';
import '../../model/search_model.dart';

class UsersController extends GetxController {
  RxList<UserModel> searchedUsers = <UserModel>[].obs;
  DataWrapper dataWrapper = DataWrapper();
  String searchText = '';

  UserSearchModel searchModel = UserSearchModel();

  clear() {
    searchModel = UserSearchModel();
    clearPagingInfo();
    searchText = '';
    dataWrapper = DataWrapper();
  }

  setIsOnlineFilter() {
    searchModel.isOnline = 1;
    loadUsers(() {});
  }

  setSearchFromParam(SearchFrom source) {
    searchModel.searchFrom = source;
    loadUsers(() {});
  }

  setIsExactMatchFilter() {
    searchModel.isExactMatch = 1;
    loadUsers(() {});
  }

  setSearchTextFilter(String text, VoidCallback callback) {
    if (text != searchText) {
      searchText = text;
      searchModel.searchText = text;

      clearPagingInfo();
      loadUsers(callback);
    }
  }

  clearPagingInfo() {
    searchedUsers.clear();
    dataWrapper = DataWrapper();
  }

  loadSuggestedUsers() {
    UsersApi.getSuggestedUsers(
        page: 1,
        resultCallback: (result) {
          searchedUsers.addAll(result);
          searchedUsers.unique((e) => e.id);

          // update();
        });
  }

  loadUsers(VoidCallback callback) {
    if (dataWrapper.haveMoreData.value) {
      if (dataWrapper.page == 1) {
        dataWrapper.isLoading.value = true;
      }

      UsersApi.searchUsers(
          searchModel: searchModel,
          page: dataWrapper.page,
          resultCallback: (result, metadata) {
            searchedUsers.addAll(result);
            searchedUsers.unique((e) => e.id);

            dataWrapper.processCompletedWithData(metadata);
            callback();

            update();
          });
    } else {
      callback();
    }
  }

  followUser(UserModel user) {
    user.followingStatus = user.isPrivateProfile
        ? FollowingStatus.requested
        : FollowingStatus.following;
    if (searchedUsers.where((e) => e.id == user.id).isNotEmpty) {
      searchedUsers[searchedUsers
          .indexWhere((element) => element.id == user.id)] = user;
    }

    update();

    UsersApi.followUnfollowUser(isFollowing: true, user: user);
  }

  unFollowUser(UserModel user) {
    user.followingStatus = FollowingStatus.notFollowing;
    if (searchedUsers.where((e) => e.id == user.id).isNotEmpty) {
      searchedUsers[searchedUsers
          .indexWhere((element) => element.id == user.id)] = user;
    }

    update();
    UsersApi.followUnfollowUser(isFollowing: false, user: user);
  }
}
