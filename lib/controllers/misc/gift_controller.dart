import 'package:foap/api_handler/apis/gift_api.dart';
import 'package:get/get.dart';
import '../../model/category_model.dart';
import '../../model/data_wrapper.dart';
import '../../model/gift_model.dart';
import '../../model/post_gift_model.dart';

class GiftController extends GetxController {
  RxList<GiftCategoryModel> giftsCategories = <GiftCategoryModel>[].obs;
  RxList<GiftModel> gifts = <GiftModel>[].obs;
  RxList<GiftModel> topGifts = <GiftModel>[].obs;
  RxList<PostGiftModel> timelineGift = <PostGiftModel>[].obs;
  RxList<ReceivedGiftModel> stickerGifts = <ReceivedGiftModel>[].obs;

  DataWrapper stickerGiftsDataWrapper = DataWrapper();
  DataWrapper timelineGiftDataWrapper = DataWrapper();

  RxInt selectedSegment = 0.obs;

  clear() {
    stickerGifts.clear();
    timelineGift.clear();
    giftsCategories.clear();
    gifts.clear();
    topGifts.clear();

    stickerGiftsDataWrapper = DataWrapper();
    timelineGiftDataWrapper = DataWrapper();
  }

  segmentChanged(int segment) {
    selectedSegment.value = segment;
    loadGifts(giftsCategories[segment].id);
  }

  loadGiftCategories() {
    gifts.clear();
    update();
    GiftApi.getStickerGiftCategories(resultCallback: (result) {
      giftsCategories.value = result;
      loadGifts(giftsCategories.first.id);
    });
  }

  loadMostUsedGifts() {
    GiftApi.getMostUsedStickerGifts(resultCallback: (result) {
      topGifts.value = result;

      update();
    });
  }

  loadGifts(int categoryId) {
    GiftApi.getStickerGiftsByCategory(categoryId,
        resultCallback: (result) {
      gifts.value = result;

      update();
    });
  }

  void fetchReceivedGifts() {
    if (timelineGiftDataWrapper.haveMoreData.value) {
      GiftApi.getReceivedStickerGifts(
          page: timelineGiftDataWrapper.page,
          resultCallback: (result, metadata) {
            timelineGiftDataWrapper.processCompletedWithData(metadata);
            stickerGifts.addAll(result);
          },
          liveId: null);
    }
  }

}
