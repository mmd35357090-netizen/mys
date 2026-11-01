import 'package:foap/helper/imports/common_import.dart';
import '../../../model/promotion_report_model.dart';

// Small helpers shared by the campaign list and the campaign report.

Color promotionStatusColor(int status) {
  switch (status) {
    case PromotionStatus.active:
      return Colors.green;
    case PromotionStatus.paused:
      return Colors.orange;
    case PromotionStatus.pending:
      return Colors.blueGrey;
    case PromotionStatus.rejected:
      return Colors.red;
    case PromotionStatus.cancelled:
      return Colors.red;
    default:
      return Colors.grey;
  }
}

String promotionGoalText(int goalType) {
  if (goalType == 4) return moreWebsiteVisits.tr;
  if (goalType == 2) return moreMessages.tr;
  return moreProfileVisits.tr;
}

String promotionMoney(String currency, double value) {
  return '$currency${value.toStringAsFixed(2)}';
}

Widget promotionStatusChip(PromotionCampaign campaign) {
  final Color color = promotionStatusColor(campaign.status);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: BodyExtraSmallText(
      campaign.statusLabel.tr,
      color: color,
      weight: TextWeight.semiBold,
    ),
  );
}

/// A label with a number below it, used in the metric blocks.
Widget promotionMetric(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      BodyExtraSmallText(
        label,
        color: AppColorConstants.subHeadingTextColor,
      ),
      const SizedBox(height: 2),
      BodyLargeText(value, weight: TextWeight.semiBold),
    ],
  );
}
