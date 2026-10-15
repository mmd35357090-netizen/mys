import 'package:foap/helper/imports/common_import.dart';

import '../login_sign_up/login_screen.dart';

class PasswordChangedPopup extends StatelessWidget {
  final VoidCallback dismissHandler;

  const PasswordChangedPopup({super.key, required this.dismissHandler});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height,
      width: Get.width,
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
              height: 400,
              color: AppColorConstants.backgroundColor,
              child: Column(
                children: [
                  Heading5Text(successString.tr, weight: TextWeight.bold)
                      .bp(20),
                  SizedBox(
                    height: 92,
                    width: 92,
                    child: Container(
                      color: AppColorConstants.themeColor.withValues(alpha: 0.5),
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
                              AppColorConstants.disabledColor.withValues(alpha: 0.1))
                      .vP25,
                  Heading5Text(
                    passwordChangedString.tr,
                    textAlign: TextAlign.center,
                    color: AppColorConstants.backgroundColor,
                  ).ripple(() {}).bp(10),
                  AppThemeButton(
                    text: signInString.tr,
                    onPress: () {
                      // _userProfileManager.logout();
                      Get.offAll(() => const LoginScreen());
                    },
                  ).hp(DesignConstants.horizontalPadding)
                ],
              ).setPadding(top: 40).hp(DesignConstants.horizontalPadding),
            ).topRounded(40),
          ),
        ],
      ),
    );
  }
}
