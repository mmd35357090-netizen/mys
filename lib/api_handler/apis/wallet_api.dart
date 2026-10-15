import 'dart:ui';
import 'package:foap/api_handler/api_wrapper.dart';
import '../../model/api_meta_data.dart';
import '../../model/package_model.dart';
import '../../model/payment_model.dart';

class WalletApi {
  static getAllPackages(
      {required Function(List<PackageModel>) resultCallback}) async {
    var url = NetworkConstantsUtil.getPackages;

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var packagesArr = result!.data['package'];
        resultCallback(List<PackageModel>.from(
            packagesArr.map((x) => PackageModel.fromJson(x))));
      }
    });
  }

  static subscribePackage(
      {required String packageId,
      required String transactionId,
      required String amount,
      required VoidCallback resultCallback}) async {
    var url = NetworkConstantsUtil.subscribePackage;

    await ApiWrapper().postApi(url: url, param: {
      "package_id": packageId,
      "transaction_id": transactionId,
      "amount": amount
    }).then((result) {
      if (result?.success == true) {
        resultCallback();
      }
    });
  }

  static getTransactionHistory(
      {required int page,
      required Function(List<TransactionModel>, APIMetaData)
          resultCallback}) async {
    var url = NetworkConstantsUtil.transactionHistory;
    url = '${url}month=2000-08,2050-09&page=$page';

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        resultCallback(
            List<TransactionModel>.from(result!.data['payment']['items']
                .map((x) => TransactionModel.fromJson(x))),
            APIMetaData.fromJson(result.data['payment']['_meta']));
      }
    });
  }

  static Future performWithdrawalRequest() async {
    var url = NetworkConstantsUtil.withdrawalRequest;

    await ApiWrapper().postApi(url: url, param: null).then((result) {
      if (result?.success == true) {}
    });
  }

  static Future redeemCoinsRequest({required int coins}) async {
    var url = NetworkConstantsUtil.redeemCoins;

    await ApiWrapper().postApi(
        url: url, param: {"redeem_coin": coins.toString()}).then((result) {
      if (result?.success == true) {}
    });
  }

  static Future rewardCoins() async {
    var url = NetworkConstantsUtil.rewardedAdCoins;

    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {}
    });
  }
}
