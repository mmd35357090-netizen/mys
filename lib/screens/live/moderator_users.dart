import 'package:foap/controllers/profile/profile_controller.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/live_imports.dart';

import 'moderator_detail_popup.dart';

class ModeratorUsers extends StatefulWidget {
  const ModeratorUsers({Key? key}) : super(key: key);

  @override
  State<ModeratorUsers> createState() => _ModeratorUsersState();
}

class _ModeratorUsersState extends State<ModeratorUsers> {
  final AgoraLiveController _agoraLiveController = Get.find();
  final ProfileController _profileController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView.separated(
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        itemBuilder: (ctx, index) {
          UserModel user = _agoraLiveController.moderatorUsers[index].user;
          return UserAvatarView(
            user: user,
            size: 25,
          ).ripple(() {
            _profileController.getOtherUserDetail(userId: user.id);
            showModalBottomSheet<void>(
                backgroundColor: Colors.transparent,
                context: context,
                isScrollControlled: true,
                builder: (context) {
                  return FractionallySizedBox(
                      heightFactor: 1, child: ModeratorDetail());
                }).then((value) {
              _profileController.clear();
            });
          });
        },
        separatorBuilder: (ctx, index) {
          return const SizedBox(
            width: 5,
          );
        },
        itemCount: _agoraLiveController.moderatorUsers.length));
  }

  void openActionSheetForUser(UserModel user) {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return FractionallySizedBox(
              heightFactor: 0.6,
              child: Container(
                color: AppColorConstants.cardColor,
                width: Get.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                            height: 55,
                            width: double.infinity,
                            child: BodyLargeText(viewProfileString.tr))
                        .ripple(() {}),
                    SizedBox(
                        height: 55,
                        width: double.infinity,
                        child: BodyLargeText(removeFromModeratorString.tr)
                            .ripple(() {
                          removeAsModerator(user);
                        })),
                  ],
                ).p(DesignConstants.horizontalPadding),
              ).topRounded(40));
        });
  }

  removeAsModerator(UserModel user) {
    Get.back();
    _agoraLiveController.removeAsModerator(user);
  }
}
