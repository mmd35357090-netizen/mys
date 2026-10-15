import 'package:foap/helper/date_extension.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/post_model.dart';
import 'club_model.dart';
import 'collaboration_model.dart';
import 'competition_model.dart';

class NotificationModel {
  int id;

  String title;
  String message;

  DateTime date;
  UserModel? actionBy;
  ClubModel? club;
  CompetitionModel? competition;
  PostModel? post;
  SMNotificationType type;
  String notificationDate = earlierString.tr;
  bool readStatus;
  CollaborationModel? collaboration;

  NotificationModel(
      {required this.id,
      required this.title,
      required this.message,
      required this.date,
      required this.type,
      this.readStatus = false,
      this.actionBy,
      this.competition,
      this.post,
      this.club,
      this.collaboration});

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json["id"],
        title: json["title"],
        message: json["message"],
        date:
        AppUtil.convertToDateTime(json['created_at']),
        type: getType(json["type"]),
        actionBy: json["createdByUser"] == null
            ? null
            : UserModel.fromJson(json["createdByUser"]),
        competition: json["type"] == 4
            ? CompetitionModel.fromJson(json["refrenceDetails"])
            : null,
        post: json["type"] == 2 || json["type"] == 3 || json["type"] == 7
            ? json["refrenceDetails"] == null
                ? null
                : PostModel.fromJson(json["refrenceDetails"])
            : null,
        collaboration: json["type"] == 40
            ? CollaborationModel.fromJson(json["refrenceDetails"])
            : null,
        readStatus: json["read_status"] == 1,
      );

  String get notificationTime {
    return date.getTimeAgo;
  }

  static SMNotificationType getType(int type) {
    if (type == 1) {
      return SMNotificationType.follow;
    }
    if (type == 2) {
      return SMNotificationType.comment;
    }
    if (type == 3) {
      return SMNotificationType.like;
    }
    if (type == 4) {
      return SMNotificationType.competitionAdded;
    }
    if (type == 6) {
      return SMNotificationType.supportRequest;
    }
    if (type == 8) {
      return SMNotificationType.gift;
    }
    if (type == 9) {
      return SMNotificationType.verification;
    }
    if (type == 11) {
      return SMNotificationType.clubInvitation;
    }
    if (type == 13) {
      return SMNotificationType.relationInvite;
    }
    if (type == 15) {
      return SMNotificationType.followRequest;
    }
    if (type == 33) {
      return SMNotificationType.subscribed;
    }
    if (type == 40) {
      return SMNotificationType.collaborate;
    }
    return SMNotificationType.none;
  }
}
