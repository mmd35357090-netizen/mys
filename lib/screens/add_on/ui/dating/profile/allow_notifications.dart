import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';

import 'add_name.dart';


class AllowNotification extends StatefulWidget {
  final bool isFromSignup;

  const AllowNotification({Key? key, required this.isFromSignup})
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
            color: Theme.of(context).cardColor,
            child: ThemeIconWidget(ThemeIcon.notification,
                color: Theme.of(context).primaryColor),
          ).round(30),
          Heading3Text(
            LocalizationString.notificationHeader,
          ).setPadding(top: 40),
          Heading5Text(
            LocalizationString.notificationSubHeader,
          ).setPadding(top: 20),
          Center(
            child: SizedBox(
                height: 50,
                width: MediaQuery.of(context).size.width - 50,
                child: AppThemeButton(
                    cornerRadius: 25,
                    text: LocalizationString.allowNotification,
                    onPress: () {
                      Get.to(() => AddName(isFromSignup: widget.isFromSignup));
                    })),
          ).setPadding(top: 150),
          Center(
            child: SizedBox(
                height: 50,
                width: MediaQuery.of(context).size.width - 50,
                child: AppThemeButton(

                    cornerRadius: 25,
                    text: LocalizationString.notNow,
                    onPress: () {
                      Get.to(() => AddName(isFromSignup: widget.isFromSignup));
                    })),
          ).setPadding(top: 20),
        ],
      ).hP25,
    );
  }
}
