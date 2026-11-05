import '../../helper/imports/common_import.dart';
import '../../model/api_meta_data.dart';
import '../../model/coin_history_model.dart';
import '../api_wrapper.dart';

class CoinHistoryApi {
  /// [filter]: all, bought, earned, spent or refund
  static Future getHistory(
      {required String filter,
      required int page,
      required Function(CoinSummary, List<CoinHistoryEntry>, APIMetaData)
          resultCallback,
      Function()? errorCallback}) async {
    final url =
        '${NetworkConstantsUtil.coinHistory}?filter=$filter&page=$page';
    await ApiWrapper().getApi(url: url).then((response) {
      if (response?.success == true && response!.data['payment'] != null) {
        final List items = response.data['payment']['items'] ?? [];
        resultCallback(
            CoinSummary.fromJson(response.data),
            items.map((e) => CoinHistoryEntry.fromJson(e)).toList(),
            APIMetaData.fromJson(response.data['payment']['_meta']));
      } else if (errorCallback != null) {
        errorCallback();
      }
    });
  }
}
