import 'package:foap/controllers/job/job_controller.dart';
import 'package:foap/model/job_model.dart';
import '../../helper/imports/common_import.dart';
import 'about_job.dart';

class JobDetail extends StatelessWidget {
  final JobController jobController = Get.find();
  final JobModel job;

  JobDetail({super.key, required this.job}) ;

  final List<String> tabs = [
    aboutString.tr,
    commentsString.tr,
    donorsString.tr
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(
            title: job.title,
          ),
          Expanded(
            child: AboutJob(
              job: job,
            ).hp(DesignConstants.horizontalPadding),
          ),
        ],
      ),
    );
  }
}
