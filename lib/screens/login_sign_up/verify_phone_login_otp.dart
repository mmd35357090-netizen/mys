import 'package:foap/helper/imports/common_import.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import '../../controllers/auth/login_controller.dart';

class VerifyRegistrationOTP extends StatefulWidget {
  final String token;

  const VerifyRegistrationOTP({super.key, required this.token});

  @override
  VerifyRegistrationOTPState createState() => VerifyRegistrationOTPState();
}

class VerifyRegistrationOTPState extends State<VerifyRegistrationOTP> {
  TextEditingController controller = TextEditingController(text: "");
  final LoginController loginController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      // কিবোর্ড পপ-আপ হলে লেআউট যেন ভেঙে না যায়
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        
                        // 🌟 স্মার্ট ভিজ্যুয়াল এলিমেন্ট (আইকন)
                        Icon(
                          Icons.lock_person_outlined,
                          size: 70,
                          color: AppColorConstants.themeColor,
                        ),
                        const SizedBox(height: 24),
                        
                        // টাইটেল
                        Heading4Text(
                          otpVerificationString.tr,
                          weight: TextWeight.bold,
                          color: AppColorConstants.themeColor,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        
                        // সাবটাইটেল / ডেসক্রিপশন
                        BodyLargeText(
                          pleaseEnterOneTimePasswordPhoneNumberChangeString.tr,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        
                        // 🔢 ওটিপি ইনপুট ফিল্ড (ফিক্সড ডিজাইন)
                        Obx(() => PinCodeTextField(
                              autofocus: true,
                              controller: controller,
                              highlightColor: AppColorConstants.themeColor,
                              defaultBorderColor: Colors.grey.shade300,
                              hasTextBorderColor: AppColorConstants.themeColor,
                              pinBoxColor: Colors.grey.shade50,
                              highlightPinBoxColor: Colors.white,
                              maxLength: loginController.pinLength,
                              hasError: loginController.hasError.value,
                              onTextChanged: (text) {
                                loginController.otpTextFilled(text);
                              },
                              onDone: (text) {
                                loginController.otpCompleted();
                              },
                              pinBoxWidth: 48,
                              pinBoxHeight: 52,
                              pinBoxRadius: 10, // কোণাগুলো কিছুটা গোল করার জন্য
                              wrapAlignment: WrapAlignment.center,
                              pinTextStyle: TextStyle(
                                  fontSize: FontSizes.h4, 
                                  fontWeight: TextWeight.medium
                              ),
                              pinTextAnimatedSwitcherTransition:
                                  ProvidedPinBoxTextAnimation.scalingTransition,
                              pinTextAnimatedSwitcherDuration:
                                  const Duration(milliseconds: 200),
                              keyboardType: TextInputType.number,
                            )),
                        const SizedBox(height: 30),
                        
                        // ⏱ রিসেন্ড ও টাইমার সেকশন (সেন্টার এলাইনড)
                        Obx(() => Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                BodyLargeText(
                                  didntReceivedCodeString.tr,
                                ),
                                const SizedBox(width: 6),
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
                                if (loginController.canResendOTP.value == false)
                                  TweenAnimationBuilder<Duration>(
                                      duration: const Duration(minutes: 2),
                                      tween: Tween(
                                          begin: const Duration(minutes: 2),
                                          end: Duration.zero),
                                      onEnd: () {
                                        loginController.canResendOTP.value = true;
                                      },
                                      builder: (BuildContext context, Duration value, Widget? child) {
                                        final minutes = value.inMinutes;
                                        // সেকেন্ডস যেন সবসময় ২ ডিজিটের দেখায় (e.g., 05)
                                        final seconds = (value.inSeconds % 60).toString().padLeft(2, '0');
                                        return BodyLargeText(' ($minutes:$seconds)',
                                            textAlign: TextAlign.center,
                                            color: AppColorConstants.themeColor,
                                            weight: TextWeight.bold,
                                        );
                                      })
                              ],
                            )),
                        
                        const Spacer(),
                        
                        // 🟩 সাবমিট বাটন
                        Obx(() => loginController.otpFilled.value == true
                            ? SizedBox(
                                width: double.infinity, // ফুল উইডথ বাটন
                                child: addSubmitBtn(),
                              )
                            : const SizedBox.shrink()),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget addSubmitBtn() {
    return AppThemeButton(
      onPress: () {
        loginController.callVerifyOTPForPhoneLogin(
          otp: controller.text,
          token: widget.token,
        );
      },
      text: verifyString.tr,
    );
  }
}
