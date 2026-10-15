import 'package:foap/helper/imports/common_import.dart';
import '../../../controllers/post/promotion_controller.dart';

class PromotionReviewScreen extends StatelessWidget {
  PromotionReviewScreen({super.key});
  final PromotionController _promotionController = Get.find();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PromotionController>(
        init: _promotionController,
        builder: (ctx) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Heading4Text(
                  reviewAd.tr,
                  weight: FontWeight.bold,
                ).setPadding(top: 30, bottom: 2),
                // BodySmallText(
                //   '${reach.tr} 100-200 people',
                //   weight: FontWeight.normal,
                //   color: AppColorConstants.grayscale600,
                // ).bp(25),
                const SizedBox(height: 20,),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  addReviewTile(
                          adGoal.tr,
                          _promotionController.order.goalType ==
                                  GoalType.profile
                              ? moreProfileVisits.tr
                              : _promotionController.order.goalType ==
                                      GoalType.website
                                  ? moreWebsiteVisits.tr
                                  : moreMessages.tr)
                      .hP16,
                  addReviewTile(
                          audience.tr,
                          _promotionController.order.audience == null
                              ? '${automatic.tr} | ${subAutomatic.tr}'
                              : '${_promotionController.order.audience!.name} | ${_promotionController.audienceSelectedInfo.value}')
                      .hP16,
                  addReviewTile(budgetDuration.tr,
                          '\$${_promotionController.order.dailyBudget.toInt() * _promotionController.order.duration} over ${_promotionController.order.duration} days')
                      .hP16,
                  divider(height: 1, color: AppColorConstants.dividerColor),
                  const SizedBox(
                    height: 10,
                  ),
                  Heading6Text(
                    costSummary.tr,
                    weight: TextWeight.semiBold,
                  ).p16,
                  paymentInfoTile(adBudget.tr,
                          '\$${_promotionController.order.dailyBudget * _promotionController.order.duration}')
                      .hP16,
                  paymentInfoTile(gst.tr,
                          '\$${double.parse((_promotionController.order.gst).toStringAsFixed(2))}')
                      .hP16,
                  paymentInfoTile(totalSpend.tr,
                          '\$${_promotionController.getTotalPayment()}',
                          boldHeader: true)
                      .hP16,
                  const SizedBox(
                    height: 10,
                  ),
                  divider(height: 1, color: AppColorConstants.dividerColor),
                ]),
                Expanded(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppThemeButton(
                            text: makePaymentString.tr,
                            onPress: () {
                              //Create post promotion api
                              _promotionController.createPostPromotionApi();
                            })
                      ]).bP25.hP16,
                ),
              ]);
        });
  }

  Widget addReviewTile(String title, String subTitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Heading6Text(
          title,
          weight: FontWeight.normal,
        ),
        subTitle == ''
            ? const SizedBox()
            : BodyMediumText(
                subTitle,
                weight: FontWeight.normal,
                color: AppColorConstants.subHeadingTextColor,
              ).tP4
      ],
    ).vP16;
  }

  Widget paymentInfoTile(String title, String subTitle,
      {bool boldHeader = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Heading6Text(
          title,
          weight: boldHeader ? TextWeight.semiBold : FontWeight.normal,
        ),
        BodyMediumText(
          subTitle,
          weight: FontWeight.normal,
          color: AppColorConstants.subHeadingTextColor,
        )
      ],
    ).vP16;
  }
}
