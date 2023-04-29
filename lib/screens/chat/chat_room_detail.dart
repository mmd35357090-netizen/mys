import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/chat_imports.dart';
import '../../components/actionSheets/action_sheet1.dart';
import '../../model/generic_item.dart';
import '../profile/other_user_profile.dart';
import '../settings_menu/settings_controller.dart';

class ChatRoomDetail extends StatefulWidget {
  final ChatRoomModel chatRoom;

  const ChatRoomDetail({Key? key, required this.chatRoom}) : super(key: key);

  @override
  State<ChatRoomDetail> createState() => _ChatRoomDetailState();
}

class _ChatRoomDetailState extends State<ChatRoomDetail> {
  final ChatRoomDetailController _chatRoomDetailController = Get.find();
  final ChatDetailController _chatDetailController = Get.find();
  final SettingsController _settingsController = Get.find();

  @override
  void initState() {
    if (_settingsController.setting.value!.enableStarMessage) {
      _chatRoomDetailController.getStarredMessages(widget.chatRoom);
    }
    _chatDetailController.getUpdatedChatRoomDetail(
        room: widget.chatRoom, callback: () {});
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ThemeIconWidget(
                  ThemeIcon.backArrow,
                  color: AppColorConstants.iconColor,
                  size: 20,
                ).p8.ripple(() {
                  Get.back();
                }),
                Obx(() => _chatDetailController.chatRoom.value == null
                    ? Container()
                    : Heading5Text(
                        _chatDetailController.chatRoom.value!.isGroupChat
                            ? _chatDetailController.chatRoom.value!.name!
                            : _chatDetailController
                                .chatRoom.value!.opponent.userDetail.userName,
                        weight: TextWeight.medium)),
                Obx(() => _chatDetailController.chatRoom.value?.amIGroupAdmin ==
                            true &&
                        _chatDetailController.chatRoom.value?.isGroupChat ==
                            true
                    ? ThemeIconWidget(
                        ThemeIcon.edit,
                        color: AppColorConstants.iconColor,
                        size: 20,
                      ).ripple(() {
                        Get.to(() => UpdateGroupInfo(
                                group: _chatDetailController.chatRoom.value!))!
                            .then((value) {
                          _chatDetailController.getUpdatedChatRoomDetail(
                              room: widget.chatRoom, callback: () {});
                        });
                      })
                    : const SizedBox(
                        width: 20,
                      )),
              ],
            ).hP16,
            divider(context: context).tP8,
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(
                    left: 0, top: 0, right: 0, bottom: 80),
                children: [
                  const SizedBox(
                    height: 25,
                  ),
                  widget.chatRoom.isGroupChat ? groupInfo() : opponentInfo(),
                  const SizedBox(
                    height: 25,
                  ),
                  widget.chatRoom.isGroupChat
                      ? Container()
                      : Column(
                          children: [
                            callWidgets(),
                            const SizedBox(
                              height: 50,
                            ),
                          ],
                        ),
                  Obx(() =>
                      (_chatDetailController.chatRoom.value?.description ?? '')
                              .isEmpty
                          ? Container()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                descriptionWidget(),
                                const SizedBox(
                                  height: 50,
                                ),
                              ],
                            )),
                  commonOptionsWidget(),
                  const SizedBox(
                    height: 50,
                  ),
                  Obx(() => _chatDetailController.chatRoom.value?.isGroupChat ==
                              true &&
                          _chatDetailController.chatRoom.value?.amIGroupAdmin ==
                              true
                      ? Column(children: [
                          groupSettingWidget(),
                          const SizedBox(
                            height: 50,
                          )
                        ])
                      : Container()),
                  widget.chatRoom.isGroupChat
                      ? Column(
                          children: [
                            participantsWidget(),
                            const SizedBox(
                              height: 50,
                            )
                          ],
                        )
                      : Container(),
                  if (_chatDetailController.messages.isNotEmpty)
                    Column(
                      children: [
                        extraOptionsWidget(),
                        const SizedBox(
                          height: 50,
                        ),
                      ],
                    ),
                  widget.chatRoom.isGroupChat
                      ? Column(children: [
                          exitAndDeleteGroup(),
                          const SizedBox(
                            height: 50,
                          )
                        ])
                      : Container(),
                ],
              ),
            )
          ],
        ));
  }

  Widget descriptionWidget() {
    return Container(
      color: AppColorConstants.cardColor,
      width: double.infinity,
      child: Heading6Text(
        _chatDetailController.chatRoom.value!.description!,
          weight: TextWeight.regular
      ).p16,
    ).round(10).backgroundCard( shadowOpacity: 0.1).hP16;
  }

  Widget groupSettingWidget() {
    return Column(
      children: [
        Container(
          height: 50,
          color: AppColorConstants.cardColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    color: AppColorConstants.themeColor,
                    child: const ThemeIconWidget(
                      ThemeIcon.setting,
                      color: Colors.white,
                    ).p4,
                  ).round(5),
                  const SizedBox(
                    width: 10,
                  ),
                  Heading6Text(
                    LocalizationString.groupSettings,
                      weight: TextWeight.regular
                  ),
                ],
              ),
              ThemeIconWidget(
                ThemeIcon.nextArrow,
                color: AppColorConstants.iconColor,
                size: 15,
              )
            ],
          ).hP8,
        ).ripple(() {
          Get.to(() => const GroupSettings());
        }),
      ],
    ).round(10).backgroundCard( shadowOpacity: 0.1).hP16;
  }

  Widget commonOptionsWidget() {
    return Column(
      children: [
        Container(
          height: 50,
          color: AppColorConstants.cardColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    color: AppColorConstants.themeColor,
                    child: const ThemeIconWidget(
                      ThemeIcon.gallery,
                      color: Colors.white,
                    ).p4,
                  ).round(5),
                  const SizedBox(
                    width: 10,
                  ),
                  Heading6Text(
                    LocalizationString.media,
                      weight: TextWeight.regular
                  ),
                ],
              ),
              ThemeIconWidget(
                ThemeIcon.nextArrow,
                color: AppColorConstants.iconColor,
                size: 15,
              )
            ],
          ).hP8,
        ).ripple(() {
          Get.to(() => ChatMediaList(
                chatRoom: widget.chatRoom,
              ));
        }),
        divider(context: context),
        Container(
          height: 50,
          color: AppColorConstants.cardColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    color: AppColorConstants.themeColor,
                    child: const ThemeIconWidget(
                      ThemeIcon.wallpaper,
                      color: Colors.white,
                    ).p4,
                  ).round(5),
                  const SizedBox(
                    width: 10,
                  ),
                  Heading6Text(
                    LocalizationString.wallpaper,
                      weight: TextWeight.regular
                  ),
                ],
              ),
              ThemeIconWidget(
                ThemeIcon.nextArrow,
                color: AppColorConstants.iconColor,
                size: 15,
              )
            ],
          ).hP8,
        ).ripple(() {
          Get.to(() => WallpaperForChatBackground(
                roomId: widget.chatRoom.id,
              ));
        }),
        divider(context: context),
        _chatRoomDetailController.starredMessages.isNotEmpty &&
                _settingsController.setting.value!.enableStarMessage
            ? Obx(() => Container(
                  height: 50,
                  color: AppColorConstants.cardColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            color: AppColorConstants.themeColor,
                            child: const ThemeIconWidget(
                              ThemeIcon.filledStar,
                              color: Colors.white,
                            ).p4,
                          ).round(5),
                          const SizedBox(
                            width: 10,
                          ),
                          Heading6Text(
                            LocalizationString.starredMessages,
                              weight: TextWeight.regular
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          BodyLargeText(
                              '(${_chatRoomDetailController.starredMessages.length})',
                              weight: TextWeight.medium),
                          ThemeIconWidget(
                            ThemeIcon.nextArrow,
                            color: AppColorConstants.iconColor,
                            size: 15,
                          )
                        ],
                      )
                    ],
                  ).hP8,
                ).ripple(() {
                  Get.to(() => StarredMessages(
                        chatRoom: widget.chatRoom,
                      ));
                }))
            : Container(),
      ],
    ).round(10).backgroundCard(shadowOpacity: 0.1).hP16;
  }

  Widget extraOptionsWidget() {
    return Column(
      children: [
        Container(
          height: 50,
          color: AppColorConstants.cardColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Heading6Text(
                LocalizationString.exportChat,
                  weight: TextWeight.regular
              )
            ],
          ).hP8,
        ).ripple(() {
          exportChatActionPopup();
        }),
        divider(context: context),
        Container(
          height: 50,
          color: AppColorConstants.cardColor,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Heading5Text(LocalizationString.deleteChat,
                    weight: TextWeight.medium, color: AppColorConstants.red)
                .hP8,
          ),
        ).ripple(() {
          _chatRoomDetailController.deleteRoomChat(widget.chatRoom);
          _chatDetailController.deleteChat(widget.chatRoom.id);
          AppUtil.showToast(
              message: LocalizationString.chatDeleted,
              isSuccess: true);
        })
      ],
    ).round(10).backgroundCard(shadowOpacity: 0.1).hP16;
  }

  Widget exitAndDeleteGroup() {
    return Column(
      children: [
        divider(context: context),
        Container(
          height: 50,
          color: AppColorConstants.cardColor,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Heading5Text(
              widget.chatRoom.amIMember
                  ? LocalizationString.leaveGroup
                  : LocalizationString.deleteGroup,
    weight: TextWeight.medium,
    color: AppColorConstants.red

            ).hP8,
          ),
        ).ripple(() {
          if (widget.chatRoom.amIMember) {

            // AppUtil.showConfirmationAlert(
            //     title: LocalizationString.leaveGroup,
            //     subTitle: LocalizationString.leaveGroupConfirmation,
            //     cxt: context,
            //     okHandler: () {
            _chatRoomDetailController.leaveGroup(widget.chatRoom);
            // });
          } else {
            // print('test 2');
            //
            // AppUtil.showConfirmationAlert(
            //     title: LocalizationString.deleteGroup,
            //     subTitle: LocalizationString.deleteGroupConfirmation,
            //     cxt: context,
            //     okHandler: () {
            _chatRoomDetailController.deleteGroup(widget.chatRoom);
            // });
          }
          Get.back();
        }),
      ],
    ).round(10).backgroundCard( shadowOpacity: 0.1).hP16;
  }

  Widget callWidgets() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_settingsController.setting.value!.enableAudioCalling)
          Container(
            child: Column(
              children: [
                const ThemeIconWidget(
                  ThemeIcon.mobile,
                  size: 20,
                ),
                const SizedBox(
                  height: 5,
                ),
                BodyMediumText(
                  LocalizationString.audio,
                    weight: TextWeight.medium
                ),
              ],
            ).setPadding(left: 16, right: 16, top: 8, bottom: 8),
          ).round(10).backgroundCard(shadowOpacity: 0.1).ripple(() {
            audioCall();
          }).rp(20),
        if (_settingsController.setting.value!.enableVideoCalling)
          Container(
            child: Column(
              children: [
                const ThemeIconWidget(
                  ThemeIcon.videoCamera,
                  size: 20,
                ),
                const SizedBox(
                  height: 5,
                ),
                BodyMediumText(
                  LocalizationString.video,
                    weight: TextWeight.medium
                ),
              ],
            ).setPadding(left: 16, right: 16, top: 8, bottom: 8),
          ).round(10).backgroundCard(shadowOpacity: 0.1).ripple(() {
            videoCall();
          }),
      ],
    );
  }

  Widget groupInfo() {
    return Obx(() => _chatDetailController.chatRoom.value == null
        ? Container()
        : Column(
            children: [
              AvatarView(
                url: _chatDetailController.chatRoom.value!.image,
                size: 100,
                name: _chatDetailController.chatRoom.value!.name!,
              ),
              const SizedBox(
                height: 10,
              ),
              Heading6Text(
                _chatDetailController.chatRoom.value!.name!,
                  weight: TextWeight.bold
              )
            ],
          ));
  }

  Widget opponentInfo() {
    return Obx(() => _chatDetailController.chatRoom.value == null
        ? Container()
        : Column(
            children: [
              UserAvatarView(
                user: _chatDetailController.chatRoom.value!.opponent.userDetail,
                size: 100,
                onTapHandler: () {
                  //open live
                },
              ),
              const SizedBox(
                height: 10,
              ),
              Heading6Text(
                _chatDetailController
                    .chatRoom.value!.opponent.userDetail.userName,
                  weight: TextWeight.bold
              )
            ],
          ));
  }

  void exportChatActionPopup() {
    showModalBottomSheet(
        context: context,
        builder: (context) => Wrap(
              children: [
                ListTile(
                    title: Center(
                        child: BodyLargeText(LocalizationString.exportChatWithMedia)),
                    onTap: () async {
                      Get.back();
                      exportChatWithMedia();
                    }),
                divider(context: context),
                ListTile(
                    title: Center(
                        child: BodyLargeText(LocalizationString.exportChatWithoutMedia)),
                    onTap: () async {
                      Get.back();
                      exportChatWithoutMedia();
                    }),
                divider(context: context),
                ListTile(
                    title: Center(child: BodyLargeText(LocalizationString.cancel)),
                    onTap: () => Get.back()),
              ],
            ));
  }

  Widget participantsWidget() {
    return Obx(() => _chatDetailController.chatRoom.value == null
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Heading5Text(
                '${_chatDetailController.chatRoom.value!.roomMembers.length} ${LocalizationString.participants}',
                  weight: TextWeight.bold
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                height:
                    (_chatDetailController.chatRoom.value!.roomMembers.length +
                            (_chatDetailController.chatRoom.value!.amIGroupAdmin
                                ? 1
                                : 0)) *
                        60,
                color: AppColorConstants.cardColor,
                child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: _chatDetailController
                            .chatRoom.value!.roomMembers.length +
                        (_chatDetailController.chatRoom.value!.amIGroupAdmin
                            ? 1
                            : 0),
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (ctx, index) {
                      if (index == 0 &&
                          _chatDetailController.chatRoom.value!.amIGroupAdmin) {
                        return Row(
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              color: AppColorConstants.themeColor.lighten(),
                              child: const ThemeIconWidget(
                                ThemeIcon.plus,
                                size: 25,
                              ),
                            ).circular,
                            const SizedBox(
                              width: 15,
                            ),
                            Heading6Text(
                              LocalizationString.addParticipants,
                                weight: TextWeight.medium
                            )
                          ],
                        ).hP8.ripple(() {
                          showModalBottomSheet(
                              backgroundColor: Colors.transparent,
                              context: context,
                              isScrollControlled: true,
                              builder: (context) => FractionallySizedBox(
                                  heightFactor: 0.9,
                                  child: SelectUserForGroupChat(
                                    group:
                                        _chatDetailController.chatRoom.value!,
                                    invitedUserCallback: () {
                                      _chatDetailController
                                          .getUpdatedChatRoomDetail(
                                              room: widget.chatRoom,
                                              callback: () {});
                                    },
                                  )));
                        });
                      }
                      ChatRoomMember member =
                          _chatDetailController.chatRoom.value!.roomMembers[
                              index -
                                  (_chatDetailController
                                          .chatRoom.value!.amIGroupAdmin
                                      ? 1
                                      : 0)];
                      return Row(
                        children: [
                          UserAvatarView(
                            user: member.userDetail,
                            size: 40,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Heading6Text(
                                member.userDetail.isMe
                                    ? LocalizationString.you
                                    : member.userDetail.userName,
                                  weight: TextWeight.regular
                              ).bP4,
                              member.userDetail.country != null
                                  ? BodyLargeText(
                                      '${member.userDetail.city!}, ${member.userDetail.country!}',

                                    )
                                  : Container()
                            ],
                          ).hP16,

                          const Spacer(),
                          member.isAdmin == 1
                              ? Heading6Text(
                                  LocalizationString.admin,
                              weight: TextWeight.medium
                                ).bP4
                              : Container()
                          // const Spacer(),
                        ],
                      ).hP8.ripple(() {
                        if (!member.userDetail.isMe) {
                          openActionOptionsForParticipant(member);
                        }
                      });
                    },
                    separatorBuilder: (ctx, index) {
                      return divider(context: context).vp(10);
                    }).vP8,
              ).round(10).backgroundCard(shadowOpacity: 0.1),
            ],
          ).hP16);
  }

  void openActionOptionsForParticipant(ChatRoomMember member) {
    GenericItem userDetail = GenericItem(
      id: '1',
      title: LocalizationString.userDetail,
      subTitle: LocalizationString.userDetail,
      // isSelected: selectedItem?.id == '1',
    );

    GenericItem makeAdmin = GenericItem(
      id: '2',
      title: LocalizationString.makeAdmin,
      subTitle: LocalizationString.makeAdmin,
      // isSelected: selectedItem?.id == '1',
    );

    GenericItem removeAdmin = GenericItem(
      id: '3',
      title: LocalizationString.removeAdmin,
      subTitle: LocalizationString.removeAdmin,
      // isSelected: selectedItem?.id == '1',
    );

    GenericItem removeFromGroup = GenericItem(
      id: '4',
      title: LocalizationString.removeFromGroup,
      subTitle: LocalizationString.removeFromGroup,
      // isSelected: selectedItem?.id == '1',
    );
    GenericItem cancel = GenericItem(
      id: '5',
      title: LocalizationString.cancel,
      subTitle: LocalizationString.cancel,
      // isSelected: selectedItem?.id == '1',
    );
    List<GenericItem> items = [];
    items.add(userDetail);
    if (member.isAdmin == 1 && widget.chatRoom.amIGroupAdmin) {
      items.add(removeAdmin);
    } else {
      if (widget.chatRoom.amIGroupAdmin) {
        items.add(makeAdmin);
        items.add(removeFromGroup);
      }
    }
    items.add(cancel);

    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => ActionSheet1(
              items: items,
              itemCallBack: (item) {
                if (item.id == '1') {
                  Get.to(() => OtherUserProfile(
                        userId: member.userDetail.id,
                      ));
                } else if (item.id == '2') {
                  _chatRoomDetailController.makeUserAsAdmin(
                      member.userDetail, widget.chatRoom);
                } else if (item.id == '3') {
                  _chatRoomDetailController.removeUserAsAdmin(
                      member.userDetail, widget.chatRoom);
                } else if (item.id == '4') {
                  _chatRoomDetailController.removeUserFormGroup(
                      member.userDetail, widget.chatRoom);
                }
              },
            ));
  }

  void exportChatWithMedia() {
    _chatRoomDetailController.exportChat(
        roomId: widget.chatRoom.id, includeMedia: true);
  }

  void exportChatWithoutMedia() {
    _chatRoomDetailController.exportChat(
        roomId: widget.chatRoom.id, includeMedia: false);
  }

  leaveChat() {
    _chatRoomDetailController.leaveGroup(widget.chatRoom);
    Get.back();
  }

  void videoCall() {
    _chatDetailController.initiateVideoCall();
  }

  void audioCall() {
    _chatDetailController.initiateAudioCall();
  }
}
