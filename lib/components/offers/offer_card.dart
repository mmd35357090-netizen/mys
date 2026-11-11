import '../../helper/imports/common_import.dart';
import '../../model/offer_model.dart';

class OfferCard extends StatelessWidget {
  final OfferModel offer;
  const OfferCard({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColorConstants.cardColor,
        borderRadius: BorderRadius.circular(20),
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: offer.coverImage,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BodyLargeText(offer.name,
                          maxLines: 1, weight: TextWeight.bold),
                      const SizedBox(height: 4),
                      BodySmallText(
                          '${codeString.tr.toUpperCase()} : ',
                          color: AppColorConstants.subHeadingTextColor),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                      color:
                          AppColorConstants.themeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12)),
                  child: BodyLargeText(offer.code,
                      weight: TextWeight.bold,
                      color: AppColorConstants.themeColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
