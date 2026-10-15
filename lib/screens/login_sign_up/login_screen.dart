import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/login_signup_imports.dart';
import '../../main.dart';

class LoginScreen extends StatefulWidget {
  final bool? showCloseBtn;

  const LoginScreen({super.key, this.showCloseBtn = false});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  final LoginController controller = Get.find();

  bool showPassword = false;

  @override
  void initState() {
    isAnyPageInStack = false;
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
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: Get.height * 0.1,
                ),
                if (widget.showCloseBtn == true)
                  const Align(
                    alignment: Alignment.centerRight,
                    child: AppThemeCloseButton(),
                  ),
                SizedBox(
                    height: Get.height * 0.12,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Heading3Text(signInMessageString.tr,
                                weight: TextWeight.bold)
                            .rp(100),
                      ],
                    )),
                SizedBox(
                  height: Get.height * 0.05,
                ),
                AppTextField(
                  controller: email,
                  hintText: emailOrUsernameString.tr,
                  icon: ThemeIcon.email,
                ),
                SizedBox(
                  height: Get.height * 0.015,
                ),
                AppPasswordTextField(
                  controller: password,
                  hintText: passwordString.tr,
                  icon: ThemeIcon.lock,
                  onChanged: (value) {},
                ),
                SizedBox(
                  height: Get.height * 0.02,
                ),
                InkWell(
                  onTap: () {
                    Get.to(() => const ForgotPasswordScreen());
                  },
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: BodySmallText(
                      forgotPwdString.tr,
                      weight: TextWeight.semiBold,
                    ),
                  ),
                ),
                SizedBox(
                  height: Get.height * 0.015,
                ),
                addLoginBtn(),
                SizedBox(
                  height: Get.height * 0.02,
                ),
                Wrap(
                  spacing: 2,
                  children: [
                    BodySmallText(dontHaveAccountString),
                    BodySmallText(
                      createAnAccountString,
                      weight: TextWeight.bold,
                    ),
                  ],
                ).ripple(() {
                  Get.to(() => const SignUpScreen());
                }),
                divider(height: 1).vp(40),
                BodyMediumText(continueWithAccountsString),
                SizedBox(
                  height: Get.height * 0.04,
                ),
                const SocialLogin(hidePhoneLogin: false)
                    .setPadding(left: 65, right: 65),

                SizedBox(
                  height: Get.height * 0.05,
                ),
                // bioMetricView(),
                // const Spacer(),
              ]),
        ).setPadding(left: 25, right: 25),
      ),
    );
  }

  Widget addLoginBtn() {
    return AppThemeButton(
      onPress: () {
        controller.login(email.text.trim(), password.text.trim());
      },
      text: signInString.tr,
    );
  }
}
