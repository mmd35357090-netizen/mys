import 'package:foap/helper/imports/common_import.dart';
import '../../../controllers/post/promotion_controller.dart';
import 'goal_website_url.dart';

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
              addCheckboxTile(moreProfileVisits.tr, GoalType.profile),
              addCheckboxTile(moreMessages.tr, GoalType.message),
              addCheckboxTile(moreWebsiteVisits.tr, GoalType.website),
              Expanded(
                child:
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
                ]).bP25,
              )
            ],
          ).hP16;
        });
  }

  addCheckboxTile(String title, GoalType type) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BodyExtraLargeText(
          title,
          weight: FontWeight.normal,
          color: AppColorConstants.mainTextColor,
        ),
        ThemeIconWidget(
            _promotionController.order.goalType == type
                ? ThemeIcon.selectedRadio
                : ThemeIcon.unSelectedRadio,
            size: 25,
            color: _promotionController.order.goalType == type
                ? AppColorConstants.themeColor
                : AppColorConstants.mainTextColor),
      ],
    ).vP16.ripple(() {
      if (type == GoalType.website) {
        Get.to(() => GoalWebsiteUrl());
      } else {
        _promotionController.selectGoalType(type);
      }
    });
  }
}
