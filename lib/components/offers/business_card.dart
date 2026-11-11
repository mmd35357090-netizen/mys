import 'package:foap/model/business_model.dart';
import '../../helper/imports/common_import.dart';

class BusinessCard extends StatelessWidget {
  final BusinessModel business;

  const BusinessCard({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
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
              imageUrl: business.coverImage,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                    child: Heading6Text(business.name,
                        maxLines: 1, weight: TextWeight.bold)),
                Icon(Icons.chevron_right_rounded,
                    color: AppColorConstants.subHeadingTextColor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
