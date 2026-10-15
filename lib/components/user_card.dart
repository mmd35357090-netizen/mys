import 'package:foap/controllers/misc/users_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/live_imports.dart';
import 'package:foap/helper/number_extension.dart';
import 'package:foap/model/collaboration_model.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import '../model/club_join_request.dart';
import '../model/club_member_model.dart';
import '../model/gift_model.dart';
import '../model/story_model.dart';
import '../screens/profile/other_user_profile.dart';
import '../screens/settings_menu/settings_controller.dart';

class UserFollowUnfollowBtnController extends GetxController {
  Rx<UserModel?> user = Rx<UserModel?>(null);
  UsersController userController = Get.find();

  setUser(UserModel user) {
    this.user.value = user;
  }

  followUser() {
    userController.followUser(user.value!);
    user.refresh();
  }

  unFollowUser() {
    userController.unFollowUser(user.value!);
    user.refresh();
  }
}

class UserFollowUnfollowButton extends StatelessWidget {
  final UserFollowUnfollowBtnController controller;

  final bool? isSmallSized;

  const UserFollowUnfollowButton(
      {super.key, required this.controller, this.isSmallSized});

  @override
  Widget build(BuildContext context) {
    return Obx(() => SizedBox(
          height: isSmallSized == true ? 25 : 35,
          width: isSmallSized == true ? 100 : 120,
          child: controller.user.value!.followingStatus ==
                  FollowingStatus.notFollowing
              ? AppThemeBorderButton(
                  text: controller.user.value!.isFollower == true
                      ? followBackString.tr
                      : followString.tr,
                  backgroundColor: AppColorConstants.backgroundColor,
                  onPress: () {
                    controller.followUser();
                  })
              : controller.user.value!.followingStatus ==
                      FollowingStatus.requested
                  ? AppThemeBorderButton(
                      text: requestedString.tr,
                      backgroundColor: AppColorConstants.themeColor
                          .withValues(alpha: 0.2),
                      onPress: () {
                        controller.unFollowUser();
                      })
                  : AppThemeButton(
                      text: unFollowString.tr,
                      onPress: () {
                        controller.unFollowUser();
                      }),
        ));
  }
}

class FollowUnfollowButton extends StatelessWidget {
  final UserModel user;
  final VoidCallback? followCallback;
  final VoidCallback? unFollowCallback;
  final bool? isSmallSized;

  const FollowUnfollowButton(
      {super.key,
      required this.user,
      required this.followCallback,
      this.isSmallSized,
      required this.unFollowCallback});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isSmallSized == true ? 25 : 35,
      width: isSmallSized == true ? 80 : 120,
      child: user.followingStatus == FollowingStatus.notFollowing
          ? AppThemeBorderButton(
              text: user.isFollower == true
                  ? followBackString.tr
                  : followString.tr,
              onPress: () {
                if (followCallback != null) {
                  followCallback!();
                }
              })
          : user.followingStatus == FollowingStatus.requested
              ? AppThemeBorderButton(
                  text: requestedString.tr,
                  backgroundColor:
                      AppColorConstants.themeColor.withValues(alpha: 0.2),
                  onPress: () {
                    if (unFollowCallback != null) {
                      unFollowCallback!();
                    }
                  })
              : AppThemeButton(
                  text: unFollowString.tr,
                  onPress: () {
                    if (unFollowCallback != null) {
                      unFollowCallback!();
                    }
                  }),
    );
  }
}

class UserInfo extends StatelessWidget {
  final UserModel model;

  const UserInfo({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UserAvatarView(
          user: model,
          size: 25,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  BodySmallText(
                    model.name ?? model.userName,
                    weight: TextWeight.semiBold,
                    maxLines: 1,
                  ),
                  if (model.isVerified) verifiedUserTag()
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              model.country != null
                  ? BodySmallText(
                      '${model.country},${model.city}',
                    )
                  : Container(),
            ],
          ),
        ),
      ],
    );
  }
}

class UserTile extends StatelessWidget {
  final UserModel profile;

  final VoidCallback? followCallback;
  final VoidCallback? unFollowCallback;
  final VoidCallback? viewCallback;

  final VoidCallback? chatCallback;
  final VoidCallback? audioCallCallback;
  final VoidCallback? videoCallCallback;

  final VoidCallback? sendCallback;

  const UserTile({
    super.key,
    required this.profile,
    this.followCallback,
    this.unFollowCallback,
    this.viewCallback,
    this.chatCallback,
    this.audioCallCallback,
    this.videoCallCallback,
    this.sendCallback,
  });

  @override
  Widget build(BuildContext context) {
    final AgoraLiveController agoraLiveController = Get.find();
    final SettingsController settingsController = Get.find();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              UserAvatarView(
                user: profile,
                size: 30,
                onTapHandler: () {
                  LiveModel live = LiveModel();
                  live.channelName = profile.liveCallDetail!.channelName;
                  live.mainHostUserDetail = profile;
                  live.token = profile.liveCallDetail!.token;
                  live.id = profile.liveCallDetail!.id;
                  agoraLiveController.joinAsAudience(
                    live: live,
                  );
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        BodyLargeText(
                          profile.userName,
                          // weight: TextWeight.regular,
                          maxLines: 1,
                        ),
                        if (profile.isVerified) verifiedUserTag()
                      ],
                    ).bP4,
                    profile.country != null
                        ? BodyMediumText(
                            '${profile.city!}, ${profile.country!}',
                          )
                        : Container()
                  ],
                ).hP8,
              ),
              // const Spacer(),
            ],
          ).ripple(() {
            if (viewCallback == null) {
              Get.to(() => OtherUserProfile(
                    userId: profile.id,
                    user: profile,
                  ));
            } else {
              viewCallback!();
            }
          }),
        ),
        // const Spacer(),
        if (followCallback != null && profile.isMe == false)
          FollowUnfollowButton(
            user: profile,
            followCallback: followCallback,
            unFollowCallback: unFollowCallback,
          ),
        if (chatCallback != null)
          Row(
            children: [
              if (settingsController.setting.value!.enableChat)
                ThemeIconWidget(
                  ThemeIcon.chat,
                  size: 20,
                ).rP16.ripple(() {
                  chatCallback!();
                }),
              if (settingsController.setting.value!.enableAudioCalling)
                ThemeIconWidget(
                  ThemeIcon.mobile,
                  size: 20,
                ).rP16.ripple(() {
                  audioCallCallback!();
                }),
              if (settingsController.setting.value!.enableVideoCalling)
                ThemeIconWidget(
                  ThemeIcon.videoCamera,
                  size: 20,
                ).ripple(() {
                  videoCallCallback!();
                }),
            ],
          ),
        if (sendCallback != null)
          SizedBox(
            height: 30,
            width: 80,
            child: ProgressButton.icon(iconedButtons: {
              ButtonState.idle: IconedButton(
                  text: sendString.tr,
                  icon: const Icon(Icons.send, color: Colors.white),
                  color: Colors.deepPurple.shade500),
              ButtonState.loading: IconedButton(
                  text: loadingString.tr,
                  color: Colors.deepPurple.shade700),
              ButtonState.fail: IconedButton(
                  text: failedString.tr,
                  icon: const Icon(Icons.cancel, color: Colors.white),
                  color: Colors.red.shade300),
              ButtonState.success: IconedButton(
                  text: sentString.tr,
                  icon: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                  ),
                  color: Colors.green.shade400)
            }, onPressed: sendCallback, state: ButtonState.idle),
          )
      ],
    );
  }
}

class UserCard extends StatelessWidget {
  final UserModel profile;

  final VoidCallback? followCallback;
  final VoidCallback? unFollowCallback;
  final VoidCallback? viewCallback;

  const UserCard({
    super.key,
    required this.profile,
    this.followCallback,
    this.unFollowCallback,
    this.viewCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: UserPlaneImageView(
            user: profile,
            size: double.infinity,
          ).ripple(() {
            if (viewCallback == null) {
              Get.to(() => OtherUserProfile(
                    userId: profile.id,
                    user: profile,
                  ));
            } else {
              viewCallback!();
            }
          }),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      BodyLargeText(
                        profile.userName,
                        weight: TextWeight.semiBold,
                        maxLines: 1,
                      ),
                      if (profile.isVerified) verifiedUserTag(),
                    ],
                  ).bP4,
                  BodyMediumText(
                    '${profile.totalFollower.formatNumber} $followersString',
                    color: AppColorConstants.mainTextColor,
                  )
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        profile.isMe
            ? const SizedBox(
                height: 35,
              )
            : FollowUnfollowButton(
                user: profile,
                followCallback: followCallback,
                unFollowCallback: unFollowCallback,
              ),
      ],
    );
  }
}

class SelectableUserCard extends StatefulWidget {
  final UserModel model;
  final bool isSelected;
  final VoidCallback? selectionHandler;

  const SelectableUserCard(
      {super.key,
      required this.model,
      required this.isSelected,
      this.selectionHandler});

  @override
  SelectableUserCardState createState() => SelectableUserCardState();
}

class SelectableUserCardState extends State<SelectableUserCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 50,
          width: 50,
          child: Stack(
            children: [
              UserAvatarView(
                user: widget.model,
                size: 50,
              ),
              widget.isSelected == true
                  ? Positioned(
                      child: Container(
                      height: 50,
                      width: 50,
                      color: Colors.black45,
                      child: Center(
                        child: ThemeIconWidget(
                          ThemeIcon.checkMark,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ).circular)
                  : Container()
            ],
          ).ripple(
            () {
              widget.selectionHandler!();
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            BodyMediumText(widget.model.userName,
                maxLines: 1, weight: TextWeight.medium),
            if (widget.model.isVerified) verifiedUserTag()
          ],
        )
      ],
    );
  }
}

class SelectableUserTile extends StatefulWidget {
  final UserModel model;
  final bool? isSelected;
  final VoidCallback? selectionHandler;

  const SelectableUserTile(
      {super.key,
      required this.model,
      this.isSelected,
      this.selectionHandler});

  @override
  SelectableUserTileState createState() => SelectableUserTileState();
}

class SelectableUserTileState extends State<SelectableUserTile> {
  late final UserModel model;

  @override
  void initState() {
    super.initState();
    model = widget.model;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            UserAvatarView(
              user: model,
              size: 40,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    BodyLargeText(
                      model.userName,
                      weight: TextWeight.semiBold,
                      maxLines: 1,
                    ),
                    if (widget.model.isVerified) verifiedUserTag()
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                model.country != null
                    ? BodySmallText(
                        '${model.country},${model.city}',
                      )
                    : Container(),
              ],
            ),
          ],
        ),
        const Spacer(),
        ThemeIconWidget(
          widget.isSelected == true
              ? ThemeIcon.checkMarkWithCircle
              : ThemeIcon.circleOutline,
          color: AppColorConstants.themeColor,
          size: 25,
        )
      ],
    ).ripple(
      () {
        if (widget.selectionHandler != null) {
          widget.selectionHandler!();
        }
      },
    );
  }
}

class InviteUserTile extends StatelessWidget {
  final UserModel profile;

  final VoidCallback? inviteCallback;

  const InviteUserTile({
    super.key,
    required this.profile,
    this.inviteCallback,
  });

  @override
  Widget build(BuildContext context) {
    final AgoraLiveController agoraLiveController = Get.find();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              UserAvatarView(
                user: profile,
                size: 40,
                onTapHandler: () {
                  LiveModel live = LiveModel();
                  live.channelName = profile.liveCallDetail!.channelName;
                  live.mainHostUserDetail = profile;
                  live.token = profile.liveCallDetail!.token;
                  live.id = profile.liveCallDetail!.id;
                  agoraLiveController.joinAsAudience(
                    live: live,
                  );
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        BodyLargeText(
                          profile.userName,
                          // weight: TextWeight.regular,
                          maxLines: 1,
                        ),
                        if (profile.isVerified) verifiedUserTag()
                      ],
                    ).bP4,
                    profile.country != null
                        ? BodyMediumText(
                            '${profile.city!}, ${profile.country!}',
                          )
                        : Container()
                  ],
                ).hP8,
              ),
              // const Spacer(),
            ],
          ),
        ),
        // const Spacer(),
        SizedBox(
          height: 35,
          width: 120,
          child: AppThemeBorderButton(
              // icon: ThemeIcon.message,
              text: inviteString.tr,
              textStyle: TextStyle(
                  fontSize: FontSizes.b2,
                  fontWeight: TextWeight.medium,
                  color: AppColorConstants.themeColor),
              onPress: () {
                if (inviteCallback != null) {
                  inviteCallback!();
                }
              }),
        ),
      ],
    );
  }
}

class RelationUserTile extends StatelessWidget {
  final UserModel profile;

  final Function(int)? inviteCallback;
  final Function(int)? unInviteCallback;
  final VoidCallback? viewCallback;

  const RelationUserTile({
    super.key,
    required this.profile,
    this.inviteCallback,
    this.unInviteCallback,
    this.viewCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            UserAvatarView(
              user: profile,
              size: 40,
            ),
            SizedBox(
              width: Get.width - 220,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      BodyLargeText(
                        profile.userName,
                        weight: TextWeight.bold,
                      ),
                      if (profile.isVerified) verifiedUserTag()
                    ],
                  ).bP4,
                  profile.country != null
                      ? BodyMediumText(
                          '${profile.city!}, ${profile.country!}',
                        )
                      : Container()
                ],
              ).hp(DesignConstants.horizontalPadding),
            ),
            // const Spacer(),
          ],
        ).ripple(() {
          if (viewCallback == null) {
            Get.to(() => OtherUserProfile(
                  userId: profile.id,
                  user: profile,
                ));
          } else {
            viewCallback!();
          }
        }),
        const Spacer(),
        if (inviteCallback != null && profile.isMe == false)
          SizedBox(
            height: 35,
            width: 120,
            child: AppThemeBorderButton(
                // icon: ThemeIcon.message,
                text: inviteString.tr,
                textStyle: TextStyle(
                    fontSize: FontSizes.b2,
                    fontWeight: TextWeight.medium,
                    color: AppColorConstants.themeColor),
                onPress: () {
                  if (inviteCallback != null) {
                    inviteCallback!(profile.id);
                  }
                }),
          ),
      ],
    );
  }
}

class ClubMemberTile extends StatelessWidget {
  final ClubMemberModel member;
  final VoidCallback? removeBtnCallback;
  final VoidCallback? viewCallback;

  const ClubMemberTile({
    super.key,
    required this.member,
    this.removeBtnCallback,
    this.viewCallback,
  });

  @override
  Widget build(BuildContext context) {
    final AgoraLiveController agoraLiveController = Get.find();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            UserAvatarView(
              user: member.user!,
              size: 40,
              onTapHandler: () {
                LiveModel live = LiveModel();
                live.channelName =
                    member.user!.liveCallDetail!.channelName;
                live.mainHostUserDetail = member.user!;
                live.token = member.user!.liveCallDetail!.token;
                live.id = member.user!.liveCallDetail!.id;
                agoraLiveController.joinAsAudience(
                  live: live,
                );
              },
            ),
            SizedBox(
              width: Get.width - 250,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      BodyLargeText(member.user!.userName,
                          weight: TextWeight.bold),
                      if (member.user!.isVerified) verifiedUserTag()
                    ],
                  ).bP4,
                  member.user!.country != null
                      ? BodyMediumText(
                          '${member.user!.city!}, ${member.user!.country!}',
                        )
                      : Container()
                ],
              ).hp(DesignConstants.horizontalPadding),
            ).ripple(() {
              if (viewCallback != null) {
                viewCallback!();
              }
            }),
            // const Spacer(),
          ],
        ),
        const Spacer(),
        member.isAdmin == 1
            ? SizedBox(
                height: 35,
                width: 120,
                child: Center(
                  child: BodyLargeText(
                    adminString.tr,
                    weight: TextWeight.medium,
                    color: AppColorConstants.themeColor,
                  ),
                ),
              )
            : removeBtnCallback != null
                ? SizedBox(
                    height: 35,
                    width: 120,
                    child: AppThemeButton(
                        // icon: ThemeIcon.message,
                        text: removeString.tr,
                        onPress: () {
                          if (removeBtnCallback != null) {
                            removeBtnCallback!();
                          }
                        }),
                  )
                : Container(),
      ],
    );
  }
}

class SendMessageUserTile extends StatelessWidget {
  final UserModel profile;
  final ButtonState state;
  final VoidCallback? viewCallback;
  final VoidCallback? sendCallback;

  const SendMessageUserTile({
    super.key,
    required this.profile,
    required this.state,
    this.viewCallback,
    this.sendCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: UserInfo(model: profile).ripple(() {
            if (viewCallback == null) {
              Get.to(() => OtherUserProfile(
                    userId: profile.id,
                    user: profile,
                  ));
            } else {
              viewCallback!();
            }
          }),
        ),
        // const Spacer(),
        const SizedBox(
          width: 10,
        ),
        sendCallback != null
            ? AbsorbPointer(
                absorbing: state == ButtonState.success,
                child: SizedBox(
                  height: 30,
                  width: 80,
                  child: ProgressButton.icon(
                      radius: 5.0,
                      textStyle: TextStyle(fontSize: FontSizes.b2),
                      iconedButtons: {
                        ButtonState.idle: IconedButton(
                            text: sendString.tr,
                            icon: Icon(
                              Icons.send,
                              color: AppColorConstants.iconColor,
                              size: 15,
                            ),
                            color:
                                AppColorConstants.themeColor.lighten(0.1)),
                        ButtonState.loading: IconedButton(
                            text: loadingString.tr,
                            color: AppColorConstants.iconColor),
                        ButtonState.fail: IconedButton(
                            text: failedString.tr,
                            icon: Icon(Icons.cancel,
                                color: AppColorConstants.iconColor,
                                size: 15),
                            color: AppColorConstants.red),
                        ButtonState.success: IconedButton(
                            text: sentString.tr,
                            icon: Icon(Icons.check_circle,
                                color: AppColorConstants.iconColor,
                                size: 15),
                            color: AppColorConstants.themeColor.darken())
                      },
                      onPressed: sendCallback,
                      state: state),
                ),
              )
            : Container()
      ],
    );
  }
}

class BlockedUserTile extends StatelessWidget {
  final UserModel profile;
  final VoidCallback? unBlockCallback;

  const BlockedUserTile({
    super.key,
    required this.profile,
    this.unBlockCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: UserInfo(model: profile)),
        SizedBox(
            height: 35,
            width: 110,
            child: AppThemeBorderButton(
                // icon: ThemeIcon.message,
                text: unblockString.tr,
                textStyle: TextStyle(
                    fontSize: FontSizes.b2,
                    fontWeight: TextWeight.medium,
                    color: AppColorConstants.themeColor),
                onPress: () {
                  if (unBlockCallback != null) {
                    unBlockCallback!();
                  }
                }))
      ],
    );
  }
}

class GifterUserTile extends StatelessWidget {
  final ReceivedGiftModel gift;

  const GifterUserTile({super.key, required this.gift});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BodyMediumText(
              gift.source == GiftSource.post
                  ? sentOnPostString.tr
                  : gift.source == GiftSource.live
                      ? sentOnLiveString.tr
                      : sentOnProfileString.tr,
              weight: TextWeight.semiBold),
          const SizedBox(
            height: 10,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: UserInfo(model: gift.sender)),
              const Spacer(),
              CachedNetworkImage(
                imageUrl: gift.giftDetail.logo,
                height: 25,
                width: 25,
              ),
              const SizedBox(
                width: 15,
              ),
              ThemeIconWidget(
                ThemeIcon.diamond,
                color: AppColorConstants.themeColor,
                size: 18,
              ),
              const SizedBox(
                width: 5,
              ),
              BodyMediumText(gift.giftDetail.coins.toString(),
                  weight: TextWeight.semiBold)
            ],
          ),
        ],
      ),
    );
  }
}

class ClubJoinRequestTile extends StatelessWidget {
  final ClubJoinRequest request;
  final VoidCallback acceptBtnClicked;
  final VoidCallback declineBtnClicked;
  final VoidCallback viewCallback;

  const ClubJoinRequestTile({
    super.key,
    required this.request,
    required this.viewCallback,
    required this.acceptBtnClicked,
    required this.declineBtnClicked,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            UserAvatarView(
              user: request.user!,
              hideLiveIndicator: true,
              size: 40,
            ),
            SizedBox(
              width: Get.width - 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      BodyLargeText(request.user!.userName,
                          weight: TextWeight.bold),
                      if (request.user!.isVerified) verifiedUserTag()
                    ],
                  ).bP4,
                  request.user!.country != null
                      ? BodyMediumText(
                          '${request.user!.city!}, ${request.user!.country!}',
                        )
                      : Container()
                ],
              ).hp(DesignConstants.horizontalPadding),
            ),
            // const Spacer(),
          ],
        ).ripple(() {
          viewCallback();
        }),
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            SizedBox(
                height: 35,
                width: 120,
                child: AppThemeButton(
                    // icon: ThemeIcon.message,
                    text: acceptString.tr,
                    onPress: () {
                      acceptBtnClicked();
                    })),
            const SizedBox(
              width: 10,
            ),
            SizedBox(
                height: 35,
                width: 120,
                child: AppThemeBorderButton(
                    // icon: ThemeIcon.message,
                    text: declineString.tr,
                    textStyle: TextStyle(
                        fontSize: FontSizes.b2,
                        fontWeight: TextWeight.medium,
                        color: AppColorConstants.themeColor),
                    onPress: () {
                      declineBtnClicked();
                    })),
          ],
        ),
      ],
    );
  }
}

class StoryViewerTile extends StatelessWidget {
  final StoryViewerModel viewer;

  const StoryViewerTile({
    super.key,
    required this.viewer,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: UserInfo(model: viewer.user!)),
        BodyMediumText(
          viewer.viewedAt,
          maxLines: 1,
          color: AppColorConstants.subHeadingTextColor,
        )
        // const Spacer(),
      ],
    );
  }
}

class FollowRequestSenderUserTile extends StatelessWidget {
  final UserModel profile;

  final VoidCallback acceptCallback;
  final VoidCallback declineCallback;

  const FollowRequestSenderUserTile({
    super.key,
    required this.profile,
    required this.acceptCallback,
    required this.declineCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorConstants.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatarView(
                user: profile,
                size: 40,
                hideLiveIndicator: true,
                hideOnlineIndicator: true,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        BodyLargeText(
                          profile.userName,
                          // weight: TextWeight.regular,
                          maxLines: 1,
                        ),
                        if (profile.isVerified) verifiedUserTag()
                      ],
                    ).bP4,
                    profile.country != null
                        ? BodyMediumText(
                            '${profile.city!}, ${profile.country!}',
                          )
                        : Container()
                  ],
                ).hP8,
              ),
              // const Spacer(),
            ],
          ).ripple(() {
            Get.to(() => OtherUserProfile(
                  userId: profile.id,
                  user: profile,
                ));
          }),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              SizedBox(
                height: 35,
                width: 120,
                child: AppThemeButton(
                    // icon: ThemeIcon.message,
                    text: acceptString.tr,
                    onPress: () {
                      acceptCallback();
                    }),
              ),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                height: 35,
                width: 120,
                child: AppThemeBorderButton(
                    backgroundColor: AppColorConstants.cardColor,
                    // icon: ThemeIcon.message,
                    text: declineString.tr,
                    onPress: () {
                      declineCallback();
                    }),
              )
            ],
          ),
        ],
      ).p(DesignConstants.horizontalPadding),
    ).round(20);
  }
}

class LiveUserTile extends StatelessWidget {
  final LiveViewer viewer;

  const LiveUserTile({
    super.key,
    required this.viewer,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              UserAvatarView(
                user: viewer.user,
                size: 30,
                onTapHandler: () {},
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        BodyMediumText(
                          viewer.user.isMe
                              ? youString.tr
                              : viewer.user.userName,
                          // weight: TextWeight.regular,
                          maxLines: 1,
                        ),
                        if (viewer.user.isVerified) verifiedUserTag()
                      ],
                    ).bP4,
                    viewer.user.country != null
                        ? BodySmallText(
                            '${viewer.user.city!}, ${viewer.user.country!}',
                          )
                        : Container()
                  ],
                ).hP8,
              ),
              // const Spacer(),
            ],
          ),
        ),
        BodyLargeText(viewer.role == LiveUserRole.host
            ? hostString.tr
            : viewer.role == LiveUserRole.moderator
                ? moderatorString.tr
                : '')
      ],
    );
  }
}

class CollaboratorTile extends StatelessWidget {
  final CollaborationModel collaborator;

  final VoidCallback removeCallback;
  final VoidCallback? viewCallback;

  const CollaboratorTile({
    super.key,
    required this.collaborator,
    required this.removeCallback,
    this.viewCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              UserAvatarView(
                user: collaborator.user!,
                size: 30,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        BodyLargeText(
                          collaborator.user!.userName,
                          maxLines: 1,
                        ),
                        if (collaborator.user!.isVerified)
                          verifiedUserTag(),
                        if (collaborator.status ==
                            CollaborationStatusType.pending)
                          BodyLargeText(
                            '(${pendingString.tr})',
                            color: Colors.orange,
                          ),
                        if (collaborator.status ==
                            CollaborationStatusType.rejected)
                          BodyLargeText('(${rejectedString.tr})',
                              color: AppColorConstants.red),
                        if (collaborator.status ==
                            CollaborationStatusType.cancelled)
                          BodyLargeText('(${cancelledString.tr})',
                              color: AppColorConstants.red),
                      ],
                    ).bP4,
                    collaborator.user!.country != null
                        ? BodyMediumText(
                            '${collaborator.user!.city!}, ${collaborator.user!.country!}',
                          )
                        : Container()
                  ],
                ).hP8,
              ),
              // const Spacer(),
            ],
          ).ripple(() {
            if (viewCallback == null) {
              Get.to(() => OtherUserProfile(
                    userId: collaborator.user!.id,
                    user: collaborator.user!,
                  ));
            } else {
              viewCallback!();
            }
          }),
        ),
        if (collaborator.status == CollaborationStatusType.pending ||
            collaborator.status == CollaborationStatusType.accepted)
          AppThemeButton(
              backgroundColor: AppColorConstants.red,
              text: removeString.tr,
              onPress: () {
                removeCallback();
              })
      ],
    );
  }
}
