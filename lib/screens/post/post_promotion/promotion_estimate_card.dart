import 'package:foap/helper/imports/common_import.dart';
import '../../../controllers/post/promotion_controller.dart';

/// Shows how many people the chosen budget can reach.
/// The numbers come from the server (real count of matching users), and are always labelled as an estimate.
class PromotionEstimateCard extends StatelessWidget {
  PromotionEstimateCard({super.key});

  final PromotionController _promotionController = Get.find();

  // 12345 -> 12,345
  String _format(int value) {
    final String text = value.toString();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(text[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PromotionController>(
        init: _promotionController,
        builder: (ctx) {
          final estimate = _promotionController.estimate.value;
          if (estimate == null) {
            return const SizedBox();
          }

          // Pay-per-result: the advertiser pays only when the goal is reached.
          if (estimate.payPerResult) {
            final String max = estimate.resultsMax == null
                ? ''
                : 'Up to ${_format(estimate.resultsMax!)} ${estimate.resultLabel}';
            final String price =
                '${estimate.currencySymbol}${estimate.pricePerResult.toStringAsFixed(estimate.pricePerResult < 0.1 ? 3 : 2)}';
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColorConstants.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColorConstants.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BodySmallText(
                    'You pay only for results',
                    color: AppColorConstants.subHeadingTextColor,
                  ),
                  const SizedBox(height: 4),
                  Heading5Text(
                      max.isEmpty ? '$price per ${estimate.resultLabel}' : max,
                      weight: TextWeight.semiBold),
                  const SizedBox(height: 4),
                  if (max.isNotEmpty)
                    BodySmallText('$price for each different person',
                        color: AppColorConstants.subHeadingTextColor),
                  const SizedBox(height: 6),
                  BodyExtraSmallText(
                    estimate.billingNote,
                    color: AppColorConstants.subHeadingTextColor,
                  ),
                ],
              ),
            );
          }

          if (!estimate.available) {
            return const SizedBox();
          }

          String headline;
          if (estimate.reachMin != null &&
              estimate.reachMax != null &&
              estimate.reachMax! > 0) {
            headline =
                '${_format(estimate.reachMin!)} - ${_format(estimate.reachMax!)} ${boostPeopleUnit.tr}';
          } else if (estimate.audienceSize != null) {
            headline =
                '${_format(estimate.audienceSize!)} ${boostAudienceMatches.tr}';
          } else {
            return const SizedBox();
          }

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColorConstants.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColorConstants.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodySmallText(
                  boostEstimatedReach.tr,
                  color: AppColorConstants.subHeadingTextColor,
                ),
                const SizedBox(height: 4),
                Heading5Text(headline, weight: TextWeight.semiBold),
                const SizedBox(height: 6),
                BodyExtraSmallText(
                  boostEstimateDisclaimer.tr,
                  color: AppColorConstants.subHeadingTextColor,
                ),
              ],
            ),
          );
        });
  }
}
