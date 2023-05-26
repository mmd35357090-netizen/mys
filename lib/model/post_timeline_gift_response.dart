import 'package:foap/model/post_gift_model.dart';

class TimelineGift {
  int? id;
  int? recieverId;
  int? senderId;
  int? giftId;
  int? coin;
  int? sendOnType;
  Null? liveCallId;
  int? postId;
  int? createdAt;
  int? postType;
  SenderDetail? senderDetail;
  PostGiftModel? giftTimelineDetail;

  TimelineGift(
      {this.id,
      this.recieverId,
      this.senderId,
      this.giftId,
      this.coin,
      this.sendOnType,
      this.liveCallId,
      this.postId,
      this.createdAt,
      this.postType,
      this.senderDetail,
      this.giftTimelineDetail});

  TimelineGift.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    recieverId = json['reciever_id'];
    senderId = json['sender_id'];
    giftId = json['gift_id'];
    coin = json['coin'];
    sendOnType = json['send_on_type'];
    liveCallId = json['live_call_id'];
    postId = json['post_id'];
    createdAt = json['created_at'];
    postType = json['post_type'];
    senderDetail = json['senderDetail'] != null
        ? new SenderDetail.fromJson(json['senderDetail'])
        : null;
    giftTimelineDetail = json['giftTimelineDetail'] != null
        ? new PostGiftModel.fromJson(json['giftTimelineDetail'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['reciever_id'] = this.recieverId;
    data['sender_id'] = this.senderId;
    data['gift_id'] = this.giftId;
    data['coin'] = this.coin;
    data['send_on_type'] = this.sendOnType;
    data['live_call_id'] = this.liveCallId;
    data['post_id'] = this.postId;
    data['created_at'] = this.createdAt;
    data['post_type'] = this.postType;
    if (this.senderDetail != null) {
      data['senderDetail'] = this.senderDetail!.toJson();
    }
    if (this.giftTimelineDetail != null) {
      data['giftTimelineDetail'] = this.giftTimelineDetail!.toJson();
    }
    return data;
  }
}

class SenderDetail {
  String? name;
  String? username;
  String? email;
  Null? image;
  int? id;
  int? isChatUserOnline;
  int? chatLastTimeOnline;
  Null? location;
  Null? latitude;
  Null? longitude;
  int? isReported;
  Null? picture;
  Null? coverImageUrl;
  Null? userStory;
  Null? profileCategoryName;
  int? isLike;

  SenderDetail(
      {this.name,
      this.username,
      this.email,
      this.image,
      this.id,
      this.isChatUserOnline,
      this.chatLastTimeOnline,
      this.location,
      this.latitude,
      this.longitude,
      this.isReported,
      this.picture,
      this.coverImageUrl,
      this.userStory,
      this.profileCategoryName,
      this.isLike});

  SenderDetail.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    username = json['username'];
    email = json['email'];
    image = json['image'];
    id = json['id'];
    isChatUserOnline = json['is_chat_user_online'];
    chatLastTimeOnline = json['chat_last_time_online'];
    location = json['location'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    isReported = json['is_reported'];
    picture = json['picture'];
    coverImageUrl = json['coverImageUrl'];
    userStory = json['userStory'];
    profileCategoryName = json['profileCategoryName'];
    isLike = json['is_like'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['username'] = this.username;
    data['email'] = this.email;
    data['image'] = this.image;
    data['id'] = this.id;
    data['is_chat_user_online'] = this.isChatUserOnline;
    data['chat_last_time_online'] = this.chatLastTimeOnline;
    data['location'] = this.location;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['is_reported'] = this.isReported;
    data['picture'] = this.picture;
    data['coverImageUrl'] = this.coverImageUrl;
    data['userStory'] = this.userStory;
    data['profileCategoryName'] = this.profileCategoryName;
    data['is_like'] = this.isLike;
    return data;
  }
}

class Links {
  Self? self;
  Self? first;
  Self? last;

  Links({this.self, this.first, this.last});

  Links.fromJson(Map<String, dynamic> json) {
    self = json['self'] != null ? new Self.fromJson(json['self']) : null;
    first = json['first'] != null ? new Self.fromJson(json['first']) : null;
    last = json['last'] != null ? new Self.fromJson(json['last']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.self != null) {
      data['self'] = this.self!.toJson();
    }
    if (this.first != null) {
      data['first'] = this.first!.toJson();
    }
    if (this.last != null) {
      data['last'] = this.last!.toJson();
    }
    return data;
  }
}

class Self {
  String? href;

  Self({this.href});

  Self.fromJson(Map<String, dynamic> json) {
    href = json['href'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['href'] = this.href;
    return data;
  }
}

class Meta {
  int? totalCount;
  int? pageCount;
  int? currentPage;
  int? perPage;

  Meta({this.totalCount, this.pageCount, this.currentPage, this.perPage});

  Meta.fromJson(Map<String, dynamic> json) {
    totalCount = json['totalCount'];
    pageCount = json['pageCount'];
    currentPage = json['currentPage'];
    perPage = json['perPage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['totalCount'] = totalCount;
    data['pageCount'] = pageCount;
    data['currentPage'] = currentPage;
    data['perPage'] = perPage;
    return data;
  }
}
