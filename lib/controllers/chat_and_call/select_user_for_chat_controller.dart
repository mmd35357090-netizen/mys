import 'dart:ui';

import 'package:foap/api_handler/apis/users_api.dart';
import 'package:foap/helper/list_extension.dart';
import 'package:foap/model/data_wrapper.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import '../../model/post_model.dart';
import '../../model/search_model.dart';
import '../../model/user_model.dart';

class SelectUserForChatController extends GetxController {
  final ChatDetailController chatDetailController = Get.find();

  RxList<UserModel> searchedUsers = <UserModel>[].obs;

  RxList<UserModel> processingActionUsers = <UserModel>[].obs;
  RxList<UserModel> completedActionUsers = <UserModel>[].obs;
  RxList<UserModel> failedActionUsers = <UserModel>[].obs;

  DataWrapper dataWrapper = DataWrapper();
  UserSearchModel searchModel = UserSearchModel();

  clearPreviousSearchedUsers() {
    dataWrapper = DataWrapper();
    searchedUsers.clear();
  }

  clear() {
    dataWrapper = DataWrapper();

    processingActionUsers.clear();
    failedActionUsers.clear();
    completedActionUsers.clear();
    searchedUsers.clear();
  }

  searchTextChanged(String text) {
    searchModel.searchText = text;
    clearPreviousSearchedUsers();
    loadUsers(() {});
  }

  loadUsers(VoidCallback callback) {
    if (dataWrapper.isLoading.value == false) {
      dataWrapper.isLoading.value = true;

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

  sendMessage({required UserModel toUser, PostModel? post}) {
    updateActionForUser(toUser, 1);
    if (post != null) {
      chatDetailController.getChatRoomWithUser(
          userId: toUser.id,
          callback: (room) {
            chatDetailController
                .sendPostAsMessage(post: post, room: room)
                .then((status) {
              if (status == true) {
                updateActionForUser(toUser, 2);
              } else {
                updateActionForUser(toUser, 0);
              }
              update();
            });
          });
    } else {
      chatDetailController.getChatRoomWithUser(
          userId: toUser.id,
          callback: (room) {
            chatDetailController
                .forwardSelectedMessages(room: room)
                .then((status) {
              if (status == true) {
                updateActionForUser(toUser, 2);
              } else {
                updateActionForUser(toUser, 0);
              }
              update();
            });
          });
    }
  }

  updateActionForUser(UserModel user, int action) {
    if (action == 0) {
      failedActionUsers.add(user);
    }
    if (action == 1) {
      processingActionUsers.add(user);
      failedActionUsers.remove(user);
    }
    if (action == 2) {
      completedActionUsers.add(user);
      processingActionUsers.remove(user);
      failedActionUsers.remove(user);
    }
  }
}
