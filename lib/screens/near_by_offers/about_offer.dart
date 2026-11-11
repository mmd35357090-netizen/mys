import 'package:foap/helper/date_extension.dart';
import 'package:foap/model/offer_model.dart';

import '../../helper/imports/common_import.dart';

class AboutOffer extends StatelessWidget {
  final OfferModel offer;

  const AboutOffer({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            height: Get.height * 0.3,
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: offer.coverImage,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                )
              ],
            ),
          ).round(25),
          const SizedBox(
            height: 16,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppColorConstants.themeColor,
                AppColorConstants.themeColor.withValues(alpha: 0.72)
              ]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_offer_rounded,
                    color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BodySmallText(codeString.tr.toUpperCase(),
                          color: Colors.white70, weight: TextWeight.semiBold),
                      const SizedBox(height: 2),
                      Heading4Text(offer.code,
                          color: Colors.white, weight: TextWeight.bold),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Heading5Text(offer.name, weight: TextWeight.bold),
          const SizedBox(
            height: 16,
          ),
          _infoCard(Icons.info_outline_rounded, aboutString.tr,
              offer.description),
          _infoCard(Icons.event_rounded, expiringOnString.tr,
              offer.endDate.formatTo('yyyy-MMM-dd')),
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
