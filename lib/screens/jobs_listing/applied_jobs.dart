import 'package:foap/controllers/job/job_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/jobs_listing/jobs_list.dart';
import '../../components/paging_scrollview.dart';

class AppliedJobs extends StatefulWidget {
  const AppliedJobs({super.key}) ;

  @override
  State<AppliedJobs> createState() => _AppliedJobsState();
}

class _AppliedJobsState extends State<AppliedJobs> {
  final JobController _jobController = Get.find();

  @override
  void initState() {
    _jobController.refreshAppliedJobs(() {});
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Column(
            children: [
              backNavigationBar(
                title: appliedJobsString.tr,
              ),
              Expanded(
                child: PagingScrollView(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 25,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() => _jobController.appliedJobsDataWrapper
                                        .totalRecords.value >
                                    0
                                ? Row(
                                    children: [
                                      Container(
                                        height: 20,
                                        width: 5,
                                        color: AppColorConstants.themeColor,
                                      ).round(5),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Obx(() => BodyLargeText(
                                          '${found.tr} ${_jobController.appliedJobsDataWrapper.totalRecords} ${appliedJobsString.tr.toLowerCase()}',
                                          weight: TextWeight.semiBold)),
                                    ],
                                  ).hp(DesignConstants.horizontalPadding)
                                : Container()),
                            const SizedBox(
                              height: 20,
                            ),
                            AppliedJobsList()
                          ],
                        )
                      ],
                    ),
                    loadMoreCallback: (refreshController) {
                      _jobController.loadMoreAppliedJobs(() {
                        refreshController.loadComplete();
                      });
                    }),
              ),
            ],
          ),
        ));
  }
}
