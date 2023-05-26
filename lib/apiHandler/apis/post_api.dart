import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../helper/enum.dart';
import '../../helper/enum_linking.dart';
import '../../helper/localization_strings.dart';
import '../../model/api_meta_data.dart';
import '../../model/comment_model.dart';
import '../../model/post_model.dart';
import '../../util/app_util.dart';
import '../../util/shared_prefs.dart';
import '../api_wrapper.dart';

class PostApi {
  static addPost(
      {required PostType postType,
      required String title,
      required List<Map<String, String>> gallery,
      String? hashTag,
      String? mentions,
      int? competitionId,
      int? clubId,
      int? audioId,
      double? audioStartTime,
      double? audioEndTime,
      bool? addToPost,
      required Function(int?) resultCallback}) async {
    var url = competitionId == null
        ? NetworkConstantsUtil.addPost
        : NetworkConstantsUtil.addCompetitionPost;

    var parameters = {
      "type": postTypeValueFrom(postType).toString(),
      "title": title,
      "hashtag": hashTag,
      "mentionUser": mentions,
      "gallary": gallery,
      'competition_id': competitionId,
      'club_id': clubId,
      'post_content_type': gallery.isEmpty ? 1 : 2,
      'audio_id': audioId,
      'audio_start_time': audioStartTime,
      'audio_end_time': audioEndTime,
      'is_add_to_post': addToPost == true ? 1 : 0
    };

    ApiWrapper().postApi(url: url, param: parameters).then((result) {
      if (result?.success == true) {
        resultCallback(result!.data['post_id']);
      } else {
        resultCallback(null);
      }
    });
  }

  static getPosts(
      {int? userId,
      int? isPopular,
      int? isFollowing,
      int? clubId,
      int? isSold,
      int? isReel,
      int? audioId,
      int? isMine,
      int? isRecent,
      String? title,
      String? hashtag,
      int page = 0,
      required Function(List<PostModel>, APIMetaData) resultCallback}) async {
    var url = NetworkConstantsUtil.searchPost;

    if (userId != null) {
      url = '$url&user_id=$userId';
    }
    if (isPopular != null) {
      url = '$url&is_popular_post=$isPopular';
    }
    if (title != null) {
      url = '$url&title=$title';
    }
    if (isRecent != null) {
      url = '$url&is_recent=$isRecent';
    }
    if (isFollowing != null) {
      url = '$url&is_following_user_post=$isFollowing';
    }
    if (isMine != null) {
      url = '$url&is_my_post=$isMine';
    }
    if (isSold != null) {
      url = '$url&is_winning_post=$isSold';
    }
    if (hashtag != null) {
      url = '$url&hashtag=$hashtag';
    }
    if (clubId != null) {
      url = '$url&club_id=$clubId';
    }
    if (isReel != null) {
      url = '$url&is_reel=$isReel';
    }
    if (audioId != null) {
      url = '$url&audio_id=$audioId';
    }
    url = '$url&page=$page';
    EasyLoading.show(status: loadingString.tr);

    print('get post url $url');
    await ApiWrapper().getApi(url: url).then((response) {
      EasyLoading.dismiss();

      if (response?.data != null) {
        List<PostModel> posts = [];
        var items = response!.data['post']['items'];
        posts = List<PostModel>.from(items.map((x) => PostModel.fromJson(x)))
            .where((element) => element.gallery.isNotEmpty)
            .toList();

        APIMetaData metaData =
            APIMetaData.fromJson(response.data['post']['_meta']);

        resultCallback(posts, metaData);
      }
    });
  }

  static getMentionedPosts(
      {int? userId,
      int page = 0,
      required Function(List<PostModel>, APIMetaData) resultCallback}) async {
    var url = '${NetworkConstantsUtil.mentionedPosts}$userId&page=$page';

    EasyLoading.show(status: loadingString.tr);

    await ApiWrapper().getApi(url: url).then((response) {
      EasyLoading.dismiss();

      if (response?.data != null) {
        List<PostModel> posts = [];
        var items = response!.data['post']['items'];
        posts = List<PostModel>.from(items.map((x) => PostModel.fromJson(x)))
            .where((element) => element.gallery.isNotEmpty)
            .toList();

        APIMetaData metaData =
            APIMetaData.fromJson(response.data['post']['_meta']);

        resultCallback(posts, metaData);
      }
    });
  }

  static Future<void> getPostDetail(int id,
      {required Function(PostModel?) resultCallback}) async {
    var url = NetworkConstantsUtil.postDetail;
    url = url.replaceAll('{id}', id.toString());
    await ApiWrapper().getApi(url: url).then((response) {
      if (response?.success == true) {
        var post = response!.data['post'];
        resultCallback(PostModel.fromJson(post));
      } else {
        resultCallback(null);
      }
    });
  }

  static Future<void> getComments(
      {required int postId,
      required int page,
      required Function(List<CommentModel>, APIMetaData)
          resultCallback}) async {
    var url =
        '${NetworkConstantsUtil.getComments}?expand=user&post_id=$postId&page=$page';

    await ApiWrapper().getApi(url: url).then((response) {
      if (response?.success == true) {
        var items = response!.data['comment']['items'];
        resultCallback(
            List<CommentModel>.from(items.map((x) => CommentModel.fromJson(x))),
            APIMetaData.fromJson(response.data['comment']['_meta']));
      }
    });
  }

  static postComment(
      {required int postId,
      required String comment,
      required VoidCallback resultCallback}) {
    var url = NetworkConstantsUtil.addComment;

    ApiWrapper().postApi(url: url, param: {
      "post_id": postId.toString(),
      'comment': comment
    }).then((value) {
      resultCallback();
    });
  }

  static reportPost(
      {required int postId, required VoidCallback resultCallback}) {
    var url = NetworkConstantsUtil.reportPost;

    ApiWrapper()
        .postApi(url: url, param: {"post_id": postId.toString()}).then((value) {
      resultCallback();
    });
  }

  static deletePost(
      {required int postId, required VoidCallback resultCallback}) {
    var url = NetworkConstantsUtil.deletePost;
    url = url.replaceAll('{{id}}', postId.toString());

    ApiWrapper().deleteApi(url: url).then((value) {
      resultCallback();
    });
  }

  static Future<void> getPostInsight(int id,
      {required Function(PostInsight) resultCallback}) async {
    var url = '${NetworkConstantsUtil.postInsight}$id';
    await ApiWrapper().getApi(url: url).then((response) {
      if (response?.success == true) {
        resultCallback(PostInsight.fromJson(response!.data['insight']));
      }
    });
  }

  static likeUnlikePost({required bool like, required int postId}) {
    var url = (like
        ? NetworkConstantsUtil.likePost
        : NetworkConstantsUtil.unlikePost);

    ApiWrapper().postApi(
        url: url, param: {"post_id": postId.toString()}).then((value) {});
  }

  static Future uploadFile(String filePath,
      {required Function(String, String) resultCallback}) async {
    EasyLoading.show(status: loadingString.tr);

    await ApiWrapper()
        .uploadPostFile(
      url: NetworkConstantsUtil.uploadPostImage,
      file: filePath,
    )
        .then((result) {
      EasyLoading.dismiss();
      if (result?.success == true) {
        resultCallback(result!.data['filename'], result.data['fileUrl']);
      }
    });
  }
}
