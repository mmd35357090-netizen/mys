import 'package:foap/api_handler/apis/subscription_api.dart';
import 'package:foap/controllers/subscription/subscription_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/profile/other_user_profile.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:foap/universal_components/subscription_tile.dart';

class MySubscribers extends StatefulWidget {
  const MySubscribers({super.key});

  @override
  State<MySubscribers> createState() => _MySubscribersState();
}

class _MySubscribersState extends State<MySubscribers> {
  final UserSubscriptionController userSubscriptionController = Get.find();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    userSubscriptionController.getMySubscribers(() {});
    super.initState();
  }

  Widget _summary(List<SubscriptionInfo> items) {
    final int active = items.where((e) => e.isActive).length;
    final int coins = items.fold(0, (sum, e) => sum + e.coins);
    Widget cell(String label, String value) => Expanded(
          child: Column(
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.85))),
            ],
          ),
        );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColorConstants.themeColor,
            AppColorConstants.themeColor.withValues(alpha: 0.75),
          ],
        ),
        boxShadow: [
          BoxShadow(
              color: AppColorConstants.themeColor.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          cell('Subscribers', '${items.length}'),
          cell('Active', '$active'),
          cell('Coins earned', '$coins'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: mySubscribersString.tr),
          Expanded(
            child: Obx(() {
              final List<SubscriptionInfo> items =
                  userSubscriptionController.subscribers.toList();
              if (items.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.workspace_premium_outlined,
                            size: 56, color: AppColorConstants.iconColor),
                        const SizedBox(height: 12),
                        BodyLargeText('No subscribers yet',
                            textAlign: TextAlign.center,
                            color: AppColorConstants.subHeadingTextColor),
                      ],
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.only(
                  top: 16,
                  bottom: 100,
                  left: DesignConstants.horizontalPadding,
                  right: DesignConstants.horizontalPadding,
                ),
                itemCount: items.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _summary(items),
                    );
                  }
                  final SubscriptionInfo info = items[index - 1];
                  return SubscriptionTile(
                    info: info,
                    asCreator: true,
                    onTap: () {
                      Get.to(() => OtherUserProfile(userId: info.user.id, user: info.user));
                    },
                  );
                },
              ).addPullToRefresh(
                  refreshController: _refreshController,
                  onRefresh: () {},
                  onLoading: () {
                    userSubscriptionController.loadMoreSubscribers(() {
                      _refreshController.loadComplete();
                    });
                  },
                  enablePullUp: true,
                  enablePullDown: false);
            }),
          ),
        ],
      ),
    );
  }
}
