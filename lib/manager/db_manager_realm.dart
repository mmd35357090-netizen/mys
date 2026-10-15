import 'dart:async';
import 'package:foap/controllers/chat_and_call/chat_detail_controller.dart';
import 'package:foap/controllers/chat_and_call/chat_history_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/list_extension.dart';
import 'package:foap/model/realm_db.dart';
import 'package:foap/model/story_model.dart';
import 'package:realm/realm.dart';
import '../model/chat_message_model.dart';
import '../model/chat_room_model.dart';
import 'file_manager.dart';

class RealmDBManager {
  final ChatDetailController _chatDetailController = Get.find();
  final ChatHistoryController _chatHistoryController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  Map<String, UserModel> cachedUsers = {};

  late Realm realm;

  Future<void> openDatabase() async {
    final config = Configuration.local([
      StoryViewHistoryRealm.schema,
      ChatRoomsRealm.schema,
      MessagesRealm.schema,
      ChatRoomMembersRealm.schema,
      UsersCacheRealm.schema,
      ChatMessageUserRealm.schema,
    ]);
    realm = Realm(config);

    realm = await Realm.open(config);
  }

  storyViewed(StoryMediaModel story) async {
    realm.write(() {
      var storyViewHistory =
          realm.query<StoryViewHistoryRealm>("storyId == ${story.id}");

      var storyViewHistoryRealm =
          StoryViewHistoryRealm(storyId: story.id, time: story.createdAtDate);

      if (storyViewHistory.isEmpty) {
        realm.add(storyViewHistoryRealm);
      }
    });
  }

  Future<List<int>> getAllViewedStories() async {
    var items = realm.all<StoryViewHistoryRealm>();
    return items.map((e) => e.storyId!).toList();
  }

  clearOldStories() async {
    // final items = await db.collection('viewedStories').get();
    int currentEpochTime = DateTime.now().millisecondsSinceEpoch;

    realm.write(() {
      var oldStories = realm.query<StoryViewHistoryRealm>(
          'time < ${currentEpochTime - 86400000}');

      for (StoryViewHistoryRealm story in oldStories) {
        realm.delete(story);
      }
    });
  }

  //***************** Chat *************//

  newMessageReceived(ChatMessageModel message) async {
    final existingRoom = await getRoomById(message.roomId);

    if (existingRoom == null) {
      // save room in database
      await _chatDetailController.getRoomDetail(message.roomId,
          (chatroom) async {
        await saveRooms([chatroom]);
        await prepareSaveMessage(
            chatMessages: [message], alreadyWritingInDB: false);
        _chatDetailController.newMessageReceived(message);
        _chatHistoryController.newMessageReceived(message);
      });
    } else {
      await prepareSaveMessage(
          chatMessages: [message], alreadyWritingInDB: false);
      _chatDetailController.newMessageReceived(message);
      _chatHistoryController.newMessageReceived(message);
    }
  }

  Future<ChatRoomModel?> getRoomById(int roomId) async {
    ChatRoomModel? room;
    room = await fetchRoom(roomId);
    return room;
  }

  Future<ChatRoomModel?> fetchRoom(int roomId) async {
    ChatRoomModel? chatRoom;
    var dbRooms = realm.query<ChatRoomsRealm>('id = $roomId');

    if (dbRooms.isNotEmpty) {
      Map<String, dynamic> roomJson = dbRooms.first.toMap();

      var userData =
          realm.query<UsersCacheRealm>('id = ${dbRooms.first.createdBy}');

      if (userData.isNotEmpty) {
        roomJson['createdByUser'] = userData.first.toMap();
      } else {
        roomJson['createdByUser'] = {'id': roomJson["created_by"]};
      }

      chatRoom = ChatRoomModel.fromJson(roomJson);
      chatRoom.roomMembers = await fetchAllMembersInRoom(chatRoom.id);
    }

    return chatRoom;
  }

  Future saveRooms(List<ChatRoomModel> chatRooms) async {
    // var realm = await Realm.open(configuration);

    final allRooms = realm.all<ChatRoomsRealm>();
    realm.write(()  {
      for (ChatRoomModel chatRoom in chatRooms) {
        if (allRooms.where((element) => element.id == chatRoom.id).isEmpty) {
          realm.add(ChatRoomsRealm(
            id: chatRoom.id,
            title: chatRoom.name,
            status: chatRoom.status,
            type: chatRoom.type,
            isChatUserOnline: chatRoom.isOnline == true ? 1 : 0,
            createdBy: chatRoom.createdBy,
            createdAt: chatRoom.createdAt,
            updatedAt: chatRoom.updatedAt,
            imageUrl: chatRoom.image,
            description: chatRoom.description,
            chatAccessGroup: chatRoom.groupAccess,
          ));

          for (ChatRoomMember member in chatRoom.roomMembers) {
            var rooms = realm.query<ChatRoomMembersRealm>('id = ${member.id}');
            if (rooms.isNotEmpty) {
              realm.delete(
                rooms.first,
              );
            }

            realm.add(
              ChatRoomMembersRealm(
                id: member.id,
                roomId: member.roomId,
                userId: member.userId,
                isAdmin: member.isAdmin,
              ),
            );

            var cachedUsers =
                realm.query<UsersCacheRealm>('id = ${member.userDetail.id}');
            if (cachedUsers.isNotEmpty) {
              realm.delete(
                cachedUsers.first,
              );
            }

            realm.add(
              UsersCacheRealm(
                id: member.userDetail.id,
                username: member.userDetail.userName,
                email: member.userDetail.email,
                picture: member.userDetail.picture,
              ),
            );
          }

          if (chatRoom.lastMessage != null) {
            saveMessage(
                chatMessages: [chatRoom.lastMessage!],
                alreadyWritingInDB: true);
          }
        } else {
          startUpdateRoom(chatRoom, true);
        }
      }
    });
    // realm.close();
  }

  prepareSaveMessage(
      {required List<ChatMessageModel> chatMessages,
      required bool alreadyWritingInDB}) async {
    if (alreadyWritingInDB) {
      saveMessage(chatMessages: chatMessages, alreadyWritingInDB: false);
    } else {
      realm.write(() {
        saveMessage(chatMessages: chatMessages, alreadyWritingInDB: true);
      });
    }
  }

  saveMessage(
      {required List<ChatMessageModel> chatMessages,
      required bool alreadyWritingInDB}) {
    for (ChatMessageModel chatMessage in chatMessages) {
      if (chatMessage.isMineMessage) {
        chatMessage.viewedAt = DateTime.now().millisecondsSinceEpoch;
      }

      var cachedMessage = realm.query<MessagesRealm>(
          'localMessageId = "${chatMessage.localMessageId}"');
      if (cachedMessage.isNotEmpty) {
        realm.delete(
          cachedMessage.first,
        );
      }

      realm.add(
        MessagesRealm(
          localMessageId: chatMessage.localMessageId,
          id: chatMessage.id,
          isEncrypted: chatMessage.isEncrypted,
          chatVersion: chatMessage.chatVersion,
          roomId: chatMessage.roomId,
          messageType: chatMessage.messageType,
          message: chatMessage.messageContent,
          repliedOnMessage: chatMessage.repliedOnMessageContent,
          username: chatMessage.userName,
          createdBy: chatMessage.senderId,
          createdAt: chatMessage.createdAt,
          viewedAt: chatMessage.viewedAt,
          isDeleted: chatMessage.isDeleted == true ? 1 : 0,
          isStar: chatMessage.isStar,
          deleteAfter: chatMessage.deleteAfter,
        ),
      );

      if (!chatMessage.isDateSeparator &&
          chatMessage.messageContentType != MessageContentType.groupAction) {
        updateRoomUpdateAtTime(chatMessage.roomId);
      }

      saveUserInCache(
        user: chatMessage.sender ?? _userProfileManager.user.value!,
      );

      // add users in message if we have message id i.e message is not mine
      if (chatMessage.id != 0) {
        List<ChatRoomMember> usersInRoom =
            getIt<RealmDBManager>().getAllMembersInRoom(chatMessage.roomId);

        List<ChatMessageUser> members = usersInRoom.map((e) {
          ChatMessageUser user = ChatMessageUser();
          user.userId = e.userId;
          user.id = e.id;
          user.messageId = chatMessage.id;
          user.status = 1;

          return user;
        }).toList();

        prepareSavingUsersInMessage(
            users: members, alreadyWritingInDB: alreadyWritingInDB);
      }
    }
  }

  prepareSavingUsersInMessage(
      {required List<ChatMessageUser> users,
      required bool alreadyWritingInDB}) {
    if (alreadyWritingInDB) {
      insertChatMessageUsers(users: users);
    } else {
      realm.write(() {
        insertChatMessageUsers(users: users);
      });
    }
  }

  startUpdateRoom(ChatRoomModel chatRoom, bool isInWriteBatch) async {
    // ChatRoomModel? room = await getRoomById(chatRoom.id);
    ChatMessageModel? lastMessage = chatRoom.lastMessage;
    int? updateAt = chatRoom.updatedAt ?? DateTime.now().millisecondsSinceEpoch;

    if (isInWriteBatch) {
      updateRoom(chatRoom, updateAt, lastMessage);
    } else {
      realm.write(()  {
        updateRoom(chatRoom, updateAt, lastMessage);
      });
    }

    // realm.close();
  }

  updateRoom(
      ChatRoomModel chatRoom, int? updateAt, ChatMessageModel? lastMessage) {
    var rooms = realm.query<ChatRoomsRealm>('id == ${chatRoom.id}');

    if (rooms.isNotEmpty) {
      rooms.first.title = chatRoom.name;
      rooms.first.status = chatRoom.status;
      rooms.first.type = chatRoom.type;
      rooms.first.isChatUserOnline = chatRoom.isOnline == true ? 1 : 0;
      rooms.first.updatedAt = updateAt;
      rooms.first.imageUrl = chatRoom.image;
      rooms.first.description = chatRoom.description;
      rooms.first.chatAccessGroup = chatRoom.groupAccess;
      rooms.first.lastMessageId = lastMessage?.localMessageId;

      var roomMembers =
          realm.query<ChatRoomMembersRealm>('roomId = ${chatRoom.id}');
      for (ChatRoomMembersRealm member in roomMembers) {
        realm.delete(
          member,
        );
      }

      for (ChatRoomMember member in chatRoom.roomMembers) {
        realm.add(
          ChatRoomMembersRealm(
            id: member.id,
            roomId: member.roomId,
            userId: member.userId,
            isAdmin: member.isAdmin,
          ),
        );

        var cachedUsers =
            realm.query<UsersCacheRealm>('id = ${member.userDetail.id}');
        if (cachedUsers.isNotEmpty) {
          realm.delete(
            cachedUsers.first,
          );
        }

        realm.add(
          UsersCacheRealm(
            id: member.userDetail.id,
            username: member.userDetail.userName,
            email: member.userDetail.email,
            picture: member.userDetail.picture,
          ),
        );
      }
    }
  }

  updateRoomUpdateAtTime(int chatRoomId) async {
    int? updateAt = DateTime.now().millisecondsSinceEpoch;

    // var realm = await Realm.open(configuration);
    var rooms = realm.query<ChatRoomsRealm>('id == $chatRoomId');

    if (rooms.isNotEmpty) {
      rooms.first.updatedAt = updateAt;
    }
    // realm.close();
  }

  List<ChatRoomMember> getAllMembersInRoom(int roomId) {
    // var realm = await Realm.open(configuration);

    List<ChatRoomMember> membersArr = [];

    // realm.write(() {
    var roomMembers = realm.query<ChatRoomMembersRealm>('roomId == $roomId');

    for (var member in roomMembers) {
      var memberDetail = member.toMap();

      var cachedUser = realm.query<UsersCacheRealm>('id == ${member.userId}');

      memberDetail['user'] = cachedUser.first.toMap();

      final userModel = ChatRoomMember.fromJson(memberDetail);
      membersArr.add(userModel);
    }
    // });

    // realm.close();

    return membersArr;
  }

  List<ChatMessageUser> getAllMembersInMessage(int messageId) {
    // var realm = await Realm.open(configuration);

    List<ChatMessageUser> membersArr = [];

    realm.write(() {
      var users =
          realm.query<ChatMessageUserRealm>('chatMessageId == $messageId');

      membersArr =
          users.map((user) => ChatMessageUser.fromJson(user.toMap())).toList();
    });

    // realm.close();

    return membersArr;
  }

  insertChatMessageUsersFirstTime({required List<ChatMessageUser> users}) {
    realm.write(() {
      insertChatMessageUsers(users: users);
    });
  }

  Future<void> insertChatMessageUsers(
      {required List<ChatMessageUser> users}) async {
    for (ChatMessageUser user in users) {
      var existingUser = realm.query<ChatMessageUserRealm>(
          'userId == ${user.userId} AND chatMessageId == ${user.messageId}');

      if (existingUser.isEmpty) {
        realm.add(ChatMessageUserRealm(
            chatMessageId: user.messageId, userId: user.userId, status: 1));
      }
    }
  }

  Future<void> updateChatMessageUserStatus(
      {required int userId,
      required int messageId,
      required int status}) async {
    // var realm = await Realm.open(configuration);
    var chatMessageUser = realm.query<ChatMessageUserRealm>(
        'userId == $userId AND chatMessageId == $messageId');
    if (chatMessageUser.isNotEmpty) {
      realm.write(() {
        chatMessageUser.first.status = status;
      });
    }
    // realm.close();
  }

  Future<List<ChatRoomMember>> fetchAllMembersInRoom(int roomId) async {
    // var realm = await Realm.open(configuration);

    List<ChatRoomMember> membersArr = [];

    // realm.write(() {
    var roomMembers = realm.query<ChatRoomMembersRealm>('roomId == $roomId');

    for (var user in roomMembers) {
      var userData = realm.query<UsersCacheRealm>('id == ${user.userId}');

      final userDetail = user.toMap();
      userDetail['user'] = userData.first.toMap();

      final userModel = ChatRoomMember.fromJson(userDetail);
      membersArr.add(userModel);
    }
    // });

    // realm.close();

    return membersArr;
  }

  UserModel fetchUser(int userId) {
    if (cachedUsers[userId.toString()] != null) {
      return cachedUsers[userId.toString()]!;
    } else {
      var user = realm.query<UsersCacheRealm>('id == $userId').first;
      return UserModel.fromJson(user.toMap());
    }
  }

  Future<List<ChatRoomModel>> getAllRooms() async {
    final rooms = realm.all<ChatRoomsRealm>();

    final List<ChatRoomModel> result = [];

    for (final room in rooms) {
      var user = realm.query<UsersCacheRealm>('id == ${room.createdBy}');

      if (user.isNotEmpty) {
        Map<String, dynamic> roomMap = room.toMap();
        roomMap['createdByUser'] = user.first.toMap();

        ChatRoomModel chatRoomModel = ChatRoomModel.fromJson(roomMap);

        final usersInRoom = await fetchAllMembersInRoom(chatRoomModel.id);

        ChatMessageModel? lastMessage =
            await getLastMessageFromRoom(roomId: chatRoomModel.id);

        if (lastMessage != null) {
          chatRoomModel.lastMessage = lastMessage;
        }

        chatRoomModel.roomMembers = usersInRoom;

        if (usersInRoom.length > 1) {
          result.add(chatRoomModel);
        }
      }
    }

    result.sort((a, b) {
      if (b.updatedAt == null || a.updatedAt == null) {
        return 0;
      }
      return b.updatedAt!.compareTo(a.updatedAt!);
    });

    // realm.close();
    return result;
  }

  saveUserInCache({required UserModel user}) async {
    var cachedUsers = realm.query<UsersCacheRealm>('id = ${user.id}');
    if (cachedUsers.isNotEmpty) {
      realm.delete(
        cachedUsers.first,
      );
    }

    realm.add(UsersCacheRealm(
      id: user.id,
      username: user.userName,
      email: user.email,
      picture: user.picture,
    ));
    // });

    // realm.close();
  }

  Future<List<ChatMessageModel>> getAllMessages(
      {required int roomId, required int offset, int? limit}) async {
    List<ChatMessageModel> messages = [];
    List<dynamic> dbMessages = [];

    var realMMessages = realm.query<MessagesRealm>("roomId == $roomId");

    dbMessages = realMMessages.map((e) => e.toMap()).toList();
    dbMessages.sort((a, b) => b['created_at'].compareTo(a['created_at']));

    if (limit != null) {
      dbMessages = dbMessages.getSublist(offset, limit);
    }

    dbMessages.sort((a, b) => a['created_at'].compareTo(b['created_at']));

    messages = dbMessages.map((e) {
      ChatMessageModel message = ChatMessageModel.fromJson((e));
      List<ChatMessageUser> usersInMessage = getAllMembersInMessage(message.id);
      message.sender = fetchUser(message.senderId);
      message.chatMessageUser = usersInMessage;

      return message;
    }).toList();

    return messages.unique((e) => e.localMessageId);
  }

  updateMessageContent(
      {required String localMessageId, required String content}) async {
    realm.write(() {
      var realmMessages =
          realm.query<MessagesRealm>('localMessageId == "$localMessageId"');

      if (realmMessages.isNotEmpty) {
        realmMessages.first.message = content;
      }
    });
  }

  setMessageId({required String localMessageId, required int id}) async {
    realm.write(() {
      var realmMessages =
          realm.query<MessagesRealm>('localMessageId == "$localMessageId"');

      if (realmMessages.isNotEmpty) {
        realmMessages.first.id = id;
      }
    });
  }

  updateMessageViewedTime(List<ChatMessageModel> messages) async {
    realm.write(() {
      for (ChatMessageModel message in messages) {
        var realmMessages = realm.query<MessagesRealm>(
            'localMessageId == "${message.localMessageId}"');

        if (realmMessages.isNotEmpty) {
          realmMessages.first.viewedAt = DateTime.now().millisecondsSinceEpoch;
        }
      }
    });
  }

  updateMessageStatus(
      {required int roomId,
      required int messageId,
      required int status,
      required int userId}) async {
    // realm.write(() async {
    updateChatMessageUserStatus(
        userId: userId, messageId: messageId, status: status);

    // if (realmMessages.isNotEmpty) {
    //   realmMessages.first.currentStatus = status;
    //   realmMessages.first.id = id;
    // }
    // });
  }

  starUnStarMessage(
      {required String localMessageId, required int isStar}) async {
    realm.write(() {
      var realmMessages =
          realm.query<MessagesRealm>('localMessageId == "$localMessageId"');

      if (realmMessages.isNotEmpty) {
        realmMessages.first.isStar = isStar;
      }
    });
  }

  Future<List<ChatMessageModel>> getMessages(
      {required int roomId, required MessageContentType contentType}) async {
    List<ChatMessageModel> messages = [];

    // await database.transaction((txn) async {

    var realmMessages = realm.query<MessagesRealm>("roomId == $roomId");

    for (var realmMessage in realmMessages) {
      messages.add(ChatMessageModel.fromJson(realmMessage.toMap()));
    }
    messages = messages
        .where((element) =>
            element.messageContentType == contentType &&
            element.messageContent.isNotEmpty)
        .toList();
    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    // });

    return messages;
  }

  Future<List<ChatMessageModel>> getStarredMessages(
      {required int roomId}) async {
    List<ChatMessageModel> messages = [];
    // await database.transaction((txn) async {
    // List<Map> dbMessages =
    //     await txn.rawQuery('SELECT * FROM Messages WHERE room_id = $roomId');
    var realmMessages =
        realm.query<MessagesRealm>("roomId == $roomId AND isStar = 1");

    for (var realmMessage in realmMessages) {
      messages.add(ChatMessageModel.fromJson(realmMessage.toMap()));
    }
    // messages = messages.where((element) => element.isStar == 1).toList();
    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    // });

    return messages;
  }

  Future<List<ChatMessageModel>> getMessagesById(
      {required int messageId, required int roomId}) async {
    List<ChatMessageModel> messages = [];

    // await database.transaction((txn) async {
    // List<Map> dbMessages = await txn.rawQuery(
    //     'SELECT * FROM Messages WHERE room_id = $roomId AND id = $messageId');
    var realmMessages = realm.query<MessagesRealm>("id == $messageId");

    for (var realmMessage in realmMessages) {
      ChatMessageModel message =
          ChatMessageModel.fromJson(realmMessage.toMap());
      // if (message.id == messageId) {
      messages.add(message);
      // }
    }
    // });

    return messages;
  }

  Future<List<ChatMessageModel>> getMediaMessages({required int roomId}) async {
    List<ChatMessageModel> messages = [];

    // await database.transaction((txn) async {
    // List<Map> dbMessages = await txn.rawQuery(
    //     'SELECT * FROM Messages WHERE room_id = $roomId AND (type = 2 || type = 3 || type = 4)');
    var realmMessages = realm.query<MessagesRealm>(
        '(roomId == $roomId) AND (type == 2 OR type == 3 OR type == 4)');

    for (var realmMessage in realmMessages) {
      messages.add(ChatMessageModel.fromJson(realmMessage.toMap()));
    }

    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    // });

    return messages;
  }

  Future<ChatMessageModel?> getLastMessageFromRoom(
      {required int roomId}) async {
    var matchedMessages = realm.query<MessagesRealm>('roomId == $roomId');

    if (matchedMessages.isNotEmpty) {
      return ChatMessageModel.fromJson(matchedMessages.last.toMap());
    }

    return null;
  }

  hardDeleteMessages({required List<ChatMessageModel> messages}) async {
    realm.write(() {
      for (ChatMessageModel message in messages) {
        var realmMessages = realm.query<MessagesRealm>(
            'localMessageId == "${message.localMessageId}"');

        if (realmMessages.isNotEmpty) {
          realm.delete(realmMessages.first);
        }
      }
    });

    for (ChatMessageModel message in messages) {
      if (message.isMediaMessage) {
        getIt<FileManager>().deleteMessageMedia(message);
      }
    }
  }

  deleteMessagesInRoom(ChatRoomModel chatRoom) async {
    realm.write(() {
      var realmMessages =
          realm.query<MessagesRealm>('roomId == ${chatRoom.id}');

      for (MessagesRealm message in realmMessages) {
        realm.delete(message);
      }
    });
    getIt<FileManager>().deleteRoomMedia(chatRoom);
  }

  deleteRooms(List<ChatRoomModel> chatRooms) async {
    // await database.transaction((txn) async {
    realm.write(() {
      for (ChatRoomModel chatRoom in chatRooms) {
        var realmRooms = realm.query<ChatRoomsRealm>('id == ${chatRoom.id}');

        if (realmRooms.isNotEmpty) {
          realm.delete(realmRooms.first);
        }

        var realmMessages =
            realm.query<MessagesRealm>('roomId == ${chatRoom.id}');

        for (MessagesRealm message in realmMessages) {
          realm.delete(message);
        }
      }
    });

    for (ChatRoomModel chatRoom in chatRooms) {
      await getIt<FileManager>().deleteRoomMedia(chatRoom);
    }
  }

  softDeleteMessages({required List<ChatMessageModel> messagesToDelete}) async {
    realm.write(() {
      for (ChatMessageModel message in messagesToDelete) {
        var realmMessages = realm.query<MessagesRealm>(
            '(id == ${message.id}) OR localMessageId == "${message.localMessageId}"');

        if (realmMessages.isNotEmpty) {
          realmMessages.first.isDeleted = 1;
        }
      }
    });
  }

  updateUnReadCount({required int roomId}) async {
    realm.write(()  {
      var dbRooms = realm.query<ChatRoomsRealm>('id = $roomId');
      if (dbRooms.isNotEmpty) {
        dbRooms.first.unreadMessagesCount =
            (dbRooms.first.unreadMessagesCount ?? 0) + 1;
      }
    });
  }

  Future<int> roomsWithUnreadMessages() async {
    var rooms = realm.query<ChatRoomsRealm>('unreadMessagesCount > 0');

    return rooms.length;
  }

  clearUnReadCount({required int roomId}) async {
    realm.write(()  {
      var dbRooms = realm.query<ChatRoomsRealm>('id = $roomId');
      if (dbRooms.isNotEmpty) {
        dbRooms.first.unreadMessagesCount = 0;
      }
    });
  }

  clearAllUnreadCount() async {
    realm.write(()  {
      var rooms = realm.all<ChatRoomsRealm>();
      for (ChatRoomsRealm room in rooms) {
        room.unreadMessagesCount = 0;
      }
    });
  }

  deleteAllChatHistory() async {
    List<ChatRoomModel> allRooms = await getAllRooms();

    deleteRooms(allRooms);
  }
}
