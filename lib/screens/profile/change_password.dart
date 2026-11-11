import 'package:foap/util/biometric_helper.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../controllers/profile/profile_controller.dart';
import '../../universal_components/rounded_input_field.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  ChangePasswordState createState() => ChangePasswordState();
}

class ChangePasswordState extends State<ChangePassword> {
  TextEditingController oldPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  final ProfileController profileController = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(
            height: 55,
          ),
          profileScreensNavigationBar(

              title: changePwdString.tr,
              rightBtnTitle: doneString.tr,
              completion: () async {
                if (!await BiometricHelper.confirmIfEnabled(
                    changePwdString.tr)) {
                  return;
                }
                profileController.resetPassword(
                    oldPassword: oldPassword.text,
                    newPassword: newPassword.text,
                    confirmPassword: confirmPassword.text,
                   );
              }),
          const SizedBox(
            height: 20,
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColorConstants.cardColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                  color: AppColorConstants.dividerColor.withValues(alpha: 0.5),
                  width: 0.6),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 5))
              ],
            ),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodyMediumText(oldPwdStrString.tr, color: AppColorConstants.subHeadingTextColor, weight: TextWeight.semiBold),
              addTextField(oldPassword, 'old_password').tP8,
              BodyMediumText(newPwdStrString.tr, color: AppColorConstants.subHeadingTextColor, weight: TextWeight.semiBold),
              addTextField(newPassword, 'new_password').tP8,
              BodyMediumText(confirmPwdStrString.tr, color: AppColorConstants.subHeadingTextColor, weight: TextWeight.semiBold)
                  .vP8,
              addTextField(confirmPassword, 'confirm_password'),
            ],
          )).hp(DesignConstants.horizontalPadding)
        ]),
      ),
    );
  }

  Widget addTextField(TextEditingController controller, String hint) {
    return SizedBox(
      height: 50,
      child: PasswordField(
        onChanged: (value) {},
        controller: controller,
        showRevealPasswordIcon: true,
        showDivider: true,
        hintText: '********',
      ),
    ).vP8;
  }
}
