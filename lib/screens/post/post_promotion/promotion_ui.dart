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
  if (goalType == 5) return 'More WhatsApp chats';
  if (goalType == 6) return 'More phone calls';
  if (goalType == 7) return 'Only reach';
  return moreProfileVisits.tr;
}

String promotionMoney(String currency, double value) {
  // small amounts (a result can cost a fraction of a cent) keep up to 4 decimals
  if (value != 0 && value.abs() < 0.1) {
    String text = value.toStringAsFixed(4).replaceFirst(RegExp(r'0+$'), '');
    if (text.endsWith('.')) text = text.substring(0, text.length - 1);
    return '$currency$text';
  }
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

/// Rounded card used by the boost screens. A selected card gets the theme colour border and tint.
Widget promotionCard(
    {required Widget child,
    bool selected = false,
    EdgeInsets padding = const EdgeInsets.all(16),
    EdgeInsets margin = const EdgeInsets.only(bottom: 12)}) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    margin: margin,
    padding: padding,
    decoration: BoxDecoration(
      color: selected
          ? AppColorConstants.themeColor.withValues(alpha: 0.08)
          : AppColorConstants.cardColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
          color: selected
              ? AppColorConstants.themeColor
              : AppColorConstants.dividerColor,
          width: selected ? 1.6 : 1),
    ),
    child: child,
  );
}

/// Round icon on a soft coloured background.
Widget promotionIconBubble(IconData icon, Color color, {double size = 46}) {
  return Container(
    height: size,
    width: size,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(size / 2.8),
    ),
    child: Icon(icon, color: color, size: size * 0.5),
  );
}
