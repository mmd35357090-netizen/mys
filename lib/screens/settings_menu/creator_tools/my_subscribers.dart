import 'package:foap/components/user_card.dart';
import 'package:foap/controllers/subscription/subscription_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: mySubscribersString.tr),
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: EdgeInsets.only(
                    top: 20,
                    bottom: 100,
                    left: DesignConstants.horizontalPadding,
                    right: DesignConstants.horizontalPadding,
                  ),
                  itemCount: userSubscriptionController.subscribers.length,
                  itemBuilder: (context, index) {
                    var subscriber =
                        userSubscriptionController.subscribers[index];
                    return UserTile(
                      profile: subscriber,
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
                    enablePullDown: false)),
          ),
        ],
      ),
    );
  }
}
