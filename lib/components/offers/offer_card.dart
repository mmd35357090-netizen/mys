import '../../helper/imports/common_import.dart';
import '../../model/offer_model.dart';

class OfferCard extends StatelessWidget {
  final OfferModel offer;
  const OfferCard({super.key, required this.offer}) ;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      color: AppColorConstants.backgroundColor,
      child: Column(
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: offer.coverImage,
              fit: BoxFit.cover,
              width: double.infinity,
              // height: double.infinity,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Wrap(
            children: [
              BodyExtraLargeText(
                '${codeString.tr.toUpperCase()} : ',
                weight: TextWeight.bold,
              ),
              BodyExtraLargeText(
                offer.code,
                weight: TextWeight.bold,
                color: AppColorConstants.themeColor,
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          BodyLargeText(
            offer.name,
            weight: TextWeight.regular,
            color: AppColorConstants.mainTextColor,
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    ).shadowWithBorder(borderWidth: 0);
  }
}
