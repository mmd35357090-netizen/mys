import 'package:foap/model/business_model.dart';
import '../../helper/imports/common_import.dart';

class BusinessCard extends StatelessWidget {
  final BusinessModel business;

  const BusinessCard({super.key, required this.business}) ;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      color: AppColorConstants.cardColor,
      child: Column(
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: business.coverImage,
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
                business.name,
                weight: TextWeight.bold,
              ),
              const SizedBox(
                height: 10,
              ),
              // Wrap(
              //   children: [
              //     BodyLargeText(
              //       '\$${campaign.raisedValue.toString()} ',
              //       weight: TextWeight.semiBold,
              //       color: AppColorConstants.themeColor,
              //     ),
              //     BodyLargeText(
              //       '\$$fundRaisedFrom ${campaign.targetValue.toString()}',
              //       weight: TextWeight.regular,
              //     ),
              //   ],
              // ),
              // const SizedBox(
              //   height: 10,
              // ),
              // Align(
              //   alignment: Alignment.centerRight,
              //   child: BodySmallText(
              //     '$closingOnString ${campaign.endDate.formatTo('yyyy-MMM-dd')}',
              //   ),
              // ),
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
