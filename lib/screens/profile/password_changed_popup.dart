import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';

class PasswordChangedPopup extends StatelessWidget {
  final UserProfileManager _userProfileManager = Get.find();

  final VoidCallback dismissHandler;

  PasswordChangedPopup({Key? key, required this.dismissHandler})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          Container(
            color: AppColorConstants.disabledColor,
          ).ripple(() {
            dismissHandler();
          }),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 360,
              color: AppColorConstants.backgroundColor,
              child: Column(
                children: [
                  Heading5Text('Password changed successfully!',
                          weight: TextWeight.bold)
                      .bp(20),
                  SizedBox(
                    height: 92,
                    width: 92,
                    child: Container(
                      color: AppColorConstants.themeColor.withOpacity(0.5),
                      height: 92,
                      width: 92,
                      child: ThemeIconWidget(ThemeIcon.checkMark,
                          size: 45, color: AppColorConstants.themeColor),
                    ).circular.p(10),
                  )
                      .borderWithRadius(
                          value: 1,
                          radius: 46,
                          color:
                              AppColorConstants.disabledColor.withOpacity(0.1))
                      .vP25,
                  Heading5Text(
                    'Your password has been changed successfully',
                    textAlign: TextAlign.center,
                    color: AppColorConstants.backgroundColor,
                  ).ripple(() {}).bp(10),
                  AppThemeButton(
                    text: 'Back to login',
                    onPress: () {
                      _userProfileManager.logout();
                    },
                  ).hP16
                ],
              ).setPadding(top: 40).hP16,
            ).topRounded(40),
          ),
        ],
      ),
    );
  }
}
