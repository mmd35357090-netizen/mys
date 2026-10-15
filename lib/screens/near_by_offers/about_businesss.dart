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
            height: 20,
          ),
          BodyMediumText(
            addressString.tr,
            color: AppColorConstants.subHeadingTextColor,
            weight: TextWeight.bold,
          ),
          const SizedBox(
            height: 8,
          ),
          BodyMediumText(
            business.address,
            color: AppColorConstants.mainTextColor,
            weight: TextWeight.medium,
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
            business.name,
            weight: TextWeight.regular,
          ),
          const SizedBox(
            height: 20,
          ),
          if (business.openTime != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BodyMediumText(
                      openTimeString.tr,
                      color: AppColorConstants.subHeadingTextColor,
                      weight: TextWeight.bold,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    BodyMediumText(
                      business.openTime!,
                      weight: TextWeight.semiBold,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BodyMediumText(
                      closeTimeString.tr,
                      color: AppColorConstants.subHeadingTextColor,
                      weight: TextWeight.bold,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    BodyMediumText(
                      business.closeTime!,
                      weight: TextWeight.semiBold,
                    ),
                  ],
                ),
              ],
            ).bp(20),
          if (business.priceRangeFrom != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyMediumText(
                  'Price range',
                  color: AppColorConstants.subHeadingTextColor,
                  weight: TextWeight.bold,
                ),
                const SizedBox(
                  height: 8,
                ),
                BodyMediumText(
                  '${business.priceRangeFrom!} - ${business.priceRangeTo!}',
                  weight: TextWeight.semiBold,
                ),
              ],
            ).bp(20),
          BodyMediumText(
            offers.tr,
            color: AppColorConstants.subHeadingTextColor,
            weight: TextWeight.bold,
          ),
          BodyMediumText(
            business.totalCoupons.toString(),
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
