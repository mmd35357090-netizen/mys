import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/number_extension.dart';

import '../model/hash_tag.dart';

class HashTagTile extends StatelessWidget {
  final Hashtag hashtag;
  final VoidCallback onItemCallback;

  const HashTagTile({
    super.key,
    required this.hashtag,
    required this.onItemCallback,
  }) ;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
        children: [
          Container(
            height: 46,
            width: 46,
            color: AppColorConstants.themeColor.withValues(alpha: 0.12),
            child: Center(
                child: Heading3Text('#',
                    color: AppColorConstants.themeColor,
                    weight: TextWeight.bold)),
          ).round(14),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyLargeText(
                  hashtag.name,
                  maxLines: 1,
                  weight: TextWeight.bold,
                ).bP4,
                BodySmallText(
                  '${hashtag.counter.formatNumber} ${postsString.tr.toLowerCase()}',
                  color: AppColorConstants.subHeadingTextColor,
                  weight: TextWeight.medium,
                )
              ],
            ),
          ),
          ThemeIconWidget(ThemeIcon.nextArrow,
              size: 13, color: AppColorConstants.subHeadingTextColor),
        ],
      ),
    ).ripple(() {
      onItemCallback();
    });
  }
}
