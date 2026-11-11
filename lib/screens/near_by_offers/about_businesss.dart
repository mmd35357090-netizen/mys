import '../../helper/imports/common_import.dart';
import '../../model/business_model.dart';

class AboutBusiness extends StatelessWidget {
  final BusinessModel business;

  const AboutBusiness({super.key, required this.business}) ;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Heading4Text(
                business.name,
                weight: TextWeight.bold,
                color: AppColorConstants.themeColor,
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          _infoCard(Icons.place_rounded, addressString.tr, business.address),
          _infoCard(Icons.info_outline_rounded, aboutString.tr, business.name),
          if (business.openTime != null)
            _infoCard(Icons.schedule_rounded,
                '${openTimeString.tr} - ${closeTimeString.tr}',
                '${business.openTime!}  -  ${business.closeTime!}'),
          if (business.priceRangeFrom != null)
            _infoCard(Icons.payments_rounded, 'Price range',
                '${business.priceRangeFrom!} - ${business.priceRangeTo!}'),
          _infoCard(Icons.local_offer_rounded, offers.tr,
              business.totalCoupons.toString()),
          const SizedBox(
            height: 150,
          ),
        ],
      ),
    );
  }
}

Widget _infoCard(IconData icon, String label, String value) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColorConstants.cardColor,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
          color: AppColorConstants.dividerColor.withValues(alpha: 0.5),
          width: 0.6),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5))
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 38,
          width: 38,
          color: AppColorConstants.themeColor.withValues(alpha: 0.12),
          child: Icon(icon, size: 19, color: AppColorConstants.themeColor),
        ).round(12),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodySmallText(label,
                  color: AppColorConstants.subHeadingTextColor,
                  weight: TextWeight.semiBold),
              const SizedBox(height: 4),
              BodyMediumText(value, weight: TextWeight.semiBold),
            ],
          ),
        ),
      ],
    ),
  );
}
