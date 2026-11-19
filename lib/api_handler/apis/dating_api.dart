import 'package:foap/api_handler/api_wrapper.dart';
import 'package:foap/helper/imports/common_import.dart';
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
    if (selectedPreferences.heightFrom != null) {
      param['height_from'] = selectedPreferences.heightFrom.toString();
    }
    if (selectedPreferences.heightTo != null) {
      param['height_to'] = selectedPreferences.heightTo.toString();
    }

    if (selectedPreferences.holisticFrom != null) {
      param['holistic_path_from'] =
          selectedPreferences.holisticFrom.toString();
    }
    if (selectedPreferences.holisticTo != null) {
      param['holistic_path_to'] =
          selectedPreferences.holisticTo.toString();
    }
    if (selectedPreferences.passionateAbout != null) {
      param['passionate'] = selectedPreferences.passionateAbout.toString();
    }

    await ApiWrapper().postApi(url: url, param: param).then((result) {
      if (result?.success == true) {}
    });
  }

  static getUserPreferenceApi(
      {required Function(AddPreferenceModel) resultCallback}) async {
    var url = NetworkConstantsUtil.getUserPreference;

    await ApiWrapper().getApi(url: url).then((result) {
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

    if (dataModel.holisticPath != null) {
      param['holistic_path'] = dataModel.holisticPath.toString();
    }
    if (dataModel.passionateAbout != null) {
      param['passionate'] = dataModel.passionateAbout.toString();
    }

    await ApiWrapper().postApi(url: url, param: param).then((result) {
      if (result?.success == true) {
        handler();
      }
    });
  }

  static getDatingProfilesApi(
      {required Function(List<UserModel>) resultCallback,
      Function(bool limitReached, int dailyLimit)? limitCallback,
      Function(Map<int, int>)? distanceCallback,
      VoidCallback? errorCallback}) async {
    var url = NetworkConstantsUtil.getDatingProfiles;
    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['preferenceMatchProfile'] ?? [];
        limitCallback?.call(result.data['limitReached'] == true,
            int.tryParse('${result.data['dailyLimit'] ?? 0}') ?? 0);
        final dist = <int, int>{};
        final d = result.data['distances'];
        if (d is Map) {
          d.forEach((k, v) {
            final id = int.tryParse('$k');
            final km = int.tryParse('$v');
            if (id != null && km != null) dist[id] = km;
          });
        }
        distanceCallback?.call(dist);
        resultCallback(
            List<UserModel>.from(items.map((x) => UserModel.fromJson(x))));
      } else {
        errorCallback?.call();
      }
    });
  }

  /// Like (or Super Like). [resultCallback] gets whether it became a match.
  static likeProfile(
      {required String profileId,
      bool superLike = false,
      required Function(bool isMatch) resultCallback,
      VoidCallback? errorCallback}) async {
    await ApiWrapper().postApi(url: NetworkConstantsUtil.profileLike, param: {
      'profile_user_id': profileId,
      if (superLike) 'super_like': '1'
    }).then((result) {
      if (result?.success == true) {
        resultCallback(result!.data['is_match'] == true ||
            (int.tryParse('${result.data['like'] ?? 0}') ?? 0) >= 2);
      } else {
        errorCallback?.call();
      }
    });
  }

  /// Undo the last skip. Gives back the profile id that was restored.
  static rewindProfile(
      {required Function(int profileUserId) resultCallback}) async {
    await ApiWrapper()
        .postApi(url: NetworkConstantsUtil.datingRewind, param: {}).then((result) {
      if (result?.success == true) {
        resultCallback(int.tryParse('${result!.data['profile_user_id']}') ?? 0);
      }
    });
  }

  static boostProfile({required VoidCallback resultCallback}) async {
    await ApiWrapper()
        .postApi(url: NetworkConstantsUtil.datingBoost, param: {}).then((result) {
      if (result?.success == true) {
        resultCallback();
      }
    });
  }

  static pauseProfile(
      {required bool paused, required VoidCallback resultCallback}) async {
    await ApiWrapper().postApi(
        url: NetworkConstantsUtil.datingPause,
        param: {'paused': paused ? '1' : '0'}).then((result) {
      if (result?.success == true) {
        resultCallback();
      }
    });
  }

  static getDatingStatus(
      {required Function(Map<String, dynamic>) resultCallback}) async {
    await ApiWrapper()
        .getApi(url: NetworkConstantsUtil.datingStatus)
        .then((result) {
      if (result?.success == true && result!.data is Map) {
        resultCallback(Map<String, dynamic>.from(result.data));
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

    await ApiWrapper().postApi(
        url: url, param: {'profile_user_id': profileId}).then((result) {
      if (result?.success == true) {
        resultCallback();
      }
    });
  }

  static getMatchedProfilesApi(
      {required Function(List<UserModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.matchedProfiles;

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['userMatch']['items'];
        resultCallback(
            List<UserModel>.from(items.map((x) => UserModel.fromJson(x))));
      }
    });
  }

  static getProfilePhotos(
      {required int userId,
      required Function(List<String>) resultCallback}) async {
    await ApiWrapper()
        .getApi(url: '${NetworkConstantsUtil.datingProfilePhotos}$userId')
        .then((result) {
      if (result?.success == true) {
        final items = result!.data['photos'] ?? [];
        resultCallback(List<String>.from(items.map((x) => x.toString())));
      }
    });
  }

  static getLikeProfilesApi(
      {required Function(List<UserModel>) resultCallback,
      Function(bool locked, int count)? lockCallback}) async {
    var url = NetworkConstantsUtil.likeProfiles;

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['profileLikeByOtherUsers'] ?? [];
        lockCallback?.call(result.data['likes_locked'] == true,
            int.tryParse('${result.data['likes_count'] ?? 0}') ?? 0);
        resultCallback(
            List<UserModel>.from(items.map((x) => UserModel.fromJson(x))));
      }
    });
  }

  static getLanguages(
      {required Function(List<LanguageModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.getLanguages;

    await ApiWrapper().getApi(url: url).then((result) {
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

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['interest'];
        resultCallback(List<InterestModel>.from(
            items.map((x) => InterestModel.fromJson(x))));
      }
    });
  }
}
