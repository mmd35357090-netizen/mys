import 'package:foap/helper/imports/common_import.dart';

import '../model/notification_modal.dart';

class NotificationTileType4 extends StatelessWidget {
  final NotificationModel notification;
  final Color? backgroundColor;
  final TextStyle? titleTextStyle;
  final TextStyle? subTitleTextStyle;
  final TextStyle? dateTextStyle;
  final Color? borderColor;

  const NotificationTileType4(
      {Key? key,
      required this.notification,
      this.backgroundColor,
      this.titleTextStyle,
      this.subTitleTextStyle,
      this.dateTextStyle,
      this.borderColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (notification.actionBy != null)
          UserAvatarView(user: notification.actionBy!),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodyMediumText(notification.title, weight: TextWeight.semiBold)
                  .bP8,
              BodyMediumText(
                notification.message,
              ).bP8,
              BodySmallText(
                notification.notificationTime(),
                color: AppColorConstants.grayscale500,
              ),
            ],
          ).setPadding(top: 16, bottom: 16, left: 8, right: 8),
        ),
        if (notification.type == NotificationType.like ||
            notification.type == NotificationType.comment)
          CachedNetworkImage(
                  height: 60,
                  width: 60,
                  imageUrl: notification.post!.gallery.first.thumbnail)
              .round(10),
        if (notification.type == NotificationType.follow)
          if (notification.actionBy?.isFollowing == false)
            AppThemeButton(text: followBackString.tr, onPress: () {})
      ],
    ).hP8.shadowWithBorder(
        borderWidth: 0.2,
        shadowOpacity: 0.5,
        borderColor: borderColor,
        radius: 10,
        fillColor: backgroundColor ?? AppColorConstants.backgroundColor);
  }
}
