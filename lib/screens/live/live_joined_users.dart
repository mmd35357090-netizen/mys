import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/live_imports.dart';
import '../../components/user_card.dart';

class LiveJoinedUsers extends StatefulWidget {
  const LiveJoinedUsers({super.key});

  @override
  State<LiveJoinedUsers> createState() => _LiveJoinedUsersState();
}

class _LiveJoinedUsersState extends State<LiveJoinedUsers> {
  final AgoraLiveController agoraLiveController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorConstants.cardColor,
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Heading6Text(joinedUsersString.tr, weight: TextWeight.bold),
          const SizedBox(
            height: 20,
          ),
          divider(),
          Expanded(
            child: Obx(() => ListView.separated(
                padding: const EdgeInsets.only(top: 20),
                itemBuilder: (ctx, index) {
                  LiveViewer viewer = agoraLiveController.liveViewers[index];
                  return SizedBox(
                    height: 50,
                    child: LiveUserTile(
                      viewer: viewer,
                    ),
                  ).ripple(() {
                    if (!viewer.user.isMe &&
                        (agoraLiveController.live.value!.amIMainHostInLive ||
                            agoraLiveController.amIModeratorInLive) &&
                        viewer.user.id !=
                            agoraLiveController
                                .live.value!.mainHostUserDetail!.id) {
                      openActionSheetForUser(viewer);
                    }
                  });
                },
                separatorBuilder: (ctx, index) {
                  return divider();
                },
                itemCount: agoraLiveController.liveViewers.length)),
          ),
        ],
      ).hp(DesignConstants.horizontalPadding),
    ).topRounded(40);
  }

  void openActionSheetForUser(LiveViewer viewer) {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return FractionallySizedBox(
              heightFactor: 0.6,
              child: Container(
                color: AppColorConstants.cardColor,
                width: Get.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (viewer.isBanned == false)
                      SizedBox(
                              height: 55,
                              width: double.infinity,
                              child: BodyLargeText(banString.tr))
                          .ripple(() {
                        banUser(viewer);
                      }),
                    if (viewer.isBanned == true)
                      SizedBox(
                              height: 55,
                              width: double.infinity,
                              child: BodyLargeText(removeBanString.tr))
                          .ripple(() {
                        unbanUser(viewer.user);
                      }),
                    if (viewer.role != LiveUserRole.moderator &&
                        viewer.isBanned != true)
                      SizedBox(
                          height: 55,
                          width: double.infinity,
                          child:
                              BodyLargeText(makeModeratorString.tr).ripple(() {
                            makeModerator(viewer.user);
                          })),
                    if (viewer.role == LiveUserRole.moderator)
                      SizedBox(
                          height: 55,
                          width: double.infinity,
                          child: BodyLargeText(removeFromModeratorString.tr)
                              .ripple(() {
                            removeAsModerator(viewer.user);
                          })),
                  ],
                ).p(DesignConstants.horizontalPadding),
              ).topRounded(40));
        });
  }

  banUser(LiveViewer viewer) {
    Get.back();

    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return FractionallySizedBox(
              heightFactor: 0.4,
              child: Container(
                color: AppColorConstants.cardColor,
                width: Get.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Container(
                    //         height: 55,
                    //         width: double.infinity,
                    //         child: BodyLargeText('Ban for 10 minute'))
                    //     .ripple(() {
                    //   banUserForTime(viewer.user, 20);
                    // }),
                    // Container(
                    //         height: 55,
                    //         width: double.infinity,
                    //         child: BodyLargeText('Ban for 15 minute'))
                    //     .ripple(() {
                    //   banUserForTime(viewer.user, 900);
                    // }),
                    SizedBox(
                        height: 55,
                        width: double.infinity,
                        child: BodyLargeText(banForOneHourString.tr).ripple(() {
                          banUserForTime(viewer.user, 1800);
                        })),
                    SizedBox(
                        height: 55,
                        width: double.infinity,
                        child: BodyLargeText(permanentBanString.tr).ripple(() {
                          banUserForTime(viewer.user, null);
                        })),
                  ],
                ).p(DesignConstants.horizontalPadding),
              ).topRounded(40));
        });
  }

  banUserForTime(UserModel user, int? time) {
    Get.back();
    agoraLiveController.banUser(user, time);
  }

  unbanUser(UserModel user) {
    Get.back();
    agoraLiveController.unbanUser(user);
  }

  makeModerator(UserModel user) {
    Get.back();
    agoraLiveController.makeModerator(user);
  }

  removeAsModerator(UserModel user) {
    Get.back();
    agoraLiveController.removeAsModerator(user);
  }
}
