import 'package:foap/helper/imports/common_import.dart';
import 'dating_card.dart';
import 'like_list.dart';
import 'matched_list.dart';
import 'set_dating_preference.dart';

class DatingDashboardController extends GetxController {
  RxInt currentIndex = 0.obs;
  RxBool isLoading = false.obs;

  indexChanged(int index) {
    currentIndex.value = index;
  }
}

class DatingDashboard extends StatefulWidget {
  const DatingDashboard({super.key}) ;

  @override
  State<DatingDashboard> createState() => DatingDashboardState();
}

class DatingDashboardState extends State<DatingDashboard> {
  final DatingDashboardController _dashboardController =
      DatingDashboardController();
  List<Widget> items = [];

  @override
  void initState() {
    items = [
      const DatingCard(),
      const MatchedList(),
      const LikeList(),
      const SetDatingPreference(),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: items[_dashboardController.currentIndex.value],
        bottomNavigationBar: Container(
          padding: EdgeInsets.only(
              top: 8,
              bottom: MediaQuery.of(context).viewPadding.bottom > 0 ? 18 : 8),
          decoration: BoxDecoration(
            color: AppColorConstants.cardColor,
            border: Border(
                top: BorderSide(
                    color: AppColorConstants.dividerColor.withValues(alpha: 0.5),
                    width: 0.6)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -2))
            ],
          ),
          child: Row(
            children: [
              _tab(0, ThemeIcon.dating, datingString.tr),
              _tab(1, ThemeIcon.fav, matchedString.tr),
              _tab(2, ThemeIcon.thumbsUp, likesString.tr),
              _tab(3, ThemeIcon.filterIcon, preferencesString.tr),
            ],
          ),
        )));
  }

  Widget _tab(int index, ThemeIcon icon, String label) {
    final bool selected = _dashboardController.currentIndex.value == index;
    final Color color =
        selected ? AppColorConstants.themeColor : AppColorConstants.iconColor;
    return Expanded(
      child: InkWell(
        onTap: () => onTabTapped(index),
        borderRadius: BorderRadius.circular(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
              decoration: BoxDecoration(
                color: selected
                    ? AppColorConstants.themeColor.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ThemeIconWidget(icon, size: 22, color: color),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: color),
            ),
          ],
        ),
      ),
    );
  }

  void onTabTapped(int index) async {
    Future.delayed(
        Duration.zero, () => _dashboardController.indexChanged(index));
  }
}
