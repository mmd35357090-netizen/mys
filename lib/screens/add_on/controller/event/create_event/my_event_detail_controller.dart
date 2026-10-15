import 'dart:ui';
import 'package:foap/api_handler/apis/events_api.dart';
import 'package:foap/helper/list_extension.dart';
import 'package:foap/model/data_wrapper.dart';
import 'package:foap/model/user_model.dart';
import 'package:get/get.dart';

import '../../../../../api_handler/apis/users_api.dart';
import '../../../../../helper/enum.dart';

class MyEventDetailController extends GetxController {
  RxList<UserModel> attendingUsers = <UserModel>[].obs;
  DataWrapper usersDataWrapper = DataWrapper();

  loadMoreUserList(
      {required int eventId, required VoidCallback callback}) async {
    if (usersDataWrapper.haveMoreData.value) {
      usersDataWrapper.isLoading.value = true;

      loadUsers(eventId: eventId, callback: callback);
    } else {
      callback();
    }
  }

  loadUsers({required int eventId, required VoidCallback callback}) {
    EventApi.getUsersAttendingEvent(
        eventId: eventId,
        page: usersDataWrapper.page,
        resultCallback: (result, metadata) {
          usersDataWrapper.processCompletedWithData(metadata);
          attendingUsers.addAll(result);
          attendingUsers.unique((e) => e.id);

          update();
        });
  }

  followUser(UserModel user) {
    user.followingStatus = user.isPrivateProfile
        ? FollowingStatus.requested
        : FollowingStatus.following;
    if (attendingUsers.where((e) => e.id == user.id).isNotEmpty) {
      attendingUsers[attendingUsers
          .indexWhere((element) => element.id == user.id)] = user;
    }

    attendingUsers.refresh();

    update();
    UsersApi.followUnfollowUser(isFollowing: true, user: user)
        .then((value) {
      update();
    });
  }

  unFollowUser(UserModel user) {
    user.followingStatus = FollowingStatus.notFollowing;
    if (attendingUsers.where((e) => e.id == user.id).isNotEmpty) {
      UserModel matchedUser =
          attendingUsers.where((element) => element.id == user.id).first;
      matchedUser.followingStatus = FollowingStatus.notFollowing;
    }

    attendingUsers.refresh();

    update();
    UsersApi.followUnfollowUser(isFollowing: false, user: user)
        .then((value) {
      update();
    });
  }
}
