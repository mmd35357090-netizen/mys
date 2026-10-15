import 'package:foap/helper/imports/common_import.dart';
import '../../model/api_meta_data.dart';
import '../../model/category_model.dart';
import '../../model/comment_model.dart';
import '../../model/fund_raising_campaign.dart';
import '../api_wrapper.dart';

class FundRaisingApi {
  static getCategories(
      {required Function(List<FundRaisingCampaignCategoryModel>)
          resultCallback}) async {
    var url = NetworkConstantsUtil.campaignCategories;

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['category'];

        resultCallback(List<FundRaisingCampaignCategoryModel>.from(
            items.map((x) => FundRaisingCampaignCategoryModel.fromJson(x))));
      }
    });
  }

  static favUnfavCampaign(bool fav, int campaignId) async {
    var url = (fav
        ? NetworkConstantsUtil.favCampaign
        : NetworkConstantsUtil.unFavCampaign);

    await ApiWrapper()
        .postApi(url: url, param: {"id": campaignId.toString()}).then((result) {
      if (result?.success == true) {}
    });
  }

  static getCampaigns(
      {required FundRaisingCampaignSearchModel searchModel,
      required int page,
      required Function(List<FundRaisingCampaign>, APIMetaData)
          resultCallback}) async {
    var url = NetworkConstantsUtil.campaignsList;

    if (searchModel.title != null) {
      url = '$url&title=${searchModel.title}';
    }
    if (searchModel.categoryId != null) {
      url = '$url&category_id=${searchModel.categoryId}';
    }
    if (searchModel.campaignerId != null) {
      url = '$url&campaigner_id=${searchModel.campaignerId}';
    }
    if (searchModel.campaignForId != null) {
      url = '$url&campaign_for_id=${searchModel.campaignForId}';
    }
    url = '$url&page=$page';

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['campaign']['items'];

        resultCallback(
            List<FundRaisingCampaign>.from(
                items.map((x) => FundRaisingCampaign.fromJson(x))),
            APIMetaData.fromJson(result.data['campaign']['_meta']));
      }
    });
  }

  static getFavCampaigns(
      {required int page,
      required Function(List<FundRaisingCampaign>, APIMetaData)
          resultCallback}) async {
    var url = NetworkConstantsUtil.favCampaignsList;
    url = '$url&page=$page';

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['campaignFavoriteList']['items'];

        resultCallback(
            List<FundRaisingCampaign>.from(
                items.map((x) => FundRaisingCampaign.fromJson(x))),
            APIMetaData.fromJson(result.data['campaignFavoriteList']['_meta']));
        // resultCallback(List<FundRaisingCampaign>.from(
        //     items.map((x) => FundRaisingCampaign.fromJson(x))));
      }
    });
  }

  static getCampaignDonors(
      {required int page,
      required int campaignId,
      required Function(List<UserModel>, APIMetaData) resultCallback}) async {
    var url = NetworkConstantsUtil.donorsList + campaignId.toString();
    url = '$url&page=$page';

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['donorsList']['items'];

        resultCallback(
            List<UserModel>.from(
                items.map((x) => UserModel.fromJson(x['userDetail']))),
            APIMetaData.fromJson(result.data['donorsList']['_meta']));
        // resultCallback(List<FundRaisingCampaign>.from(
        //     items.map((x) => FundRaisingCampaign.fromJson(x))));
      }
    });
  }

  static getComments(
      {required int page,
      int? parentId,
      required int campaignId,
      required Function(List<CommentModel>, APIMetaData)
          resultCallback}) async {
    var url =
        '${NetworkConstantsUtil.campaignComments}&campaign_id=$campaignId';

    if (parentId != null) {
      url = '$url&parent_id=$parentId';
    }
    url = '$url&page=$page';

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['comment']['items'];

        resultCallback(
            List<CommentModel>.from(items.map((x) => CommentModel.fromJson(x))),
            APIMetaData.fromJson(result.data['comment']['_meta']));
      }
    });
  }

  static postComment(
      {required String comment,
      required int campaignId,
      int? parentCommentId,
      required Function(int) resultCallback}) async {
    var url = NetworkConstantsUtil.addCommentOnCampaign;
    await ApiWrapper().postApi(url: url, param: {
      'campaign_id': campaignId,
      'parent_id': parentCommentId ?? 0,
      'comment': comment
    }).then((response) {
      if (response?.success == true) {
        var id = response!.data['id'];

        resultCallback(id);
      }
    });
  }

  static makeDonationPayment(
      {required FundraisingDonationRequest orderRequest,
      required Function(bool) resultCallback}) async {
    var url = NetworkConstantsUtil.makeDonationPayment;
    dynamic param = orderRequest.toJson();

    await ApiWrapper().postApi(url: url, param: param).then((result) {
      if (result?.success == true) {
        resultCallback(true);
      } else {
        resultCallback(false);
      }
    });
  }

  static deleteComment(
      {required int commentId, required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.deleteCampaignComment;

    await ApiWrapper()
        .postApi(url: url, param: {'id': commentId.toString()}).then((value) {
      resultCallback();
    });
  }

  static reportComment(
      {required int commentId, required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.reportGenericComment;

    await ApiWrapper().postApi(url: url, param: {
      "reference_id": commentId.toString(),
      "type": '1'
    }).then((value) {
      resultCallback();
    });
  }

  static favComment(
      {required int commentId, required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.likeComment;

    await ApiWrapper().postApi(url: url, param: {
      "comment_id": commentId.toString(),
      "source_type": "2"
    }).then((value) {
      resultCallback();
    });
  }

  static unfavComment(
      {required int commentId, required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.unLikeComment;

    await ApiWrapper().postApi(url: url, param: {
      "comment_id": commentId.toString(),
      "source_type": "2"
    }).then((value) {
      resultCallback();
    });
  }
}
