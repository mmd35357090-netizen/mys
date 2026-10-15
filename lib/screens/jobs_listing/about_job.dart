import 'package:foap/components/user_card.dart';
import 'package:foap/controllers/job/job_controller.dart';
import 'package:foap/model/job_model.dart';
import 'package:foap/screens/jobs_listing/apply_job.dart';
import '../../helper/imports/common_import.dart';

class AboutJob extends StatelessWidget {
  final JobModel job;
  final JobController jobController = Get.find();

  AboutJob({super.key, required this.job}) ;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Heading4Text(
                      job.title,
                      weight: TextWeight.semiBold,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                      color: AppColorConstants.themeColor.withValues(alpha: 0.5),
                      child: BodySmallText(job.category!.name)
                          .setPadding(left: 20, right: 20, top: 8, bottom: 8))
                  .round(5),
              divider(height: 0.1).vP16,
              Column(
                children: [
                  Row(
                    children: [
                      BodyLargeText(
                        experienceString.tr,
                        weight: TextWeight.semiBold,
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      BodyLargeText(
                          '${job.minExperience} ${yearString.tr} - ${job.maxExperience} ${yearString.tr}'),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      BodyLargeText(salaryString.tr,
                          weight: TextWeight.semiBold),
                      const SizedBox(
                        width: 20,
                      ),
                      BodyLargeText('\$${job.minSalary} - \$${job.maxSalary}'),
                    ],
                  )
                ],
              ),
              divider(height: 0.1).vP16,
              BodyLargeText(
                skillsString.tr,
                weight: TextWeight.semiBold,
              ),
              const SizedBox(
                height: 10,
              ),
              BodyMediumText(job.skills),
              divider(height: 0.1).vP16,
              BodyLargeText(
                locationString.tr,
                weight: TextWeight.semiBold,
              ),
              const SizedBox(
                height: 10,
              ),
              BodyMediumText('${job.city},${job.state},${job.country}'),
              divider(height: 0.1).vP16,
              BodyLargeText(
                aboutString,
                weight: TextWeight.semiBold,
              ),
              const SizedBox(
                height: 10,
              ),
              BodyMediumText(job.description),
              divider(height: 0.1).vP16,
              createdBy(),
              const SizedBox(
                height: 100,
              ),
            ],
          ),
        ),
        if (!job.isApplied)
          Positioned(
            bottom: 20,
            left: DesignConstants.horizontalPadding,
            right: DesignConstants.horizontalPadding,
            child: AppThemeButton(
                text: applyString,
                onPress: () {
                  Get.to(() => ApplyJob(job));
                }),
          ),
      ],
    );
  }

  Widget createdBy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BodyLargeText(
          postedByString,
          weight: TextWeight.semiBold,
        ),
        const SizedBox(
          height: 20,
        ),
        UserInfo(
          model: job.postedBy!,
        )
      ],
    );
  }

  Widget createdFor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Heading6Text(
          fundRaisingForString,
          weight: TextWeight.semiBold,
          color: AppColorConstants.themeColor,
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            AvatarView(
              url: job.postedBy!.picture,
              name: job.postedBy!.name,
              size: 50,
            ),
            Expanded(
              child: Column(
                children: [
                  BodyLargeText(
                    job.postedBy!.name!,
                    weight: TextWeight.semiBold,
                  ),
                ],
              ),
            ),
            const Spacer()
          ],
        )
      ],
    );
  }
}
