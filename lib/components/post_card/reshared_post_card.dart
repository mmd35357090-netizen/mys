import 'package:flare_flutter/flare_controls.dart';
import 'package:foap/components/post_card/post_text_widget.dart';
import 'package:foap/components/post_card/post_user_info.dart';
import 'package:foap/helper/imports/post_imports.dart';
import '../../controllers/chat_and_call/chat_detail_controller.dart';
import '../../controllers/chat_and_call/select_user_for_chat_controller.dart';
import '../../controllers/home/home_controller.dart';
import '../../helper/imports/common_import.dart';

class ResharedPostCard extends StatelessWidget {
  final PostModel model;
  final HomeController homeController = Get.find();
  final PostCardController postCardController = Get.find();
  final ChatDetailController chatDetailController = Get.find();
  final SelectUserForChatController selectUserForChatController =
      SelectUserForChatController();
  final FlareControls flareControls = FlareControls();

  ResharedPostCard({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        PostUserInfo(
          post: model,
          isSponsored: false,
        ),
        model.postTitle.isNotEmpty
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 4),
                RichTextPostTitle(model: model),
                const SizedBox(height: 10),
              ])
            : const SizedBox(),
        const SizedBox(
          height: 10,
        ),
        if (model.gallery.isNotEmpty)
          PostMediaTile(
            model: model,
            isSharedPostMedia: true,
          ),
      ]).p(DesignConstants.horizontalPadding),
    ).borderWithRadius(value: 1, radius: 10).ripple(() {
      Get.to(() => SinglePostDetail(postId: model.id));
    });
  }
}
