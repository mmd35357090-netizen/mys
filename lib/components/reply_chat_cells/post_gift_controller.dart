import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../apiHandler/api_controller.dart';
import '../../model/gift_model.dart';
import '../../model/post_gift_model.dart';
import '../../util/app_util.dart';

class PostGiftController extends GetxController {
  RxList<PostGiftModel> timelineGift = <PostGiftModel>[].obs;

  void fetchPostGift(int postId) {
    AppUtil.checkInternet().then((value) {
      timelineGift.clear();
      ApiController()
          .getPostGifts(sendOnType: 3, postId: postId)
          .then((response) {
        // print('fetchPostGift success : $response');
        // Get.snackbar('fetchPostGift', 'done');
        final postGift = response.postTimelineGift;
        timelineGift.clear();
        postGift?.timelineGift?.items?.forEach((item) {
          if (item.giftTimelineDetail != null) {
            timelineGift.add(item.giftTimelineDetail!);
          }
        });
      });
    });
  }

  void fetchTimelinePostGift() {
    AppUtil.checkInternet().then((value) {
      ApiController().getTimelineGifts().then((response) {
        timelineGift.clear();
        timelineGift.addAll(response.timelineGift);
      });
    });
  }
}
