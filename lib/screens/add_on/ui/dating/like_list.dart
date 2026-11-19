import 'package:foap/controllers/chat_and_call/chat_detail_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/add_on/controller/dating/dating_controller.dart';
import 'package:foap/screens/chat/chat_detail.dart';
import 'package:foap/screens/profile/other_user_profile.dart';
import 'dart:ui' as ui;
import 'package:foap/screens/add_on/ui/dating/dating_plans.dart';
import 'package:intl/intl.dart';

class LikeList extends StatefulWidget {
  const LikeList({super.key}) ;

  @override
  State<LikeList> createState() => LikeListState();
}

class LikeListState extends State<LikeList> {
  final DatingController datingController = DatingController();
  final ChatDetailController _chatDetailController = Get.find();

  @override
  void initState() {
    super.initState();
    datingController.getLikeProfilesApi();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(
            title: likedByString.tr,
          ),
          Expanded(
              child: Obx(() => datingController.isLoading.value
                  ? const ShimmerLikeList()
                  : datingController.likeUsers.isEmpty
                      ? emptyData(
                          title: noLikeProfilesFoundString.tr,
                          subTitle: noLikeProfilesString.tr,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 15, bottom: 15),
                          shrinkWrap: true,
                          itemCount: datingController.likeUsers.length +
                              (datingController.likesLocked.value ? 1 : 0),
                          itemBuilder: (BuildContext context, int index) {
                            if (datingController.likesLocked.value) {
                              if (index == 0) return _lockBanner();
                              return _lockedTile(index - 1);
                            }
                            return matchedTile(index);
                          }))),
        ],
      ),
    );
  }

  Widget _lockBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
            colors: [Color(0xFF7B4DFF), Color(0xFFE5484D)]),
      ),
      child: Row(children: [
        const Icon(Icons.lock_rounded, color: Colors.white, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '${datingController.likesCount.value} people like you. Get a dating plan to see who.',
            style: const TextStyle(
                color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF7B4DFF),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20))),
          onPressed: () => Get.to(() => const DatingPlans()),
          child: const Text('See'),
        ),
      ]),
    );
  }

  Widget _lockedTile(int index) {
    return GestureDetector(
      onTap: () => Get.to(() => const DatingPlans()),
      child: AbsorbPointer(
        child: ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: matchedTile(index),
        ),
      ),
    );
  }

  Widget matchedTile(int index) {
    UserModel profile = datingController.likeUsers[index];

    String? yearStr;
    if (profile.dob != null && profile.dob != '') {
      DateTime birthDate = DateFormat("yyyy-MM-dd").parse(profile.dob!);
      Duration diff = DateTime.now().difference(birthDate);
      int years = diff.inDays ~/ 365;
      yearStr = years.toString();
    }

    return Container(
            decoration: BoxDecoration(
              color: AppColorConstants.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColorConstants.dividerColor.withValues(alpha: 0.5),
                  width: 0.6),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 5))
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    userPictureView(
                      profile,
                      50,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BodyMediumText(
                          (profile.name == null
                                  ? profile.userName
                                  : profile.name ?? '') +
                              (yearStr != null ? ', $yearStr' : ''),
                          weight: TextWeight.bold,
                        ).bP4,
                        BodySmallText(
                          profile.genderType == GenderType.female
                              ? femaleString.tr
                              : profile.genderType == GenderType.other
                                  ? otherString.tr
                                  : maleString.tr,
                        )
                      ],
                    ).hp(DesignConstants.horizontalPadding),
                    // const Spacer(),
                  ],
                ).ripple(() {
                  Get.to(() => OtherUserProfile(userId: profile.id,user: profile,));
                }),
                const Spacer(),
                AppThemeBorderButton(
                    height: 36,
                    borderColor: AppColorConstants.themeColor,
                    text: likeBackString.tr,
                    onPress: () {
                      datingController.likeUnlikeProfile(
                          DatingActions.liked, profile.id.toString());
                      Loader.show(status: loadingString.tr);
                      _chatDetailController.getChatRoomWithUser(
                          userId: profile.id,
                          callback: (room) {
                            Loader.dismiss();
                            Get.to(() => ChatDetail(
                                  chatRoom: room,
                                ));
                            setState(() {
                              datingController.likeUsers.removeAt(index);
                            });
                          });
                    })
              ],
            ).paddingSymmetric(horizontal: 14, vertical: 14))
        .setPadding(bottom: 14, left: 15, right: 15);
  }

  Widget userPictureView(UserModel user, double size) {
    return user.picture != null
        ? CachedNetworkImage(
            imageUrl: user.picture!,
            fit: BoxFit.cover,
            height: size,
            width: size,
            placeholder: (context, url) => SizedBox(
                height: 20,
                width: 20,
                child: const CircularProgressIndicator().p16),
            errorWidget: (context, url, error) => SizedBox(
                height: size,
                width: size,
                child: Icon(
                  Icons.error,
                  size: size / 2,
                )),
          ).borderWithRadius(
            value: 0, radius: size / 2, color: Colors.transparent)
        : SizedBox(
            height: size,
            width: size,
            child: Center(
              child: Text(
                user.getInitials,
                style: TextStyle(
                    fontSize:
                        user.getInitials.length == 1 ? (size / 2) : (size / 3),
                    fontWeight: FontWeight.w600),
              ),
            ),
          ).borderWithRadius(
            value: 0, radius: size / 2, color: Colors.transparent);
  }
}
