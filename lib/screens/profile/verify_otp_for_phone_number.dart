import 'package:foap/helper/imports/common_import.dart';
import '../../components/otp_fields/otp_field1.dart';
import '../../controllers/auth/login_controller.dart';

class VerifyOTPPhoneNumberChange extends StatefulWidget {
  final String token;

  const VerifyOTPPhoneNumberChange({super.key, required this.token});

  @override
  VerifyOTPPhoneNumberChangeState createState() =>
      VerifyOTPPhoneNumberChangeState();
}

class VerifyOTPPhoneNumberChangeState
    extends State<VerifyOTPPhoneNumberChange> {
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
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ThemeIconWidget(
                    ThemeIcon.backArrow,
                    size: 20,
                  ).ripple(() {
                    Get.back();
                  }),
                  // Image.asset(
                  //   'assets/logo.png',
                  //   width: 80,
                  //   height: 25,
                  // ),
                  const SizedBox(
                    width: 20,
                  )
                ],
              ),
              const SizedBox(
                height: 105,
              ),
              Heading5Text(
                helpToChangePhoneNumberString.tr,
                weight: TextWeight.bold,
                color: AppColorConstants.themeColor,
                textAlign: TextAlign.center,
              ),
              BodyLargeText(pleaseEnterOtpSentToYourPhoneString.tr,
                  color: AppColorConstants.themeColor)
                  .setPadding(top: 43, bottom: 35),
              SizedBox(
                height: 100,
                child: OTPFieldView(
                  length: loginController.pinLength,
                  defaultPinTheme: PinTheme(
                      height: 50,
                      width: 50,
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
                children: [
                  BodyLargeText(didntReceivedCodeString.tr,
                      color: AppColorConstants.themeColor),
                  BodyLargeText(resendOTPString.tr,
                      color: loginController.canResendOTP.value ==
                          false
                          ? AppColorConstants.disabledColor
                          : AppColorConstants.themeColor,
                      weight: TextWeight.medium)
                      .ripple(() {
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
                  // Text(' in (1:20) ', style: TextStyle(fontSize: FontSizes.b2).headingColor),
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
        loginController.callVerifyOTPForChangePhone(
            otp: filledOTP, token: widget.token);
      },
      text: verifyString.tr,
    );
  }
}
