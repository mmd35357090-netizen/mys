// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_db.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class StoryViewHistoryRealm extends _StoryViewHistoryRealm
    with RealmEntity, RealmObjectBase, RealmObject {
  StoryViewHistoryRealm({
    int? storyId,
    int? time,
  }) {
    RealmObjectBase.set(this, 'storyId', storyId);
    RealmObjectBase.set(this, 'time', time);
  }

  StoryViewHistoryRealm._();

  @override
  int? get storyId => RealmObjectBase.get<int>(this, 'storyId') as int?;

  @override
  set storyId(int? value) => RealmObjectBase.set(this, 'storyId', value);

  @override
  int? get time => RealmObjectBase.get<int>(this, 'time') as int?;

  @override
  set time(int? value) => RealmObjectBase.set(this, 'time', value);

  @override
  Stream<RealmObjectChanges<StoryViewHistoryRealm>> get changes =>
      RealmObjectBase.getChanges<StoryViewHistoryRealm>(this);

  @override
  StoryViewHistoryRealm freeze() =>
      RealmObjectBase.freezeObject<StoryViewHistoryRealm>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;

  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(StoryViewHistoryRealm._);
    return  SchemaObject(ObjectType.realmObject, StoryViewHistoryRealm,
        'StoryViewHistoryRealm', [
      SchemaProperty('storyId', RealmPropertyType.int, optional: true),
      SchemaProperty('time', RealmPropertyType.int, optional: true),
    ]);
  }
}

class ChatRoomsRealm extends _ChatRoomsRealm
    with RealmEntity, RealmObjectBase, RealmObject {
  ChatRoomsRealm({
    int? id,
    String? title,
    int? status,
    int? type,
    int? isChatUserOnline,
    int? createdBy,
    int? createdAt,
    int? updatedAt,
    String? imageUrl,
    String? description,
    int? chatAccessGroup,
    String? lastMessageId,
    int? unreadMessagesCount,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'title', title);
    RealmObjectBase.set(this, 'status', status);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'isChatUserOnline', isChatUserOnline);
    RealmObjectBase.set(this, 'createdBy', createdBy);
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set(this, 'updatedAt', updatedAt);
    RealmObjectBase.set(this, 'imageUrl', imageUrl);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'chatAccessGroup', chatAccessGroup);
    RealmObjectBase.set(this, 'lastMessageId', lastMessageId);
    RealmObjectBase.set(this, 'unreadMessagesCount', unreadMessagesCount);
  }

  ChatRoomsRealm._();

  @override
  int? get id => RealmObjectBase.get<int>(this, 'id') as int?;

  @override
  set id(int? value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get title => RealmObjectBase.get<String>(this, 'title') as String?;

  @override
  set title(String? value) => RealmObjectBase.set(this, 'title', value);

  @override
  int? get status => RealmObjectBase.get<int>(this, 'status') as int?;

  @override
  set status(int? value) => RealmObjectBase.set(this, 'status', value);

  @override
  int? get type => RealmObjectBase.get<int>(this, 'type') as int?;

  @override
  set type(int? value) => RealmObjectBase.set(this, 'type', value);

  @override
  int? get isChatUserOnline =>
      RealmObjectBase.get<int>(this, 'isChatUserOnline') as int?;

  @override
  set isChatUserOnline(int? value) =>
      RealmObjectBase.set(this, 'isChatUserOnline', value);

  @override
  int? get createdBy => RealmObjectBase.get<int>(this, 'createdBy') as int?;

  @override
  set createdBy(int? value) => RealmObjectBase.set(this, 'createdBy', value);

  @override
  int? get createdAt => RealmObjectBase.get<int>(this, 'createdAt') as int?;

  @override
  set createdAt(int? value) => RealmObjectBase.set(this, 'createdAt', value);

  @override
  int? get updatedAt => RealmObjectBase.get<int>(this, 'updatedAt') as int?;

  @override
  set updatedAt(int? value) => RealmObjectBase.set(this, 'updatedAt', value);

  @override
  String? get imageUrl =>
      RealmObjectBase.get<String>(this, 'imageUrl') as String?;

  @override
  set imageUrl(String? value) => RealmObjectBase.set(this, 'imageUrl', value);

  @override
  String? get description =>
      RealmObjectBase.get<String>(this, 'description') as String?;

  @override
  set description(String? value) =>
      RealmObjectBase.set(this, 'description', value);

  @override
  int? get chatAccessGroup =>
      RealmObjectBase.get<int>(this, 'chatAccessGroup') as int?;

  @override
  set chatAccessGroup(int? value) =>
      RealmObjectBase.set(this, 'chatAccessGroup', value);

  @override
  String? get lastMessageId =>
      RealmObjectBase.get<String>(this, 'lastMessageId') as String?;

  @override
  set lastMessageId(String? value) =>
      RealmObjectBase.set(this, 'lastMessageId', value);

  @override
  int? get unreadMessagesCount =>
      RealmObjectBase.get<int>(this, 'unreadMessagesCount') as int?;

  @override
  set unreadMessagesCount(int? value) =>
      RealmObjectBase.set(this, 'unreadMessagesCount', value);

  @override
  Stream<RealmObjectChanges<ChatRoomsRealm>> get changes =>
      RealmObjectBase.getChanges<ChatRoomsRealm>(this);

  @override
  ChatRoomsRealm freeze() => RealmObjectBase.freezeObject<ChatRoomsRealm>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;

  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(ChatRoomsRealm._);
    return  SchemaObject(
        ObjectType.realmObject, ChatRoomsRealm, 'ChatRoomsRealm', [
      SchemaProperty('id', RealmPropertyType.int, optional: true),
      SchemaProperty('title', RealmPropertyType.string, optional: true),
      SchemaProperty('status', RealmPropertyType.int, optional: true),
      SchemaProperty('type', RealmPropertyType.int, optional: true),
      SchemaProperty('isChatUserOnline', RealmPropertyType.int, optional: true),
      SchemaProperty('createdBy', RealmPropertyType.int, optional: true),
      SchemaProperty('createdAt', RealmPropertyType.int, optional: true),
      SchemaProperty('updatedAt', RealmPropertyType.int, optional: true),
      SchemaProperty('imageUrl', RealmPropertyType.string, optional: true),
      SchemaProperty('description', RealmPropertyType.string, optional: true),
      SchemaProperty('chatAccessGroup', RealmPropertyType.int, optional: true),
      SchemaProperty('lastMessageId', RealmPropertyType.string, optional: true),
      SchemaProperty('unreadMessagesCount', RealmPropertyType.int,
          optional: true),
    ]);
  }
}

class MessagesRealm extends _MessagesRealm
    with RealmEntity, RealmObjectBase, RealmObject {
  MessagesRealm({
    String? localMessageId,
    int? id,
    int? roomId,
    int? messageType,
    String? message,
    String? username,
    int? createdBy,
    int? createdAt,
    int? viewedAt,
    int? isDeleted,
    int? isStar,
    int? deleteAfter,
    int? isEncrypted,
    int? chatVersion,
    int? currentStatus,
    String? encryptionKey,
    String? repliedOnMessage,
  }) {
    RealmObjectBase.set(this, 'localMessageId', localMessageId);
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'roomId', roomId);
    RealmObjectBase.set(this, 'messageType', messageType);
    RealmObjectBase.set(this, 'message', message);
    RealmObjectBase.set(this, 'username', username);
    RealmObjectBase.set(this, 'createdBy', createdBy);
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set(this, 'viewedAt', viewedAt);
    RealmObjectBase.set(this, 'isDeleted', isDeleted);
    RealmObjectBase.set(this, 'isStar', isStar);
    RealmObjectBase.set(this, 'deleteAfter', deleteAfter);
    RealmObjectBase.set(this, 'isEncrypted', isEncrypted);
    RealmObjectBase.set(this, 'chatVersion', chatVersion);
    RealmObjectBase.set(this, 'currentStatus', currentStatus);
    RealmObjectBase.set(this, 'encryptionKey', encryptionKey);
    RealmObjectBase.set(this, 'repliedOnMessage', repliedOnMessage);
  }

  MessagesRealm._();

  @override
  String? get localMessageId =>
      RealmObjectBase.get<String>(this, 'localMessageId') as String?;

  @override
  set localMessageId(String? value) =>
      RealmObjectBase.set(this, 'localMessageId', value);

  @override
  int? get id => RealmObjectBase.get<int>(this, 'id') as int?;

  @override
  set id(int? value) => RealmObjectBase.set(this, 'id', value);

  @override
  int? get roomId => RealmObjectBase.get<int>(this, 'roomId') as int?;

  @override
  set roomId(int? value) => RealmObjectBase.set(this, 'roomId', value);

  @override
  int? get messageType => RealmObjectBase.get<int>(this, 'messageType') as int?;

  @override
  set messageType(int? value) =>
      RealmObjectBase.set(this, 'messageType', value);

  @override
  String? get message =>
      RealmObjectBase.get<String>(this, 'message') as String?;

  @override
  set message(String? value) => RealmObjectBase.set(this, 'message', value);

  @override
  String? get username =>
      RealmObjectBase.get<String>(this, 'username') as String?;

  @override
  set username(String? value) => RealmObjectBase.set(this, 'username', value);

  @override
  int? get createdBy => RealmObjectBase.get<int>(this, 'createdBy') as int?;

  @override
  set createdBy(int? value) => RealmObjectBase.set(this, 'createdBy', value);

  @override
  int? get createdAt => RealmObjectBase.get<int>(this, 'createdAt') as int?;

  @override
  set createdAt(int? value) => RealmObjectBase.set(this, 'createdAt', value);

  @override
  int? get viewedAt => RealmObjectBase.get<int>(this, 'viewedAt') as int?;

  @override
  set viewedAt(int? value) => RealmObjectBase.set(this, 'viewedAt', value);

  @override
  int? get isDeleted => RealmObjectBase.get<int>(this, 'isDeleted') as int?;

  @override
  set isDeleted(int? value) => RealmObjectBase.set(this, 'isDeleted', value);

  @override
  int? get isStar => RealmObjectBase.get<int>(this, 'isStar') as int?;

  @override
  set isStar(int? value) => RealmObjectBase.set(this, 'isStar', value);

  @override
  int? get deleteAfter => RealmObjectBase.get<int>(this, 'deleteAfter') as int?;

  @override
  set deleteAfter(int? value) =>
      RealmObjectBase.set(this, 'deleteAfter', value);

  @override
  int? get isEncrypted => RealmObjectBase.get<int>(this, 'isEncrypted') as int?;

  @override
  set isEncrypted(int? value) =>
      RealmObjectBase.set(this, 'isEncrypted', value);

  @override
  int? get chatVersion => RealmObjectBase.get<int>(this, 'chatVersion') as int?;

  @override
  set chatVersion(int? value) =>
      RealmObjectBase.set(this, 'chatVersion', value);

  @override
  int? get currentStatus =>
      RealmObjectBase.get<int>(this, 'currentStatus') as int?;

  @override
  set currentStatus(int? value) =>
      RealmObjectBase.set(this, 'currentStatus', value);

  @override
  String? get encryptionKey =>
      RealmObjectBase.get<String>(this, 'encryptionKey') as String?;

  @override
  set encryptionKey(String? value) =>
      RealmObjectBase.set(this, 'encryptionKey', value);

  @override
  String? get repliedOnMessage =>
      RealmObjectBase.get<String>(this, 'repliedOnMessage') as String?;

  @override
  set repliedOnMessage(String? value) =>
      RealmObjectBase.set(this, 'repliedOnMessage', value);

  @override
  Stream<RealmObjectChanges<MessagesRealm>> get changes =>
      RealmObjectBase.getChanges<MessagesRealm>(this);

  @override
  MessagesRealm freeze() => RealmObjectBase.freezeObject<MessagesRealm>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;

  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(MessagesRealm._);
    return  SchemaObject(
        ObjectType.realmObject, MessagesRealm, 'MessagesRealm', [
      SchemaProperty('localMessageId', RealmPropertyType.string,
          optional: true),
      SchemaProperty('id', RealmPropertyType.int, optional: true),
      SchemaProperty('roomId', RealmPropertyType.int, optional: true),
      SchemaProperty('messageType', RealmPropertyType.int, optional: true),
      SchemaProperty('message', RealmPropertyType.string, optional: true),
      SchemaProperty('username', RealmPropertyType.string, optional: true),
      SchemaProperty('createdBy', RealmPropertyType.int, optional: true),
      SchemaProperty('createdAt', RealmPropertyType.int, optional: true),
      SchemaProperty('viewedAt', RealmPropertyType.int, optional: true),
      SchemaProperty('isDeleted', RealmPropertyType.int, optional: true),
      SchemaProperty('isStar', RealmPropertyType.int, optional: true),
      SchemaProperty('deleteAfter', RealmPropertyType.int, optional: true),
      SchemaProperty('isEncrypted', RealmPropertyType.int, optional: true),
      SchemaProperty('chatVersion', RealmPropertyType.int, optional: true),
      SchemaProperty('currentStatus', RealmPropertyType.int, optional: true),
      SchemaProperty('encryptionKey', RealmPropertyType.string, optional: true),
      SchemaProperty('repliedOnMessage', RealmPropertyType.string,
          optional: true),
    ]);
  }
}

class ChatRoomMembersRealm extends _ChatRoomMembersRealm
    with RealmEntity, RealmObjectBase, RealmObject {
  ChatRoomMembersRealm({
    int? id,
    int? roomId,
    int? userId,
    int? isAdmin,
    String? user,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'roomId', roomId);
    RealmObjectBase.set(this, 'userId', userId);
    RealmObjectBase.set(this, 'isAdmin', isAdmin);
    RealmObjectBase.set(this, 'user', user);
  }

  ChatRoomMembersRealm._();

  @override
  int? get id => RealmObjectBase.get<int>(this, 'id') as int?;

  @override
  set id(int? value) => RealmObjectBase.set(this, 'id', value);

  @override
  int? get roomId => RealmObjectBase.get<int>(this, 'roomId') as int?;

  @override
  set roomId(int? value) => RealmObjectBase.set(this, 'roomId', value);

  @override
  int? get userId => RealmObjectBase.get<int>(this, 'userId') as int?;

  @override
  set userId(int? value) => RealmObjectBase.set(this, 'userId', value);

  @override
  int? get isAdmin => RealmObjectBase.get<int>(this, 'isAdmin') as int?;

  @override
  set isAdmin(int? value) => RealmObjectBase.set(this, 'isAdmin', value);

  @override
  String? get user => RealmObjectBase.get<String>(this, 'user') as String?;

  @override
  set user(String? value) => RealmObjectBase.set(this, 'user', value);

  @override
  Stream<RealmObjectChanges<ChatRoomMembersRealm>> get changes =>
      RealmObjectBase.getChanges<ChatRoomMembersRealm>(this);

  @override
  ChatRoomMembersRealm freeze() =>
      RealmObjectBase.freezeObject<ChatRoomMembersRealm>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;

  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(ChatRoomMembersRealm._);
    return  SchemaObject(
        ObjectType.realmObject, ChatRoomMembersRealm, 'ChatRoomMembersRealm', [
      SchemaProperty('id', RealmPropertyType.int, optional: true),
      SchemaProperty('roomId', RealmPropertyType.int, optional: true),
      SchemaProperty('userId', RealmPropertyType.int, optional: true),
      SchemaProperty('isAdmin', RealmPropertyType.int, optional: true),
      SchemaProperty('user', RealmPropertyType.string, optional: true),
    ]);
  }
}

class UsersCacheRealm extends _UsersCacheRealm
    with RealmEntity, RealmObjectBase, RealmObject {
  UsersCacheRealm({
    int? id,
    String? username,
    String? email,
    String? picture,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'username', username);
    RealmObjectBase.set(this, 'email', email);
    RealmObjectBase.set(this, 'picture', picture);
  }

  UsersCacheRealm._();

  @override
  int? get id => RealmObjectBase.get<int>(this, 'id') as int?;

  @override
  set id(int? value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get username =>
      RealmObjectBase.get<String>(this, 'username') as String?;

  @override
  set username(String? value) => RealmObjectBase.set(this, 'username', value);

  @override
  String? get email => RealmObjectBase.get<String>(this, 'email') as String?;

  @override
  set email(String? value) => RealmObjectBase.set(this, 'email', value);

  @override
  String? get picture =>
      RealmObjectBase.get<String>(this, 'picture') as String?;

  @override
  set picture(String? value) => RealmObjectBase.set(this, 'picture', value);

  @override
  Stream<RealmObjectChanges<UsersCacheRealm>> get changes =>
      RealmObjectBase.getChanges<UsersCacheRealm>(this);

  @override
  UsersCacheRealm freeze() =>
      RealmObjectBase.freezeObject<UsersCacheRealm>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;

  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(UsersCacheRealm._);
    return  SchemaObject(
        ObjectType.realmObject, UsersCacheRealm, 'UsersCacheRealm', [
      SchemaProperty('id', RealmPropertyType.int, optional: true),
      SchemaProperty('username', RealmPropertyType.string, optional: true),
      SchemaProperty('email', RealmPropertyType.string, optional: true),
      SchemaProperty('picture', RealmPropertyType.string, optional: true),
    ]);
  }
}

class ChatMessageUserRealm extends _ChatMessageUserRealm
    with RealmEntity, RealmObjectBase, RealmObject {
  ChatMessageUserRealm({
    int? chatMessageId,
    int? userId,
    int? status,
  }) {
    RealmObjectBase.set(this, 'chatMessageId', chatMessageId);
    RealmObjectBase.set(this, 'userId', userId);
    RealmObjectBase.set(this, 'status', status);
  }

  ChatMessageUserRealm._();

  @override
  int? get chatMessageId =>
      RealmObjectBase.get<int>(this, 'chatMessageId') as int?;

  @override
  set chatMessageId(int? value) =>
      RealmObjectBase.set(this, 'chatMessageId', value);

  @override
  int? get userId => RealmObjectBase.get<int>(this, 'userId') as int?;

  @override
  set userId(int? value) => RealmObjectBase.set(this, 'userId', value);

  @override
  int? get status => RealmObjectBase.get<int>(this, 'status') as int?;

  @override
  set status(int? value) => RealmObjectBase.set(this, 'status', value);

  @override
  Stream<RealmObjectChanges<ChatMessageUserRealm>> get changes =>
      RealmObjectBase.getChanges<ChatMessageUserRealm>(this);

  @override
  ChatMessageUserRealm freeze() =>
      RealmObjectBase.freezeObject<ChatMessageUserRealm>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;

  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(ChatMessageUserRealm._);
    return  SchemaObject(
        ObjectType.realmObject, ChatMessageUserRealm, 'ChatMessageUserRealm', [
      SchemaProperty('chatMessageId', RealmPropertyType.int, optional: true),
      SchemaProperty('userId', RealmPropertyType.int, optional: true),
      SchemaProperty('status', RealmPropertyType.int, optional: true),
    ]);
  }
}
