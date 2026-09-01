import '../../components/notification_tile.dart';
import '../../controllers/notification/notifications_controller.dart';
import '../../controllers/profile/profile_controller.dart';
import '../../helper/imports/common_import.dart';
import '../../model/notification_modal.dart';
import '../competitions/competition_detail_screen.dart';
import '../home_feed/comments_screen.dart';
import '../post/single_post_detail.dart';
import '../profile/follow_requests.dart';
import '../profile/other_user_profile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationController _notificationController =
      NotificationController();
  final ProfileController _profileController = Get.find();

  @override
  void initState() {
    _notificationController.getNotifications();
    _notificationController.getFollowRequests(() {});

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: Column(
          children: [
            backNavigationBarWithTrailingWidget(
              title: notificationsString,
              widget: BodyLargeText(
                filterString,
                weight: TextWeight.semiBold,
              ).ripple(() {
                filterNotifications();
              }),
            ),
            Obx(() => _notificationController.followRequests.isEmpty
                ? Container()
                : Container(
                    height: 80,
                    color: AppColorConstants.themeColor.withOpacity(0.1),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const ThemeIconWidget(
                          ThemeIcon.request,
                          size: 20,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BodyMediumText(
                                followRequestsString.tr,
                                weight: TextWeight.semiBold,
                              ),
                              BodySmallText(
                                acceptFollowRequestsString.tr,
                                weight: TextWeight.semiBold,
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const ThemeIconWidget(ThemeIcon.nextArrow),
                      ],
                    ).hp(DesignConstants.horizontalPadding),
                  ).round(20).ripple(() {
                    Get.to(() => const FollowRequestList());
                  }).p(DesignConstants.horizontalPadding)),
            Expanded(
              child: Obx(() => _notificationController
                      .groupedNotifications.keys.isNotEmpty
                  ? ListView.separated(
                      padding: EdgeInsets.only(
                          top: 20,
                          left: 0,
                          right: 0,
                          bottom: 50),
                      itemCount: _notificationController
                          .groupedNotifications.keys.length,
                      itemBuilder: (BuildContext context, int index) {
                        String key = _notificationController
                            .groupedNotifications.keys
                            .toList()[index];
                        List<NotificationModel> notifications =
                            _notificationController
                                    .groupedNotifications[key] ??
                                [];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Heading5Text(
                              key,
                              weight: TextWeight.bold,
                            ).hp(DesignConstants.horizontalPadding),
                            const SizedBox(
                              height: 20,
                            ),
                            for (NotificationModel notification
                                in notifications)
                              Column(
                                children: [
                                  NotificationTile(
                                    notification: notification,
                                    followBackUserHandler: () {
                                      _profileController.followUser(
                                          notification.actionBy!);
                                      _notificationController
                                          .getNotifications();
                                    },
                                  ).ripple(() {
                                    handleNotificationTap(notification);
                                  }),
                                ],
                              ),
                          ],
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return divider(height: 0.2).bP16;
                      })
                  : emptyData(
                      title: noNotificationFoundString.tr,
                      subTitle: '',
                    )),
            ),
          ],
        ));
  }

  filterNotifications() {
    Get.bottomSheet(Container(
      color: AppColorConstants.cardColor,
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          BodyLargeText(
            filterString,
          ),
          const SizedBox(
            height: 20,
          ),
          divider().vP8,
          Column(
            children: [
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BodyLargeText(
                        commentsString,
                        weight: TextWeight.regular,
                      ),
                      ThemeIconWidget(_notificationController
                              .selectedNotificationsTypes
                              .contains(SMNotificationType.comment)
                          ? ThemeIcon.checkMarkWithCircle
                          : ThemeIcon.circleOutline)
                    ],
                  )).ripple(() {
                _notificationController
                    .selectNotificationType(SMNotificationType.comment);
              }),
              const SizedBox(
                height: 20,
              ),
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BodyLargeText(
                        likesString,
                        weight: TextWeight.regular,
                      ),
                      ThemeIconWidget(_notificationController
                              .selectedNotificationsTypes
                              .contains(SMNotificationType.like)
                          ? ThemeIcon.checkMarkWithCircle
                          : ThemeIcon.circleOutline)
                    ],
                  )).ripple(() {
                _notificationController
                    .selectNotificationType(SMNotificationType.like);
              }),
              const SizedBox(
                height: 20,
              ),
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BodyLargeText(
                        followsString.tr,
                        weight: TextWeight.regular,
                      ),
                      ThemeIconWidget(_notificationController
                              .selectedNotificationsTypes
                              .contains(SMNotificationType.follow)
                          ? ThemeIcon.checkMarkWithCircle
                          : ThemeIcon.circleOutline)
                    ],
                  )).ripple(() {
                _notificationController
                    .selectNotificationType(SMNotificationType.follow);
              }),
              const SizedBox(
                height: 20,
              ),
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BodyLargeText(
                        giftsString,
                        weight: TextWeight.regular,
                      ),
                      ThemeIconWidget(_notificationController
                              .selectedNotificationsTypes
                              .contains(SMNotificationType.gift)
                          ? ThemeIcon.checkMarkWithCircle
                          : ThemeIcon.circleOutline)
                    ],
                  )).ripple(() {
                _notificationController
                    .selectNotificationType(SMNotificationType.gift);
              }),
              const SizedBox(
                height: 20,
              ),
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BodyLargeText(
                        clubsString,
                        weight: TextWeight.regular,
                      ),
                      ThemeIconWidget(_notificationController
                              .selectedNotificationsTypes
                              .contains(SMNotificationType.clubInvitation)
                          ? ThemeIcon.checkMarkWithCircle
                          : ThemeIcon.circleOutline)
                    ],
                  )).ripple(() {
                _notificationController.selectNotificationType(
                    SMNotificationType.clubInvitation);
              }),
              const SizedBox(
                height: 20,
              ),
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BodyLargeText(
                        competitionString,
                        weight: TextWeight.regular,
                      ),
                      ThemeIconWidget(_notificationController
                              .selectedNotificationsTypes
                              .contains(
                                  SMNotificationType.competitionAdded)
                          ? ThemeIcon.checkMarkWithCircle
                          : ThemeIcon.circleOutline)
                    ],
                  )).ripple(() {
                _notificationController.selectNotificationType(
                    SMNotificationType.competitionAdded);
              }),
              const SizedBox(
                height: 20,
              ),
              AppThemeButton(
                  text: doneString,
                  onPress: () {
                    _notificationController.filterNotifications();
                    Get.back();
                  })
            ],
          ).hp16,
        ],
      ),
    ).topRounded(40));
  }

  handleNotificationTap(NotificationModel notification) {
    _notificationController.markNotificationAsRead(notification.id);

    if (notification.type == SMNotificationType.follow) {
      int userId = notification.actionBy!.id;
      Get.to(() => OtherUserProfile(userId: userId));
    } else if (notification.type == SMNotificationType.comment) {
      int postId = notification.post!.id;
      Get.to(() => CommentsScreen(
            postId: postId,
            isPopup: false,
            handler: () {},
            commentPostedCallback: () {},
            commentDeletedCallback: () {},
          ));
    } else if (notification.type == SMNotificationType.like) {
      Get.to(() => SinglePostDetail(postId: notification.post!.id));
    } else if (notification.type == SMNotificationType.competitionAdded) {
      int competitionId = notification.competition!.id;
      Get.to(() => CompetitionDetailScreen(
            competitionId: competitionId,
            refreshPreviousScreen: () {},
          ));
    }
  }
}
