import 'package:foap/api_handler/apis/subscription_api.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/data_wrapper.dart';
import 'package:foap/model/subscription_plan.dart';

class UserSubscriptionController extends GetxController {
  final UserProfileManager _userProfileManager = Get.find();
  RxList<SubscriptionPlan> plans = <SubscriptionPlan>[].obs;
  RxList<UserModel> subscribers = <UserModel>[].obs;
  RxList<UserModel> subscriptions = <UserModel>[].obs;

  DataWrapper subscribersDataWrapper = DataWrapper();
  DataWrapper subscriptionsDataWrapper = DataWrapper();

  List<int> coinsList = [100, 200, 500, 1000, 2000];
  RxInt selectedCoins = 100.obs;

  setExistingSubscriptionCost() {
    if (_userProfileManager.user.value!.subscriptionPlans.isNotEmpty) {
      selectedCoins.value =
          _userProfileManager.user.value!.subscriptionPlans.first.value!;
    } else {
      selectedCoins.value = 100;
    }
  }

  selectSubscriptionCoins(int value) {
    selectedCoins.value = value;
  }

  getSubscriptionPlans() {
    setExistingSubscriptionCost();
    SubscriptionApi.getSubscriptionPlans(resultCallback: (result) {
      plans.value = result;
    });
  }

  setSubscriptionPlanCost() {
    SubscriptionApi.setSubscriptionPlanCost(
        planId: plans.first.id,
        planCost: selectedCoins.value,
        resultCallback: () {});
  }

  subscribeUser(
      {required int userPlanId, required VoidCallback succesCalback}) {
    SubscriptionApi.subscribeUser(
      userPlanId: userPlanId,
      resultCallback: () {
        succesCalback();
      },
    );
  }

  loadMoreSubscribers(VoidCallback callback) {
    if (subscribersDataWrapper.isLoading.value) return;
    subscribersDataWrapper.isLoading.value = true;
    if (subscribersDataWrapper.haveMoreData.value) {
      getMySubscribers(callback);
    } else {
      callback();
    }
  }

  getMySubscribers(VoidCallback callback) {
    var id = _userProfileManager.user.value!.id;
    SubscriptionApi.getSubscribers(
        id: id,
        resultCallback: (result, metadata) {
          subscribers.value = result;
          subscribersDataWrapper.processCompletedWithData(metadata);
          callback();
        });
  }

  loadMoreSubscriptions(VoidCallback callback) {
    if (subscriptionsDataWrapper.isLoading.value) return;
    subscriptionsDataWrapper.isLoading.value = true;
    if (subscriptionsDataWrapper.haveMoreData.value) {
      getMySubscriptions(callback);
    } else {
      callback();
    }
  }

  getMySubscriptions(VoidCallback callback) {
    var id = _userProfileManager.user.value!.id;
    SubscriptionApi.getMySubscriptions(
        id: id,
        resultCallback: (result, metadata) {
          print('subscriptions: ${subscriptions.length}');
          subscriptions.value = result;
          subscriptionsDataWrapper.processCompletedWithData(metadata);
          callback();
        });
  }
}
