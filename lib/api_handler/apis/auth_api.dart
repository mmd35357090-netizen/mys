import 'dart:io';
import 'package:foap/helper/device_info.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../util/shared_prefs.dart';
import '../api_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthApi {
  static login(
      {required String email,
      required String password,
      required Function(String) successCallback,
      required Function(String) verifyOtpCallback}) async {
    String? fcmToken = await SharedPrefs().getFCMToken();
    String? voipToken = await SharedPrefs().getVoipToken();
    dynamic param = {
      "email": email,
      "password": password,
      "device_type": DeviceInfoManager.info.deviceType,
      "device_token": fcmToken ?? '',
      "device_token_voip_ios": voipToken ?? '',
      'device_model': DeviceInfoManager.info.model,
      'device_os_version': DeviceInfoManager.info.osVersion,
      'device_app_release_version': AppConfigConstants.currentVersion,
      'login_ip': DeviceInfoManager.info.ip,
      'login_location': '',
    };

    Loader.show(status: loadingString.tr);

    await ApiWrapper()
        .postApiWithoutToken(url: NetworkConstantsUtil.login, param: param)
        .then((response) {
      Loader.dismiss();

      if (response?.success == true) {
        String authKey = response!.data!['auth_key'];
        successCallback(authKey);
      } else {
        if (response?.data != null) {
          if (response!.data['token'] != null) {
            String authKey = response.data!['token'];
            verifyOtpCallback(authKey);
          }
        }
        AppUtil.showToast(
            message: response?.message ?? errorMessageString.tr,
            isSuccess: false);
      }
    });
  }

  static logout() async {
    Loader.show(status: loadingString.tr);

    await ApiWrapper().postApi(
        url: NetworkConstantsUtil.logout, param: {}).then((response) {
      Loader.dismiss();

      if (response?.success == true) {
      } else {
        AppUtil.showToast(
            message: response?.message ?? errorMessageString.tr,
            isSuccess: false);
      }
    });
  }

  static loginWithPhoneUsingSayHiServer(
      {required String code,
      required String phone,
      required Function(String) successCallback}) async {
    String? fcmToken = await SharedPrefs().getFCMToken();
    String? voipToken = await SharedPrefs().getVoipToken();

    dynamic param = {
      "country_code": code,
      "phone": phone,
      "device_token": fcmToken ?? '',
      "device_token_voip_ios": voipToken ?? '',
      "device_type": DeviceInfoManager.info.deviceType,
      'device_model': DeviceInfoManager.info.model,
      'device_os_version': DeviceInfoManager.info.osVersion,
      'device_app_release_version': AppConfigConstants.currentVersion,
      'login_ip': DeviceInfoManager.info.ip,
      'login_location': '',
    };
    Loader.show(status: loadingString.tr);

    await ApiWrapper()
        .postApiWithoutToken(
            url: NetworkConstantsUtil.loginWithPhone, param: param)
        .then((response) {
      Loader.dismiss();

      if (response?.success == true) {
        String token = response!.data!['verify_token'];

        successCallback(token);
      } else {
        AppUtil.showToast(
            message: response?.message ?? errorMessageString.tr,
            isSuccess: false);
      }
    });
  }

  static loginWithPhoneUsingFirebase(
      {required String code,
      required String phone,
      required Function(String) successCallback}) async {
    Loader.show(status: loadingString.tr);

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+$code $phone',
      verificationCompleted: (PhoneAuthCredential credential) {
      },
      verificationFailed: (FirebaseAuthException e) {
        Loader.dismiss();
        AppUtil.showToast(
            message: errorMessageString.tr, isSuccess: false);
      },
      codeSent: (String verificationId, int? resendToken) {
        Loader.dismiss();

        successCallback(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        Loader.dismiss();
        AppUtil.showToast(
            message: errorMessageString.tr, isSuccess: false);
      },
    );
  }

  static socialLogin(
      {required String name,
      required String userName,
      required String socialType,
      required String socialId,
      required String email,
      required Function(String) successCallback}) async {
    String? fcmToken = await SharedPrefs().getFCMToken();
    String? voipToken = await SharedPrefs().getVoipToken();
    Loader.show(status: loadingString.tr);

    await ApiWrapper().postApiWithoutToken(
        url: NetworkConstantsUtil.socialLogin,
        param: {
          "name": name,
          "username": userName,
          "social_type": socialType,
          "social_id": socialId,
          "email": email,
          "device_token": fcmToken ?? '',
          "device_token_voip_ios": voipToken ?? '',
          "device_type": DeviceInfoManager.info.deviceType,
          'device_model': DeviceInfoManager.info.model,
          'device_os_version': DeviceInfoManager.info.osVersion,
          'device_app_release_version': AppConfigConstants.currentVersion,
          'login_ip': DeviceInfoManager.info.ip,
          'login_location': '',
        }).then((response) {
      Loader.dismiss();

      if (response?.success == true) {
        String authKey = response!.data!['auth_key'];

        successCallback(authKey);
      } else {
        AppUtil.showToast(
            message: response?.message ?? errorMessageString.tr,
            isSuccess: false);
      }
    });
  }

  static register(
      {required String email,
      required String name,
      required String password,
      required Function(String) successCallback}) async {
    String? fcmToken = await SharedPrefs().getFCMToken();
    String? voipToken = await SharedPrefs().getVoipToken();
    Loader.show(status: loadingString.tr);
    await ApiWrapper()
        .postApiWithoutToken(url: NetworkConstantsUtil.register, param: {
      "username": name,
      "name": name,
      "email": email,
      "password": password,
      "device_token": fcmToken ?? '',
      "device_token_voip_ios": voipToken ?? '',
      'role': '3',
      "device_type": DeviceInfoManager.info.deviceType,
      'device_model': DeviceInfoManager.info.model,
      'device_os_version': DeviceInfoManager.info.osVersion,
      'device_app_release_version': AppConfigConstants.currentVersion,
      'login_ip': DeviceInfoManager.info.ip,
      'login_location': '',
    }).then((response) {
      Loader.dismiss();
      if (response?.success == true) {
        String token = response!.data!['token'];

        successCallback(token);
      } else {
        AppUtil.showToast(
            message: response?.message ?? errorMessageString.tr,
            isSuccess: false);
      }
    });
  }

  static deleteAccount({required VoidCallback successCallback}) async {
    Loader.show(status: loadingString.tr);

    await ApiWrapper()
        .postApi(url: NetworkConstantsUtil.deleteAccount, param: null)
        .then((response) {
      Loader.dismiss();

      if (response?.success == true) {
        successCallback();
      } else {
        AppUtil.showToast(
            message: response?.message ?? errorMessageString.tr,
            isSuccess: false);
      }
    });
  }

  static updateFcmToken() async {
    String? fcmToken = await SharedPrefs().getFCMToken();
    String? voipToken = await SharedPrefs().getVoipToken();

    await ApiWrapper()
        .postApi(url: NetworkConstantsUtil.updatedDeviceToken, param: {
      "device_type": DeviceInfoManager.info.deviceType,
      "device_token": fcmToken ?? '',
      "device_token_voip_ios": voipToken ?? ''
    }).then((response) {
      if (response?.success == true) {
        // successCallback();
      } else {
        AppUtil.showToast(
            message: response?.message ?? errorMessageString.tr,
            isSuccess: false);
      }
    });
  }

  static checkUsername(
      {required String username,
      required VoidCallback successCallback,
      required VoidCallback failureCallback}) async {
    // Loader.show(status: loadingString.tr);

    await ApiWrapper().postApiWithoutToken(
        url: NetworkConstantsUtil.checkUserName,
        param: {
          "username": username,
        }).then((response) {
      // Loader.dismiss();

      if (response?.success == true) {
        successCallback();
      } else {
        failureCallback();
      }
    });
  }

  static forgotPassword(
      {required String email,
      required Function(String) successCallback}) async {
    dynamic param = {
      "verification_with": '1',
      "email": email,
      "country_code": '',
      "phone": ''
    };
    Loader.show(status: loadingString.tr);
    await ApiWrapper()
        .postApiWithoutToken(
            url: NetworkConstantsUtil.forgotPassword, param: param)
        .then((response) {
      Loader.dismiss();
      if (response?.success == true) {
        String token = response!.data!['token'];

        successCallback(token);
      } else {
        AppUtil.showToast(
            message: response?.message ?? errorMessageString.tr,
            isSuccess: false);
      }
    });
  }

  static resetPassword(
      {required String token,
      required String newPassword,
      required VoidCallback successCallback}) async {
    dynamic param = {
      "token": token,
      "password": newPassword,
    };
    Loader.show(status: loadingString.tr);

    await ApiWrapper()
        .postApiWithoutToken(
            url: NetworkConstantsUtil.resetPassword, param: param)
        .then((response) {
      Loader.dismiss();
      if (response?.success == true) {
        successCallback();
      } else {
        AppUtil.showToast(
            message: response?.message ?? errorMessageString.tr,
            isSuccess: false);
      }
    });
  }

  static resendOTP(
      {required String token,
      required VoidCallback successCallback}) async {
    Loader.show(status: loadingString.tr);

    await ApiWrapper()
        .postApiWithoutToken(url: NetworkConstantsUtil.resendOTP, param: {
      "token": token,
    }).then((response) {
      Loader.dismiss();

      if (response?.success == true) {
        successCallback();
      } else {
        AppUtil.showToast(
            message: response?.message ?? errorMessageString.tr,
            isSuccess: false);
      }
    });
  }

  static verifyRegistrationOTPViaSayHiServer(
      {required String otp,
      required String token,
      required Function(String) successCallback}) async {
    Loader.show(status: loadingString.tr);

    await ApiWrapper().postApiWithoutToken(
        url: NetworkConstantsUtil.verifyRegistrationOTP,
        param: {
          "otp": otp,
          "token": token,
          "device_type": DeviceInfoManager.info.deviceType,
          'device_model': DeviceInfoManager.info.model,
          'device_os_version': DeviceInfoManager.info.osVersion,
          'device_app_release_version': AppConfigConstants.currentVersion,
          'login_ip': DeviceInfoManager.info.ip,
          'login_location': '',
        }).then((response) {
      Loader.dismiss();

      if (response?.success == true) {
        String authKey = response!.data!['auth_key'];
        successCallback(authKey);
      } else {
        AppUtil.showToast(
            message: response?.message ?? errorMessageString.tr,
            isSuccess: false);
      }
    });
  }

  static verifyForgotPasswordOTPViaSayHiServer(
      {required String otp,
      required String token,
      required Function(String) successCallback}) async {
    Loader.show(status: loadingString.tr);

    await ApiWrapper().postApiWithoutToken(
        url: NetworkConstantsUtil.verifyFwdPWDOTP,
        param: {
          "otp": otp,
          "token": token,
        }).then((response) {
      Loader.dismiss();

      if (response?.success == true) {
        String token = response!.data!['token'];

        successCallback(token);
      } else {
        AppUtil.showToast(
            message: response?.message ?? errorMessageString.tr,
            isSuccess: false);
      }
    });
  }

  static verifyChangePhoneOTPViaSayHiServer(
      {required String otp,
      required String token,
      required VoidCallback successCallback}) async {
    Loader.show(status: loadingString.tr);

    await ApiWrapper()
        .postApi(url: NetworkConstantsUtil.verifyChangePhoneOTP, param: {
      "otp": otp,
      "verify_token": token,
    }).then((response) {
      Loader.dismiss();

      if (response?.success == true) {
        successCallback();
      } else {
        AppUtil.showToast(
            message: response?.message ?? errorMessageString.tr,
            isSuccess: false);
      }
    });
  }

  static verifyPhoneLoginOTPViaFirebase(
      {required String countryCode,
      required String phone,
      required String otp,
      required String token,
      required Function(String) successCallback}) async {
    Loader.show(status: loadingString.tr);

    AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: token, smsCode: '123456');
    UserCredential authResult =
        await FirebaseAuth.instance.signInWithCredential(credential);
    Loader.dismiss();

    if (authResult.user != null) {
      String? fcmToken = await SharedPrefs().getFCMToken();
      String? voipToken = await SharedPrefs().getVoipToken();

      dynamic param = {
        "country_code": countryCode,
        "phone": phone,
        "device_type": Platform.isAndroid ? '1' : '2',
        "device_token": fcmToken ?? '',
        "device_token_voip_ios": voipToken ?? '',
        'device_model': DeviceInfoManager.info.model,
        'device_os_version': DeviceInfoManager.info.osVersion,
        'device_app_release_version': AppConfigConstants.currentVersion,
        'login_ip': DeviceInfoManager.info.ip,
        'login_location': '',
      };
      Loader.show(status: loadingString.tr);

      await ApiWrapper()
          .postApiWithoutToken(
              url: NetworkConstantsUtil.loginWithoutPhone, param: param)
          .then((response) {
        Loader.dismiss();

        if (response?.success == true) {
          String token = response!.data!['auth_key'];

          successCallback(token);
        } else {
          AppUtil.showToast(
              message: response?.message ?? errorMessageString.tr,
              isSuccess: false);
        }
      });
    } else {
      AppUtil.showToast(message: errorMessageString.tr, isSuccess: false);
    }
  }
}
