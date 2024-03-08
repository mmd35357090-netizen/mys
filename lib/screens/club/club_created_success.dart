import 'package:lottie/lottie.dart';
import '../../../controllers/post/add_post_controller.dart';
import '../../../helper/imports/common_import.dart';
import 'invite_users_to_club.dart';

class ClubCreatedSuccess extends StatelessWidget {
  final int clubId;
  final AddPostController addPostController = Get.find();

  ClubCreatedSuccess({super.key, required this.clubId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/lottie/success.json'),
          const SizedBox(
            height: 40,
          ),
          BodyLargeText(clubCreatedSuccessfullyString.tr),
          const SizedBox(
            height: 40,
          ),
          AppThemeButton(
              text: shareToFeedString.tr,
              onPress: () {
                addPostController.shareToFeed(
                    productId: clubId, contentType: PostContentType.club);
                Get.close(4);
                AppUtil.showToast(message: postedString.tr, isSuccess: true);
              }),
          const SizedBox(
            height: 20,
          ),
          AppThemeBorderButton(
              text: addMoreClubsString.tr,
              onPress: () {
                Get.close(3);
              }),
          const SizedBox(
            height: 10,
          ),
          BodyLargeText(
            inviteFriendString,
            weight: TextWeight.semiBold,
          ).ripple(() {
            Get.to(() => InviteUsersToClub(clubId: clubId));
          })
        ],
      ).hp(DesignConstants.horizontalPadding),
    );
  }
}
