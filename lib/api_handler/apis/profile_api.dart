import 'dart:typed_data';
import 'package:foap/api_handler/api_wrapper.dart';
import '../../helper/imports/common_import.dart';
import 'package:foap/model/verification_request_model.dart';
import '../../model/location.dart';

class ProfileApi {
  static getMyProfile(
      {required Function(UserModel) resultCallback}) async {
    var url = NetworkConstantsUtil.getMyProfile;
    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        resultCallback(UserModel.fromJson(result!.data['user']));
      }
    });
  }

  static updateUserName(
      {required String userName,
      required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.updateUserProfile;

    await ApiWrapper().postApi(url: url, param: {
      "username": userName,
    }).then((result) {
      if (result?.success == true) {
        resultCallback();
      }
    });
  }

  static updateProfileCategoryType(
      {required int categoryType,
      required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.updateUserProfile;

    await ApiWrapper().postApi(url: url, param: {
      "profile_category_type": categoryType.toString(),
    }).then((result) {
      if (result?.success == true) {
        resultCallback();
      }
    });
  }

  static updateBiometricSetting(
      {required int setting, required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.updateUserProfile;

    await ApiWrapper().postApi(url: url, param: {
      "is_biometric_login": setting.toString(),
    }).then((result) {
      if (result?.success == true) {
        resultCallback();
      }
    });
  }

  static updatePhone(
      {required String countryCode,
      required String phone,
      required Function(String) resultCallback}) async {
    var url = NetworkConstantsUtil.updatePhone;

    await ApiWrapper().postApi(url: url, param: {
      "country_code": countryCode,
      "phone": phone
    }).then((result) {
      if (result?.success == true) {
        resultCallback(result!.data['verify_token']);
      }
    });
  }

  static updatePaymentDetails(
      {required String paypalId,
      required Function() resultCallback}) async {
    var url = NetworkConstantsUtil.updatePaymentDetail;
    var params = {"paypal_id": paypalId};

    await ApiWrapper().postApi(url: url, param: params).then((result) {
      if (result?.success == true) {
        resultCallback();
      }
    });
  }

  static updateCountryCity(
      {required String country,
      required String city,
      required Function() resultCallback}) async {
    var url = NetworkConstantsUtil.updateUserProfile;

    await ApiWrapper().postApi(
        url: url,
        param: {"country": country, "city": city}).then((result) {
      if (result?.success == true) {
        resultCallback();
      }
    });
  }

  static updateUserLocation(
      {required LocationModel location,
      required Function() resultCallback}) async {
    var url = NetworkConstantsUtil.updateLocation;

    await ApiWrapper().postApi(url: url, param: {
      'latitude': location.latitude.toString(),
      'longitude': location.longitude.toString(),
      'location': ''
    }).then((result) {
      if (result?.success == true) {
        resultCallback();
      }
    });
  }

  static pauseUserLocation({required Function() resultCallback}) async {
    var url = NetworkConstantsUtil.updateLocation;

    await ApiWrapper().postApi(url: url, param: {
      'latitude': '',
      'longitude': '',
      'location': ''
    }).then((result) {
      if (result?.success == true) {
        resultCallback();
      }
    });
  }

  static changePassword(
      {required String oldPassword,
      required String newPassword,
      required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.updatePassword;

    await ApiWrapper().postApi(url: url, param: {
      "old_password": oldPassword,
      "password": newPassword
    }).then((result) {
      if (result?.success == true) {
        resultCallback();
      }
    });
  }

  static updateAccountPrivacy(
      {required bool isPrivate,
      required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.updateAccountPrivacy;

    await ApiWrapper().postApi(url: url, param: {
      'profile_visibility': isPrivate ? 2 : 1,
    }).then((result) {
      resultCallback();
    });
  }

  static updateOnlineStatusSetting(
      {required int status, required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.updateOnlineStatusSetting;

    await ApiWrapper().postApi(url: url, param: {
      'is_show_online_chat_status': status.toString(),
    }).then((result) {
      resultCallback();
    });
  }

  static sendProfileVerificationRequest(
      {required String userMessage,
      required String documentType,
      required List<Map<String, String>> images,
      required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.requestVerification;

    await ApiWrapper().postApi(url: url, param: {
      "user_message": userMessage,
      'document': images,
      'document_type': documentType,
    }).then((result) {
      resultCallback();
    });
  }

  static cancelProfileVerificationRequest(
      {required int id,
      required String userMessage,
      required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.cancelVerification;

    await ApiWrapper().postApi(url: url, param: {
      'user_message': userMessage,
      'id': id.toString(),
    }).then((result) {
      resultCallback();
    });
  }

  static getVerificationRequestHistory(
      {required Function(List<VerificationRequest>)
          resultCallback}) async {
    var url = NetworkConstantsUtil.requestVerificationHistory;

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['verification']['items'];

        resultCallback(List<VerificationRequest>.from(
            items.map((x) => VerificationRequest.fromJson(x))));
      }
    });
  }

  static uploadProfileImage(Uint8List imageData,
      {required VoidCallback resultCallback}) async {
    Loader.show(status: loadingString.tr);

    await ApiWrapper()
        .multipartImageUpload(
            url: NetworkConstantsUtil.updateProfileImage,
            imageFileData: imageData)
        .then((result) {
      Loader.dismiss();
      if (result?.success == true) {
        resultCallback();
      }
    });
  }
}
