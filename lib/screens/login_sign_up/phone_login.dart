import 'package:foap/helper/imports/common_import.dart';
import 'package:get/get.dart';
import 'package:foap/helper/imports/login_signup_imports.dart';
import '../../universal_components/rounded_input_field.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({Key? key}) : super(key: key);

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
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: SingleChildScrollView(
        child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.08,
                    ),
                    Heading3Text(LocalizationString.welcome,
                        weight: TextWeight.bold),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    Heading3Text(LocalizationString.signInMessage,
                        weight: TextWeight.medium),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                    ),
                    Obx(() => InputMobileNumberField(
                          controller: phone,
                          showDivider: true,
                          hintText: LocalizationString.phoneNumber,
                          cornerRadius: 5,
                          phoneCodeText: controller.phoneCountryCode.value,
                          onChanged: (String value) {},
                          phoneCodeValueChanged: (String value) {
                            controller.phoneCodeSelected(value);
                          },
                        )),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04,
                    ),
                    addLoginBtn(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    InkWell(
                      onTap: () {
                        Get.to(() => const ForgotPasswordScreen());
                      },
                      child: Center(
                        child: BodyMediumText(
                          LocalizationString.forgotPwd,
                          weight: TextWeight.bold,
                          color: AppColorConstants.themeColor,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 1,
                          width: MediaQuery.of(context).size.width * 0.37,
                          color: AppColorConstants.themeColor,
                        ),
                        Heading6Text(
                          LocalizationString.or,
                        ),
                        Container(
                          height: 1,
                          width: MediaQuery.of(context).size.width * 0.37,
                          color: AppColorConstants.themeColor,
                        )
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04,
                    ),
                    const SocialLogin(
                      hidePhoneLogin: true,
                    ).setPadding(left: 65, right: 65),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Heading6Text(
                          LocalizationString.dontHaveAccount,
                        ),
                        Heading6Text(
                          LocalizationString.signUp,
                          weight: TextWeight.medium,
                          color: AppColorConstants.themeColor,
                        ).ripple(() {
                          Get.to(() => const SignUpScreen());
                        }),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    // bioMetricView(),
                    // const Spacer(),
                  ]),
            )).setPadding(left: 25, right: 25),
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
      text: LocalizationString.signIn,
    );
  }
}
