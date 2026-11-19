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

  // dating status (limits, super likes, boost, pause)
  RxBool limitReached = false.obs;
  RxBool isPaused = false.obs;
  RxBool boostActive = false.obs;
  RxBool boostAvailable = true.obs;
  RxInt superLikesLeft = 0.obs;
  RxInt dailyLimit = 0.obs;
  RxInt remaining = 0.obs;
  RxBool loadFailed = false.obs;

  // distance (km) per profile id, photos per profile id
  RxMap<int, int> distances = <int, int>{}.obs;
  RxMap<int, List<String>> photos = <int, List<String>>{}.obs;
  final Set<int> _photoLoading = {};

  // "who liked me" lock (premium only, switched on the server)
  RxBool likesLocked = false.obs;
  RxInt likesCount = 0.obs;

  loadPhotos(int userId) {
    if (photos.containsKey(userId) || _photoLoading.contains(userId)) return;
    _photoLoading.add(userId);
    DatingApi.getProfilePhotos(
        userId: userId,
        resultCallback: (list) {
          photos[userId] = list;
          _photoLoading.remove(userId);
        });
  }

  /// last skipped profile, so Rewind can bring the card back
  UserModel? lastSkipped;

  loadStatus() {
    DatingApi.getDatingStatus(resultCallback: (s) {
      isPaused.value = s['paused'] == true;
      boostActive.value = s['boost_active'] == true;
      boostAvailable.value = s['boost_available'] == true;
      superLikesLeft.value = int.tryParse('${s['super_likes_left'] ?? 0}') ?? 0;
      dailyLimit.value = int.tryParse('${s['daily_limit'] ?? 0}') ?? 0;
      remaining.value = int.tryParse('${s['remaining'] ?? 0}') ?? 0;
      limitReached.value = dailyLimit.value > 0 && remaining.value <= 0;
    });
  }

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
    loadFailed.value = false;
    loadStatus();
    DatingApi.getDatingProfilesApi(
        limitCallback: (reached, limit) {
          limitReached.value = reached;
        },
        distanceCallback: (d) {
          distances.addAll(d);
        },
        errorCallback: () {
          isLoading.value = false;
          loadFailed.value = true;
        },
        resultCallback: (result) {
          isLoading.value = false;
          datingUsers.value = result;
          update();
        });
  }

  /// Like / Super Like. [onMatch] is called when both people liked each other.
  likeProfile(UserModel profile,
      {bool superLike = false, Function(UserModel)? onMatch}) {
    DatingApi.likeProfile(
        profileId: profile.id.toString(),
        superLike: superLike,
        resultCallback: (isMatch) {
          loadStatus();
          if (isMatch) {
            onMatch?.call(profile);
          }
        },
        errorCallback: loadStatus);
  }

  skipProfile(UserModel profile) {
    lastSkipped = profile;
    DatingApi.likeUnlikeDatingProfile(
        action: DatingActions.rejected,
        profileId: profile.id.toString(),
        resultCallback: loadStatus);
  }

  /// Bring the last skipped card back on top.
  rewind() {
    final UserModel? back = lastSkipped;
    if (back == null) return;
    DatingApi.rewindProfile(resultCallback: (_) {
      lastSkipped = null;
      datingUsers.add(back);
      datingUsers.refresh();
      loadStatus();
    });
  }

  boost() {
    DatingApi.boostProfile(resultCallback: () {
      loadStatus();
    });
  }

  setPaused(bool paused) {
    DatingApi.pauseProfile(
        paused: paused,
        resultCallback: () {
          isPaused.value = paused;
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
    DatingApi.getLikeProfilesApi(lockCallback: (locked, count) {
      likesLocked.value = locked;
      likesCount.value = count;
    }, resultCallback: (result) {
      isLoading.value = false;
      likeUsers.value = result;
      update();
    });
  }
}


