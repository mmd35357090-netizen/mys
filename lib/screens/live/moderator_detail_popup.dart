import '../../controllers/chat_and_call/chat_detail_controller.dart';
import '../../controllers/profile/profile_controller.dart';
import '../../helper/imports/common_import.dart';
import '../chat/chat_detail.dart';
import '../profile/user_profile_stat.dart';
import '../settings_menu/settings_controller.dart';
import 'gifts_list.dart';

class ModeratorDetail extends StatelessWidget {
  final ProfileController _profileController = Get.find();
  final SettingsController _settingsController = Get.find();
  final ChatDetailController _chatDetailController = Get.find();

  ModeratorDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.back(closeOverlays: true);
      },
      child: Container(
        color: Colors.black45,
        width: Get.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              color: AppColorConstants.cardColor,
              width: Get.width * 0.9,
              child: addProfileView().tP25,
            ).round(20),
          ],
        ),
      ),
    );
  }

  Widget addProfileView() {
    return GetBuilder<ProfileController>(
        init: _profileController,
        builder: (ctx) {
          return _profileController.user.value != null
              ? Column(
                  children: [
                    imageAndNameView(),
                    const SizedBox(
                      height: 20,
                    ),
                    UserProfileStatistics(
                      user: _profileController.user.value!,
                    ).hp(DesignConstants.horizontalPadding),
                    const SizedBox(
                      height: 40,
                    ),
                    divider(height: 1),
                    actionButtonsView().hp(DesignConstants.horizontalPadding),
                    divider(height: 1),
                  ],
                )
              : Container();
        });
  }

  Widget imageAndNameView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            UserAvatarView(
                user: _profileController.user.value!,
                size: 50,
                onTapHandler: () {
                  //open live
                }),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Heading6Text(_profileController.user.value!.userName,
                    weight: TextWeight.medium),
                if (_profileController.user.value!.isVerified) verifiedUserTag()
              ],
            ).bP4,
            if (_profileController.user.value!.profileCategoryTypeId != 0)
              BodyLargeText(
                      _profileController.user.value!.profileCategoryTypeName,
                      weight: TextWeight.regular)
                  .bP4,
            if (_profileController.user.value?.country != null)
              BodyMediumText(
                '${_profileController.user.value!.country},${_profileController.user.value!.city}',
              ),
          ],
        ),
      ],
    );
  }

  Widget actionButtonsView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 50,
          child: Center(
            child: BodyMediumText(
              _profileController.user.value!.followingStatus ==
                      FollowingStatus.following
                  ? unFollowString.tr
                  : _profileController.user.value!.followingStatus ==
                          FollowingStatus.requested
                      ? requestedString.tr
                      : _profileController.user.value!.isFollower
                          ? followBackString.tr
                          : followString.tr,
              color: _profileController.user.value!.followingStatus ==
                      FollowingStatus.following
                  ? AppColorConstants.themeColor
                  : AppColorConstants.mainTextColor,
              weight: _profileController.user.value!.followingStatus ==
                      FollowingStatus.following
                  ? TextWeight.bold
                  : TextWeight.medium,
            ),
          ),
        ).ripple(() {
          _profileController.followUnFollowUser(
              user: _profileController.user.value!);
        }),
        Container(
          height: 50,
          width: 1,
          color: AppColorConstants.dividerColor,
        ),
        if (_settingsController.setting.value!.enableChat)
          SizedBox(
            height: 50,
            child: Center(child: BodyMediumText(chatString.tr)),
          ).ripple(() {
            EasyLoading.show(status: loadingString.tr);
            _chatDetailController.getChatRoomWithUser(
                userId: _profileController.user.value!.id,
                callback: (room) {
                  EasyLoading.dismiss();
                  Get.to(() => ChatDetail(
                        chatRoom: room,
                      ));
                });
          }),
        Container(
          height: 50,
          width: 1,
          color: AppColorConstants.dividerColor,
        ),
        if (_settingsController.setting.value!.enableGift)
          SizedBox(
            height: 50,
            child: Center(child: BodyMediumText(sendGiftString.tr)),
          ).ripple(() {
            showModalBottomSheet<void>(
                context: Get.context!,
                builder: (BuildContext context) {
                  return FractionallySizedBox(
                      heightFactor: 0.8,
                      child: GiftsPageView(giftSelectedCompletion: (gift) {
                        Get.back();
                        _profileController.sendGift(gift);
                      }));
                });
          }),
      ],
    );
  }
}
