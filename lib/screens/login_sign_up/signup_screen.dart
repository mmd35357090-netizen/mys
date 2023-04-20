import 'package:flutter/gestures.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/login_signup_imports.dart';

import '../../universal_components/rounded_input_field.dart';
import '../../universal_components/rounded_password_field.dart';
import '../settings_menu/settings_controller.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  SettingsController settingsController = Get.find();

  String countryCode = '+1';
  final LoginController loginController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.08,
            ),
            Heading2Text(LocalizationString.hi,
                weight: TextWeight.bold, color: AppColorConstants.themeColor),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Heading2Text(LocalizationString.signUpMessage,
                weight: TextWeight.medium),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            GetBuilder<LoginController>(
                init: loginController,
                builder: (ctx) {
                  return Stack(children: [
                    Container(
                      color: Colors.transparent,
                      height: 50,
                      child: InputField(
                        controller: name,
                        showDivider: true,
                        hintText: LocalizationString.userName,
                        onChanged: (value) {
                          if (value.length > 3) {
                            loginController.verifyUsername(value);
                          }
                        },
                      ),
                    ),
                    Positioned(
                        right: 10,
                        bottom: 15,
                        child: loginController.userNameCheckStatus != -1
                            ? loginController.userNameCheckStatus == 1
                                ? ThemeIconWidget(
                                    ThemeIcon.checkMark,
                                    color: AppColorConstants.themeColor,
                                  )
                                : ThemeIconWidget(
                                    ThemeIcon.close,
                                    color: AppColorConstants.red,
                                  )
                            : Container()),
                    const SizedBox(
                      width: 20,
                    )
                  ]);
                }),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.015,
            ),
            addTextField(email, LocalizationString.email),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.015,
            ),
            PasswordField(
              showDivider: true,
              cornerRadius: 5,
              onChanged: (value) {
                loginController.checkPassword(value);
              },
              controller: password,
              hintText: LocalizationString.password,
              showRevealPasswordIcon: true,
            ),
            Obx(() {
              return loginController.passwordStrength.value < 0.8 &&
                      password.text.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 5,
                        ),
                        LinearProgressIndicator(
                          value: loginController.passwordStrength.value,
                          backgroundColor: Colors.grey[300],
                          color: loginController.passwordStrength.value <= 1 / 4
                              ? Colors.red
                              : loginController.passwordStrength.value == 2 / 4
                                  ? Colors.yellow
                                  : loginController.passwordStrength.value ==
                                          3 / 4
                                      ? Colors.blue
                                      : Colors.green,
                          minHeight: 5,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        BodySmallText(
                          loginController.passwordStrengthText.value,
                        ),
                      ],
                    )
                  : Container();
            }),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.015,
            ),
            PasswordField(
              showDivider: true,
              cornerRadius: 5,
              onChanged: (value) {},
              controller: confirmPassword,
              hintText: LocalizationString.confirmPassword,
              showRevealPasswordIcon: true,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.015,
            ),
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                      text: LocalizationString.signingInTerms,
                      style: TextStyle(fontSize: FontSizes.b3)),
                  TextSpan(
                      text: ' ${LocalizationString.termsOfService}',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          loginController.launchUrlInBrowser(settingsController
                              .setting.value!.termsOfServiceUrl!);
                        },
                      style: TextStyle(
                          fontSize: FontSizes.b3,
                          color: AppColorConstants.themeColor)),
                  TextSpan(
                      text: ' ${LocalizationString.and}',
                      style: TextStyle(fontSize: FontSizes.b3)),
                  TextSpan(
                      text: ' ${LocalizationString.privacyPolicy}',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          loginController.launchUrlInBrowser(settingsController
                              .setting.value!.privacyPolicyUrl!);
                        },
                      style: TextStyle(
                          fontSize: FontSizes.b4,
                          color: AppColorConstants.themeColor)),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
            ),
            addSignUpBtn(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 1,
                  width: MediaQuery.of(context).size.width * 0.35,
                  color: AppColorConstants.themeColor,
                ),
                Heading5Text(
                  LocalizationString.or,
                ),
                Container(
                  height: 1,
                  width: MediaQuery.of(context).size.width * 0.35,
                  color: AppColorConstants.themeColor,
                )
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            const SocialLogin(hidePhoneLogin: false)
                .setPadding(left: 45, right: 45),
            const SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BodyLargeText(
                  LocalizationString.alreadyHaveAcc,
                ),
                BodyLargeText(LocalizationString.signIn,
                        weight: TextWeight.medium,
                        color: AppColorConstants.themeColor)
                    .ripple(() {
                  Get.to(() => const LoginScreen());
                })
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
          ]),
        ).setPadding(left: 25, right: 25),
      ),
    );
  }

  Widget addTextField(TextEditingController controller, String hintText) {
    return InputField(
      controller: controller,
      showDivider: true,
      hintText: hintText,
      cornerRadius: 5,
    );
  }

  addSignUpBtn() {
    return AppThemeButton(
      onPress: () {
        FocusScope.of(context).requestFocus(FocusNode());
        loginController.register(
            name: name.text,
            email: email.text,
            password: password.text,
            confirmPassword: confirmPassword.text,
            context: context);
      },
      text: LocalizationString.signUp,
    );
  }
}
