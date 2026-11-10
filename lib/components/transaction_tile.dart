import 'package:foap/helper/enum_linking.dart';
import 'package:foap/helper/imports/common_import.dart';

import '../model/payment_model.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel model;

  const TransactionTile({super.key, required this.model}) ;

  @override
  Widget build(BuildContext context) {
    final bool credit = model.transactionType == TransactionType.credit;
    final Color color = credit ? AppColorConstants.green : AppColorConstants.red;
    final bool isMoney = model.transactionMedium == TransactionMedium.money;
    final String amountText = isMoney
        ? '${credit ? '+' : '-'} \$${model.amount}'
        : '${credit ? '+' : '-'} ${model.coins} ${coinsString.tr}';
    final String statusText = model.status == 1
        ? pendingString.tr
        : model.status == 2
            ? rejectedString.tr
            : completedString.tr;
    final Color statusColor = model.status == 1
        ? const Color(0xFFF59E0B)
        : model.status == 2
            ? AppColorConstants.red
            : AppColorConstants.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColorConstants.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: AppColorConstants.dividerColor.withValues(alpha: 0.5),
            width: 0.6),
      ),
      child: Row(children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
              credit ? Icons.south_west_rounded : Icons.north_east_rounded,
              color: color,
              size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodyLargeText(_adsTitle(model.paymentType),
                  weight: TextWeight.semiBold),
              const SizedBox(height: 2),
              BodySmallText(model.createDate,
                  color: AppColorConstants.subHeadingTextColor),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            BodyLargeText(amountText, weight: TextWeight.bold, color: color),
            if (isMoney) ...[
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(statusText,
                    style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: statusColor)),
              ),
            ],
          ],
        ),
      ]),
    );
  }
}

/// Titles for the Ads transaction history.
String _adsTitle(PaymentType type) {
  switch (type) {
    case PaymentType.promotion:
      return 'Boost';
    case PaymentType.promotionRefund:
      return 'Boost cancelled (refund)';
    case PaymentType.withdrawal:
      return 'Withdraw';
    case PaymentType.withdrawalRefund:
      return 'Withdraw failed (refund)';
    default:
      return paymentTypeStringFromId(type);
  }
}
