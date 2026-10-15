import 'package:foap/helper/imports/common_import.dart';
import '../../helper/enum_linking.dart';
import '../../model/api_meta_data.dart';
import '../../model/comment_model.dart';
import '../../model/location.dart';
import '../../model/post_model.dart';
import '../api_wrapper.dart';

class PostApi {
  static addPost(
      {required PostCategory postType,
      required PostContentType postContentType,
      required String title,
      required List<Map<String, String>> gallery,
      required bool allowComments,
      required bool isPaidContent,
      LocationModel? location,
      String? hashTag,
      String? mentions,
      int? competitionId,
      int? sharingPostId,
      int? contentRefId,
      int? clubId,
      int? eventId,
      int? fundRaisingCampaignId,
      int? audioId,
      double? audioStartTime,
      double? audioEndTime,
      required Function(int?) resultCallback}) async {
    var url = competitionId == null
        ? NetworkConstantsUtil.addPost
        : NetworkConstantsUtil.addCompetitionPost;

    var parameters = {
      "type": postTypeValueFrom(postType).toString(),
      "origin_post_id": sharingPostId,
      "title": title,
      "hashtag": hashTag,
      "mentionUser": mentions,
      "gallary": gallery,
      'competition_id': competitionId,
      'content_type_reference_id': contentRefId,
      'club_id': clubId,
      'event_id': eventId,
      'campaign_id': fundRaisingCampaignId,
      'post_content_type':
          postContentTypeIdFrom(postContentType).toString(),
      'audio_id': audioId,
      'audio_start_time': audioStartTime,
      'audio_end_time': audioEndTime,
      'is_add_to_post': 1,
      'display_whose': isPaidContent ? 2 : 1,
      'is_comment_enable': allowComments == true ? 1 : 0,
      'latitude': location == null ? '' : location.latitude.toString(),
      'longitude': location == null ? '' : location.longitude.toString(),
      'address': location == null ? '' : location.name.toString()
    };

    print('parameters $parameters');

    await ApiWrapper().postApi(url: url, param: parameters).then((result) {
      if (result?.success == true) {
        resultCallback(result!.data['post_id']);
      } else {
        resultCallback(null);
      }
    });
  }

  static updatePost(
      {required int postId,
      required String title,
      required bool allowComments,
      required VoidCallback successHandler}) async {
    var url = '${NetworkConstantsUtil.editPost}$postId';

    var parameters = {
      "title": title,
      'is_comment_enable': allowComments == true ? 1 : 0
    };

    await ApiWrapper().putApi(url: url, param: parameters).then((result) {
      if (result?.success == true) {
        successHandler();
      }
    });
  }

  static getPosts(
      {PostCategory? postType,
      int? userId,
      int? isPopular,
      int? isFollowing,
      int? clubId,
      int? eventId,
      int? fundRaisingCampaignId,
      int? isSold,
      int? isSaved,
      int? audioId,
      int? isVideo,
      int? isMine,
      int? isRecent,
      int? isCollaboration,
      String? title,
      String? hashtag,
      int page = 0,
      required Function(List<PostModel>, APIMetaData)
          resultCallback}) async {
    var url = NetworkConstantsUtil.searchPost;

    if (postType != null) {
      url = '$url&type=${postTypeValueFrom(postType).toString()}';
    }
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
    } else {
      url = '$url&is_recent=1';
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
    if (isCollaboration != null) {
      url = '$url&is_collaborate=1';
    }
    if (eventId != null) {
      url = '$url&event_id=$eventId';
    }
    if (fundRaisingCampaignId != null) {
      url = '$url&campaign_id=$fundRaisingCampaignId';
    }
    if (audioId != null) {
      url = '$url&audio_id=$audioId';
    }
    if (isSaved != null) {
      url = '$url&is_favorite=1';
    }
    if (isVideo != null) {
      url = '$url&is_video_post=1';
    }
    url = '$url&page=$page';
    await ApiWrapper().getApi(url: url).then((response) {
      if (response?.data != null) {
        List<PostModel> posts = [];
        var items = response!.data['post']['items'];
        posts =
            List<PostModel>.from(items.map((x) => PostModel.fromJson(x)))
                .toList();

        APIMetaData metaData =
            APIMetaData.fromJson(response.data['post']['_meta']);

        resultCallback(posts, metaData);
      }
    });
  }

  static getPromotionalPosts(
      {int page = 0,
      required Function(List<PostModel>, APIMetaData)
          resultCallback}) async {
    var url = NetworkConstantsUtil.getPromotedPosts;

    await ApiWrapper().getApi(url: url).then((response) {
      Loader.dismiss();

      if (response?.data != null) {
        List<PostModel> posts = [];
        var items = response!.data['postPromotionList']['items'];
        posts =
            List<PostModel>.from(items.map((x) => PostModel.fromJson(x)))
                .toList();

        APIMetaData metaData = APIMetaData.fromJson(
            response.data['postPromotionList']['_meta']);

        resultCallback(posts, metaData);
      }
    });
  }

  static getMentionedPosts(
      {int? userId,
      int page = 1,
      required Function(List<PostModel>, APIMetaData)
          resultCallback}) async {
    var url = '${NetworkConstantsUtil.mentionedPosts}$userId&page=$page';

    await ApiWrapper().getApi(url: url).then((response) {
      if (response?.data != null) {
        List<PostModel> posts = [];
        var items = response!.data['post']['items'];
        posts =
            List<PostModel>.from(items.map((x) => PostModel.fromJson(x)))
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

  static Future<void> getPostDetailByUniqueId(String id,
      {required Function(PostModel?) resultCallback}) async {
    var url = NetworkConstantsUtil.postDetailByUniqueId;
    url =
        '$url$id&expand=user,user.userLiveDetail,clubDetail,audio,giftSummary,clubDetail.createdByUser';
    await ApiWrapper().getApi(url: url).then((response) {
      if (response?.success == true) {
        var post = response!.data['post'];
        if (post != null) {
          resultCallback(PostModel.fromJson(post));
        } else {
          resultCallback(null);
        }
      } else {}
    });
  }

  static Future<void> getComments(
      {required int postId,
      int? parentId,
      required int page,
      required Function(List<CommentModel>, APIMetaData)
          resultCallback}) async {
    var url = NetworkConstantsUtil.getComments;
    if (parentId != null) {
      url =
          '$url?expand=user,isPin,isLike&post_id=$postId&parent_id=$parentId&page=$page';
    } else {
      url =
          '$url?expand=user,isPin,isLike,totalChildComment,childCommentDetail.isLike,childCommentDetail.user&post_id=$postId&page=$page';
    }

    await ApiWrapper().getApi(url: url).then((response) {
      if (response?.success == true) {
        var items = response!.data['comment']['items'];
        resultCallback(
            List<CommentModel>.from(
                items.map((x) => CommentModel.fromJson(x))),
            APIMetaData.fromJson(response.data['comment']['_meta']));
      }
    });
  }

  static postComment(
      {required int postId,
      int? parentCommentId,
      required CommentType? type,
      required Function(int) resultCallback,
      String? comment,
      String? filename}) async {
    var url = NetworkConstantsUtil.addComment;

    await ApiWrapper().postApi(url: url, param: {
      "post_id": postId.toString(),
      "parent_id": parentCommentId ?? 0,
      'comment': comment ?? '',
      "type": type == CommentType.gif
          ? '4'
          : type == CommentType.video
              ? '3'
              : type == CommentType.image
                  ? '2'
                  : '1',
      "filename": filename ?? ''
    }).then((response) {
      if (response?.success == true) {
        var id = response!.data['id'];

        resultCallback(id);
      }
    });
  }

  static deleteComment(
      {required int commentId,
      required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.deleteComment + commentId.toString();

    await ApiWrapper().deleteApi(url: url).then((value) {
      resultCallback();
    });
  }

  static reportComment(
      {required int commentId,
      required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.reportComment;

    await ApiWrapper().postApi(
        url: url,
        param: {"post_comment_id": commentId.toString()}).then((value) {
      resultCallback();
    });
  }

  static favComment(
      {required int commentId,
      required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.likeComment;

    await ApiWrapper().postApi(url: url, param: {
      "comment_id": commentId.toString(),
      "source_type": "1"
    }).then((value) {
      resultCallback();
    });
  }

  static unfavComment(
      {required int commentId,
      required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.unLikeComment;

    await ApiWrapper().postApi(url: url, param: {
      "comment_id": commentId.toString(),
      "source_type": "1"
    }).then((value) {
      resultCallback();
    });
  }

  static reportPost(
      {required int postId, required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.reportPost;

    await ApiWrapper().postApi(
        url: url, param: {"post_id": postId.toString()}).then((value) {
      resultCallback();
    });
  }

  static deletePost(
      {required int postId, required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.deletePost;
    url = url.replaceAll('{{id}}', postId.toString());

    await ApiWrapper().deleteApi(url: url).then((value) {
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

  static likeUnlikePost({required bool like, required int postId}) async {
    var url = (like
        ? NetworkConstantsUtil.likePost
        : NetworkConstantsUtil.unlikePost);

    await ApiWrapper().postApi(
        url: url, param: {"post_id": postId.toString()}).then((value) {});
  }

  static Future<void> postLikedByUsers(
      {required int postId,
      required int page,
      required Function(List<UserModel>, APIMetaData)
          resultCallback}) async {
    var url = NetworkConstantsUtil.postLikedByUsers
        .replaceAll('{{post_id}}', postId.toString());

    url = '$url&page=$page';

    await ApiWrapper().getApi(url: url).then((response) {
      if (response?.success == true) {
        var items = response!.data['results']['items'];
        resultCallback(
            List<UserModel>.from(
                items.map((x) => UserModel.fromJson(x['user']))),
            APIMetaData.fromJson(response.data['results']['_meta']));
      }
    });
  }

  static saveUnSavePost({required bool save, required int postId}) async {
    var url = (save
        ? NetworkConstantsUtil.savePost
        : NetworkConstantsUtil.removeSavedPost);

    await ApiWrapper().postApi(url: url, param: {
      "reference_id": postId.toString(),
      'type': '3'
    }).then((value) {});
  }

  static postView(
      {required int postId,
      required int sourceType,
      int? postPromotionId}) async {
    var url = NetworkConstantsUtil.postView;

    await ApiWrapper().postApi(url: url, param: {
      'post_id': postId.toString(),
      'view_source': sourceType.toString(),
      'post_promotion_id': postPromotionId
    });
  }

  static linkCollaborator(
      {required int postId, required int collaboratorId}) async {
    var url = NetworkConstantsUtil.addCollaborate;

    await ApiWrapper().postApi(url: url, param: {
      'reference_id': postId.toString(),
      'type': '1',
      'collaborator_id': collaboratorId.toString()
    });
  }

  static updateCollaborationStatus(
      {required int id, required CollaborationStatusType status}) async {
    var url = NetworkConstantsUtil.addCollaborationStatus;

    await ApiWrapper().postApi(url: url, param: {
      'id': id.toString(),
      'status': collaborationStatusTypeId(status).toString(),
    });
  }

  static createPoll(
      {required String question,
      required List<String> options,
      required Function(int) successCallback,
      required VoidCallback failureCallback}) async {
    var url = NetworkConstantsUtil.createPoll;

    await ApiWrapper().postApi(url: url, param: {
      "type": '2',
      "category_id": "1",
      "description": "Just for testing",
      "start_time": "2023/08/27",
      "end_time": "2030/08/27",
      "title": question,
      'options': options.map((e) => {"title": e}).toList(),
    }).then((result) {
      if (result?.success == true) {
        successCallback(result!.data['id']);
      } else {
        failureCallback();
      }
    });
  }
}
