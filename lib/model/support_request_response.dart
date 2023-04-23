class SupportRequestsResponse {
  SupportRequest? supportRequest;

  SupportRequestsResponse({this.supportRequest});

  SupportRequestsResponse.fromJson(Map<String, dynamic> json) {
    supportRequest = json['supportRequest'] != null
        ? new SupportRequest.fromJson(json['supportRequest'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.supportRequest != null) {
      data['supportRequest'] = this.supportRequest!.toJson();
    }
    return data;
  }
}

class SupportRequest {
  List<Items>? items;
  Links? lLinks;
  Meta? mMeta;

  SupportRequest({this.items, this.lLinks, this.mMeta});

  SupportRequest.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(new Items.fromJson(v));
      });
    }
    lLinks = json['_links'] != null ? new Links.fromJson(json['_links']) : null;
    mMeta = json['_meta'] != null ? new Meta.fromJson(json['_meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    if (this.lLinks != null) {
      data['_links'] = this.lLinks!.toJson();
    }
    if (this.mMeta != null) {
      data['_meta'] = this.mMeta!.toJson();
    }
    return data;
  }
}

class Items {
  int? id;
  int? userId;
  String? name;
  String? email;
  String? phone;
  String? requestMessage;
  Null? replyMessage;
  int? isReply;
  int? status;
  int? createdAt;
  int? createdBy;
  Null? updatedAt;
  Null? updatedBy;

  Items(
      {this.id,
        this.userId,
        this.name,
        this.email,
        this.phone,
        this.requestMessage,
        this.replyMessage,
        this.isReply,
        this.status,
        this.createdAt,
        this.createdBy,
        this.updatedAt,
        this.updatedBy});

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    requestMessage = json['request_message'];
    replyMessage = json['reply_message'];
    isReply = json['is_reply'];
    status = json['status'];
    createdAt = json['created_at'];
    createdBy = json['created_by'];
    updatedAt = json['updated_at'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['request_message'] = this.requestMessage;
    data['reply_message'] = this.replyMessage;
    data['is_reply'] = this.isReply;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['created_by'] = this.createdBy;
    data['updated_at'] = this.updatedAt;
    data['updated_by'] = this.updatedBy;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalCount'] = this.totalCount;
    data['pageCount'] = this.pageCount;
    data['currentPage'] = this.currentPage;
    data['perPage'] = this.perPage;
    return data;
  }
}