import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/live_imports.dart';
import '../../components/user_card.dart';

class BannedUsers extends StatefulWidget {
  const BannedUsers({Key? key}) : super(key: key);

  @override
  State<BannedUsers> createState() => _BannedUsersState();
}

class _BannedUsersState extends State<BannedUsers> {
  final AgoraLiveController agoraLiveController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorConstants.cardColor,
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Heading6Text(bannedUsersString.tr, weight: TextWeight.bold),
          const SizedBox(
            height: 20,
          ),
          divider(),
          Expanded(
            child: Obx(() => agoraLiveController.bannedUsers.isEmpty
                ? emptyUser(title: noUserFoundString, subTitle: '')
                : ListView.separated(
                    padding: const EdgeInsets.only(top: 20),
                    itemBuilder: (ctx, index) {
                      UserModel user =
                          agoraLiveController.bannedUsers[index].user;
                      return UserTile(
                        profile: user,
                        viewCallback: () {
                          if (!user.isMe) {
                            openActionSheetForUser(user);
                          }
                        },
                      );
                    },
                    separatorBuilder: (ctx, index) {
                      return const SizedBox(
                        height: 20,
                      );
                    },
                    itemCount: agoraLiveController.bannedUsers.length)),
          ),
        ],
      ).hp(DesignConstants.horizontalPadding),
    ).topRounded(40);
  }

  void openActionSheetForUser(UserModel user) {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return FractionallySizedBox(
              heightFactor: 0.4,
              child: Container(
                color: AppColorConstants.cardColor,
                width: Get.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                            height: 55,
                            width: double.infinity,
                            child: BodyLargeText('Remove Ban'))
                        .ripple(() {
                      print('Remove Ban');
                      unbanUser(user);
                    }),
                    Container(
                            height: 55,
                            width: double.infinity,
                            child: BodyLargeText(cancelString.tr))
                        .ripple(() {
                      Get.back();
                    }),
                  ],
                ).p(DesignConstants.horizontalPadding),
              ).topRounded(40));
        });
  }

  unbanUser(UserModel user) {
    Get.back();
    agoraLiveController.unbanUser(user);
  }
}
