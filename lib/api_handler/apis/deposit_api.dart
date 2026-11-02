import '../../helper/imports/common_import.dart';
import '../../model/api_meta_data.dart';
import '../../model/deposit_model.dart';
import '../api_wrapper.dart';

class DepositApi {
  static Future getMethods(
      {required Function(List<DepositMethodModel>) resultCallback}) async {
    await ApiWrapper()
        .getApi(url: NetworkConstantsUtil.depositMethods)
        .then((response) {
      if (response?.success == true && response!.data['methods'] is List) {
        List data = response.data['methods'];
        resultCallback(data.map((e) => DepositMethodModel.fromJson(e)).toList());
      }
    });
  }

  /// Returns null when it worked, otherwise the message to show.
  /// [rateChanged] is true when the server says the rate moved meanwhile.
  static Future<({String? error, bool rateChanged})> createRequest({
    required int methodId,
    required double usdAmount,
    required double expectedLocalAmount,
    required String trxId,
    required String senderNumber,
    String? proofImage,
    String? note,
  }) async {
    final response = await ApiWrapper().postApi(
        url: NetworkConstantsUtil.depositCreate,
        param: {
          'method_id': methodId,
          'usd_amount': usdAmount,
          'expected_local_amount': expectedLocalAmount,
          'trx_id': trxId,
          'sender_number': senderNumber,
          'proof_image': proofImage ?? '',
          'user_note': note ?? '',
        });

    if (response?.success == true) {
      return (error: null, rateChanged: false);
    }
    bool rateChanged = false;
    try {
      rateChanged = _int(response?.data?['rate_changed']) == 1;
    } catch (_) {}
    String message = (response?.message ?? '').isNotEmpty
        ? response!.message!
        : errorString.tr;
    return (error: message, rateChanged: rateChanged);
  }

  static Future getRequests(
      {required int page,
      required Function(List<DepositRequestModel>, APIMetaData)
          resultCallback}) async {
    await ApiWrapper()
        .getApi(url: '${NetworkConstantsUtil.depositRequests}?page=$page')
        .then((response) {
      if (response?.success == true && response!.data['requests'] != null) {
        List data = response.data['requests']['items'] ?? [];
        resultCallback(
            data.map((e) => DepositRequestModel.fromJson(e)).toList(),
            APIMetaData.fromJson(response.data['requests']['_meta']));
      }
    });
  }

  static int _int(dynamic v) {
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}
