import 'package:foap/controllers/chat_and_call/chat_detail_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/add_on/controller/dating/dating_controller.dart';
import 'package:foap/screens/chat/chat_detail.dart';
import 'package:foap/screens/profile/other_user_profile.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';


class LikeList extends StatefulWidget {
  const LikeList({Key? key}) : super(key: key);

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
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(
            title: likedByString.tr,
          ),
          divider().tP8,
          Expanded(
              child: GetBuilder<DatingController>(
                  init: datingController,
                  builder: (ctx) {
                    return datingController.isLoading.value
                        ? const ShimmerLikeList()
                        : datingController.likeUsers.isEmpty
                            ? emptyData(
                                title: noLikeProfilesFoundString.tr,
                                subTitle: noLikeProfilesString.tr,
                              )
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.only(top: 15, bottom: 15),
                                shrinkWrap: true,
                                itemCount: datingController.likeUsers.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return matchedTile(index);
                                });
                  })),
        ],
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
            color: AppColorConstants.cardColor,
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
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 200,
                      child: Column(
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
                      ).hP16,
                    ),
                    // const Spacer(),
                  ],
                ).ripple(() {
                  Get.to(() => OtherUserProfile(userId: profile.id));
                }),
                const Spacer(),
                AppThemeBorderButton(
                    height: 30,
                    borderColor: AppColorConstants.themeColor,
                    text: likeBackString.tr,
                    textStyle: TextStyle(
                        fontSize: FontSizes.h6,
                        fontWeight: TextWeight.medium,
                        color: AppColorConstants.themeColor),
                    onPress: () {
                      datingController.likeUnlikeProfile(
                          DatingActions.liked, profile.id.toString());
                      EasyLoading.show(status: loadingString.tr);
                      _chatDetailController.getChatRoomWithUser(
                          userId: profile.id,
                          callback: (room) {
                            EasyLoading.dismiss();
                            Get.to(() => ChatDetail(
                                  chatRoom: room,
                                ));
                            setState(() {
                              datingController.likeUsers.removeAt(index);
                            });
                          });
                    })
              ],
            ).paddingSymmetric(horizontal: 15, vertical: 20))
        .round(10)
        .setPadding(bottom: 15, left: 15, right: 15);
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
            value: 1,
            radius: size / 3,
            color: AppColorConstants.themeColor)
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
            value: 1,
            radius: size / 3,
            color: AppColorConstants.themeColor);
  }
}
