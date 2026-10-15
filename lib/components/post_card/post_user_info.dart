import 'package:foap/components/user_card.dart';
import 'package:foap/controllers/clubs/clubs_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/models.dart';
import 'package:foap/model/collaboration_model.dart';
import '../../controllers/misc/misc_controller.dart';
import '../../controllers/post/add_post_controller.dart';
import '../../controllers/profile/profile_controller.dart';
import '../../screens/club/club_detail.dart';
import '../../screens/post/edit_post.dart';
import '../../screens/profile/my_profile.dart';
import '../../screens/profile/other_user_profile.dart';
import '../post_card_controller.dart';

class PostUserInfo extends StatefulWidget {
  final PostModel post;
  final bool isSponsored;
  final VoidCallback removePostHandler;
  final VoidCallback blockUserHandler;
  final bool isResharedPost;

  const PostUserInfo({
    super.key,
    required this.post,
    required this.isSponsored,
    required this.removePostHandler,
    required this.blockUserHandler,
    required this.isResharedPost,

  });

  @override
  State<PostUserInfo> createState() => _PostUserInfoState();
}

class _PostUserInfoState extends State<PostUserInfo> {
  final ProfileController _profileController = Get.find();
  final PostCardController postCardController = Get.find();
  final UserFollowUnfollowBtnController _userFollowUnfollowBtnController =
      UserFollowUnfollowBtnController();

  @override
  void initState() {
    _userFollowUnfollowBtnController.setUser(widget.post.user);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
            height: 35,
            width: 35,
            child: UserAvatarView(
              size: 35,
              user: widget.post.user,
              onTapHandler: () {
                openProfile(widget.post.user);
              },
            )),
        const SizedBox(width: 10),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                userInfo(widget.post.user),
                if (widget.post.collaborations.isNotEmpty)
                  widget.post.isMyPost
                      ? collaborationsViewForPostOwner()
                      : collaborationsView(),
                if (widget.post.postedInClub != null)
                  Expanded(
                    child: BodyMediumText(
                      ' ${sharedInString.tr} (${widget.post.postedInClub!.name})',
                      weight: TextWeight.semiBold,
                      color: AppColorConstants.themeColor,
                      maxLines: 1,
                    ).ripple(() {
                      openClubDetail();
                    }),
                  ),
                if (widget.post.sharedPost != null)
                  BodySmallText(
                    ' ($reSharedString) ',
                    weight: TextWeight.semiBold,
                    maxLines: 1,
                  )
              ],
            ),
            const SizedBox(
              height: 2,
            ),
            widget.isSponsored == true
                ? BodyExtraSmallText(sponsoredString.tr)
                : Row(
                    children: [
                      ThemeIconWidget(ThemeIcon.clock, size: 12),
                      const SizedBox(
                        width: 5,
                      ),
                      BodyExtraSmallText(widget.post.postTime.tr),
                    ],
                  ),
          ],
        )),
        if (widget.post.user.followingStatus ==
            FollowingStatus.notFollowing)
          UserFollowUnfollowButton(
            isSmallSized: true,
            controller: _userFollowUnfollowBtnController,
          ),
        const SizedBox(
          width: 5,
        ),
        if (!widget.isResharedPost)
          Row(
            children: [
              if (widget.post.isPinned)
                Row(
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: ThemeIconWidget(
                        ThemeIcon.pin,
                        color: AppColorConstants.themeColor,
                        size: 25,
                      ),
                    ).ripple(() {
                      setState(() {
                        widget.post.isPinned = false;
                        MiscController controller = Get.find();
                        controller.removeFromPin(
                            PinContentType.post, widget.post.id);
                      });
                    }),
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              SizedBox(
                height: 20,
                width: 20,
                child: Obx(() => ThemeIconWidget(
                      postCardController.savedPosts
                                  .contains(widget.post) ||
                              widget.post.isSaved
                          ? ThemeIcon.bookMarked
                          : ThemeIcon.bookMark,
                      color: widget.post.isSaved ||
                              postCardController.savedPosts
                                  .contains(widget.post)
                          ? AppColorConstants.themeColor
                          : AppColorConstants.iconColor,
                      size: 25,
                    )),
              ).ripple(() {
                postCardController.saveUnSavePost(post: widget.post);
              }),
              const SizedBox(
                width: 20,
              ),
              SizedBox(
                height: 20,
                width: 20,
                child: ThemeIconWidget(
                  ThemeIcon.more,
                  color: AppColorConstants.iconColor,
                  size: 25,
                ),
              ).ripple(() {
                openActionPopup();
              })
            ],
          )
      ],
    );
  }

  Widget userInfo(UserModel user) {
    return Row(
      children: [
        BodySmallText(
          user.userName,
          weight: TextWeight.medium,
        ).ripple(() {
          if (user.role != UserRole.admin) {
            openProfile(user);
          }
        }),
        if (user.isVerified) verifiedUserTag().rP8,
      ],
    );
  }

  Widget collaborationsViewForPostOwner() {
    if (widget.post.collaborations.length == 1 &&
        widget.post.activeCollaborations.length == 1) {
      return Row(
        children: [
          BodySmallText(
            andString.tr,
            weight: TextWeight.medium,
          ),
          userInfo(widget.post.activeCollaborations.first.user!),
        ],
      );
    } else {
      return Row(
        children: [
          BodySmallText(
            andString.tr,
            weight: TextWeight.medium,
          ),
          BodyMediumText(
            '${widget.post.collaborations.length} ${otherString.tr}',
            weight: TextWeight.medium,
          ).ripple(() {
            List<CollaborationModel> allCollaborators =
                widget.post.collaborations;

            showModalBottomSheet(
              context: context,
              builder: (context) {
                return CollaboratorsListModal(
                  collaborators: allCollaborators,
                  isMyPost: widget.post.isMyPost,
                  removeCollaboratorCallback: (collaborator) {
                    AddPostController controller = Get.find();
                    controller.updateCollaborationStatus(
                        id: collaborator.id,
                        status: CollaborationStatusType.cancelled);
                    setState(() {
                      widget.post.removeCollaboration(collaborator);
                    });
                  },
                );
              },
            );
          })
        ],
      );
    }
  }

  Widget collaborationsView() {
    if (widget.post.activeCollaborations.isEmpty) return Container();
    if (widget.post.activeCollaborations.length == 1) {
      return Row(
        children: [
          BodyMediumText(
            andString.tr,
            weight: TextWeight.medium,
          ),
          userInfo(widget.post.activeCollaborations.first.user!),
        ],
      );
    } else {
      return Row(
        children: [
          BodyMediumText(
            andString.tr,
            weight: TextWeight.medium,
          ),
          BodyMediumText(
            '${widget.post.activeCollaborations.length} ${otherString.tr}',
            weight: TextWeight.medium,
          ).ripple(() {
            List<CollaborationModel> acceptedCollaborations = widget
                .post.collaborations
                .where((e) => e.status == CollaborationStatusType.accepted)
                .toList();

            showModalBottomSheet(
              context: context,
              builder: (context) {
                return CollaboratorsListModal(
                  collaborators: acceptedCollaborations,
                  isMyPost: widget.post.isMyPost,
                  removeCollaboratorCallback: (collaborator) {},
                );
              },
            );
          })
        ],
      );
    }
  }

  void openProfile(UserModel user) async {
    if (user.isMe) {
      Get.to(() => const MyProfile(
            showBack: true,
          ));
    } else {
      _profileController.otherUserProfileView(
          refId: user.id, viewSource: UserViewSourceType.post);
      Get.to(() => OtherUserProfile(userId: user.id, user: user));
    }
  }

  void openClubDetail() async {
    ClubsController clubsController = Get.find();

    clubsController.getClubDetail(widget.post.postedInClub!.id!, (club) {
      Get.to(() => ClubDetail(
          club: club,
          needRefreshCallback: () {},
          deleteCallback: (club) {}));
    });
  }

  void openActionPopup() {
    Get.bottomSheet(Container(
      color: AppColorConstants.cardColor.darken(),
      child: widget.post.user.isMe
          ? Wrap(
              children: [
                ListTile(
                    title: Center(
                        child: Heading6Text(
                      editPostString.tr,
                      weight: TextWeight.semiBold,
                    )),
                    onTap: () async {
                      Get.back();
                      Get.to(() => EditPostScreen(post: widget.post));
                    }),
                divider(),
                ListTile(
                    title: Center(
                        child: Heading6Text(
                      deletePostString.tr,
                      weight: TextWeight.semiBold,
                    )),
                    onTap: () async {
                      Get.back();
                      postCardController.deletePost(
                          post: widget.post,
                          callback: () {
                            widget.removePostHandler();
                          });
                    }),
                divider(),
                ListTile(
                    title: Center(
                        child: Heading6Text(
                      widget.post.isPinned ? unPinString.tr : pinString.tr,
                      weight: TextWeight.semiBold,
                    )),
                    onTap: () async {
                      Get.back();
                      MiscController miscController = Get.find();

                      setState(() {
                        if (widget.post.isPinned) {
                          miscController.removeFromPin(
                              PinContentType.post, widget.post.pinId!);
                          widget.post.isPinned = false;
                        } else {
                          miscController.addToPin(
                              PinContentType.post, widget.post.id, (id) {
                            widget.post.pinId = id;
                          });
                          widget.post.isPinned = true;
                        }
                      });
                    }),
                divider(),
                ListTile(
                    title: Center(
                        child: BodyLargeText(
                      cancelString.tr,
                      weight: TextWeight.semiBold,
                      color: AppColorConstants.red,
                    )),
                    onTap: () => Get.back()),
              ],
            )
          : Wrap(
              children: [
                ListTile(
                    title: Center(
                        child: Heading6Text(
                      reportString.tr,
                      weight: TextWeight.bold,
                    )),
                    onTap: () async {
                      Get.back();

                      AppUtil.showNewConfirmationAlert(
                        title: reportString.tr,
                        subTitle: areYouSureToReportPostString.tr,
                        okHandler: () {
                          postCardController.reportPost(
                              post: widget.post,
                              callback: () {
                                widget.removePostHandler();
                              });
                        },
                        cancelHandler: () {
                          Get.back();
                        },
                      );
                    }),
                divider(),
                ListTile(
                    title: Center(
                        child: Heading6Text(blockUserString.tr,
                            weight: TextWeight.bold)),
                    onTap: () async {
                      Get.back();
                      AppUtil.showNewConfirmationAlert(
                        title: blockString.tr,
                        subTitle: areYouSureToBlockUserString.tr,
                        okHandler: () {
                          postCardController.blockUser(
                              userId: widget.post.user.id,
                              callback: () {
                                widget.blockUserHandler();
                              });
                        },
                        cancelHandler: () {
                          Get.back();
                        },
                      );
                    }),
                divider(),
                if (widget.post.amICollaborator)
                  Column(
                    children: [
                      divider(),
                      ListTile(
                          title: Center(
                            child: Heading6Text(
                              withdrawCollaborationString.tr,
                              weight: TextWeight.bold,
                              color: AppColorConstants.red,
                            ),
                          ),
                          onTap: () {
                            Get.back();

                            setState(() {
                              widget.post.removeMyCollaboration();
                            });
                            AddPostController controller = Get.find();
                            controller.updateCollaborationStatus(
                                id: widget.post.myCollaboration.id,
                                status: CollaborationStatusType.cancelled);
                          }),
                    ],
                  ),
                ListTile(
                    title: Center(
                      child: Heading6Text(
                        cancelString.tr,
                        weight: TextWeight.regular,
                        color: AppColorConstants.red,
                      ),
                    ),
                    onTap: () => Get.back()),
                const SizedBox(
                  height: 25,
                )
              ],
            ),
    ).topRounded(40));
  }
}

class CollaboratorsListModal extends StatefulWidget {
  final List<CollaborationModel> collaborators;
  final bool isMyPost;
  final Function(CollaborationModel) removeCollaboratorCallback;

  const CollaboratorsListModal({
    super.key,
    required this.collaborators,
    required this.isMyPost,
    required this.removeCollaboratorCallback,
  });

  @override
  State<CollaboratorsListModal> createState() =>
      _CollaboratorsListModalState();
}

class _CollaboratorsListModalState extends State<CollaboratorsListModal> {
  @override
  Widget build(BuildContext context) {
    // Close the modal if the list is empty
    if (widget.collaborators.isEmpty) {
      Navigator.pop(context);
      return Container(); // Return an empty container to avoid build errors
    }

    return IntrinsicHeight(
      child: Container(
        color: AppColorConstants.backgroundColor,
        child: Column(
          children: [
            BodyLargeText(collaboratorsString.tr),
            divider(height: 0.5).vP16,
            Column(
              children: widget.collaborators.map((collaborator) {
                return widget.isMyPost
                    ? CollaboratorTile(
                        collaborator: collaborator,
                        removeCallback: () {
                          setState(() {
                            collaborator.status =
                                CollaborationStatusType.cancelled;
                          });
                          widget.removeCollaboratorCallback(collaborator);
                        },
                      ).vP8
                    : UserTile(
                        profile: collaborator.user!,
                        viewCallback: () {
                          Get.back();
                          Get.to(() => OtherUserProfile(
                              userId: collaborator.user!.id));
                        },
                      ).vP8;
              }).toList(),
            ).hp(DesignConstants.horizontalPadding),
          ],
        ).vP25,
      ),
    ).topRounded(20);
  }
}
