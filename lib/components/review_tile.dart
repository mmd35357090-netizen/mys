import 'package:foap/components/rating_star.dart';
import 'package:foap/helper/string_extension.dart';
import 'package:foap/model/rating_model.dart';
import '../helper/imports/common_import.dart';

class ReviewsTile extends StatelessWidget {
  final RatingModel review;

  const ReviewsTile({super.key, required this.review}) ;

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              review.user!.picture != null
                  ? CachedNetworkImage(
                      imageUrl: review.user!.picture!,
                      height: 48,
                      width: 48,
                      fit: BoxFit.cover,
                    ).circular.rP16
                  : Container(
                      color: AppColorConstants.themeColor,
                      height: 48,
                      width: 48,
                      child: Center(
                        child: Heading4Text(
                            review.user!.userName.getInitials.toUpperCase(),
                            color: Colors.white),
                      ),
                    ).circular.rP16,
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        BodyLargeText(
                          review.user!.name!,
                          weight: TextWeight.bold,
                        ),
                        const Spacer(),
                        BodyExtraSmallText(
                          review.timeAgoStr,
                          weight: TextWeight.bold,
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                        width: 80, child: RatingStar(rating: review.rating)),
                  ],
                ).hP8,
              )
            ],
          ).vP16,
          BodyMediumText(review.reviewMsg).bP16,
        ],
      ).p16,
    );
  }
}
