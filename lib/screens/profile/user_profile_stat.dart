import '../../helper/imports/common_import.dart';
import '../dashboard/posts.dart';
import 'follower_following_list.dart';

class UserProfileStatistics extends StatelessWidget {
  final UserModel user;

  const UserProfileStatistics({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return statsView();
  }

  Widget statsView() {
    return Container(
      color: AppColorConstants.cardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Heading4Text(
                user.totalPost.toString(),
              ).bP8,
              BodySmallText(
                postsString.tr,
              ),
            ],
          ).ripple(() {
            if (user.totalPost > 0) {
              Get.to(() => Posts(
                    userId: user.id,
                  ));
            }
          }),
          // const SizedBox(
          //   width: 20,
          // ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Heading4Text(
                '${user.totalFollower}',
              ).bP8,
              BodySmallText(
                followersString.tr,
              ),
            ],
          ).ripple(() {
            if (user.totalFollower > 0) {
              Get.to(() => FollowerFollowingList(
                        isFollowersList: true,
                        userId: user.id,
                      ))!
                  .then((value) {
                // initialLoad();
              });
            }
          }),

          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Heading4Text(
                '${user.totalFollowing}',
              ).bP8,
              BodySmallText(
                followingString.tr,
              ),
            ],
          ).ripple(() {
            if (user.totalFollowing > 0) {
              Get.to(() => FollowerFollowingList(
                        isFollowersList: false,
                        userId: user.id,
                      ))!
                  .then((value) {
                // initialLoad();
              });
            }
          }),
        ],
      ).p16,
    ).round(15);
  }
}
