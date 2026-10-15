import 'package:flutter/services.dart';
import 'package:foap/components/post_card/reshare_post.dart';
import 'package:foap/helper/imports/models.dart';
import '../../controllers/chat_and_call/select_user_for_chat_controller.dart';
import '../../helper/imports/common_import.dart';
import '../../screens/chat/select_users.dart';
import '../post_card_controller.dart';

class SharePost extends StatelessWidget {
  final PostModel post;

  SharePost({super.key, required this.post});

  final SelectUserForChatController selectUserForChatController =
      SelectUserForChatController();
  final PostCardController postCardController = Get.find();

  @override
  Widget build(BuildContext context) {
    return sharePost();
  }

  Widget sharePost() {
    return Container(
      color: AppColorConstants.cardColor,
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                BodyMediumText(
                  shareToFeedString.tr,
                  weight: TextWeight.semiBold,
                ),
                const SizedBox(
                  height: 10,
                ),
                ReSharePost(
                  post: post,
                ),
                divider(height: 0.5).vP16,
                BodyMediumText(
                  sendSeparatelyToFriends.tr,
                  weight: TextWeight.semiBold,
                ),
                Expanded(child: SelectFollowingUserForMessageSending(
                    sendToUserCallback: (user) {
                  selectUserForChatController.sendMessage(
                      toUser: user, post: post);
                })),
              ],
            ).p(DesignConstants.horizontalPadding),
          ),
          Container(
            color: AppColorConstants.backgroundColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      color: AppColorConstants.themeColor,
                      child: ThemeIconWidget(
                        ThemeIcon.share,
                        color: Colors.white,
                      ),
                    ).circular,
                    const SizedBox(
                      height: 5,
                    ),
                    BodySmallText(shareToString.tr)
                  ],
                ).ripple(() {
                  postCardController.sharePost(post: post);
                }),
                const SizedBox(
                  width: 20,
                ),
                Column(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      color: AppColorConstants.themeColor,
                      child: ThemeIconWidget(
                        ThemeIcon.copyToClipboard,
                        color: Colors.white,
                      ),
                    ).circular,
                    const SizedBox(
                      height: 5,
                    ),
                    BodySmallText(copyLinkString.tr)
                  ],
                ).ripple(() async {
                  AppUtil.showToast(
                      message: copiedString.tr, isSuccess: true);

                  await Clipboard.setData(
                      ClipboardData(text: post.shareLink));
                })
              ],
            ).setPadding(
                left: 100,
                right: 100,
                top: DesignConstants.horizontalPadding,
                bottom: DesignConstants.horizontalPadding),
          )
        ],
      ),
    ).topRounded(40);
  }
}
