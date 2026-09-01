import 'package:foap/helper/enum_linking.dart';
import 'package:foap/helper/imports/common_import.dart';

class CollaborationModel {
  int id;
  int refId;
  int collaboratorId;
  int authorId;
  CollaborationStatusType status;
  DateTime createdAt;

  UserModel? user;

  CollaborationModel(
      {required this.id,
      required this.refId,
      required this.collaboratorId,
      required this.authorId,
      required this.status,
      required this.createdAt,
      this.user});

  factory CollaborationModel.fromJson(Map<String, dynamic> json) =>
      CollaborationModel(
        id: json["id"],
        refId: json["reference_id"],
        collaboratorId: json["collaborator_id"],
        authorId: json["author_id"],
        status: collaborationStatusType(json["status"]),
        user: json["collaboratorDetail"] == null
            ? null
            : UserModel.fromJson(json["collaboratorDetail"]),
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(json['created_at'] * 1000)
                .toUtc(),
      );
}
