import 'package:foap/controllers/job/job_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/event_imports.dart';
import 'package:foap/screens/jobs_listing/jobs_list.dart';
import '../../components/paging_scrollview.dart';

class JobsByCategory extends StatefulWidget {
  final CategoryModel category;

  const JobsByCategory({super.key, required this.category}) ;

  @override
  State<JobsByCategory> createState() => _JobsByCategoryState();
}

class _JobsByCategoryState extends State<JobsByCategory> {
  final JobController _jobController = Get.find();

  @override
  void initState() {
    super.initState();
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
                title: widget.category.name,
              ),
              Expanded(
                child: PagingScrollView(
                    child: Column(
                      children: [
                        SFSearchBar(
                                onSearchChanged: (text) {
                                  _jobController.setTitle(text);
                                },
                                onSearchCompleted: (text) {})
                            .p(DesignConstants.horizontalPadding),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() => _jobController
                                        .jobsDataWrapper.totalRecords.value >
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
                                          '${found.tr} ${_jobController.jobsDataWrapper.totalRecords} ${campaignsString.tr.toLowerCase()}',
                                          weight: TextWeight.semiBold)),
                                    ],
                                  ).hp(DesignConstants.horizontalPadding)
                                : Container()),
                            const SizedBox(
                              height: 20,
                            ),
                            JobsList()
                          ],
                        )
                      ],
                    ),
                    loadMoreCallback: (refreshController) {
                      _jobController.loadMoreJobs(() {
                        refreshController.loadComplete();
                      });
                    }),
              ),
            ],
          ),
        ));
  }
}
