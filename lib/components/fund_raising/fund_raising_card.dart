import 'package:foap/helper/date_extension.dart';
import 'package:foap/helper/number_extension.dart';
import 'package:foap/model/fund_raising_campaign.dart';
import '../../helper/imports/common_import.dart';

class FundraisingCard extends StatelessWidget {
  final FundRaisingCampaign campaign;

  const FundraisingCard({super.key, required this.campaign});

  @override
  Widget build(BuildContext context) {
    final raised = double.tryParse(campaign.raisedValue.toString()) ?? 0;
    final target = double.tryParse(campaign.targetValue.toString()) ?? 0;
    final progress = target <= 0 ? 0.0 : (raised / target).clamp(0.0, 1.0);

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CachedNetworkImage(
            imageUrl: campaign.coverImage,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 160,
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Heading6Text(campaign.title,
                    maxLines: 1, weight: TextWeight.bold),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor:
                        AppColorConstants.themeColor.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppColorConstants.themeColor),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  children: [
                    BodyMediumText(
                      '\$${campaign.raisedValue.toString()} ',
                      weight: TextWeight.bold,
                      color: AppColorConstants.themeColor,
                    ),
                    BodyMediumText(
                      '\$$fundRaisedFrom ${campaign.targetValue.toString()}',
                      color: AppColorConstants.subHeadingTextColor,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Wrap(
                      children: [
                        BodyMediumText(
                          campaign.totalDonors.formatNumber,
                          weight: TextWeight.bold,
                        ),
                        BodyMediumText(
                          ' $donorsString',
                          color: AppColorConstants.subHeadingTextColor,
                        ),
                      ],
                    ),
                    BodySmallText(
                      '$closingOnString ${campaign.endDate.formatTo('yyyy-MMM-dd')}',
                      color: AppColorConstants.subHeadingTextColor,
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
