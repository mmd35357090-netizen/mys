import 'package:foap/api_handler/api_wrapper.dart';
import '../../model/api_meta_data.dart';
import '../../screens/add_on/model/pickleball_model.dart';

class PickleballApi {
  static getCourts(
      {required int page,
      String? search,
      required Function(List<PickleballCourtModel>, APIMetaData)
          resultCallback}) async {
    var url = '${NetworkConstantsUtil.pickleballCourts}?page=$page';
    if (search != null && search.isNotEmpty) {
      url += '&name=${Uri.encodeQueryComponent(search)}';
    }
    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['court']['items'] as List<dynamic>;
        resultCallback(items.map((e) => PickleballCourtModel.fromJson(e)).toList(),
            APIMetaData.fromJson(result.data['court']['_meta']));
      }
    });
  }

  /// statusType: 1 ongoing, 2 completed
  static getMatches(
      {required int page,
      required int statusType,
      required bool mineOnly,
      required Function(List<PickleballMatchModel>, APIMetaData)
          resultCallback}) async {
    var url =
        '${NetworkConstantsUtil.pickleballMatches}?page=$page&status_type=$statusType'
        '&is_my_match=${mineOnly ? 1 : 0}'
        '&expand=court,matchTeam.teamPlayer.playerDetail';
    await ApiWrapper().getApi(url: url).then((result) {
      if (result?.success == true) {
        var items = result!.data['match']['items'] as List<dynamic>;
        resultCallback(
            items.map((e) => PickleballMatchModel.fromJson(e)).toList(),
            APIMetaData.fromJson(result.data['match']['_meta']));
      }
    });
  }
}
