import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/number_extension.dart';

import '../../components/timer_view.dart';
import '../../model/call_model.dart';

class BattleInvitation extends StatelessWidget {
  final Live live;
  final VoidCallback okHandler;
  final VoidCallback cancelHandler;

  const BattleInvitation(
      {Key? key,
      required this.live,
      required this.okHandler,
      required this.cancelHandler})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 250,
      width: Get.width,
      color: AppColorConstants.backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Container(
              height: 30,
              width: 120,
              color: AppColorConstants.red,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const ThemeIconWidget(
                    ThemeIcon.clock,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 5),
                  Center(
                      child: UnlockTimerView(
                    unlockTime:
                        AppConfigConstants.liveBattleConfirmationWaitTime,
                    completionHandler: () {
                      Get.back(closeOverlays: true);
                      // cancelHandler();
                    },
                  )),
                ],
              ).hP4,
            ).bottomRounded(10),
          ),
          const SizedBox(
            height: 20,
          ),
          Heading3Text(
            joinInvitationsString,
            color: AppColorConstants.themeColor,
            weight: TextWeight.bold,
          ),
          const SizedBox(
            height: 20,
          ),
          UserAvatarView(
            user: live.mainHostUserDetail,
            size: 70,
            hideLiveIndicator: true,
            hideOnlineIndicator: true,
          ),
          const SizedBox(
            height: 20,
          ),
          Heading6Text(
            '${live.mainHostUserDetail.userName} invited you for ${live.battleDetail!.totalBattleTime.convertSecondsToTimeString} live battle',
            weight: TextWeight.regular,
          ),
          const SizedBox(
            height: 20,
          ),
          Column(
            children: [
              Wrap(
                spacing: 20,
                children: [
                  BodyLargeText(
                    acceptString,
                    color: AppColorConstants.grayscale100,
                    weight: TextWeight.bold,
                  )
                      .p(10)
                      .makeChip(backGroundColor: AppColorConstants.grayscale900)
                      .ripple(() {
                    Get.back(closeOverlays: true);
                    okHandler();
                  }),
                  BodyLargeText(
                    declineString,
                    color: Colors.white,
                    weight: TextWeight.bold,
                  )
                      .p(10)
                      .makeChip(backGroundColor: AppColorConstants.red)
                      .ripple(() {
                    cancelHandler();
                    Get.back(closeOverlays: true);
                  }),
                ],
              ),
            ],
          )
        ],
      ).hP16,
    ).round(20);
  }
}

class AlreadyInvitedTimerView extends StatelessWidget {
  final UserModel user;
  final int time;

  const AlreadyInvitedTimerView(
      {Key? key, required this.user, required this.time})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorConstants.cardColor,
      child: Column(
        children: [
          // Center(
          //   child: Container(
          //     height: 30,
          //     width: 120,
          //     color: AppColorConstants.red,
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         const ThemeIconWidget(
          //           ThemeIcon.clock,
          //           color: Colors.white,
          //           size: 20,
          //         ),
          //         const SizedBox(width: 5),
          //         Center(
          //             child: UnlockTimerView(
          //           unlockTime: time,
          //           completionHandler: () {
          //             Get.back(closeOverlays: true);
          //             // cancelHandler();
          //           },
          //         )),
          //       ],
          //     ).hP4,
          //   ).bottomRounded(10),
          // ),
          Heading5Text(waitingToAcceptString),
          const SizedBox(
            height: 20,
          ),
          UserAvatarView(user: user),
          const SizedBox(
            height: 20,
          ),
          BodyLargeText(
            alreadyInvitedInLiveString.replaceAll(
                '{{user_name}}', user.userName),
            weight: TextWeight.regular,
            textAlign: TextAlign.center,
          ),
        ],
      ).p25,
    ).topRounded(40);
  }
}

class InvitationDeclinedView extends StatelessWidget {
  final UserModel user;

  const InvitationDeclinedView({Key? key, required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorConstants.cardColor,
      child: Column(
        children: [
          Heading5Text(
            invitationDeclinedString,
            weight: TextWeight.bold,
          ),
          const SizedBox(
            height: 20,
          ),
          UserAvatarView(
            user: user,
            hideOnlineIndicator: true,
            hideLiveIndicator: true,
          ),
          const SizedBox(
            height: 20,
          ),
          Heading6Text(
            invitationDeclinedByOpponentString.replaceAll(
                '{{user_name}}', user.userName),
            weight: TextWeight.regular,
            textAlign: TextAlign.center,
          ),
        ],
      ).p25,
    ).topRounded(40);
  }
}

class NoResponseOnInvitationView extends StatelessWidget {
  final UserModel user;

  const NoResponseOnInvitationView({Key? key, required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorConstants.cardColor,
      child: Column(
        children: [
          Heading5Text(
            noResponseString,
            weight: TextWeight.bold,
          ),
          const SizedBox(
            height: 20,
          ),
          UserAvatarView(
            user: user,
            hideOnlineIndicator: true,
            hideLiveIndicator: true,
          ),
          const SizedBox(
            height: 20,
          ),
          Heading6Text(
            noResponseByOpponentString.replaceAll(
                '{{user_name}}', user.userName),
            weight: TextWeight.regular,
            textAlign: TextAlign.center,
          ),
        ],
      ).p25,
    ).topRounded(40);
  }
}
