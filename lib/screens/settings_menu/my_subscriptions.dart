import 'package:foap/components/user_card.dart';
import 'package:foap/controllers/subscription/subscription_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MySubscriptions extends StatefulWidget {
  const MySubscriptions({super.key});

  @override
  State<MySubscriptions> createState() => _MySubscriptionsState();
}

class _MySubscriptionsState extends State<MySubscriptions> {
  final UserSubscriptionController userSubscriptionController = Get.find();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    userSubscriptionController.getMySubscriptions(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: mySubscriptionString.tr),
          Expanded(
              child: Obx(() => ListView.builder(
                    padding: EdgeInsets.only(
                      top: 20,
                      bottom: 100,
                      left: DesignConstants.horizontalPadding,
                      right: DesignConstants.horizontalPadding,
                    ),
                    itemCount: userSubscriptionController.subscriptions.length,
                    itemBuilder: (context, index) {
                      var subscriber = userSubscriptionController.subscriptions[index];
                      return UserTile(
                        profile: subscriber,
                      );
                    },
                  ).addPullToRefresh(
                      refreshController: _refreshController,
                      onRefresh: () {},
                      onLoading: () {
                        userSubscriptionController
                            .loadMoreSubscriptions(() {});
                        _refreshController.loadComplete();
                      },
                      enablePullUp: true,
                      enablePullDown: false))),
        ],
      ),
    );
  }
}
