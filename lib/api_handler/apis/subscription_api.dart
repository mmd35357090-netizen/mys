import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/subscription_plan.dart';
import '../../model/api_meta_data.dart';
import '../api_wrapper.dart';

class SubscriptionApi {
  static getSubscriptionPlans(
      {required Function(List<SubscriptionPlan>) resultCallback}) async {
    var url = NetworkConstantsUtil.getSubscriptionPlans;

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['subscription_plan'];

        resultCallback(
          List<SubscriptionPlan>.from(
              items.map((x) => SubscriptionPlan.fromJson(x))),
        );
      }
    });
  }

  static setSubscriptionPlanCost(
      {required int planId,
      required int planCost,
      required Function() resultCallback}) async {
    var url = NetworkConstantsUtil.setSubscriptionPlanCost;

    await ApiWrapper().postApi(url: url, param: {
      'subscription_plan': [
        {
          "subscription_plan_id": planId.toString(),
          "value": planCost.toString()
        },
      ]
    }).then((result) {
      if (result?.success == true) {
        // var items = result!.data['subscription_plan'];
        //
        // resultCallback();
      }
    });
  }

  static subscribeUser(
      {required int userPlanId,
      required Function() resultCallback}) async {
    var url = NetworkConstantsUtil.subscribeUser;

    await ApiWrapper().postApi(url: url, param: {
      "subscription_plan_user_id": userPlanId.toString(),
    }).then((result) {
      if (result?.success == true) {
        // var items = result!.data['subscription_plan'];
        //
        // resultCallback();
      } else {
        AppUtil.showToast(message: result!.message!, isSuccess: false);
      }
    });
  }

  static getSubscribers(
      {required int id,
      required Function(List<UserModel>, APIMetaData)
          resultCallback}) async {
    var url = NetworkConstantsUtil.subscribersList;
    url = url.replaceAll('{{user_id}}', id.toString());

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['subscriber']['items'];

        resultCallback(
            List<UserModel>.from(items.map((x) => UserModel.fromJson(x['subscriberDetail']))),
            APIMetaData.fromJson(result.data['subscriber']['_meta']));
      }
    });
  }

  static getMySubscriptions(
      {required int id,
      required Function(List<UserModel>,APIMetaData) resultCallback}) async {
    var url = NetworkConstantsUtil.mySubscription;
    url = url.replaceAll('{{user_id}}', id.toString());

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['subscription']['items'];

        resultCallback(
          List<UserModel>.from(items.map((x) => UserModel.fromJson(x['subscriptionUserDetail']))),
            APIMetaData.fromJson(result.data['subscription']['_meta'])
        );
      }
    });
  }
}
