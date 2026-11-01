// Models for the Boost / post promotion screens: pricing limits, the
// estimate shown before paying, the campaign list and the campaign report.

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ??
      (double.tryParse(value.toString())?.toInt() ?? 0);
}

class PromotionStatus {
  static const int pending = 1;
  static const int rejected = 2;
  static const int paused = 3;
  static const int active = 10;
  static const int completed = 11;
  static const int cancelled = 12;
}

/// Limits, tax and currency, as decided by the server.
class PromotionPricing {
  String currencySymbol = '\$';
  double taxPercent = 18;
  int minDailyBudget = 1;
  int maxDailyBudget = 1000;
  int minDuration = 2;
  int maxDuration = 30;
  double pricePerView = 0;
  bool autoApprove = true;

  PromotionPricing();

  factory PromotionPricing.fromJson(dynamic json) {
    PromotionPricing model = PromotionPricing();
    if (json is! Map) return model;
    model.currencySymbol = (json['currency_symbol'] ?? '\$').toString();
    model.taxPercent = _toDouble(json['tax_percent']);
    model.minDailyBudget = _toInt(json['min_daily_budget']);
    model.maxDailyBudget = _toInt(json['max_daily_budget']);
    model.minDuration = _toInt(json['min_duration']);
    model.maxDuration = _toInt(json['max_duration']);
    model.pricePerView = _toDouble(json['price_per_view']);
    model.autoApprove = _toInt(json['auto_approve']) == 1;
    // never let a broken response produce an unusable slider
    if (model.maxDailyBudget <= model.minDailyBudget) {
      model.minDailyBudget = 1;
      model.maxDailyBudget = 1000;
    }
    if (model.maxDuration <= model.minDuration) {
      model.minDuration = 2;
      model.maxDuration = 30;
    }
    return model;
  }
}

/// What the server calculates for a given budget and audience.
class PromotionEstimate {
  bool available = false;
  int? audienceSize;
  int? reachMin;
  int? reachMax;
  String? error;
  double totalAmount = 0;
  double tax = 0;
  double grandAmount = 0;

  PromotionEstimate();

  factory PromotionEstimate.fromJson(dynamic json) {
    PromotionEstimate model = PromotionEstimate();
    if (json is! Map) return model;
    model.available = json['available'] == true || json['available'] == 1;
    model.audienceSize =
        json['audience_size'] == null ? null : _toInt(json['audience_size']);
    model.reachMin =
        json['reach_min'] == null ? null : _toInt(json['reach_min']);
    model.reachMax =
        json['reach_max'] == null ? null : _toInt(json['reach_max']);
    model.error = json['error']?.toString();
    var pricing = json['pricing'];
    if (pricing is Map) {
      model.totalAmount = _toDouble(pricing['total_amount']);
      model.tax = _toDouble(pricing['tax']);
      model.grandAmount = _toDouble(pricing['grand_amount']);
    }
    return model;
  }
}

class PromotionDailyPoint {
  String date = '';
  int reach = 0;
  int actions = 0;

  PromotionDailyPoint();

  factory PromotionDailyPoint.fromJson(dynamic json) {
    PromotionDailyPoint model = PromotionDailyPoint();
    model.date = (json['date'] ?? '').toString();
    model.reach = _toInt(json['reach']);
    model.actions = _toInt(json['actions']);
    return model;
  }
}

/// One campaign. The list fills the first block of fields, the report fills all of them.
class PromotionCampaign {
  int id = 0;
  int postId = 0;
  String postTitle = '';
  int goalType = 1; // 1 profile visits, 2 messages, 4 website visits
  int status = 0;
  String statusLabel = '';
  double dailyBudget = 0;
  int duration = 0;
  double totalAmount = 0;
  double grandAmount = 0;
  double spend = 0;
  int reach = 0;
  int impressions = 0;
  int createdAt = 0;
  int expiry = 0;

  // report only
  double remaining = 0;
  int clicks = 0;
  int profileVisits = 0;
  int messages = 0;
  int websiteVisits = 0;
  int results = 0;
  double? costPerResult;
  double ctr = 0;
  int newFollowers = 0;
  String currencySymbol = '\$';
  bool trackingAvailable = true;
  List<PromotionDailyPoint> daily = [];
  Map<String, int> gender = {};
  Map<String, int> age = {};

  PromotionCampaign();

  factory PromotionCampaign.fromJson(dynamic json) {
    PromotionCampaign model = PromotionCampaign();
    model.id = _toInt(json['id']);
    model.postId = _toInt(json['post_id']);
    model.postTitle = (json['post_title'] ?? '').toString();
    model.goalType = _toInt(json['goal_type']);
    model.status = _toInt(json['status']);
    model.statusLabel = (json['status_label'] ?? '').toString();
    model.dailyBudget = _toDouble(json['daily_budget']);
    model.duration = _toInt(json['duration']);
    model.totalAmount = _toDouble(json['total_amount']);
    model.grandAmount = _toDouble(json['grand_amount']);
    model.spend = _toDouble(json['spend']);
    model.reach = _toInt(json['reach']);
    model.impressions = _toInt(json['impressions']);
    model.createdAt = _toInt(json['created_at']);
    model.expiry = _toInt(json['expiry']);

    model.remaining = _toDouble(json['remaining']);
    model.clicks = _toInt(json['clicks']);
    model.profileVisits = _toInt(json['profile_visits']);
    model.messages = _toInt(json['messages']);
    model.websiteVisits = _toInt(json['website_visits']);
    model.results = _toInt(json['results']);
    model.costPerResult = json['cost_per_result'] == null
        ? null
        : _toDouble(json['cost_per_result']);
    model.ctr = _toDouble(json['ctr']);
    model.newFollowers = _toInt(json['new_followers']);
    if (json['currency_symbol'] != null) {
      model.currencySymbol = json['currency_symbol'].toString();
    }
    model.trackingAvailable = json['tracking_available'] == null
        ? true
        : _toInt(json['tracking_available']) == 1;

    if (json['daily'] is List) {
      model.daily = (json['daily'] as List)
          .map((e) => PromotionDailyPoint.fromJson(e))
          .toList();
    }
    if (json['gender'] is Map) {
      (json['gender'] as Map).forEach((key, value) {
        model.gender[key.toString()] = _toInt(value);
      });
    }
    if (json['age'] is Map) {
      (json['age'] as Map).forEach((key, value) {
        model.age[key.toString()] = _toInt(value);
      });
    }
    return model;
  }

  bool get isRunning =>
      status == PromotionStatus.active || status == PromotionStatus.paused;

  bool get canBeCancelled => isRunning || status == PromotionStatus.pending;

  /// Whole days left (0 when it is over).
  int get daysLeft {
    if (expiry <= 0) return 0;
    int seconds = expiry - DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (seconds <= 0) return 0;
    return (seconds / 86400).ceil();
  }

  /// Share of the budget already used, from 0 to 1.
  double get spendProgress {
    if (totalAmount <= 0) return 0;
    double value = spend / totalAmount;
    if (value < 0) return 0;
    if (value > 1) return 1;
    return value;
  }
}
