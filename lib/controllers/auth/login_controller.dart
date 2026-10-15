import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/account.dart';
import 'package:foap/screens/login_sign_up/verif_otp_for_forgot_password.dart';
import 'package:foap/screens/login_sign_up/verify_otp_for_phone_login.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../api_handler/apis/auth_api.dart';
import '../../screens/login_sign_up/verify_otp_for_signup.dart';
import '../../util/shared_prefs.dart';
import 'dart:async';
import 'package:foap/manager/socket_manager.dart';
import 'package:foap/util/form_validator.dart';
import 'package:foap/screens/dashboard/dashboard_screen.dart';
import 'package:foap/screens/settings_menu/settings_controller.dart';
import 'package:foap/screens/login_sign_up/reset_password.dart';
import '../profile/profile_controller.dart';

class LoginController extends GetxController {
  final SettingsController _settingsController = Get.find();
  final UserProfileManager _userProfileManager = Get.find();

  bool passwordReset = false;
  int userNameCheckStatus = -1;
  RxBool canResendOTP = true.obs;

  RxString passwordStrengthText = ''.obs;
  RxDouble passwordStrength = 0.toDouble().obs;
  RxString phoneCountryCode = '1'.obs;

  int pinLength = 6;
  RxBool hasError = false.obs;
  RxBool otpFilled = false.obs;

  RegExp numReg = RegExp(r".*[0-9].*");
  RegExp letterReg = RegExp(r".*[A-Za-z].*");

  void login(String email, String password) {
    if (FormValidator().isTextEmpty(email)) {
      showErrorMessage(
        pleaseEnterValidEmailString.tr,
      );
    } else if (FormValidator().isTextEmpty(password)) {
      showErrorMessage(
        pleaseEnterPasswordString.tr,
      );
    } else {
      AuthApi.login(
          email: email,
          password: password,
          successCallback: (authKey) async {
            loginSuccess(authKey);
          },
          verifyOtpCallback: (token) {
            Get.to(() => VerifyOTPForSignup(
                  token: token,
                ));
          });
    }
  }

  void phoneLogin({required String countryCode, required String phone}) {
    if (FormValidator().isTextEmpty(phone)) {
      showErrorMessage(pleaseEnterValidPhoneString.tr);
    } else {
      if (_settingsController.setting.value!.smsGateway ==
          SMSGateway.firebase) {
        AuthApi.loginWithPhoneUsingFirebase(
            code: countryCode,
            phone: phone,
            successCallback: (token) {
              Get.to(() => VerifyOTPForPhoneLogin(
                    token: token,
                    countryCode: countryCode,
                    phone: phone,
                  ));
            });
      } else {
        AuthApi.loginWithPhoneUsingSayHiServer(
            code: countryCode,
            phone: phone,
            successCallback: (token) {
              Get.to(() => VerifyOTPForPhoneLogin(
                    token: token,
                    countryCode: countryCode,
                    phone: phone,
                  ));
            });
      }
    }
  }

  void socialLogin(String type, String userId, String name, String email) {
    Loader.show(status: loadingString.tr);

    AuthApi.socialLogin(
        name: name,
        userName: '',
        socialType: type,
        socialId: userId,
        email: email,
        successCallback: (authKey) async {
          Loader.dismiss();
          loginSuccess(authKey);
        });
  }

  checkPassword(String password) {
    password = password.trim();

    if (password.isEmpty) {
      passwordStrength.value = 0;
      passwordStrengthText.value = pleaseEnterYourPassword.tr;
    } else if (password.length < 6) {
      passwordStrength.value = 1 / 4;
      passwordStrengthText.value = passwordIsToShort.tr;
    } else if (password.length < 8) {
      passwordStrength.value = 2 / 4;
      passwordStrengthText.value = passwordIsShortButAcceptable.tr;
    } else {
      if (!letterReg.hasMatch(password) || !numReg.hasMatch(password)) {
        // Password length >= 8
        // But doesn't contain both letter and digit characters
        passwordStrength.value = 3 / 4;
        passwordStrengthText.value = passwordMustByAlphanumeric.tr;
      } else {
        // Password length >= 8
        // Password contains both letter and digit characters
        passwordStrength.value = 1;
        passwordStrengthText.value = passwordIsGreat.tr;
      }
    }

    update();
  }

  void register({
    required String email,
    required String userName,
    required String password,
  }) {
    final ProfileController profileController = Get.find();

    if (FormValidator().isTextEmpty(userName)) {
      AppUtil.showToast(
          message: pleaseEnterUserNameString.tr, isSuccess: false);
    } else if (profileController.userNameCheckStatus.value != 1) {
      AppUtil.showToast(
          message: pleaseEnterValidUserNameString.tr, isSuccess: false);
    } else if (FormValidator().isTextEmpty(email)) {
      showErrorMessage(
        pleaseEnterValidEmailString.tr,
      );
    } else if (FormValidator().isNotValidEmail(email)) {
      showErrorMessage(
        pleaseEnterValidEmailString.tr,
      );
    } else if (FormValidator().isTextEmpty(password)) {
      showErrorMessage(
        pleaseEnterPasswordString.tr,
      );
    } else {
      AuthApi.register(
          email: email,
          name: userName,
          password: password,
          successCallback: (token) {
            Get.to(() => VerifyOTPForSignup(
                  token: token,
                ));
          });
    }
  }

  void resetPassword({
    required String newPassword,
    required String confirmPassword,
    required String token,
  }) {
    if (FormValidator().isTextEmpty(newPassword)) {
      showErrorMessage(
        pleaseEnterPasswordString.tr,
      );
    } else if (FormValidator().isTextEmpty(confirmPassword)) {
      showErrorMessage(
        pleaseEnterConfirmPasswordString.tr,
      );
    } else if (newPassword != confirmPassword) {
      showErrorMessage(
        passwordsDoesNotMatchedString.tr,
      );
    } else {
      AuthApi.resetPassword(
          token: token,
          newPassword: newPassword,
          successCallback: () {
            passwordReset = true;
            update();
          });
    }
  }

  void verifyUsername(String userName) {
    if (userName.contains(' ')) {
      userNameCheckStatus = 0;
      update();
      return;
    }

    AuthApi.checkUsername(
        username: userName,
        successCallback: () {
          userNameCheckStatus = 1;
          update();
        },
        failureCallback: () {
          userNameCheckStatus = 0;
          update();
        });
  }

  phoneCodeSelected(String code) {
    phoneCountryCode.value = code;
  }

  otpTextFilled(String otp) {
    otpFilled.value = otp.length == pinLength;
    hasError.value = false;

    update();
  }

  otpCompleted() {
    otpFilled.value = true;
    hasError.value = false;

    update();
  }

  void resendOTP({required String token}) {
    Loader.show(status: loadingString.tr);
    AuthApi.resendOTP(
        token: token,
        successCallback: () {
          Loader.dismiss();
          canResendOTP.value = false;
          update();
        });
  }

  void callForgotPwdVerifyOTP({
    required String otp,
    required String token,
  }) {
    Loader.show(status: loadingString.tr);
    AuthApi.verifyForgotPasswordOTPViaSayHiServer(
        otp: otp,
        token: token,
        successCallback: (token) {
          Loader.dismiss();

          Future.delayed(const Duration(milliseconds: 500), () async {
            Get.to(() => ResetPasswordScreen(token: token));
          });
        });
  }

  void callVerifyOTPForRegistration({
    required String otp,
    required String token,
  }) {
    Loader.show(status: loadingString.tr);

    AuthApi.verifyRegistrationOTPViaSayHiServer(
        otp: otp,
        token: token,
        successCallback: (authKey) {
          Loader.dismiss();
          Future.delayed(const Duration(milliseconds: 500), () async {
            loginSuccess(authKey);
          });
        });
  }

  void callVerifyOTPForPhoneLogin({
    required String otp,
    required String token,
    required String countryCode,
    required String phone,
  }) {
    if (_settingsController.setting.value!.smsGateway ==
        SMSGateway.firebase) {
      AuthApi.verifyPhoneLoginOTPViaFirebase(
          countryCode: countryCode,
          phone: phone,
          otp: otp,
          token: token,
          successCallback: (authKey) {
            Loader.dismiss();
            loginSuccess(authKey);
          });
    } else {
      AuthApi.verifyRegistrationOTPViaSayHiServer(
          otp: otp,
          token: token,
          successCallback: (authKey) {
            Loader.dismiss();
            loginSuccess(authKey);
          });
    }
  }

  void callVerifyOTPForChangePhone({
    required String otp,
    required String token,
  }) {
    AuthApi.verifyChangePhoneOTPViaSayHiServer(
        otp: otp,
        token: token,
        successCallback: () {
          Future.delayed(const Duration(milliseconds: 500), () {
            Get.back();
          });
        });
  }

  void forgotPassword({required String email}) {
    if (FormValidator().isTextEmpty(email)) {
      AppUtil.showToast(
          message: pleaseEnterEmailString.tr, isSuccess: false);
    } else if (FormValidator().isNotValidEmail(email)) {
      AppUtil.showToast(
          message: pleaseEnterValidEmailString.tr, isSuccess: false);
    } else {
      AuthApi.forgotPassword(
          email: email,
          successCallback: (token) {
            Get.to(() => VerifyOTPForForgotPassword(
                  token: token,
                  isFromForgotPassword: true,
                ));
          });
    }
  }

  loginSuccess(String authKey) async {
    loginSilently(authKey, () {
      Get.offAll(() => const DashboardScreen());
    });
  }

  loginSilently(String authKey, VoidCallback callback) async {
    getIt<SocketManager>().logout();
    await SharedPrefs().setAuthorizationKey(authKey);
    await _userProfileManager.refreshProfile();
    if (_userProfileManager.user.value != null) {
      SayHiAppAccount account = SayHiAppAccount(
          username: _userProfileManager.user.value!.userName,
          userId: _userProfileManager.user.value!.id.toString(),
          authToken: authKey,
          picture: _userProfileManager.user.value!.picture,
          isLoggedIn: true);
      _userProfileManager.loginAccount(account);
      await _settingsController.getSettings();
      getIt<SocketManager>().connect();
      callback();
    }
  }

  Future<void> launchUrlInBrowser(String url) async {
    await launchUrl(Uri.parse(url));
  }

  showSuccessMessage(String message) {
    AppUtil.showToast(message: message, isSuccess: true);
  }

  showErrorMessage(String message) {
    AppUtil.showToast(message: message, isSuccess: false);
  }
}
