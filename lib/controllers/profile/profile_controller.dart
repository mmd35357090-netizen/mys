import 'package:camera/camera.dart';
import 'package:foap/api_handler/apis/profile_api.dart';
import 'package:foap/api_handler/apis/wallet_api.dart';
import 'package:foap/helper/enum_linking.dart';
import 'package:foap/helper/file_extension.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/helper/list_extension.dart';
import 'package:foap/model/data_wrapper.dart';
import '../../api_handler/apis/auth_api.dart';
import '../../api_handler/apis/post_api.dart';
import '../../api_handler/apis/users_api.dart';
import '../../screens/profile/verify_otp_for_phone_number.dart';
import '../../util/shared_prefs.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:async';
import 'package:foap/manager/location_manager.dart';
import 'package:foap/util/form_validator.dart';
import 'package:foap/controllers/post/post_controller.dart';
import 'package:foap/model/payment_model.dart';
import 'package:foap/model/gift_model.dart';
import 'package:foap/model/post_model.dart';
import 'package:foap/screens/dashboard/dashboard_screen.dart';
import 'package:foap/screens/login_sign_up/login_screen.dart';
import 'package:foap/screens/login_sign_up/set_profile_category_type.dart';

class ProfileController extends GetxController {
  final PostController postController = Get.find<PostController>();
  final UserProfileManager _userProfileManager = Get.find();

  // RxList<UserModel> linkedAccounts = <UserModel>[].obs;

  DataWrapper transactionsDataWrapper = DataWrapper();
  DataWrapper postDataWrapper = DataWrapper();
  DataWrapper reelsDataWrapper = DataWrapper();
  DataWrapper mentionedPostDataWrapper = DataWrapper();
  DataWrapper collaborationsDataWrapper = DataWrapper();

  Rx<UserModel?> user = Rx<UserModel?>(null);

  int totalPages = 100;

  RxInt userNameCheckStatus = (-1).obs;
  RxBool isLoading = true.obs;

  RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  RxInt selectedSegment = 0.obs;

  RxBool noDataFound = false.obs;

  RxList<PostModel> posts = <PostModel>[].obs;
  RxList<PostModel> mentions = <PostModel>[].obs;
  RxList<PostModel> reels = <PostModel>[].obs;
  RxList<PostModel> collaborations = <PostModel>[].obs;

  Rx<GiftModel?> sendingGift = Rx<GiftModel?>(null);

  clear() {
    selectedSegment.value = 0;

    postDataWrapper = DataWrapper();
    reelsDataWrapper = DataWrapper();
    mentionedPostDataWrapper = DataWrapper();
    collaborationsDataWrapper = DataWrapper();

    totalPages = 100;

    posts.clear();
    mentions.clear();
    reels.clear();
    collaborations.clear();
  }

  getMyProfile() async {
    await _userProfileManager.refreshProfile();
    user.value = _userProfileManager.user.value!;
    update();
  }

  setUser(UserModel userObj) {
    user.value = userObj;
    update();
  }

  segmentChanged(int index) {
    selectedSegment.value = index;
    postController.update();
    update();
  }

  void updateLocation({
    required String country,
    required String city,
  }) {
    if (FormValidator().isTextEmpty(country)) {
      AppUtil.showToast(
          message: pleaseEnterCountryString.tr, isSuccess: false);
    } else if (FormValidator().isTextEmpty(city)) {
      AppUtil.showToast(
          message: pleaseEnterCityString.tr, isSuccess: false);
    } else {
      Loader.show(status: loadingString.tr);

      ProfileApi.updateCountryCity(
          country: country,
          city: city,
          resultCallback: () {
            Loader.dismiss();
            AppUtil.showToast(
                message: profileUpdatedString.tr, isSuccess: true);
            _userProfileManager.refreshProfile();

            user.value!.country = country;
            user.value!.city = city;
            update();
            Future.delayed(const Duration(milliseconds: 1200), () {
              Get.back();
            });
          });
    }
  }

  void resetPassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    if (FormValidator().isTextEmpty(oldPassword)) {
      AppUtil.showToast(
          message: enterOldPasswordString.tr, isSuccess: false);
    } else if (FormValidator().isTextEmpty(newPassword)) {
      AppUtil.showToast(
          message: enterNewPasswordString.tr, isSuccess: false);
    } else if (FormValidator().isTextEmpty(confirmPassword)) {
      AppUtil.showToast(
          message: enterConfirmPasswordString.tr, isSuccess: false);
    } else if (newPassword != confirmPassword) {
      AppUtil.showToast(
          message: passwordsDoesNotMatchedString.tr, isSuccess: false);
    } else {
      Loader.show(status: loadingString.tr);

      ProfileApi.changePassword(
          oldPassword: oldPassword,
          newPassword: newPassword,
          resultCallback: () {
            Loader.dismiss();
            _userProfileManager.refreshProfile();
            Future.delayed(const Duration(milliseconds: 500), () {
              Get.to(() => const LoginScreen());
            });
          });
    }
  }

  updatePaypalId({required String paypalId}) {
    if (FormValidator().isTextEmpty(paypalId)) {
      AppUtil.showToast(
          message: pleaseEnterPaypalIdString.tr, isSuccess: false);
    } else {
      ProfileApi.updatePaymentDetails(
          paypalId: paypalId,
          resultCallback: () {
            AppUtil.showToast(
                message: paymentDetailUpdatedString.tr, isSuccess: true);
            _userProfileManager.refreshProfile();

            Future.delayed(const Duration(milliseconds: 1200), () {
              Get.back();
            });
          });
    }
  }

  void updateMobile({
    required String countryCode,
    required String phoneNumber,
  }) {
    if (FormValidator().isTextEmpty(phoneNumber)) {
      AppUtil.showToast(
          message: enterPhoneNumberString.tr, isSuccess: false);
    } else {
      Loader.show(status: loadingString.tr);

      ProfileApi.updatePhone(
          countryCode: countryCode,
          phone: phoneNumber,
          resultCallback: (token) {
            Loader.dismiss();
            _userProfileManager.refreshProfile();
            Get.to(() => VerifyOTPPhoneNumberChange(
                  token: token,
                ));
          });
    }
  }

  updateUserName({
    required String userName,
    required isSigningUp,
  }) {
    if (FormValidator().isTextEmpty(userName)) {
      AppUtil.showToast(
          message: pleaseEnterUserNameString.tr, isSuccess: false);
    } else if (userNameCheckStatus.value != 1) {
      AppUtil.showToast(
          message: pleaseEnterValidUserNameString.tr, isSuccess: false);
    } else {
      Loader.show(status: loadingString.tr);
      ProfileApi.updateUserName(
          userName: userName,
          resultCallback: () {
            Loader.dismiss();
            AppUtil.showToast(
                message: userNameIsUpdatedString.tr, isSuccess: true);
            getMyProfile();
            if (isSigningUp == true) {
              Get.to(() => const SetProfileCategoryType(
                    isFromSignup: true,
                  ));
            } else {
              Future.delayed(const Duration(milliseconds: 1200), () {
                Get.back();
              });
            }
          });
    }
  }

  updateProfileCategoryType({
    required int profileCategoryType,
    required isSigningUp,
  }) {
    Loader.show(status: loadingString.tr);

    ProfileApi.updateProfileCategoryType(
        categoryType: profileCategoryType,
        resultCallback: () {
          Loader.dismiss();
          AppUtil.showToast(
              message: categoryTypeUpdatedString.tr, isSuccess: true);
          getMyProfile();
          if (isSigningUp == true) {
            getIt<LocationManager>().postLocation();
            Get.offAll(() => const DashboardScreen());
          } else {
            Future.delayed(const Duration(milliseconds: 1200), () {
              Get.back();
            });
          }
        });
  }

  void verifyUsername({required String userName}) {
    AuthApi.checkUsername(
        username: userName,
        successCallback: () {
          userNameCheckStatus.value = 1;
          update();
        },
        failureCallback: () {
          userNameCheckStatus.value = 0;
          update();
        });
  }

  void editProfileImageAction(XFile pickedFile) async {
    Uint8List compressedData = await File(pickedFile.path)
        .compress(minHeight: 1000, minWidth: 1000, byQuality: 50);

    ProfileApi.uploadProfileImage(compressedData, resultCallback: () {
      _userProfileManager.refreshProfile().then((value) {
        user.value = _userProfileManager.user.value;
        update();
      });
    });
  }

  updateBioMetricSetting(bool value) {
    user.value!.isBioMetricLoginEnabled = value == true ? 1 : 0;
    SharedPrefs().setBioMetricAuthStatus(value);
    Loader.show(status: loadingString.tr);

    ProfileApi.updateBiometricSetting(
        setting: user.value!.isBioMetricLoginEnabled ?? 0,
        resultCallback: () {
          _userProfileManager.refreshProfile();
          Loader.dismiss();
          AppUtil.showToast(
              message: profileUpdatedString.tr, isSuccess: true);
        });
  }

  //////////////********** other user profile **************/////////////////

  void getOtherUserDetail(
      {required int userId,
      required Function(UserModel) completionBlock}) {
    UsersApi.getOtherUser(
        userId: userId,
        resultCallback: (result) {
          user.value = result;
          completionBlock(result);

          update();
        });
  }

  void followUnFollowUser({required UserModel user}) {
    if (user.isPrivateProfile &&
        user.followingStatus == FollowingStatus.notFollowing) {
      this.user.value!.followingStatus = FollowingStatus.requested;
    } else if (user.followingStatus == FollowingStatus.notFollowing) {
      this.user.value!.followingStatus = FollowingStatus.following;
    } else {
      this.user.value!.followingStatus = FollowingStatus.notFollowing;
    }

    this.user.refresh();
    update();

    UsersApi.followUnfollowUser(
            isFollowing: this.user.value!.followingStatus ==
                    FollowingStatus.notFollowing
                ? false
                : true,
            user: user)
        .then((value) {
      this.user.refresh();
      update();
    });
  }

  void reportUser() {
    user.value!.isReported = true;
    update();

    UsersApi.reportUser(userId: user.value!.id, resultCallback: () {});
  }

  void blockUser() {
    user.value!.isReported = true;
    update();

    UsersApi.blockUser(userId: user.value!.id, resultCallback: () {});
  }

//////////////********** other user profile **************/////////////////

  void withdrawalRequest() async {
    await WalletApi.performWithdrawalRequest();
    getMyProfile();
  }

  void redeemRequest(int coins, VoidCallback callback) async {
    await WalletApi.redeemCoinsRequest(coins: coins);
    await getMyProfile();
    callback();
  }

  loadMore(VoidCallback callback) {
    if (transactionsDataWrapper.haveMoreData.value) {
      getTransactionHistory(callback);
    } else {
      callback();
    }
  }

  void getTransactionHistory(VoidCallback callback) {
    WalletApi.getTransactionHistory(
        page: transactionsDataWrapper.page,
        resultCallback: (result, metadata) {
          transactions.addAll(result);
          transactions.unique((e) => e.id);

          transactionsDataWrapper.processCompletedWithData(metadata);

          callback();
          update();
        });
  }

  followUser(UserModel user) {
    user.followingStatus = user.isPrivateProfile
        ? FollowingStatus.requested
        : FollowingStatus.following;
    update();
    UsersApi.followUnfollowUser(isFollowing: true, user: user)
        .then((value) {
      update();
    });
  }

  unFollowUser(UserModel user) {
    user.followingStatus = FollowingStatus.notFollowing;

    update();
    UsersApi.followUnfollowUser(isFollowing: false, user: user)
        .then((value) {
      update();
    });
  }

  //******************** Posts ****************//
  removePostFromList(PostModel post) {
    posts.removeWhere((element) => element.id == post.id);
    mentions.removeWhere((element) => element.id == post.id);
    reels.removeWhere((element) => element.id == post.id);
    collaborations.removeWhere((element) => element.id == post.id);

    posts.refresh();
    mentions.refresh();
    reels.refresh();
    collaborations.refresh();
  }

  removeUsersAllPostFromList(PostModel post) {
    posts.removeWhere((element) => element.user.id == post.user.id);
    mentions.removeWhere((element) => element.user.id == post.user.id);
    reels.removeWhere((element) => element.user.id == post.user.id);
    collaborations
        .removeWhere((element) => element.user.id == post.user.id);

    posts.refresh();
    mentions.refresh();
    reels.refresh();
    collaborations.refresh();
  }

  void getPosts(
      {required int userId, required VoidCallback callback}) async {
    if (postDataWrapper.haveMoreData.value == true &&
        totalPages > postDataWrapper.page) {
      if (postDataWrapper.page == 1) {
        postDataWrapper.isLoading.value = true;
      }

      PostApi.getPosts(
          userId: userId,
          page: postDataWrapper.page,
          resultCallback: (result, metadata) {
            posts.addAll(result);
            posts.unique((e) => e.id);
            postDataWrapper.processCompletedWithData(metadata);

            callback();
            update();
          });
    } else {
      callback();
    }
  }

  void getReels(int userId) async {
    if (reelsDataWrapper.haveMoreData.value == true) {
      reelsDataWrapper.isLoading.value = true;
      PostApi.getPosts(
          userId: userId,
          postType: PostCategory.reel,
          page: reelsDataWrapper.page,
          resultCallback: (result, metadata) {
            reels.addAll(result);
            reels.unique((e) => e.id);
            reelsDataWrapper.processCompletedWithData(metadata);
            update();
          });
    }
  }

  void getMentionPosts(int userId) {
    if (mentionedPostDataWrapper.haveMoreData.value) {
      mentionedPostDataWrapper.isLoading.value = true;

      PostApi.getMentionedPosts(
          userId: userId,
          page: mentionedPostDataWrapper.page,
          resultCallback: (result, metadata) {
            mentions.addAll(result.reversed.toList());
            mentions.unique((e) => e.id);
            mentionedPostDataWrapper.processCompletedWithData(metadata);
            update();
          });
    }
  }

  void getCollaborationsPosts() {
    if (collaborationsDataWrapper.haveMoreData.value) {
      collaborationsDataWrapper.isLoading.value = true;

      PostApi.getPosts(
          isCollaboration: 1,
          page: collaborationsDataWrapper.page,
          resultCallback: (result, metadata) {
            collaborations.addAll(result.reversed.toList());
            collaborations.unique((e) => e.id);
            collaborationsDataWrapper.processCompletedWithData(metadata);
            update();
          });
    }
  }


  otherUserProfileView(
      {required int refId, required UserViewSourceType viewSource}) {
    UsersApi.otherUserProfileView(
        refId: refId, sourceType: userViewSourceTypeToId(viewSource));
  }
}
