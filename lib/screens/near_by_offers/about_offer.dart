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
            height: 20,
          ),
          BodyMediumText(
            offer.name,
            color: AppColorConstants.subHeadingTextColor,
            weight: TextWeight.bold,
          ),
          const SizedBox(
            height: 20,
          ),
          BodyMediumText(
            aboutString.tr,
            color: AppColorConstants.subHeadingTextColor,
            weight: TextWeight.bold,
          ),
          const SizedBox(
            height: 8,
          ),
          BodyMediumText(
            offer.description,
            weight: TextWeight.regular,
          ),
          const SizedBox(
            height: 20,
          ),
          BodyMediumText(
            expiringOnString.tr,
            color: AppColorConstants.subHeadingTextColor,
            weight: TextWeight.bold,
          ),
          const SizedBox(
            height: 8,
          ),
          BodyMediumText(
            offer.endDate.formatTo('yyyy-MMM-dd'),
            weight: TextWeight.semiBold,
          ),
          const SizedBox(
            height: 150,
          ),
        ],
      ),
    );
  }
}
