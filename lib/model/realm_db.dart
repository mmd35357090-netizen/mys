import 'package:realm/realm.dart';

part 'realm_db.g.dart';

@RealmModel()
class _StoryViewHistoryRealm {
  int? storyId;
  int? time;
}

@RealmModel()
class _ChatRoomsRealm {
  int? id;
  String? title;
  int? status;
  int? type;
  int? isChatUserOnline;
  int? createdBy;
  int? createdAt;
  int? updatedAt;
  String? imageUrl;
  String? description;
  int? chatAccessGroup;
  String? lastMessageId;
  int? unreadMessagesCount;
}

@RealmModel()
class _MessagesRealm {
  String? localMessageId;
  int? id;
  int? roomId;
  int? messageType;
  String? message;
  String? username;
  int? createdBy;
  int? createdAt;
  int? viewedAt;
  int? isDeleted;
  int? isStar;
  int? deleteAfter;
  int? isEncrypted;
  int? chatVersion;
  int? currentStatus;
  String? encryptionKey;
  String? repliedOnMessage;
}

@RealmModel()
class _ChatRoomMembersRealm {
  int? id;
  int? roomId;
  int? userId;
  int? isAdmin;
  String? user;
}

@RealmModel()
class _UsersCacheRealm {
  int? id;
  String? username;
  String? email;
  String? picture;
}

@RealmModel()
class _ChatMessageUserRealm {
  int? chatMessageId;
  int? userId;
  int? status;
}

extension ChatMessageUserRealmExtension on ChatMessageUserRealm {
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'chatMessageId': chatMessageId,
      'userId': userId,
      'status': status,
      // Add other properties and their values
    };
  }
}

extension UsersCacheRealmExtension on UsersCacheRealm {
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'username': username,
      'email': email,
      'picture': picture,
      // Add other properties and their values
    };
  }
}

extension ChatRoomMembersRealmExtension on ChatRoomMembersRealm {
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'roomId': roomId,
      'userId': userId,
      'isAdmin': isAdmin,
      // Add other properties and their values
    };
  }
}

extension ChatRoomsRealmExtension on ChatRoomsRealm {
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'status': status,
      'type': type,
      'is_chat_user_online': isChatUserOnline,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'imageUrl': imageUrl,
      'description': description,
      'chat_access_group': chatAccessGroup,
      'last_message_id': lastMessageId,
      'unread_messages_count': unreadMessagesCount,

      // Add other properties and their values
    };
  }
}

extension MessagesRealmExtension on MessagesRealm {
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'local_message_id': localMessageId,
      'id': id,
      'room_id': roomId,
      'messageType': messageType,
      'message': message,
      'username': username,
      'created_by': createdBy,
      'created_at': createdAt,
      'viewed_at': viewedAt,
      'isDeleted': isDeleted,
      'isStar': isStar,
      'deleteAfter': deleteAfter,
      'is_encrypted': isEncrypted,
      'chat_version': chatVersion,
      'current_status': currentStatus,
      'replied_on_message': repliedOnMessage,

      // Add other properties and their values
    };
  }
}
