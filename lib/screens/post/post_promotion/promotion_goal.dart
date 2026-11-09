import 'package:foap/helper/imports/common_import.dart';
import '../../../controllers/post/promotion_controller.dart';
import 'goal_phone.dart';
import 'goal_website_url.dart';
import 'promotion_ui.dart';

class PromotionGoalScreen extends StatelessWidget {
  PromotionGoalScreen({super.key});
  final PromotionController _promotionController = Get.find();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PromotionController>(
        init: _promotionController,
        builder: (ctx) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50,),
              // PostCard(
              //   model: _promotionController.order.post!,
              //   textTapHandler: (value) {},
              //   blockUserHandler: () {},
              //   removePostHandler: () {},
              // ),
              // _promotionController.order.post?.gallery.first.thumbnail == null
              //     ? const SizedBox()
              //     : CachedNetworkImage(
              //         imageUrl: _promotionController
              //             .order.post!.gallery.first.thumbnail,
              //         fit: BoxFit.cover,
              //         height: 100,
              //         width: 100,
              //         placeholder: (context, url) => SizedBox(
              //             height: 60,
              //             width: 60,
              //             child: const CircularProgressIndicator().p16),
              //         errorWidget: (context, url, error) => const Icon(
              //           Icons.error,
              //         ),
              //       ).round(5).setPadding(top: 20, bottom: 20),
              Heading4Text(
                selectGoal.tr,
                weight: FontWeight.bold,
              ),
              BodyMediumText(
                goalInfo.tr,
                weight: FontWeight.normal,
                color: AppColorConstants.subHeadingTextColor,
              ).setPadding(top: 8, bottom: 25),
              Expanded(
                child: ListView(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      addCheckboxTile(moreProfileVisits.tr, GoalType.profile,
                          Icons.person_search_rounded, const Color(0xFF6C63FF),
                          'People visit your profile and may follow you'),
                      addCheckboxTile(moreMessages.tr, GoalType.message,
                          Icons.chat_bubble_rounded, const Color(0xFF00B8A9),
                          'People open a chat with you'),
                      addCheckboxTile(moreWebsiteVisits.tr, GoalType.website,
                          Icons.language_rounded, const Color(0xFF3D8BFD),
                          'People go to your website or download page'),
                      addCheckboxTile('More WhatsApp chats', GoalType.whatsapp,
                          Icons.chat_rounded, const Color(0xFF25D366),
                          'People start a WhatsApp chat with you'),
                      addCheckboxTile('More phone calls', GoalType.call,
                          Icons.call_rounded, const Color(0xFFFF7A45),
                          'People call you from the ad'),
                      addCheckboxTile('Only reach', GoalType.reach,
                          Icons.campaign_rounded, const Color(0xFFE84393),
                          'Show your post to as many people as possible'),
                    ]),
              ),
              Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  AppThemeButton(
                      text: nextString.tr,
                      onPress: () async {
                        if (_promotionController.order.goalType != null) {
                          _promotionController.getAudienceApi();
                          _promotionController.nextButtonEvent();
                        } else {
                          AppUtil.showToast(
                              message: promptSelectGoal.tr, isSuccess: false);
                        }
                      })
              ]).tP16.bP25,
            ],
          ).hP16;
        });
  }

  addCheckboxTile(String title, GoalType type, IconData icon, Color color,
      String subtitle) {
    final bool selected = _promotionController.order.goalType == type;
    return promotionCard(
      selected: selected,
      child: Row(
        children: [
          promotionIconBubble(icon, color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyLargeText(title, weight: TextWeight.semiBold),
                const SizedBox(height: 2),
                BodySmallText(subtitle,
                    color: AppColorConstants.subHeadingTextColor),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 26,
              color: selected
                  ? AppColorConstants.themeColor
                  : AppColorConstants.dividerColor),
        ],
      ),
    ).ripple(() {
      if (type == GoalType.website) {
        Get.to(() => GoalWebsiteUrl());
      } else if (type == GoalType.whatsapp || type == GoalType.call) {
        Get.to(() => GoalPhone(type: type));
      } else {
        _promotionController.selectGoalType(type);
      }
    });
  }
}
