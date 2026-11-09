import 'package:foap/helper/imports/common_import.dart';
import '../../../controllers/post/promotion_controller.dart';
import '../../../model/post_promotion_model.dart';
import 'promotion_estimate_card.dart';
import 'promotion_ui.dart';

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
                          adPreview(order).hP16.bP16,
                          addReviewTile(
                                  adGoal.tr,
                                  promotionGoalText(goalTypeCode(order.goalType)))
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
                          promotionCard(
                            margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                            child: Column(children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Heading6Text(
                                  costSummary.tr,
                                  weight: TextWeight.semiBold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              paymentInfoTile(adBudget.tr,
                                  '$currency${order.totalAmount.toStringAsFixed(2)}'),
                              paymentInfoTile(
                                  '${gst.tr} (${_taxText(order.taxPercent)}%)',
                                  '$currency${order.gst.toStringAsFixed(2)}'),
                              Divider(
                                  height: 20,
                                  color: AppColorConstants.dividerColor),
                              paymentInfoTile(totalSpend.tr,
                                  '$currency${order.grandTotalAmount.toStringAsFixed(2)}',
                                  boldHeader: true),
                            ]),
                          ),
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

  /// How the ad will look in other people's feed.
  Widget adPreview(dynamic order) {
    final post = order.post;
    String? imageUrl;
    if (post != null && post.gallery.isNotEmpty) {
      final g = post.gallery.first;
      imageUrl = (g.mediaType == 2 ? g.videoThumbnail : g.filePath);
    }
    final GoalType? goal = order.goalType;
    final bool hasOwnText =
        order.urlText != null && order.urlText.toString().isNotEmpty;
    final String buttonText = goal == GoalType.reach
        ? ''
        : (goal == GoalType.website || goal == GoalType.whatsapp || goal == GoalType.call)
            ? (hasOwnText
                ? order.urlText.toString()
                : goal == GoalType.website
                    ? learnMore.tr
                    : goal == GoalType.whatsapp
                        ? 'WhatsApp us'
                        : 'Call now')
            : goal == GoalType.message
                ? sendMessagesString.tr
                : viewProfileString.tr;
    final String caption = post == null ? '' : post.postTitle;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColorConstants.dividerColor),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(children: [
            Expanded(
                child: Heading6Text(post?.user.userName ?? '',
                    weight: TextWeight.semiBold)),
            BodySmallText(sponsoredString.tr,
                color: AppColorConstants.subHeadingTextColor),
          ]),
        ),
        if (imageUrl != null && imageUrl.isNotEmpty)
          CachedNetworkImage(
              imageUrl: imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorWidget: (c, u, e) =>
                  const SizedBox(height: 180, child: Icon(Icons.error))),
        if (caption.isNotEmpty)
          Padding(
              padding: const EdgeInsets.all(10),
              child: BodyMediumText(caption, maxLines: 2)),
        if (buttonText.isNotEmpty)
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            AppColorConstants.themeColor,
            AppColorConstants.themeColor.withValues(alpha: 0.78)
          ])),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BodyLargeText(buttonText,
                    color: Colors.white, weight: TextWeight.semiBold),
                const Icon(Icons.arrow_forward_ios,
                    size: 18, color: Colors.white),
              ]),
        ),
      ]),
    );
  }

  Widget addReviewTile(String title, String subTitle) {
    return promotionCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodySmallText(title,
                  color: AppColorConstants.subHeadingTextColor),
              if (subTitle != '') ...[
                const SizedBox(height: 4),
                BodyLargeText(subTitle, weight: TextWeight.semiBold),
              ],
            ],
          ),
        ),
      ]),
    );
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
