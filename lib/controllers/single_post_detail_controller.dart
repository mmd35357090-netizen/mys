import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';
import 'package:foap/apiHandler/api_controller.dart';
import 'package:foap/model/post_model.dart';

class SinglePostDetailController extends GetxController {
  Rx<PostModel?> post = Rx<PostModel?>(null);
  bool isLoading = false;

  clear() {
    post.value = null;
    isLoading = false;
  }

  getPostDetail(int postId) async {
    isLoading = true;
    await ApiController().getPostDetail(postId).then((value) {
      post.value = value.post;
      isLoading = false;
      update();
    });
  }

  void likeUnlikePost( BuildContext context) {
    post.value!.isLike = !post.value!.isLike;
    post.value!.totalLike = post.value!.isLike
        ? (post.value!.totalLike) + 1
        : (post.value!.totalLike) - 1;
    AppUtil.checkInternet().then((value) async {
      if (value) {
        ApiController()
            .likeUnlike(post.value!.isLike, post.value!.id)
            .then((response) async {});
      } else {
        AppUtil.showToast(
            message: LocalizationString.noInternet, isSuccess: true);
      }
    });

    update();
  }
}
