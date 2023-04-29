import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';

import '../../components/notification_tile.dart';
import '../../controllers/notifications_controller.dart';
import '../../model/notification_modal.dart';
import '../competitions/competition_detail_screen.dart';
import '../home_feed/comments_screen.dart';
import '../post/single_post_detail.dart';
import '../profile/other_user_profile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationController _notificationController =
      NotificationController();

  @override
  void initState() {
    _notificationController.getNotifications();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            backNavigationBar(
                context: context, title: LocalizationString.notifications),
            divider(context: context).tP8,
            Expanded(
              child: GetBuilder<NotificationController>(
                  init: _notificationController,
                  builder: (ctx) {
                    return _notificationController.notifications.isNotEmpty
                        ? ListView.separated(
                            padding: const EdgeInsets.only(bottom: 100),
                            itemCount:
                                _notificationController.notifications.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  index == 0
                                      ? const SizedBox(height: 20)
                                      : Container(),
                                  NotificationTileType4(
                                          notification: _notificationController
                                              .notifications[index])
                                      .hP16
                                      .ripple(() {
                                    handleNotificationTap(
                                        _notificationController
                                            .notifications[index]);
                                  }),
                                ],
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return const SizedBox(height: 20);
                            })
                        : emptyData(
                            title: LocalizationString.noNotificationFound,
                            subTitle: '',
                          );
                  }),
            ),
          ],
        ));
  }

  handleNotificationTap(NotificationModel notification) {
    if (notification.type == NotificationType.follow) {
      int userId = notification.actionBy!.id;
      Get.to(() => OtherUserProfile(userId: userId));
    } else if (notification.type == NotificationType.comment) {
      int postId = notification.post!.id;
      Get.to(() => CommentsScreen(
            postId: postId,
            handler: () {},
            commentPostedCallback: () {},
          ));
    } else if (notification.type == NotificationType.like) {
      Get.to(() => SinglePostDetail(postId: notification.post!.id));
    } else if (notification.type == NotificationType.competitionAdded) {
      int competitionId = notification.competition!.id;
      Get.to(() => CompetitionDetailScreen(
            competitionId: competitionId,
            refreshPreviousScreen: () {},
          ));
    }
    // else if (notification.type == 7) {
    //   Get.to(() => SinglePostDetail(
    //         postId: notification.post!.id,
    //       ));
    // }
  }
}
