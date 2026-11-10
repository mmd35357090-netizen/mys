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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: Get.height * 0.08),
                if (widget.showCloseBtn == true)
                  const Align(
                    alignment: Alignment.centerRight,
                    child: AppThemeCloseButton(),
                  ),
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
                            color: AppColorConstants.themeColor
                                .withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6))
                      ],
                    ),
                    child: const Icon(Icons.person_rounded,
                        color: Colors.white, size: 38),
                  ),
                ),
                const SizedBox(height: 22),
                Heading3Text(signInMessageString.tr,
                    weight: TextWeight.bold, textAlign: TextAlign.center),
                const SizedBox(height: 28),
                AppTextField(
                  controller: email,
                  hintText: emailOrUsernameString.tr,
                  icon: ThemeIcon.email,
                ),
                const SizedBox(height: 12),
                AppPasswordTextField(
                  controller: password,
                  hintText: passwordString.tr,
                  icon: ThemeIcon.lock,
                  onChanged: (value) {},
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: BodySmallText(
                    forgotPwdString.tr,
                    weight: TextWeight.semiBold,
                    color: AppColorConstants.themeColor,
                  ).ripple(() {
                    Get.to(() => const ForgotPasswordScreen());
                  }),
                ),
                const SizedBox(height: 18),
                addLoginBtn(),
                const SizedBox(height: 18),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 4,
                  children: [
                    BodyMediumText(dontHaveAccountString,
                        color: AppColorConstants.subHeadingTextColor),
                    BodyMediumText(
                      createAnAccountString,
                      weight: TextWeight.bold,
                      color: AppColorConstants.themeColor,
                    ),
                  ],
                ).ripple(() {
                  Get.to(() => const SignUpScreen());
                }),
                const SizedBox(height: 28),
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
                const SocialLogin(hidePhoneLogin: false),
                SizedBox(height: Get.height * 0.05),
              ]),
        ).setPadding(left: 24, right: 24),
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
