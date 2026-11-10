import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/model/subscription_plan_model.dart';
import '../../model/api_meta_data.dart';
import '../api_wrapper.dart';

/// One subscription row: the other person plus what was paid and until when.
class SubscriptionInfo {
  final UserModel user;
  final int coins;
  final int expiryTime; // unix seconds
  final int startedAt; // unix seconds

  SubscriptionInfo(
      {required this.user,
      required this.coins,
      required this.expiryTime,
      required this.startedAt});

  bool get isActive =>
      expiryTime > DateTime.now().millisecondsSinceEpoch ~/ 1000;

  int get daysLeft {
    final int left = expiryTime - DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return left <= 0 ? 0 : (left / 86400).ceil();
  }

  static int _toInt(dynamic v) =>
      v == null ? 0 : (double.tryParse(v.toString()) ?? 0).round();

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json, String key) {
    return SubscriptionInfo(
      user: UserModel.fromJson(json[key]),
      coins: _toInt(json['subscription_plan_value']),
      expiryTime: _toInt(json['expiry_time']),
      startedAt: _toInt(json['created_at']),
    );
  }
}

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
      required Function(List<SubscriptionInfo>, APIMetaData)
          resultCallback}) async {
    var url = NetworkConstantsUtil.subscribersList;
    url = url.replaceAll('{{user_id}}', id.toString());

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['subscriber']['items'];

        resultCallback(
            List<SubscriptionInfo>.from(items
                .where((x) => x['subscriberDetail'] != null)
                .map((x) => SubscriptionInfo.fromJson(
                    Map<String, dynamic>.from(x), 'subscriberDetail'))),
            APIMetaData.fromJson(result.data['subscriber']['_meta']));
      }
    });
  }

  static getMySubscriptions(
      {required int id,
      required Function(List<SubscriptionInfo>, APIMetaData)
          resultCallback}) async {
    var url = NetworkConstantsUtil.mySubscription;
    url = url.replaceAll('{{user_id}}', id.toString());

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['subscription']['items'];

        resultCallback(
          List<SubscriptionInfo>.from(items
              .where((x) => x['subscriptionUserDetail'] != null)
              .map((x) => SubscriptionInfo.fromJson(
                  Map<String, dynamic>.from(x), 'subscriptionUserDetail'))),
            APIMetaData.fromJson(result.data['subscription']['_meta'])
        );
      }
    });
  }
}
