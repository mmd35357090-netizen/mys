import 'package:foap/api_handler/apis/dating_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/screens/add_on/model/preference_model.dart';


class DatingController extends GetxController {
  RxList<InterestModel> interests = <InterestModel>[].obs;
  RxList<UserModel> datingUsers = <UserModel>[].obs;
  RxList<UserModel> matchedUsers = <UserModel>[].obs;
  RxList<UserModel> likeUsers = <UserModel>[].obs;
  RxList<LanguageModel> languages = <LanguageModel>[].obs;
  RxBool isLoading = false.obs;
  AddPreferenceModel? preferenceModel;

  clearInterests() {
    interests.clear();
    datingUsers.clear();
    update();
  }

  getInterests() {
    DatingApi.getInterests(resultCallback: (result) {
      interests.value = result;
      interests.refresh();
      update();
    });
  }

  setPreferencesApi(AddPreferenceModel selectedPreferences) async {
    Loader.show(status: loadingString.tr);
    await DatingApi.addUserPreference(selectedPreferences);

    Loader.dismiss();
    update();
  }

  updateDatingProfile(AddDatingDataModel dataModel, VoidCallback handler) {
    Loader.show(status: loadingString.tr);
    DatingApi.updateDatingProfile(dataModel: dataModel, handler: (){
      Loader.dismiss();

      handler();
    });

    update();
  }

  getUserPreference(VoidCallback handler) {
    Loader.show();
    DatingApi.getUserPreferenceApi(resultCallback: (result) {
      preferenceModel = result;
      update();
      handler();
      Loader.dismiss();
    });
  }

  getDatingProfiles() {
    isLoading.value = true;
    DatingApi.getDatingProfilesApi(resultCallback: (result) {
      isLoading.value = false;
      datingUsers.value = result;
      update();
    });
  }

  getLanguages() {
    DatingApi.getLanguages(resultCallback: (result) {
      languages.value = result;
      update();
    });
  }

  likeUnlikeProfile(DatingActions like, String profileId) {
    DatingApi.likeUnlikeDatingProfile(
        action: like,
        profileId: profileId,
        resultCallback: () {
          update();
        });
  }

  getMatchedProfilesApi() {
    isLoading.value = true;
    DatingApi.getMatchedProfilesApi(resultCallback: (result) {
      isLoading.value = false;
      matchedUsers.value = result;
      update();
    });
  }

  getLikeProfilesApi() {
    isLoading.value = true;
    DatingApi.getLikeProfilesApi(resultCallback: (result) {
      isLoading.value = false;
      likeUsers.value = result;
      update();
    });
  }
}


