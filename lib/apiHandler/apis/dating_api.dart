import 'package:foap/apiHandler/api_wrapper.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../screens/add_on/controller/dating/dating_controller.dart';
import '../../screens/add_on/model/preference_model.dart';

class DatingApi {
  static Future addUserPreference(
      AddPreferenceModel selectedPreferences) async {
    var url = NetworkConstantsUtil.addUserPreference;

    dynamic param = {
      // 'profile_category_type': '2',
      // "work_experience_from": "2",
      // "work_experience_to": "4",
    };
    if (selectedPreferences.languages != null) {
      String? result =
          selectedPreferences.languages!.map((val) => val.id).join(',');
      param['language'] = result;
    }
    if (selectedPreferences.religion != null) {
      param['religion'] = selectedPreferences.religion;
    }
    if (selectedPreferences.status != null) {
      param['marital_status'] = selectedPreferences.status.toString();
    }
    if (selectedPreferences.smoke != null) {
      param['smoke_id'] = selectedPreferences.smoke.toString();
    }
    if (selectedPreferences.drink != null) {
      param['drinking_habit'] = selectedPreferences.drink.toString();
    }
    if (selectedPreferences.interests != null) {
      String? result =
          selectedPreferences.interests!.map((val) => val.id).join(',');
      param['interest'] = result;
    }
    if (selectedPreferences.gender != null) {
      param['gander'] = selectedPreferences.gender.toString();
    }
    if (selectedPreferences.selectedColor != null) {
      param['color'] = selectedPreferences.selectedColor;
    }
    if (selectedPreferences.ageFrom != null) {
      param['age_from'] = selectedPreferences.ageFrom.toString();
    }
    if (selectedPreferences.ageTo != null) {
      param['age_to'] = selectedPreferences.ageTo.toString();
    }
    if (selectedPreferences.heightTo != null) {
      param['height'] = selectedPreferences.heightTo.toString();
    }

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

  static Future updateDatingProfile(
      {required AddDatingDataModel dataModel,
      required VoidCallback handler}) async {
    var url = NetworkConstantsUtil.updateUserProfile;
    dynamic param = {
      // 'profile_category_type': '2',
      // "work_experience_month": '9',
    };
    if (dataModel.latitude != null) {
      param['latitude'] = dataModel.latitude.toString();
      param['longitude'] = dataModel.longitude.toString();
    }
    if (dataModel.name != null) {
      param['name'] = dataModel.name;
    }
    if (dataModel.dob != null) {
      param['dob'] = dataModel.dob;
    }
    if (dataModel.gender != null) {
      param['sex'] = dataModel.gender.toString();
    }
    if (dataModel.selectedColor != null) {
      param['color'] = dataModel.selectedColor;
    }
    if (dataModel.height != null) {
      param['height'] = dataModel.height.toString();
    }
    if (dataModel.religion != null) {
      param['religion'] = dataModel.religion;
    }
    if (dataModel.status != null) {
      param['marital_status'] = dataModel.status.toString();
    }
    if (dataModel.smoke != null) {
      param['smoke_id'] = dataModel.smoke.toString();
    }
    if (dataModel.drink != null) {
      param['drinking_habit'] = dataModel.drink.toString();
    }
    if (dataModel.interests != null) {
      String result = dataModel.interests!.map((val) => val.id).join(',');
      param['interest_id'] = result;
    }
    if (dataModel.languages != null) {
      String result = dataModel.languages!.map((val) => val.id).join(',');
      param['language_id'] = result;
    }
    if (dataModel.qualification != null) {
      param['qualification'] = dataModel.qualification;
    }
    if (dataModel.occupation != null) {
      param['occupation'] = dataModel.occupation;
    }
    if (dataModel.experienceYear != null) {
      param['work_experience_year'] = dataModel.experienceYear;
    }
    if (dataModel.experienceMonth != null) {
      param['work_experience_month'] = dataModel.experienceMonth;
    }

    await ApiWrapper().postApi(url: url, param: param).then((result) {
      if (result?.success == true) {
        handler();
      }
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
