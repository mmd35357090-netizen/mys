import 'package:foap/helper/date_extension.dart';
import 'package:foap/helper/number_extension.dart';
import 'package:foap/model/fund_raising_campaign.dart';
import '../../helper/imports/common_import.dart';

class FundraisingCard extends StatelessWidget {
  final FundRaisingCampaign campaign;

  const FundraisingCard({super.key, required this.campaign}) ;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 270,
      color: AppColorConstants.cardColor,
      child: Column(
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: campaign.coverImage,
              fit: BoxFit.cover,
              // height: double.infinity,
              width: double.infinity,
            ).round(20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              Heading5Text(
                campaign.title,
                weight: TextWeight.bold,
              ),
              const SizedBox(
                height: 10,
              ),
              Wrap(
                children: [
                  BodyLargeText(
                    '\$${campaign.raisedValue.toString()} ',
                    weight: TextWeight.semiBold,
                    color: AppColorConstants.themeColor,
                  ),
                  BodyLargeText(
                    '\$$fundRaisedFrom ${campaign.targetValue.toString()}',
                    weight: TextWeight.regular,
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    children: [
                      BodyLargeText(
                        campaign.totalDonors.formatNumber,
                        weight: TextWeight.regular,
                      ),
                      BodyLargeText(
                        ' $donorsString',
                        weight: TextWeight.semiBold,
                        color: AppColorConstants.themeColor,
                      ),
                    ],
                  ),
                  BodySmallText(
                    '$closingOnString ${campaign.endDate.formatTo('yyyy-MMM-dd')}',
                  )
                ],
              ),
            ],
          ).hP16,
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    ).shadowWithBorder(borderWidth: 0);
  }
}
