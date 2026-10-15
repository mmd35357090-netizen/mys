import 'package:foap/controllers/job/job_controller.dart';
import 'package:foap/screens/jobs_listing/applied_jobs.dart';
import '../../helper/imports/common_import.dart';
import 'explore_jobs.dart';
import 'job_categories.dart';

class JobsDashboardController extends GetxController {
  RxInt currentIndex = 0.obs;
  RxInt unreadMsgCount = 0.obs;
  RxBool isLoading = false.obs;

  indexChanged(int index) {
    currentIndex.value = index;
  }

  updateUnreadMessageCount(int count) {
    unreadMsgCount.value = count;
  }
}

class JobDashboard extends StatelessWidget {
  JobDashboard({super.key});

  final JobsDashboardController _dashboardController =
      JobsDashboardController();
  final JobController jobController = Get.find();

  final List<Widget> items = [
    const ExploreJobs(
      fromCategory: false,
    ),
    JobCategories(),
    const AppliedJobs(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: items[_dashboardController.currentIndex.value],
        bottomNavigationBar: SizedBox(
          height: MediaQuery.of(context).viewPadding.bottom > 0 ? 90 : 70.0,
          width: Get.width,
          child: BottomNavigationBar(
            backgroundColor: AppColorConstants.backgroundColor,
            type: BottomNavigationBarType.fixed,
            currentIndex: _dashboardController.currentIndex.value,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            unselectedItemColor: Colors.grey,
            selectedItemColor: AppColorConstants.themeColor,
            onTap: (index) => {onTabTapped(index)},
            items: [
              BottomNavigationBarItem(
                  icon: ThemeIconWidget(ThemeIcon.homeOutlined,
                      size: 20,
                      color: _dashboardController.currentIndex.value == 0
                          ? AppColorConstants.themeColor
                          : AppColorConstants.iconColor),
                  label: ''),
              BottomNavigationBarItem(
                  icon: ThemeIconWidget(ThemeIcon.categories,
                      size: 20,
                      color: _dashboardController.currentIndex.value == 1
                          ? AppColorConstants.themeColor
                          : AppColorConstants.iconColor),
                  label: ''),
              BottomNavigationBarItem(
                icon: ThemeIconWidget(ThemeIcon.checkMark,
                    size: 20,
                    color: _dashboardController.currentIndex.value == 2
                        ? AppColorConstants.themeColor
                        : AppColorConstants.iconColor),
                label: '',
              ),
            ],
          ),
        )));
  }

  void onTabTapped(int index) async {
    Future.delayed(
        Duration.zero, () => _dashboardController.indexChanged(index));
  }
}
