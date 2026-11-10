import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/login_signup_imports.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  PhoneLoginScreenState createState() => PhoneLoginScreenState();
}

class PhoneLoginScreenState extends State<PhoneLoginScreen> {
  TextEditingController phone = TextEditingController();

  final LoginController controller = Get.find();

  bool showPassword = false;

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
            child: SizedBox(
              height: Get.height,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: Get.height * 0.1),
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
                              AppColorConstants.themeColor
                                  .withValues(alpha: 0.7)
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: AppColorConstants.themeColor
                                    .withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6))
                          ],
                        ),
                        child: const Icon(Icons.phone_iphone_rounded,
                            color: Colors.white, size: 36),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Heading3Text(welcomeString.tr,
                        weight: TextWeight.bold, textAlign: TextAlign.center),
                    const SizedBox(height: 6),
                    BodyMediumText(signInMessageString.tr,
                        textAlign: TextAlign.center,
                        color: AppColorConstants.subHeadingTextColor),
                    const SizedBox(height: 30),
                    Obx(() => AppMobileTextField(
                          controller: phone,
                          hintText: phoneNumberString.tr,
                          countryCodeText:
                              '+${controller.phoneCountryCode.value}',
                          onChanged: (String value) {},
                          countryCodeValueChanged: (String value) {
                            controller.phoneCodeSelected(value);
                          },
                        )),
                    const SizedBox(height: 22),
                    addLoginBtn(),
                    const SizedBox(height: 16),
                    Center(
                      child: BodyMediumText(
                        forgotPwdString.tr,
                        weight: TextWeight.bold,
                        color: AppColorConstants.themeColor,
                      ).ripple(() {
                        Get.to(() => const ForgotPasswordScreen());
                      }),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(child: divider(height: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: BodySmallText(orString.tr,
                              color: AppColorConstants.subHeadingTextColor),
                        ),
                        Expanded(child: divider(height: 1)),
                      ],
                    ),
                    const SizedBox(height: 22),
                    const SocialLogin(
                      hidePhoneLogin: true,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BodyMediumText(dontHaveAccountString.tr,
                            color: AppColorConstants.subHeadingTextColor),
                        const SizedBox(width: 4),
                        BodyMediumText(
                          signUpString.tr,
                          weight: TextWeight.bold,
                          color: AppColorConstants.themeColor,
                        ).ripple(() {
                          Get.to(() => const SignUpScreen());
                        }),
                      ],
                    ),
                    SizedBox(height: Get.height * 0.05),
                  ]),
            )).setPadding(left: 24, right: 24),
      ),
    );
  }

  Widget addLoginBtn() {
    return AppThemeButton(
      onPress: () {
        controller.phoneLogin(
            countryCode: controller.phoneCountryCode.value,
            phone: phone.text.trim());
      },
      text: signInString.tr,
    );
  }
}
