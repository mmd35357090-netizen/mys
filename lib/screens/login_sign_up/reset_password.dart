import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/imports/login_signup_imports.dart';
import '../../universal_components/rounded_input_field.dart';
import '../profile/password_changed_popup.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;

  const ResetPasswordScreen({super.key, required this.token});

  @override
  ResetPasswordScreenState createState() => ResetPasswordScreenState();
}

class ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final UserProfileManager _userProfileManager = Get.find();

  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  late String token;

  final LoginController controller = Get.find();

  @override
  void initState() {
    super.initState();
    token = widget.token;
  }

  @override
  void dispose() {
    controller.passwordReset = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Stack(
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 90),
              Center(
                child: Container(
                  height: 84,
                  width: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColorConstants.themeColor.withValues(alpha: 0.12),
                  ),
                  child: Icon(Icons.password_rounded,
                      size: 40, color: AppColorConstants.themeColor),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Heading3Text(resetPwdString.tr,
                    weight: TextWeight.bold),
              ),
              const SizedBox(height: 30),
              addTextField(newPassword, newPasswordString.tr),
              addTextField(confirmPassword, confirmPasswordString.tr).tP16,
              const Spacer(),
              addSubmitBtn(),
              const SizedBox(
                height: 55,
              )
            ]).setPadding(left: 25, right: 25),
            GetBuilder<LoginController>(
                init: controller,
                builder: (ctx) {
                  return controller.passwordReset == true
                      ? Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: PasswordChangedPopup(dismissHandler: () {
                            controller.passwordReset = false;
                            _userProfileManager.logout();
                          }))
                      : Container();
                })
          ],
        ),
      ),
    );
  }

  Widget addTextField(TextEditingController controller, String hint) {
    return PasswordField(
      onChanged: (value) {},
      controller: controller,
      showRevealPasswordIcon: true,
      hintText: hint,
      backgroundColor: AppColorConstants.cardColor.darken(0.02),
      cornerRadius: 14,
      showBorder: true,
      borderColor: AppColorConstants.dividerColor.withValues(alpha: 0.7),
    );
  }

  addSubmitBtn() {
    return AppThemeButton(
      onPress: () {
        controller.resetPassword(
          newPassword: newPassword.text.trim(),
          confirmPassword: confirmPassword.text.trim(),
          token: token,
        );
      },
      text: changePwdString.tr,
    );
  }
}
