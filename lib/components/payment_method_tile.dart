import 'package:foap/helper/imports/common_import.dart';

class PaymentMethodTile extends StatelessWidget {
  const PaymentMethodTile({
    super.key,
    required this.text,
    required this.price,
    required this.icon,
    required this.isSelected,
    this.press,
  }) ;

  final String text, price, icon;
  final VoidCallback? press;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColorConstants.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: isSelected
                ? AppColorConstants.themeColor
                : AppColorConstants.dividerColor.withValues(alpha: 0.5),
            width: isSelected ? 1.4 : 0.6),
        boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 5))
          ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Image.asset(
              icon,
              height: 36,
              fit: BoxFit.contain,
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColorConstants.subHeadingTextColor,
          ),
        ],
      ).hP16,
    ).vP8.ripple(press!);
  }
}
