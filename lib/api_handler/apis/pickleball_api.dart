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

  static getMatch(
      {required int id,
      required Function(PickleballMatchModel) resultCallback}) async {
    await ApiWrapper()
        .getApi(
            url:
                '${NetworkConstantsUtil.pickleballMatchDetail}/$id?expand=court,matchTeam.teamPlayer.playerDetail')
        .then((result) {
      if (result?.success == true && result!.data['match'] != null) {
        resultCallback(PickleballMatchModel.fromJson(result.data['match']));
      }
    });
  }

  /// teams: [{name, player: [{player_id, is_send_invitation}]}]
  static createMatch(
      {required int courtId,
      required int matchType,
      required int pointToWin,
      required int startTime,
      required List<Map<String, dynamic>> teams,
      required Function(bool, String?) resultCallback}) async {
    await ApiWrapper().postApi(url: NetworkConstantsUtil.pickleballCreateMatch, param: {
      'court_id': courtId,
      'match_type': matchType,
      'point_to_win': pointToWin,
      'start_time': startTime,
      'match_team': teams,
    }).then((result) {
      resultCallback(result?.success == true, result?.message);
    });
  }

  static replyInvitation(
      {required int teamPlayerId,
      required bool accept,
      required Function(bool, String?) resultCallback}) async {
    await ApiWrapper().postApi(
        url: NetworkConstantsUtil.pickleballReplyInvitation,
        param: {
          'id': teamPlayerId,
          'status': accept ? 3 : 2
        }).then((result) {
      resultCallback(result?.success == true, result?.message);
    });
  }

  static addPlayer(
      {required int teamId,
      required int playerId,
      required Function(bool, String?) resultCallback}) async {
    await ApiWrapper().postApi(
        url: NetworkConstantsUtil.pickleballAddPlayer,
        param: {'team_id': teamId, 'player_id': playerId}).then((result) {
      resultCallback(result?.success == true, result?.message);
    });
  }

  static removePlayer(
      {required int teamPlayerId,
      required Function(bool, String?) resultCallback}) async {
    await ApiWrapper().postApi(
        url: NetworkConstantsUtil.pickleballRemovePlayer,
        param: {'id': teamPlayerId}).then((result) {
      resultCallback(result?.success == true, result?.message);
    });
  }

  static getTopPlayers(
      {required int page,
      required Function(List<PickleballTopPlayer>, APIMetaData)
          resultCallback}) async {
    await ApiWrapper()
        .getApi(
            url:
                '${NetworkConstantsUtil.pickleballTopPlayers}?page=$page&expand=pickleballSummary')
        .then((result) {
      if (result?.success == true) {
        var items = result!.data['player']['items'] as List<dynamic>;
        resultCallback(
            items.map((e) => PickleballTopPlayer.fromJson(e)).toList(),
            APIMetaData.fromJson(result.data['player']['_meta']));
      }
    });
  }

  /// teams: [{team_id, team_point, player: [{player_id, point_gain}]}]
  static declareResult(
      {required int matchId,
      required int winnerTeamId,
      required List<Map<String, dynamic>> teams,
      required Function(bool, String?) resultCallback}) async {
    await ApiWrapper().postApi(
        url: NetworkConstantsUtil.pickleballDeclareResult,
        param: {
          'id': matchId,
          'winner_team_id': winnerTeamId,
          'match_team': teams,
        }).then((result) {
      resultCallback(result?.success == true, result?.message);
    });
  }
}
