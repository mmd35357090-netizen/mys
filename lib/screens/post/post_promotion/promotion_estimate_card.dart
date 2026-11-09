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
            // up to 4 decimals, without trailing zeros ($0.05, $0.0001)
            String amount = estimate.pricePerResult.toStringAsFixed(4);
            amount = amount.replaceFirst(RegExp(r'0+$'), '');
            if (amount.endsWith('.')) amount = amount.substring(0, amount.length - 1);
            final String price = '${estimate.currencySymbol}$amount';
            return _shell(
                icon: Icons.verified_rounded,
                title: 'You pay only for results',
                headline: max.isEmpty ? '$price per ${estimate.resultLabel}' : max,
                sub: max.isEmpty ? '' : '$price for each different person',
                note: estimate.billingNote);
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

          return _shell(
              icon: Icons.groups_rounded,
              title: boostEstimatedReach.tr,
              headline: headline,
              sub: '',
              note: boostEstimateDisclaimer.tr);
        });
  }

  Widget _shell(
      {required IconData icon,
      required String title,
      required String headline,
      required String sub,
      required String note}) {
    final Color color = AppColorConstants.themeColor;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.12), color.withValues(alpha: 0.03)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodySmallText(title,
                    color: AppColorConstants.subHeadingTextColor),
                const SizedBox(height: 4),
                Heading5Text(headline, weight: TextWeight.bold),
                if (sub.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  BodySmallText(sub, color: color, weight: TextWeight.semiBold),
                ],
                if (note.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  BodyExtraSmallText(note,
                      color: AppColorConstants.subHeadingTextColor),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
