class RelationTypeModel {
  int id = 0;
  String name = '';

  RelationTypeModel();

  factory RelationTypeModel.fromJson(dynamic json) {
    RelationTypeModel model = RelationTypeModel();
    model.id = json['id'] ?? 0;
    model.name = (json['name'] ?? '').toString();
    return model;
  }
}

/// A relation invitation / relation row. [isIncoming] is true when somebody
/// invited me (I can accept or decline), false for relations I created.
class RelationInvitationModel {
  int id = 0;
  int status = 1; // 1 pending, 2 cancelled, 3 rejected, 4 accepted
  String relationName = '';
  int otherUserId = 0;
  String otherUserName = '';
  String? otherUserPicture;
  bool isIncoming = false;

  RelationInvitationModel();

  factory RelationInvitationModel.fromJson(dynamic json,
      {required bool isIncoming}) {
    RelationInvitationModel model = RelationInvitationModel();
    model.id = json['id'] ?? 0;
    model.status = json['status'] ?? 1;
    model.isIncoming = isIncoming;

    var relationShip = json['relationShip'];
    model.relationName = relationShip == null
        ? ''
        : (relationShip['name'] ?? '').toString();

    var other = isIncoming ? json['createdBy'] : json['user'];
    if (other != null) {
      model.otherUserId = other['id'] ?? 0;
      model.otherUserName = (other['username'] ?? '').toString();
      model.otherUserPicture =
          (other['picture'] ?? other['imageUrl'])?.toString();
    }
    return model;
  }

  bool get isPending => status == 1;
  bool get isAccepted => status == 4;
}
