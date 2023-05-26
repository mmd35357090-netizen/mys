import 'package:foap/apiHandler/apis/misc_api.dart';
import 'package:foap/apiHandler/apis/users_api.dart';
import 'package:foap/controllers/post_controller.dart';
import 'package:get/get.dart';

import '../apiHandler/api_controller.dart';
import '../model/hash_tag.dart';
import '../model/location.dart';
import '../model/post_search_query.dart';
import '../model/user_model.dart';

class ExploreController extends GetxController {
  final PostController postController = Get.find<PostController>();

  RxList<LocationModel> locations = <LocationModel>[].obs;
  RxList<Hashtag> hashTags = <Hashtag>[].obs;
  RxList<UserModel> suggestedUsers = <UserModel>[].obs;
  RxList<UserModel> searchedUsers = <UserModel>[].obs;

  bool isSearching = false;
  RxString searchText = ''.obs;
  int selectedSegment = 0;

  int suggestUserPage = 1;
  bool canLoadMoreSuggestUser = true;
  bool suggestUserIsLoading = false;

  int accountsPage = 1;
  bool canLoadMoreAccounts = true;
  bool accountsIsLoading = false;

  int hashtagsPage = 1;
  bool canLoadMoreHashtags = true;
  bool hashtagsIsLoading = false;

  clear() {
    isSearching = false;
    searchText.value = '';
    selectedSegment = 0;

    suggestUserPage = 1;
    canLoadMoreSuggestUser = true;
    suggestUserIsLoading = false;

    accountsPage = 1;
    canLoadMoreAccounts = true;
    accountsIsLoading = false;

    hashtagsPage = 1;
    canLoadMoreHashtags = true;
    hashtagsIsLoading = false;

    hashTags.clear();
    suggestedUsers.clear();
    searchedUsers.clear();
  }

  startSearch() {
    // isSearching = true;
    update();
  }

  closeSearch() {
    clear();
    postController.clearPosts();
    searchText.value = '';
    selectedSegment = 0;
    update();
  }

  searchTextChanged(String text) {
    clear();
    searchText.value = text;
    postController.clearPosts();
    searchData();
  }

  searchData() {
    if (searchText.isNotEmpty) {
      if (selectedSegment == 0) {
        PostSearchQuery query = PostSearchQuery();
        // query.isPopular = 1;
        query.title = searchText.value;
        postController.setPostSearchQuery(query: query,callback: (){});

        // postController.getPosts();
        // getPosts(isPopular: 1, title: searchText);
      } else if (selectedSegment == 1) {
        searchUser(searchText.value);
      } else if (selectedSegment == 2) {
        searchHashTags(searchText.value);
      } else if (selectedSegment == 3) {
        // searchLocations(searchText);
      }
      update();
    } else {
      closeSearch();
    }
  }

  segmentChanged(int index) {
    selectedSegment = index;
    searchData();
    update();
  }

  searchHashTags(String text) {
    if (canLoadMoreHashtags) {
      hashtagsIsLoading = true;
      MiscApi.searchHashtag(
          hashtag: text,
          page: hashtagsPage,
          resultCallback: (result, metadata) {
            hashTags.addAll(result);
            hashtagsIsLoading = false;
            hashtagsPage += 1;
            canLoadMoreHashtags = result.length >= metadata.perPage;
            update();
          });
    }
  }

  getSuggestedUsers() {
    if (canLoadMoreSuggestUser) {
      suggestUserIsLoading = true;

      UsersApi.getSuggestedUsers(
          page: suggestUserPage,
          resultCallback: (result) {
            suggestUserIsLoading = false;
            suggestedUsers.value = result;
            // suggestUserPage += 1;
            // canLoadMoreSuggestUser = result.length >= metadata.perPage;
            update();
          });
    }
  }

  searchUser(String text) {
    if (canLoadMoreAccounts) {
      accountsIsLoading = true;

      UsersApi.searchUsers(
          page: accountsPage,
          isExactMatch: 0,
          searchText: text,
          resultCallback: (result, metadata) {
            accountsIsLoading = false;
            searchedUsers.addAll(result);
            canLoadMoreSuggestUser = result.length >= metadata.perPage;
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
    if (suggestedUsers.where((e) => e.id == user.id).isNotEmpty) {
      suggestedUsers[
          suggestedUsers.indexWhere((element) => element.id == user.id)] = user;
    }
    update();

    UsersApi.followUnfollowUser(isFollowing: true, userId: user.id);
  }

  unFollowUser(UserModel user) {
    user.isFollowing = false;
    if (searchedUsers.where((e) => e.id == user.id).isNotEmpty) {
      searchedUsers[
          searchedUsers.indexWhere((element) => element.id == user.id)] = user;
    }
    if (suggestedUsers.where((e) => e.id == user.id).isNotEmpty) {
      suggestedUsers[
          suggestedUsers.indexWhere((element) => element.id == user.id)] = user;
    }
    update();
    UsersApi.followUnfollowUser(isFollowing: false, userId: user.id);
  }
}
