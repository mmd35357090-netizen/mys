import 'package:foap/components/otp_fields/otp_field1.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../controllers/auth/login_controller.dart';

class VerifyOTPForForgotPassword extends StatefulWidget {
  final bool isFromForgotPassword;
  final String token;

  const VerifyOTPForForgotPassword(
      {super.key,
        required this.token,
        required this.isFromForgotPassword});

  @override
  VerifyOTPForForgotPasswordState createState() =>
      VerifyOTPForForgotPasswordState();
}

class VerifyOTPForForgotPasswordState
    extends State<VerifyOTPForForgotPassword> {
  final LoginController loginController = Get.find();
  String filledOTP = '';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 55,
              ),
              // Center(
              //     child: Image.asset(
              //   'assets/logo.png',
              //   width: 80,
              //   height: 25,
              // )),
              const SizedBox(
                height: 50,
              ),
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
              Heading4Text(
                otpVerificationString.tr,
                weight: TextWeight.bold,
                textAlign: TextAlign.center,
              ),
              BodyMediumText(
                pleaseEnterOneTimePasswordPhoneNumberChangeString.tr,
                textAlign: TextAlign.center,
                color: AppColorConstants.subHeadingTextColor,
              ).setPadding(top: 10, bottom: 28),
              SizedBox(
                height: 70,
                child: OTPFieldView(
                  length: loginController.pinLength,
                  defaultPinTheme: PinTheme(
                            height: 56,
                            width: 50,
                            decoration: BoxDecoration(
                              color: AppColorConstants.cardColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: AppColorConstants.dividerColor
                                      .withValues(alpha: 0.8)),
                            ),
                      textStyle: TextStyle(
                          fontSize: FontSizes.h4,
                          fontWeight: TextWeight.medium)),
                  onSubmitted: (String pin) {
                    filledOTP = pin;
                    loginController.otpCompleted();
                  },
                  onChanged: (String pin) {
                    loginController.otpTextFilled(pin);
                  },
                ),
              ),
              Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                  BodyLargeText(
                    didntReceivedCodeString.tr,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  BodyLargeText(
                    resendOTPString.tr,
                    weight: TextWeight.bold,
                    color: loginController.canResendOTP.value == false
                        ? AppColorConstants.disabledColor
                        : AppColorConstants.themeColor,
                  ).ripple(() {
                    if (loginController.canResendOTP.value == true) {
                      loginController.resendOTP(token: widget.token);
                    }
                  }),
                  loginController.canResendOTP.value == false
                      ? TweenAnimationBuilder<Duration>(
                      duration: const Duration(minutes: 2),
                      tween: Tween(
                          begin: const Duration(minutes: 2),
                          end: Duration.zero),
                      onEnd: () {
                        loginController.canResendOTP.value = true;
                        setState(() {});
                      },
                      builder: (BuildContext context,
                          Duration value, Widget? child) {
                        final minutes = value.inMinutes;
                        final seconds = value.inSeconds % 60;
                        return BodyLargeText(
                            ' ($minutes:$seconds)',
                            textAlign: TextAlign.center,
                            color: AppColorConstants.themeColor);
                      })
                      : Container()
                ],
              )).setPadding(top: 20, bottom: 25),
              const Spacer(),
              Obx(() => loginController.otpFilled.value == true
                  ? addSubmitBtn()
                  : Container()),
              const SizedBox(
                height: 55,
              )
            ]),
      ).setPadding(left: 25, right: 25),
    );
  }

  addSubmitBtn() {
    return AppThemeButton(
      onPress: () {
        if (loginController.otpFilled.value == true) {
          loginController.callForgotPwdVerifyOTP(
            otp: filledOTP,
            token: widget.token,
          );
        }
      },
      text: verifyString.tr,
    );
  }
}
