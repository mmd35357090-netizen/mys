import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/login_signup_imports.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ForgotPasswordState createState() => ForgotPasswordState();
}

class ForgotPasswordState extends State<ForgotPasswordScreen> {
  TextEditingController email = TextEditingController();
  final LoginController loginController = Get.find();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        backgroundColor: AppColorConstants.backgroundColor,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Get.height * 0.07),
              const Align(
                alignment: Alignment.centerLeft,
                child: AppThemeBackButton(),
              ),
              SizedBox(height: Get.height * 0.04),
              Center(
                child: Container(
                  height: 84,
                  width: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColorConstants.themeColor.withValues(alpha: 0.12),
                  ),
                  child: Icon(Icons.lock_reset_rounded,
                      size: 40, color: AppColorConstants.themeColor),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Heading3Text(forgotPwdString.tr,
                    weight: TextWeight.bold),
              ),
              const SizedBox(height: 8),
              Center(
                child: BodyMediumText(
                  helpToGetAccountString.tr,
                  textAlign: TextAlign.center,
                  color: AppColorConstants.subHeadingTextColor,
                ),
              ),
              const SizedBox(height: 28),
              AppTextField(
                controller: email,
                hintText: enterEmailString.tr,
                icon: ThemeIcon.email,
              ),
              const SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: BodySmallText(
                  loginAnotherAccountString.tr,
                  weight: TextWeight.bold,
                  textAlign: TextAlign.start,
                  color: AppColorConstants.themeColor,
                ).ripple(() {
                  Get.back();
                }),
              ),
              const Spacer(),
              addSubmitBtn(),
              const SizedBox(
                height: 55,
              )
            ],
          ).hp(DesignConstants.horizontalPadding),
        ));
  }

  addSubmitBtn() {
    return AppThemeButton(
      onPress: () {
        loginController.forgotPassword(email: email.text);
      },
      text: sendOTPString.tr,
    ).setPadding(top: 25);
  }
}
