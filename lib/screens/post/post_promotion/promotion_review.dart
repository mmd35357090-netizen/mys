import 'package:foap/helper/imports/common_import.dart';
import '../../../controllers/post/promotion_controller.dart';
import 'promotion_estimate_card.dart';

class PromotionReviewScreen extends StatelessWidget {
  PromotionReviewScreen({super.key});
  final PromotionController _promotionController = Get.find();

  String _taxText(double percent) {
    return percent == percent.roundToDouble()
        ? percent.toInt().toString()
        : percent.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PromotionController>(
        init: _promotionController,
        builder: (ctx) {
          final order = _promotionController.order;
          final String currency = _promotionController.currency;
          final bool needsApproval =
              _promotionController.pricing.value?.autoApprove == false;

          return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Heading4Text(
                  reviewAd.tr,
                  weight: FontWeight.bold,
                ).setPadding(top: 30, bottom: 2),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          addReviewTile(
                                  adGoal.tr,
                                  order.goalType == GoalType.profile
                                      ? moreProfileVisits.tr
                                      : order.goalType == GoalType.website
                                          ? moreWebsiteVisits.tr
                                          : moreMessages.tr)
                              .hP16,
                          addReviewTile(
                                  audience.tr,
                                  order.audience == null
                                      ? '${automatic.tr} | ${subAutomatic.tr}'
                                      : '${order.audience!.name} | ${_promotionController.audienceSelectedInfo.value}')
                              .hP16,
                          addReviewTile(budgetDuration.tr,
                                  '$currency${order.totalAmount.toInt()} ${boostOverLabel.tr} ${order.duration} ${daysString.tr}')
                              .hP16,
                          PromotionEstimateCard().hP16.bP16,
                          divider(
                              height: 1, color: AppColorConstants.dividerColor),
                          const SizedBox(
                            height: 10,
                          ),
                          Heading6Text(
                            costSummary.tr,
                            weight: TextWeight.semiBold,
                          ).p16,
                          paymentInfoTile(adBudget.tr,
                                  '$currency${order.totalAmount.toStringAsFixed(2)}')
                              .hP16,
                          paymentInfoTile(
                                  '${gst.tr} (${_taxText(order.taxPercent)}%)',
                                  '$currency${order.gst.toStringAsFixed(2)}')
                              .hP16,
                          paymentInfoTile(totalSpend.tr,
                                  '$currency${order.grandTotalAmount.toStringAsFixed(2)}',
                                  boldHeader: true)
                              .hP16,
                          const SizedBox(
                            height: 10,
                          ),
                          divider(
                              height: 1, color: AppColorConstants.dividerColor),
                          if (needsApproval)
                            BodySmallText(
                              boostPendingNote.tr,
                              color: AppColorConstants.subHeadingTextColor,
                            ).p16,
                        ]),
                  ),
                ),
                AppThemeButton(
                    text: makePaymentString.tr,
                    onPress: () {
                      //Create post promotion api
                      _promotionController.createPostPromotionApi();
                    }).bP25.hP16,
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
