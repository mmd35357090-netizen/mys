class LiveUserResponse {
  int? status;
  String? statusText;
  String? message;
  Data? data;

  LiveUserResponse({this.status, this.statusText, this.message, this.data});

  LiveUserResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusText = json['statusText'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['statusText'] = this.statusText;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<LiveStreamUser>? liveStreamUser;

  Data({this.liveStreamUser});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['liveStreamUser'] != null) {
      liveStreamUser = <LiveStreamUser>[];
      json['liveStreamUser'].forEach((v) {
        liveStreamUser!.add(new LiveStreamUser.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.liveStreamUser != null) {
      data['liveStreamUser'] =
          this.liveStreamUser!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LiveStreamUser {
  int? id;
  int? userId;
  int? status;
  int? startTime;
  Null? endTime;
  int? totalTime;
  String? channelName;
  String? token;

  LiveStreamUser(
      {this.id,
        this.userId,
        this.status,
        this.startTime,
        this.endTime,
        this.totalTime,
        this.channelName,
        this.token});

  LiveStreamUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    status = json['status'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    totalTime = json['total_time'];
    channelName = json['channel_name'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['status'] = this.status;
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
    data['total_time'] = this.totalTime;
    data['channel_name'] = this.channelName;
    data['token'] = this.token;
    return data;
  }
}