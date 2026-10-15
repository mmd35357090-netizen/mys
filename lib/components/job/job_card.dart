import 'package:foap/model/job_model.dart';
import '../../helper/imports/common_import.dart';

class JobCard extends StatelessWidget {
  final JobModel job;

  const JobCard({super.key, required this.job}) ;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 130,
          color: AppColorConstants.cardColor,
          child: Row(
            children: [
              CachedNetworkImage(
                height: double.infinity,
                width: 80,
                imageUrl: job.postedBy!.picture!,
                fit: BoxFit.cover,
              ).round(10),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    BodyLargeText(
                      job.postedBy!.name!,
                      weight: TextWeight.semiBold,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    BodyMediumText(
                      job.title,
                      weight: TextWeight.regular,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    BodyMediumText(
                      '\$${job.minSalary} - \$${job.maxSalary}',
                      weight: TextWeight.bold,
                      maxLines: 4,
                      color: AppColorConstants.themeColor,
                    ),
                  ],
                ),
              ),
            ],
          ).hP8,
        ),
        if (job.isApplied)
          Positioned(
            right: 10,
            top: 10,
            child: Container(
              color: AppColorConstants.themeColor,
              child: BodySmallText(
                appliedString.tr,
                color: Colors.white,
              ).p4,
            ).round(5),
          )
      ],
    ).round(10);
  }
}
