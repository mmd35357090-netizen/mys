import 'package:foap/util/time_convertor.dart';
import 'package:get/get.dart';

import '../helper/enum.dart';
import '../helper/localization_strings.dart';
import 'user_model.dart';

class CommentModel {
  int id = 0;
  String comment = "";

  int userId = 0;
  String userName = '';
  String? userPicture;
  String commentTime = '';

  CommentType type = CommentType.text; // text=1, image=2, video = 3, gif =4
  String filename = '';

  CommentModel();

  factory CommentModel.fromJson(dynamic json) {
    CommentModel model = CommentModel();
    model.id = json['id'];
    model.comment = json['comment'];
    model.userId = json['user_id'];
    dynamic user = json['user'];
    if (user != null) {
      model.userName = user['username'];
      model.userPicture = user['picture'];
    }

    model.type = json['type'] == 4
        ? CommentType.gif
        : json['type'] == 3
            ? CommentType.video
            : json['type'] == 2
                ? CommentType.image
                : CommentType.text;
    model.filename = json['filenameUrl'] ?? '';

    DateTime createDate =
        DateTime.fromMillisecondsSinceEpoch(json['created_at'] * 1000).toUtc();
    model.commentTime = TimeAgo.timeAgoSinceDate(createDate);
    return model;
  }

  factory CommentModel.fromNewMessage(CommentType type, UserModel user,
      {String? comment, String? filename}) {
    CommentModel model = CommentModel();
    model.type = type;
    model.comment = comment ?? '';
    model.filename = type == CommentType.image
        ? 'https://product.fwdtechnology.co/social_media_plus/uploads/image/${filename ?? ''}'
        : filename ?? '';

    model.userId = user.id;
    model.userName = user.userName;
    model.userPicture = user.picture;

    model.commentTime = justNowString.tr;

    return model;
  }
}
