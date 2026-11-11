import 'package:foap/helper/imports/chat_imports.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/string_extension.dart';

class PublicGroupDetail extends StatefulWidget {
  const PublicGroupDetail({
    super.key,
  }) ;

  @override
  PublicGroupDetailState createState() => PublicGroupDetailState();
}

class PublicGroupDetailState extends State<PublicGroupDetail> {
  final ChatDetailController _chatDetailController = Get.find();
  final ChatRoomDetailController _chatRoomDetailController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Stack(
        children: [
          Obx(() => SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                        height: 330,
                        child: _chatRoomDetailController
                                .currentRoom.value!.image!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: _chatRoomDetailController
                                    .currentRoom.value!.image!,
                                fit: BoxFit.cover,
                              )
                            : Center(
                                child: Heading1Text(_chatRoomDetailController
                                    .currentRoom.value!.name!.getInitials))).bottomRounded(28),
                    const SizedBox(
                      height: 20,
                    ),
                    Heading4Text(
                            _chatRoomDetailController.currentRoom.value!.name!,
                            weight: TextWeight.bold)
                        .hp(DesignConstants.horizontalPadding),
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColorConstants.themeColor
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(children: [
                            ThemeIconWidget(ThemeIcon.userGroup,
                                size: 14,
                                color: AppColorConstants.themeColor),
                            const SizedBox(width: 6),
                            BodySmallText(
                              publicGroupString.tr,
                              color: AppColorConstants.themeColor,
                              weight: TextWeight.semiBold,
                            ),
                          ]),
                        ),
                        // ThemeIconWidget(
                        //   ThemeIcon.circle,
                        //   size: 8,
                        // ).hP8,
                        // BodyMediumText(
                        //         '${_clubDetailController.club.value!.totalMembers!.formatNumber} ${clubMembersString.tr}',
                        //         weight: TextWeight.regular)
                        //     .ripple(() {
                        //   Get.to(() => ClubMembers(
                        //       club: _clubDetailController.club.value!));
                        // })
                      ],
                    ).hp(DesignConstants.horizontalPadding),
                    const SizedBox(
                      height: 12,
                    ),
                    buttonsWidget().hp(DesignConstants.horizontalPadding),
                    const SizedBox(
                      height: 20,
                    ),
                    if (_chatRoomDetailController
                        .currentRoom.value!.description!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColorConstants.cardColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: AppColorConstants.dividerColor
                                  .withValues(alpha: 0.5),
                              width: 0.6),
                        ),
                        child: BodyMediumText(_chatRoomDetailController
                            .currentRoom.value!.description!),
                      ).hp(DesignConstants.horizontalPadding),
                    const SizedBox(height: 30),
                  ],
                ),
              )),
          appBar()
        ],
      ),
    );
  }

  Widget buttonsWidget() {
    return Obx(() => Row(
          children: [
            if (_chatRoomDetailController.currentRoom.value!.amIGroupAdmin ==
                false)
              Container(
                      // width: 40,
                      height: 38,
                      color: AppColorConstants.themeColor.withValues(alpha: 0.14),
                      child: Row(
                        children: [
                          Icon(
                            _chatRoomDetailController
                                        .currentRoom.value!.amIMember ==
                                    true
                                ? Icons.exit_to_app
                                : Icons.add,
                            color: AppColorConstants.iconColor,
                            size: 15,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          BodyLargeText(_chatRoomDetailController
                                      .currentRoom.value!.amIMember ==
                                  true
                              ? joinedString.tr
                              : joinString.tr)
                        ],
                      ).hP16)
                  .round(19)
                  .ripple(() {
                if (_chatRoomDetailController.currentRoom.value!.amIMember ==
                    true) {
                  _chatRoomDetailController.leavePublicGroup(
                      _chatRoomDetailController.currentRoom.value!);
                } else {
                  _chatRoomDetailController.addUsersToPublicRoom(
                      room: _chatRoomDetailController.currentRoom.value!,
                      selectedFriends: [_userProfileManager.user.value!]);
                }
              }).rP8,
            if (_chatRoomDetailController.currentRoom.value!.amIMember == true)
              Container(
                      // width: 40,
                      height: 38,
                      color: AppColorConstants.themeColor.withValues(alpha: 0.14),
                      child: Row(
                        children: [
                          Icon(
                            Icons.chat,
                            size: 15,
                            color: AppColorConstants.iconColor,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          BodyLargeText(chatString.tr)
                        ],
                      ).hP16)
                  .round(19)
                  .ripple(() {
                Get.to(() => ChatDetail(
                    chatRoom: _chatRoomDetailController.currentRoom.value!));
              }).rP8,
          ],
        ));
  }

  Widget appBar() {
    return Positioned(
      child: Container(
        height: 150.0,
        width: Get.width,
        decoration: BoxDecoration(
            color: Colors.white,
            gradient: LinearGradient(
                begin: FractionalOffset.topCenter,
                end: FractionalOffset.bottomCenter,
                colors: [
                  Colors.black,
                  Colors.black.withValues(alpha: 0.5),
                  Colors.grey.withValues(alpha: 0.0),
                ],
                stops: const [
                  0.0,
                  0.5,
                  1.0
                ])),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 38,
              width: 38,
              color: Colors.black.withValues(alpha: 0.35),
              child: Center(
                child: ThemeIconWidget(
                  ThemeIcon.backArrow,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ).round(19).ripple(() {
              Get.back();
            }),
            Obx(() => _chatRoomDetailController.currentRoom.value!.amIGroupAdmin
                ? Row(
                    children: [
                      const SizedBox(width: 10),
                      ThemeIconWidget(
                        ThemeIcon.setting,
                        size: 20,
                        color: Colors.white,
                      ).ripple(() {
                        Get.to(() => UpdateGroupInfo(
                                group: _chatRoomDetailController
                                    .currentRoom.value!))!
                            .then((value) {
                          _chatDetailController.getUpdatedChatRoomDetail(
                              room:
                                  _chatRoomDetailController.currentRoom.value!,
                              callback: () {});
                        });
                      }),
                    ],
                  )
                : const SizedBox(
                    width: 20,
                  ))
          ],
        ).hp(DesignConstants.horizontalPadding),
      ),
    );
  }
}
