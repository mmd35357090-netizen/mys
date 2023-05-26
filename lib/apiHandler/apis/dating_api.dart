import 'package:foap/apiHandler/api_wrapper.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../screens/add_on/controller/dating/dating_controller.dart';
import '../../screens/add_on/model/preference_model.dart';

class DatingApi {
  static Future addUserPreference(
      AddPreferenceModel selectedPreferences) async {
    var url = NetworkConstantsUtil.addUserPreference;
    dynamic param = ApiParamModel().addUserPreferenceParam(selectedPreferences);

    await ApiWrapper().postApi(url: url, param: param).then((result) {
      if (result?.success == true) {}
    });
  }

  static getUserPreferenceApi(
      {required Function(AddPreferenceModel) resultCallback}) async {
    var url = NetworkConstantsUtil.getUserPreference;

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var settings = result!.data['preferenceSetting'];
        resultCallback(AddPreferenceModel.fromJson(settings));
      }
    });
  }

  static Future updateDatingProfile(AddDatingDataModel dataModel) async {
    var url = NetworkConstantsUtil.updateUserProfile;
    dynamic param = ApiParamModel().updateDatingProfileParam(dataModel);

    await ApiWrapper().postApi(url: url, param: param).then((result) {
      if (result?.success == true) {}
    });
  }

  static getDatingProfilesApi(
      {required Function(List<UserModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.getDatingProfiles;
    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['preferenceMatchProfile'];
          resultCallback(
              List<UserModel>.from(items.map((x) => UserModel.fromJson(x))));

      }
    });
  }

  static likeUnlikeDatingProfile(
      {required DatingActions action,
      required String profileId,
      required VoidCallback resultCallback}) async {
    var url = (action == DatingActions.liked
        ? NetworkConstantsUtil.profileLike
        : action == DatingActions.rejected
            ? NetworkConstantsUtil.profileSkip
            : NetworkConstantsUtil.undoProfileLike);

    ApiWrapper().postApi(url: url, param: {'profile_user_id': profileId}).then(
        (result) {
      if (result?.success == true) {
        resultCallback();
      }
    });
  }

  static getMatchedProfilesApi(
      {required Function(List<UserModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.matchedProfiles;

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['userMatch'];
          resultCallback(
              List<UserModel>.from(items.map((x) => UserModel.fromJson(x))));

      }
    });
  }

  static getLikeProfilesApi(
      {required Function(List<UserModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.likeProfiles;

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['profileLikeByOtherUsers'];
          resultCallback(
              List<UserModel>.from(items.map((x) => UserModel.fromJson(x))));

      }
    });
  }

  static getLanguages(
      {required Function(List<LanguageModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.getLanguages;

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['language'];
        resultCallback(List<LanguageModel>.from(
            items.map((x) => LanguageModel.fromJson(x))));
      }
    });
  }

  static getInterests(
      {required Function(List<InterestModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.interests;

    ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['interest'];
          resultCallback(List<InterestModel>.from(
              items.map((x) => InterestModel.fromJson(x))));

      }
    });
  }
}
