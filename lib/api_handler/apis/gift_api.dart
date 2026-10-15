import 'package:foap/api_handler/api_wrapper.dart';
import 'package:foap/helper/enum_linking.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../model/api_meta_data.dart';
import '../../model/category_model.dart';
import '../../model/gift_model.dart';

class GiftApi {
  static getReceivedStickerGifts(
      {required int page,
      GiftSource? giftSource,
      int? postId,
      int? liveId,
      required Function(List<ReceivedGiftModel>, APIMetaData)
          resultCallback}) async {
    var url = NetworkConstantsUtil.giftsReceived;
    url = url.replaceAll('{{send_on_type}}',
        liveId == null ? '' : giftSourceId(giftSource!).toString());
    url = url.replaceAll(
        '{{live_call_id}}', liveId == null ? '' : liveId.toString());
    url = url.replaceAll(
        '{{post_id}}', postId == null ? '' : postId.toString());

    url = '$url&page=$page';

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['gift']['items'];

        resultCallback(
            List<ReceivedGiftModel>.from(
                items.map((x) => ReceivedGiftModel.fromJson(x))),
            APIMetaData.fromJson(result.data['gift']['_meta']));
      }
    });
  }

  static getLiveCallReceivedStickerGifts(
      {required int page,
      required int liveId,
      required int? battleId,
      required Function(List<ReceivedGiftModel>, List<LiveCallHostUser>,
              APIMetaData?)
          resultCallback}) async {
    var url =
        '${NetworkConstantsUtil.liveGiftsReceived}live_call_id=$liveId';
    if (battleId != null) {
      url = '$url&battle_id=$battleId';
    }
    url = '$url&page=$page';

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var giftsItems = result!.data['gift'] == null
            ? []
            : result.data['gift']['items'];
        var users = result.data['battleUser'];

        resultCallback(
            List<ReceivedGiftModel>.from(
                giftsItems.map((x) => ReceivedGiftModel.fromJson(x))),
            List<LiveCallHostUser>.from(
                users.map((x) => LiveCallHostUser.fromJson(x))),
            result.data['gift']['_meta'] == null
                ? null
                : APIMetaData.fromJson(result.data['gift']['_meta']));
      }
    });
  }

  static getStickerGiftCategories(
      {required Function(List<GiftCategoryModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.giftsCategories;

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['category'];

        resultCallback(List<GiftCategoryModel>.from(
            items.map((x) => GiftCategoryModel.fromJson(x))));
      }
    });
  }

  static getStickerGiftsByCategory(int categoryId,
      {required Function(List<GiftModel>) resultCallback}) async {
    var url = '${NetworkConstantsUtil.giftsByCategory}$categoryId';

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['gift']['items'];

        resultCallback(
            List<GiftModel>.from(items.map((x) => GiftModel.fromJson(x))));
      }
    });
  }

  static getMostUsedStickerGifts(
      {required Function(List<GiftModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.mostUsedGifts;

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['gift']['items'];

        resultCallback(
            List<GiftModel>.from(items.map((x) => GiftModel.fromJson(x))));
      }
    });
  }

  static sendStickerGift(
      {required GiftModel gift,
      required int? liveId,
      required int? postId,
      required int receiverId,
      required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.sendGift;

    await ApiWrapper().postApi(url: url, param: {
      "gift_id": gift.id.toString(),
      'reciever_id': receiverId.toString(),
      'send_on_type': liveId != null
          ? giftSourceId(GiftSource.live)
          : postId != null
              ? giftSourceId(GiftSource.post)
              : giftSourceId(GiftSource.profile),
      'live_call_id': liveId == null ? '' : liveId.toString(),
      'post_id': postId == null ? '' : postId.toString()
    }).then((result) {
      if (result?.success == true) {
        resultCallback();
      }
    });
  }
}
