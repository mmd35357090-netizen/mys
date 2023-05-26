import 'package:foap/apiHandler/apis/users_api.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/chat_imports.dart';

import '../../apiHandler/api_controller.dart';
import '../../manager/socket_manager.dart';
import '../../model/user_model.dart';

class SelectUserForGroupChatController extends GetxController {
  final ChatDetailController _chatDetailController = Get.find();

  RxList<UserModel> friends = <UserModel>[].obs;
  RxList<UserModel> selectedFriends = <UserModel>[].obs;

  int page = 1;
  bool canLoadMore = true;
  bool isLoading = false;

  String searchText = '';

  clear() {
    page = 1;
    canLoadMore = true;
    isLoading = false;
    selectedFriends.clear();
  }

  addUsersToRoom(ChatRoomModel room) {
    for (UserModel user in selectedFriends) {
      getIt<SocketManager>().emit(SocketConstants.addUserInChatRoom,
          {'userId': user.id.toString(), 'room': room.id});

      _chatDetailController.chatRoom.value!.roomMembers
          .add(user.toChatRoomMember);
    }

    _chatDetailController.update();
  }

  searchTextChanged(String text) {
    searchText = text;
  }

  selectFriend(UserModel user) {
    if (selectedFriends.contains(user)) {
      selectedFriends.remove(user);
    } else {
      selectedFriends.add(user);
    }
    update();
  }

  getFriends() {
    if (canLoadMore) {
      isLoading = true;
      UsersApi.getFollowingUsers(
          page: page,
          resultCallback: (result, metadata) {
            isLoading = false;
            friends.addAll(result);

            page += 1;
            canLoadMore = result.length >= metadata.perPage;

            update();
          });
    }
  }
}
