import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/string_extension.dart';
import '../../model/club_invitation.dart';
import '../../model/club_model.dart';
import 'package:foap/helper/number_extension.dart';

class ClubCard extends StatelessWidget {
  final ClubModel club;
  final VoidCallback joinBtnClicked;
  final VoidCallback previewBtnClicked;
  final VoidCallback leaveBtnClicked;

  const ClubCard(
      {super.key,
      required this.club,
      required this.joinBtnClicked,
      required this.leaveBtnClicked,
      required this.previewBtnClicked})
      ;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorConstants.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: club.image!,
              fit: BoxFit.cover,
            ).topRounded(10).ripple(() {
              previewBtnClicked();
            }),
          ),
          const SizedBox(
            height: 10,
          ),
          !club.createdByUser!.isMe
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          BodyLargeText(
                            club.name!,
                            maxLines: 1,
                            weight: TextWeight.semiBold,
                          ).hP8,
                          const SizedBox(
                            height: 5,
                          ),
                          BodySmallText(
                            '${club.totalMembers!.formatNumber} ${clubMembersString.tr}',
                          ).hP8,
                        ],
                      ),
                    ),
                    Container(
                        height: 50,
                        width: 50,
                        color: club.isJoined == true
                            ? AppColorConstants.red
                            : AppColorConstants.themeColor,
                        child: ThemeIconWidget(
                          club.isJoined == true
                              ? ThemeIcon.checkMark
                              : ThemeIcon.plus,
                          color: Colors.white,
                        )).topLeftDiognalRounded(20).ripple(() {
                      if (club.isJoined == true) {
                        leaveBtnClicked();
                      } else {
                        joinBtnClicked();
                      }
                    }),
                  ],
                )
              // AppThemeButton(
              //     text: club.isJoined == true
              //         ? leaveClubString.tr
              //         : club.isRequested == true
              //             ? requestedString.tr
              //             : club.isRequestBased == true
              //                 ? requestJoinString.tr
              //                 : joinString.tr,
              //     backgroundColor: club.isJoined == true
              //         ? AppColorConstants.red
              //         : AppColorConstants.themeColor,
              //     onPress: () {
              //
              //     }).hP25)
              : SizedBox(
                  height: 50,
                  width: 100,
                  child: Center(
                    child: BodyLargeText(
                      youAreAdminString,
                      color: AppColorConstants.themeColor,
                      weight: TextWeight.bold,
                    ),
                  )).hP4,
        ],
      ),
    ).round(15);
  }
}

class ClubInvitationCard extends StatelessWidget {
  final ClubInvitation invitation;
  final VoidCallback acceptBtnClicked;
  final VoidCallback previewBtnClicked;
  final VoidCallback declineBtnClicked;

  const ClubInvitationCard(
      {super.key,
      required this.invitation,
      required this.acceptBtnClicked,
      required this.declineBtnClicked,
      required this.previewBtnClicked})
      ;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      color: AppColorConstants.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: invitation.club!.image!,
              fit: BoxFit.cover,
            ).topRounded(10).ripple(() {
              previewBtnClicked();
            }),
          ),
          const SizedBox(
            height: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Heading5Text(invitation.club!.name!, weight: TextWeight.bold).vP8,
              BodyMediumText(
                '${invitation.club!.totalMembers!.formatNumber} ${clubMembersString.tr}',
              ),
              SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppThemeButton(
                          width: Get.width * 0.35,
                          text: acceptString.tr,
                          onPress: () {
                            acceptBtnClicked();
                          }),
                      AppThemeBorderButton(
                          width: Get.width * 0.35,
                          text: declineString.tr,
                          onPress: () {
                            declineBtnClicked();
                          })
                    ],
                  )).vP16,
            ],
          ).hp(DesignConstants.horizontalPadding),
        ],
      ),
    ).round(15);
  }
}

class TopClubCard extends StatelessWidget {
  final ClubModel club;
  final VoidCallback joinBtnClicked;
  final VoidCallback previewBtnClicked;
  final VoidCallback leaveBtnClicked;

  const TopClubCard(
      {super.key,
      required this.club,
      required this.joinBtnClicked,
      required this.leaveBtnClicked,
      required this.previewBtnClicked})
      ;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      color: club.name!.generateColorFromText.darken(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(
            height: 8,
          ),
          Row(
            children: [
              CachedNetworkImage(
                imageUrl: club.image!,
                fit: BoxFit.cover,
                height: 50,
                width: 50,
              ).circular,
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: BodyLargeText(
                  club.name!,
                  weight: TextWeight.semiBold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          BodySmallText(
            club.desc!,
            weight: TextWeight.medium,
            maxLines: 2,
            color: Colors.white,
          ),
          const Spacer(),
          Row(
            children: [
              BodyMediumText(
                club.totalMembers!.formatNumber,
                weight: TextWeight.bold,
                color: Colors.white60,
              ),
              const SizedBox(
                width: 5,
              ),
              BodyMediumText(
                clubMembersString,
                color: Colors.white60,
              ),
              const Spacer(),
              BodyMediumText(club.creationTime!, color: Colors.white60),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     ,
          //     const Spacer(),
          //     // if (!club.createdByUser!.isMe)
          //     //   SizedBox(
          //     //       height: 40,
          //     //       width: 120,
          //     //       child: FilledButtonType(
          //     //           text: club.isJoined == 1
          //     //               ? LocalizationString.leaveClub
          //     //               : LocalizationString.join,
          //     //           onPress: () {
          //     //             if (club.isJoined == 1) {
          //     //               leaveBtnClicked();
          //     //             } else {
          //     //               joinBtnClicked();
          //     //             }
          //     //           })),
          //     // SizedBox(
          //     //     height: 40,
          //     //     width: 120,
          //     //     child: FilledButtonType1(
          //     //         text: LocalizationString.preview,
          //     //         onPress: () {
          //     //           previewBtnClicked();
          //     //         }))
          //   ],
          // )
        ],
      ).hP16,
    ).round(15).ripple(() {
      previewBtnClicked();
    });
  }
}
