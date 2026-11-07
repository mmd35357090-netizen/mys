import '../../helper/imports/common_import.dart';
import '../api_wrapper.dart';

class CreatorPoolApi {
  /// Tells the server that a feed ad was shown next to this post (used for the creator revenue share).
  /// It must never disturb the app, so every error is ignored.
  static void reportAdImpression({required int postId}) {
    try {
      ApiWrapper()
          .postApi(
              url: NetworkConstantsUtil.creatorAdImpression,
              param: {'post_id': postId.toString()})
          .then((_) {})
          .catchError((_) {});
    } catch (_) {}
  }
}

class CreatorStatus {
  bool enabled = false;
  double sharePercent = 0;
  bool eligible = false;
  int followers = 0, followersNeeded = 0;
  int posts = 0, postsNeeded = 0;
  int accountDays = 0, accountDaysNeeded = 0;
  int thisMonthPoints = 0, todayPoints = 0, allCreatorsPoints = 0;
  double shareOfPoolPercent = 0;
  int lastPayoutCoins = 0;
  int lastPayoutTime = 0;

  static int _i(dynamic v) => int.tryParse((v ?? 0).toString()) ?? 0;
  static double _d(dynamic v) => double.tryParse((v ?? 0).toString()) ?? 0;

  CreatorStatus.fromJson(Map<String, dynamic> json) {
    enabled = json['enabled'] == true;
    sharePercent = _d(json['share_percent']);
    final Map e = (json['eligibility'] ?? {}) as Map;
    eligible = e['eligible'] == true;
    followers = _i(e['followers']);
    followersNeeded = _i(e['followers_needed']);
    posts = _i(e['posts']);
    postsNeeded = _i(e['posts_needed']);
    accountDays = _i(e['account_days']);
    accountDaysNeeded = _i(e['account_days_needed']);
    thisMonthPoints = _i(json['this_month_points']);
    todayPoints = _i(json['today_points']);
    allCreatorsPoints = _i(json['all_creators_points']);
    shareOfPoolPercent = _d(json['share_of_pool_percent']);
    if (json['last_payout'] is Map) {
      lastPayoutCoins = _i(json['last_payout']['coins']);
      lastPayoutTime = _i(json['last_payout']['time']);
    }
  }
}

class CreatorStatusApi {
  static Future getStatus(
      {required Function(CreatorStatus) resultCallback,
      Function()? errorCallback}) async {
    await ApiWrapper()
        .getApi(url: NetworkConstantsUtil.creatorPoolStatus)
        .then((response) {
      if (response?.success == true && response!.data != null) {
        resultCallback(CreatorStatus.fromJson(
            Map<String, dynamic>.from(response.data as Map)));
      } else if (errorCallback != null) {
        errorCallback();
      }
    });
  }
}
