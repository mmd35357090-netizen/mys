import 'package:foap/components/user_card.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/add_on/controller/event/create_event/my_event_detail_controller.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../profile/other_user_profile.dart';

class EventAttendingUsersList extends StatelessWidget {
  final int eventId;
  final MyEventDetailController _eventDetailController = Get.find();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  EventAttendingUsersList({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: usersString.tr),
          Expanded(child: usersView())
        ],
      ),
    );
  }

  Widget usersView() {
    return Obx(() => _eventDetailController
            .usersDataWrapper.isLoading.value
        ? const ShimmerUsers()
        : _eventDetailController.attendingUsers.isNotEmpty
            ? ListView.builder(
                padding: EdgeInsets.only(
                    top: 20,
                    left: DesignConstants.horizontalPadding,
                    right: DesignConstants.horizontalPadding),
                itemCount: _eventDetailController.attendingUsers.length,
                itemBuilder: (BuildContext ctx, int index) {
                  UserModel user =
                      _eventDetailController.attendingUsers[index];
                  return UserTile(
                    profile: user,
                    viewCallback: () {
                      Get.to(() => OtherUserProfile(
                            userId: user.id,
                            user: user,
                          ))!;
                    },
                    followCallback: () {
                      _eventDetailController.followUser(user);
                    },
                    unFollowCallback: () {
                      _eventDetailController.unFollowUser(user);
                    },
                  );
                },
              ).addPullToRefresh(
                refreshController: _refreshController,
                onRefresh: () {},
                onLoading: () {
                  _eventDetailController.loadUsers(
                      eventId: eventId,
                      callback: () {
                        _refreshController.loadComplete();
                      });
                },
                enablePullUp: true,
                enablePullDown: false)
            : SizedBox(
                height: Get.size.height * 0.5,
                child:
                    emptyUser(title: noUserFoundString.tr, subTitle: ''),
              ));
  }
}
