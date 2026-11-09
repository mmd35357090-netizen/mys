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

  Widget _stat(String value, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Heading4Text(value, weight: TextWeight.bold),
              const SizedBox(height: 4),
              BodySmallText(
                label,
                color: AppColorConstants.subHeadingTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 30,
        color: AppColorConstants.dividerColor.withValues(alpha: 0.7),
      );

  Widget statsView() {
    return Container(
      decoration: BoxDecoration(
        color: AppColorConstants.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColorConstants.dividerColor.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          _stat(user.totalPost.toString(), postsString.tr, () {
            if (user.totalPost > 0) {
              Get.to(() => Posts(userId: user.id, title: user.userName));
            }
          }),
          _divider(),
          _stat('${user.totalFollower}', followersString.tr, () {
            if (user.totalFollower > 0) {
              Get.to(() => FollowerFollowingList(
                  isFollowersList: true, userId: user.id));
            }
          }),
          _divider(),
          _stat('${user.totalFollowing}', followingString.tr, () {
            if (user.totalFollowing > 0) {
              Get.to(() => FollowerFollowingList(
                  isFollowersList: false, userId: user.id));
            }
          }),
        ],
      ),
    );
  }
}
