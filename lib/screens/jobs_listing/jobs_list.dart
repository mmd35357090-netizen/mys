import 'package:foap/controllers/job/job_controller.dart';
import 'package:foap/model/job_model.dart';
import 'package:foap/screens/jobs_listing/job_detail.dart';
import '../../components/job/job_card.dart';
import '../../helper/imports/common_import.dart';

class JobsList extends StatelessWidget {
  final JobController jobController = Get.find();

  JobsList({super.key}) ;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<JobController>(
        init: jobController,
        builder: (ctx) {
          return SizedBox(
              height: jobController.jobs.length * 290,
              child: ListView.separated(
                itemCount: jobController.jobs.length,
                padding: EdgeInsets.only(
                    top: 0,
                    left: DesignConstants.horizontalPadding,
                    right: DesignConstants.horizontalPadding,
                    bottom: 50),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (ctx, index) {
                  JobModel job = jobController.jobs[index];
                  return JobCard(job: job).ripple(() {
                    jobController.setCurrentJob(job);
                    Get.to(() => JobDetail(
                              job: job,
                            ))!
                        .then((value) {});
                  });
                },
                separatorBuilder: (ctx, index) {
                  return const SizedBox(
                    height: 20,
                  );
                },
              ));
        });
  }
}

class AppliedJobsList extends StatelessWidget {
  final JobController jobController = Get.find();

  AppliedJobsList({super.key}) ;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<JobController>(
        init: jobController,
        builder: (ctx) {
          return SizedBox(
              height: jobController.appliedJobs.length * 290,
              child: ListView.separated(
                itemCount: jobController.appliedJobs.length,
                padding: EdgeInsets.only(
                    top: 0,
                    left: DesignConstants.horizontalPadding,
                    right: DesignConstants.horizontalPadding,
                    bottom: 50),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (ctx, index) {
                  JobModel job = jobController.appliedJobs[index];
                  return JobCard(job: job).ripple(() {
                    jobController.setCurrentJob(job);
                    Get.to(() => JobDetail(
                              job: job,
                            ))!
                        .then((value) {});
                  });
                },
                separatorBuilder: (ctx, index) {
                  return const SizedBox(
                    height: 20,
                  );
                },
              ));
        });
  }
}
