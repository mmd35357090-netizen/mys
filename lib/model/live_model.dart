import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/user_model.dart';
import 'package:intl/intl.dart';

import 'call_model.dart';

class LiveModel {
  int id = 0;
  int startTime = 0;
  bool isOngoing = false;
  int endTime = 0;
  int totalTime = 0;
  bool isBattle = false;
  GiftSummary? giftSummary;
  String? startedAt;

  UserProfileManager userProfileManager = Get.find();
  String channelName = '';
  String shareLink = '';

  // List<LiveCallHostUser> battleUsers = [];
  UserModel? invitedUserDetail;
  UserModel? mainHostUserDetail;
  BattleDetail? battleDetail;

  String token = '';
  List<UserModel>? host;

  LiveModel();

  factory LiveModel.fromJson(dynamic json) {
    LiveModel model = LiveModel();
    model.id = json['id'];
    model.isOngoing = json['status'] == 1;
    model.startTime = json['start_time'];
    model.endTime = json['end_time'] ?? 0;
    model.totalTime = json['total_time'];
    model.giftSummary = json['giftSummary'] == null
        ? null
        : GiftSummary.fromJson(json['giftSummary']);
    model.shareLink = json['share_link'];

    model.startedAt = DateFormat('dd-MM-yyyy hh:mm a')
        .format(DateTime.fromMillisecondsSinceEpoch(json['start_time'] * 1000));
    model.channelName = json['channel_name'] ?? '';
    model.token = json['token'] ?? '';
    if (json['userdetails'] != null) {
      model.host = <UserModel>[];
      json['userdetails'].forEach((v) {
        model.host!.add(UserModel.fromJson(v));
      });
    }
    return model;
  }

  bool isPendingInvitation() {
    return invitedUserDetail != null;
  }

  bool get amIMainHostInLive {
    return mainHostUserDetail!.id == userProfileManager.user.value!.id;
  }

  bool get amIHostInLive {
    if ((battleDetail?.battleUsers ?? []).isNotEmpty) {
      return battleDetail!.amIHostInLive;
    }
    return mainHostUserDetail!.id == userProfileManager.user.value!.id;
  }

  BattleStatus get battleStatus {
    if (battleDetail == null) {
      return BattleStatus.none;
    }
    return battleDetail!.battleStatus;
  }

  bool get canInvite {
    return invitedUserDetail == null && battleStatus == BattleStatus.none;
  }

  clearBattleData() {
    battleDetail = null;
    invitedUserDetail = null;
  }
}
