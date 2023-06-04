import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';

import 'add_name.dart';

class AllowNotification extends StatefulWidget {
  final bool isSettingProfile;

  const AllowNotification({Key? key, required this.isSettingProfile})
      : super(key: key);

  @override
  State<AllowNotification> createState() => _AllowNotificationState();
}

class _AllowNotificationState extends State<AllowNotification> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 60,
            width: 60,
            color: AppColorConstants.themeColor,
            child: ThemeIconWidget(ThemeIcon.notification,
                color: AppColorConstants.backgroundColor),
          ).round(30),
          Heading3Text(
            allowNotiifcationString.tr,
          ).setPadding(top: 40),
          Heading5Text(
            weWillLetYouKnowString.tr,
          ).setPadding(top: 20),
          Center(
            child: SizedBox(
                height: 50,
                width: MediaQuery.of(context).size.width - 50,
                child: AppThemeButton(
                    cornerRadius: 25,
                    text: allowNotificationString.tr,
                    onPress: () {
                      Get.to(() => AddName(isSettingProfile: widget.isSettingProfile));
                    })),
          ).setPadding(top: 150),
          Center(
            child: SizedBox(
                height: 50,
                width: MediaQuery.of(context).size.width - 50,
                child: AppThemeButton(
                    cornerRadius: 25,
                    text: notNowString.tr,
                    onPress: () {
                      Get.to(() => AddName(isSettingProfile: widget.isSettingProfile));
                    })),
          ).setPadding(top: 20),
        ],
      ).hP25,
    );
  }
}
