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
              const SizedBox(height: 20),
              Heading4Text(job.title, weight: TextWeight.bold),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                    color: AppColorConstants.themeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14)),
                child: BodySmallText(job.category!.name,
                    color: AppColorConstants.themeColor,
                    weight: TextWeight.semiBold),
              ),
              const SizedBox(height: 18),
              _card(Column(
                children: [
                  _infoRow(Icons.work_outline_rounded, experienceString.tr,
                      '${job.minExperience} ${yearString.tr} - ${job.maxExperience} ${yearString.tr}'),
                  const SizedBox(height: 14),
                  _infoRow(Icons.payments_outlined, salaryString.tr,
                      '\$${job.minSalary} - \$${job.maxSalary}'),
                  const SizedBox(height: 14),
                  _infoRow(Icons.location_on_outlined, locationString.tr,
                      '${job.city}, ${job.state}, ${job.country}'),
                ],
              )),
              const SizedBox(height: 14),
              _card(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BodyLargeText(skillsString.tr, weight: TextWeight.bold),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: job.skills
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .map((e) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                  color: AppColorConstants.backgroundColor,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: AppColorConstants.dividerColor
                                          .withValues(alpha: 0.7))),
                              child: BodySmallText(e),
                            ))
                        .toList(),
                  ),
                ],
              )),
              const SizedBox(height: 14),
              _card(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BodyLargeText(aboutString, weight: TextWeight.bold),
                  const SizedBox(height: 10),
                  BodyMediumText(job.description,
                      color: AppColorConstants.subHeadingTextColor),
                ],
              )),
              const SizedBox(height: 14),
              _card(createdBy()),
              const SizedBox(
                height: 100,
              ),
            ],
          ).hp(DesignConstants.horizontalPadding),
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

  Widget _card(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: child,
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
              color: AppColorConstants.themeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 20, color: AppColorConstants.themeColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodySmallText(label,
                  color: AppColorConstants.subHeadingTextColor),
              const SizedBox(height: 2),
              BodyMediumText(value, weight: TextWeight.semiBold),
            ],
          ),
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
