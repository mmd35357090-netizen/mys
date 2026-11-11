import 'package:foap/model/job_model.dart';
import '../../helper/imports/common_import.dart';

class JobCard extends StatelessWidget {
  final JobModel job;

  const JobCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Row(
        children: [
          CachedNetworkImage(
            height: 84,
            width: 84,
            imageUrl: job.postedBy!.picture!,
            fit: BoxFit.cover,
          ).round(16),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: BodySmallText(
                        job.postedBy!.name!,
                        maxLines: 1,
                        color: AppColorConstants.subHeadingTextColor,
                        weight: TextWeight.medium,
                      ),
                    ),
                    if (job.isApplied)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                            color: AppColorConstants.green
                                .withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12)),
                        child: BodySmallText(appliedString.tr,
                            color: AppColorConstants.green,
                            weight: TextWeight.semiBold),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                BodyLargeText(job.title,
                    maxLines: 2, weight: TextWeight.bold),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color:
                          AppColorConstants.themeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12)),
                  child: BodyMediumText(
                    '\$${job.minSalary} - \$${job.maxSalary}',
                    weight: TextWeight.bold,
                    color: AppColorConstants.themeColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
