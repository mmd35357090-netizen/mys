import 'dart:async';
import 'package:foap/api_handler/apis/chat_api.dart';
import 'package:foap/helper/date_extension.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/list_extension.dart';
import 'package:foap/model/data_wrapper.dart';
import '../../manager/db_manager_realm.dart';
import '../../screens/dashboard/dashboard_screen.dart';

class ChatHistoryController extends GetxController {
  final ChatDetailController _chatDetailController = Get.find();
  final DashboardController _dashboardController = Get.find();

  List<ChatRoomModel> allRooms = [];
  RxList<ChatRoomModel> publicGroups = <ChatRoomModel>[].obs;

  final RxList<ChatRoomModel> _searchedRooms = <ChatRoomModel>[].obs;
  RxMap<String, List<ChatRoomModel>> groupedRooms =
      <String, List<ChatRoomModel>>{}.obs;

  Map<String, dynamic> typingStatus = {};

  DataWrapper publicGroupsDataWrapper = DataWrapper();

  getChatRooms() async {
    allRooms = await getIt<RealmDBManager>().getAllRooms();

    _searchedRooms.value = allRooms;
    update();

    ChatApi.getChatRooms(resultCallback: (result) async {
      allRooms = result;
      await getIt<RealmDBManager>().saveRooms(result);

      _searchedRooms.value = allRooms;
      groupRooms();
      update();
    });
  }

  refreshPublicGroups(VoidCallback callback) {
    publicGroupsDataWrapper = DataWrapper();
    getPublicChatRooms(callback);
  }

  loadMorePublicGroups(VoidCallback callback) {
    if (publicGroupsDataWrapper.haveMoreData.value) {
      getPublicChatRooms(callback);
    } else {
      callback();
    }
  }

  getPublicChatRooms(VoidCallback callback) async {
    publicGroupsDataWrapper.isLoading.value = true;

    ChatApi.getPublicChatRooms(
        page: publicGroupsDataWrapper.page,
        resultCallback: (result, metaData) async {
          publicGroups.addAll(result);
          publicGroups.unique((e) => e.id);

          publicGroupsDataWrapper.processCompletedWithData(metaData);
          callback();
          update();
        });
  }

  groupRooms() {
    _searchedRooms.value = _searchedRooms
        .where((e) => e.isGroupChat == true || (e.roomMembers.length > 1))
        .toList();
    _searchedRooms.value = _searchedRooms.map((e) {
      ChatRoomModel room = e;
      if (e.lastMessage?.date.isToday == true || e.createAtDate.isToday) {
        room.roomDateForGrouping = todayString;
      } else if (e.lastMessage?.date.isThisWeek == true ||
          e.createAtDate.isThisWeek) {
        room.roomDateForGrouping = thisWeekString;
      } else if (e.lastMessage?.date.isThisMonth == true ||
          e.createAtDate.isThisMonth) {
        room.roomDateForGrouping = thisMonthString;
      } else {
        room.roomDateForGrouping = earlierString;
      }
      return room;
    }).toList();
    groupedRooms.value = _searchedRooms.groupBy((m) => m.roomDateForGrouping);
    update();
  }

  searchTextChanged(String text) {
    if (text.isEmpty) {
      _searchedRooms.value = allRooms;
      groupRooms();
      return;
    }
    _searchedRooms.value = allRooms.where((room) {
      if (room.isGroupChat) {
        return room.name!.toLowerCase().contains(text);
      } else {
        return room.opponent!.userDetail.userName.toLowerCase().contains(text);
      }
    }).toList();
    groupRooms();
    update();
  }

  clearUnreadCount({required ChatRoomModel chatRoom}) async {
    getIt<RealmDBManager>().clearUnReadCount(roomId: chatRoom.id);
    int roomsWithUnreadMessageCount =
        await getIt<RealmDBManager>().roomsWithUnreadMessages();
    _dashboardController.updateUnreadMessageCount(roomsWithUnreadMessageCount);

    getChatRooms();
    update();
  }

  deleteRoom(ChatRoomModel chatRoom) {
    allRooms.removeWhere((element) => element.id == chatRoom.id);
    getIt<RealmDBManager>().deleteRooms([chatRoom]);
    update();
    ChatApi.deleteChatRoom(chatRoom.id);
  }

  // ******************* updates from socket *****************//

  newMessageReceived(ChatMessageModel message) async {
    List<ChatRoomModel> existingRooms =
        allRooms.where((room) => room.id == message.roomId).toList();

    if (existingRooms.isNotEmpty &&
        message.roomId != _chatDetailController.chatRoom.value?.id) {
      ChatRoomModel room = existingRooms.first;
      room.lastMessage = message;
      room.whoIsTyping.remove(message.userName);
      typingStatus[message.userName] = null;

      _searchedRooms.refresh();
      update();
      getIt<RealmDBManager>().updateUnReadCount(roomId: message.roomId);
    }

    getChatRooms();
  }

  userTypingStatusChanged(
      {required String userName, required int roomId, required bool status}) {
    var matchedRooms = allRooms.where((element) => element.id == roomId);

    if (matchedRooms.isNotEmpty) {
      var room = matchedRooms.first;

      if (typingStatus[userName] == null) {
        room.whoIsTyping.add(userName);
        _searchedRooms.refresh();
      }

      typingStatus[userName] = DateTime.now();

      if (status == true) {
        Timer(const Duration(seconds: 5), () {
          if (typingStatus[userName] != null) {
            if (DateTime.now().difference(typingStatus[userName]!).inSeconds >
                4) {
              room.whoIsTyping.remove(userName);
              typingStatus[userName] = null;
              _searchedRooms.refresh();
              update();
            }
          }
        });
      }
      update();
    }
  }

  userAvailabilityStatusChange({required int userId, required bool isOnline}) {
    var matchedRooms =
        allRooms.where((element) => element.opponent?.id == userId);

    if (matchedRooms.isNotEmpty) {
      var room = matchedRooms.first;
      room.isOnline = isOnline;
      room.opponent!.userDetail.isOnline = isOnline;
      _searchedRooms.refresh();
    }
  }

  joinPublicGroup(ChatRoomModel room) {
    final UserProfileManager userProfileManager = Get.find();

    publicGroups.value = publicGroups.map((element) {
      if (element.id == room.id) {
        ChatRoomMember member = ChatRoomMember(
            id: 0,
            userDetail: userProfileManager.user.value!,
            roomId: room.id,
            userId: userProfileManager.user.value!.id,
            isAdmin: 0);

        element.roomMembers.add(member);
      }
      return element;
    }).toList();
    publicGroups.refresh();
  }

  leavePublicGroup(ChatRoomModel room) {
    final UserProfileManager userProfileManager = Get.find();

    publicGroups.value = publicGroups.map((element) {
      if (element.id == room.id) {
        element.roomMembers.removeWhere((element) =>
            element.userDetail.id == userProfileManager.user.value!.id);
      }
      return element;
    }).toList();
    publicGroups.refresh();
  }
}
