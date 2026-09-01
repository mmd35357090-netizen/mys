import 'package:flutter/gestures.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../model/notification_modal.dart';
import '../screens/profile/other_user_profile.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final Color? backgroundColor;
  final TextStyle? titleTextStyle;
  final TextStyle? subTitleTextStyle;
  final TextStyle? dateTextStyle;
  final Color? borderColor;
  final VoidCallback? followBackUserHandler;

  const NotificationTile(
      {super.key,
      required this.notification,
      this.backgroundColor,
      this.titleTextStyle,
      this.subTitleTextStyle,
      this.dateTextStyle,
      this.followBackUserHandler,
      this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: notification.readStatus
          ? Colors.transparent
          : AppColorConstants.themeColor.withOpacity(0.1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (notification.actionBy != null)
            UserAvatarView(
              user: notification.actionBy!,
              hideLiveIndicator: true,
              hideOnlineIndicator: true,
              size: 40,
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                    maxLines: 2,
                    text: TextSpan(children: [
                      TextSpan(
                        text: notification.actionBy?.userName ?? '',
                        style: TextStyle(
                            fontSize: FontSizes.b3,
                            color: AppColorConstants.mainTextColor,
                            fontWeight: TextWeight.semiBold),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            if (notification.actionBy != null) {
                              openProfile(notification.actionBy!.id);
                            }
                          },
                      ),
                      TextSpan(
                        text: ' ${notificationMessage(notification)}',
                        style: TextStyle(
                            fontSize: FontSizes.b3,
                            color: AppColorConstants.mainTextColor,
                            fontWeight: TextWeight.medium),
                      ),
                      TextSpan(
                        text: ' ${notification.notificationTime}',
                        style: TextStyle(
                            fontSize: FontSizes.b3,
                            color: AppColorConstants.mainTextColor,
                            fontWeight: TextWeight.semiBold),
                      ),
                    ]))
              ],
            ).setPadding(left: 12, right: 12),
          ),
          if ((notification.type == SMNotificationType.like ||
                  notification.type == SMNotificationType.comment) &&
              notification.post!.gallery.isNotEmpty)
            CachedNetworkImage(
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                    imageUrl: notification.post!.gallery.first.thumbnail)
                .round(20),
        ],
      ).p(DesignConstants.horizontalPadding/2),
    );
  }

  void openProfile(int userId) async {
    Get.to(() => OtherUserProfile(userId: userId));
  }

  followBack() {
    followBackUserHandler!();
  }

  String notificationMessage(NotificationModel notification) {
    if (notification.type == SMNotificationType.follow) {
      return startedFollowingYouString.tr;
    } else if (notification.type == SMNotificationType.followRequest) {
      return sentYourFollowRequestString.tr;
    } else if (notification.type == SMNotificationType.comment) {
      return commentedOnYourPostString.tr;
    } else if (notification.type == SMNotificationType.like) {
      return likedYourPostString.tr;
    } else if (notification.type == SMNotificationType.competitionAdded) {
      return adminAddedNewCompetitionString.tr;
    } else if (notification.type == SMNotificationType.supportRequest) {
      return adminRepliedOnYourSupportRequestString.tr;
    } else if (notification.type == SMNotificationType.verification) {
      return congratsYourVerificationIsApprovedString.tr;
    } else if (notification.type == SMNotificationType.gift) {
      return sentAGiftString.tr;
    } else if (notification.type == SMNotificationType.clubInvitation) {
      return '${invitedYouToClubString.tr} ${notification.club?.name ?? ''}';
    } else if (notification.type == SMNotificationType.subscribed) {
      return '${subscribedYouString.tr} ';
    }
    return '';
  }
}
