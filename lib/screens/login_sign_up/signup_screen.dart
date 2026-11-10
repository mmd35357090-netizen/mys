import 'package:flutter/gestures.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/login_signup_imports.dart';
import '../../controllers/profile/profile_controller.dart';
import '../settings_menu/settings_controller.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  TextEditingController userName = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  SettingsController settingsController = Get.find();
  final ProfileController profileController = Get.find();

  String countryCode = '+1';
  final LoginController loginController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            SizedBox(height: Get.height * 0.07),
            const Align(
              alignment: Alignment.centerLeft,
              child: AppThemeBackButton(),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                height: 76,
                width: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColorConstants.themeColor,
                      AppColorConstants.themeColor.withValues(alpha: 0.7)
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                        color:
                            AppColorConstants.themeColor.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6))
                  ],
                ),
                child: const Icon(Icons.person_add_alt_1_rounded,
                    color: Colors.white, size: 36),
              ),
            ),
            const SizedBox(height: 22),
            Heading3Text(createAnAccountString.tr,
                weight: TextWeight.bold, textAlign: TextAlign.center),
            const SizedBox(height: 26),
            Stack(
              children: [
                AppTextField(
                  icon: ThemeIcon.account,
                  hintText: userNameString.tr,
                  controller: userName,
                  onChanged: (value) {
                    if (value.length > 3) {
                      profileController.verifyUsername(userName: value);
                    }
                  },
                ),
                Positioned(
                  right: DesignConstants.horizontalPadding,
                  bottom: 0,
                  top: 0,
                  child: Center(
                    child: Obx(
                        () => profileController.userNameCheckStatus.value == 1
                            ? ThemeIconWidget(
                                ThemeIcon.checkMark,
                                color: AppColorConstants.themeColor,
                              )
                            : profileController.userNameCheckStatus.value == 0
                                ? ThemeIconWidget(
                                    ThemeIcon.close,
                                    color: AppColorConstants.red,
                                  )
                                : Container()),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: Get.height * 0.015,
            ),
            AppTextField(
              icon: ThemeIcon.email,
              controller: email,
              hintText: emailString,
            ),
            SizedBox(
              height: Get.height * 0.015,
            ),
            AppPasswordTextField(
              controller: password,
              hintText: passwordString.tr,
              icon: ThemeIcon.lock,
              onChanged: (value) {
                loginController.checkPassword(value);
              },
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
                          borderRadius: BorderRadius.circular(6),
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
              height: Get.height * 0.015,
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                      text: signingInTermsString.tr,
                      style: TextStyle(
                          fontSize: FontSizes.b3,
                          color: AppColorConstants.mainTextColor)),
                  TextSpan(
                      text: ' ${termsOfServiceString.tr}',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          loginController.launchUrlInBrowser(settingsController
                              .setting.value!.termsOfServiceUrl!);
                        },
                      style: TextStyle(
                          fontSize: FontSizes.b3,
                          color: AppColorConstants.themeColor)),
                  TextSpan(
                      text: ' ${andString.tr}',
                      style: TextStyle(
                          fontSize: FontSizes.b3,
                          color: AppColorConstants.mainTextColor)),
                  TextSpan(
                      text: ' ${privacyPolicyString.tr}',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          loginController.launchUrlInBrowser(settingsController
                              .setting.value!.privacyPolicyUrl!);
                        },
                      style: TextStyle(
                          fontSize: FontSizes.b3,
                          color: AppColorConstants.themeColor)),
                ],
              ),
            ),
            SizedBox(
              height: Get.height * 0.015,
            ),
            addSignUpBtn(),
            SizedBox(
              height: Get.height * 0.02,
            ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              children: [
                BodyMediumText(alreadyHaveAccString,
                    color: AppColorConstants.subHeadingTextColor),
                BodyMediumText(
                  signInString,
                  weight: TextWeight.bold,
                  color: AppColorConstants.themeColor,
                ),
              ],
            ).ripple(() {
              Get.to(() => const LoginScreen());
            }),
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(child: divider(height: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: BodySmallText(continueWithAccountsString,
                      color: AppColorConstants.subHeadingTextColor),
                ),
                Expanded(child: divider(height: 1)),
              ],
            ),
            const SizedBox(height: 22),
            const SocialLogin(
              hidePhoneLogin: false,
            ),
            SizedBox(
              height: Get.height * 0.08,
            ),
          ]),
        ).setPadding(left: 25, right: 25),
      ),
    );
  }

  addSignUpBtn() {
    return AppThemeButton(
      onPress: () {
        FocusScope.of(context).requestFocus(FocusNode());
        loginController.register(
          userName: userName.text,
          email: email.text,
          password: password.text,
        );
      },
      text: signUpString.tr,
    );
  }
}
