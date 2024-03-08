import 'package:foap/helper/imports/live_imports.dart';
import '../../helper/imports/common_import.dart';

class LiveEndScreen extends StatelessWidget {
  final LiveModel live;

  const LiveEndScreen({super.key, required this.live});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: liveEndWidgetForViewers(),
    );
  }

  Widget liveEndWidgetForViewers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          height: 50,
        ),
        Row(
          children: [
            ThemeIconWidget(
              ThemeIcon.close,
              size: 25,
              // color: Colors.white,
            ).ripple(() {
              Get.back();
            }),
            const Spacer()
          ],
        ),
        hostUserInfo(),
      ],
    ).hP25;
  }

  Widget hostUserInfo() {
    UserModel mainHostDetail = live.mainHostUserDetail!;
    return Column(
      children: [
        const SizedBox(
          height: 150,
        ),
        UserAvatarView(
          user: mainHostDetail,
          hideLiveIndicator: true,
          hideOnlineIndicator: true,
          size: 100,
        ),
        const SizedBox(
          height: 10,
        ),
        Heading4Text(
          mainHostDetail.userName,
          weight: TextWeight.bold,
          color: AppColorConstants.mainTextColor,
        ),
        const SizedBox(
          height: 20,
        ),
        Heading6Text(liveEndString.tr, weight: TextWeight.medium),
      ],
    );
  }
}
