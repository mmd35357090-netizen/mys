// Models for the manual wallet top-up (bKash, Nagad, ...).
// The wallet is always in USD; the rate converts it to the local currency.

double _num(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

int _int(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

class DepositStatus {
  static const int pending = 1;
  static const int rejected = 2;
  static const int approved = 10;
}

class DepositMethodModel {
  int id = 0;
  String title = '';
  int accountType = 1;
  String accountTypeLabel = '';
  String accountNumber = '';
  String accountName = '';
  String currencyCode = '';
  String currencySymbol = '';
  int currencyDecimals = 2;
  double rate = 1;
  double feePercent = 0;
  double minUsd = 1;
  double maxUsd = 1000;
  bool requireScreenshot = true;
  String instructions = '';

  DepositMethodModel();

  factory DepositMethodModel.fromJson(dynamic json) {
    DepositMethodModel m = DepositMethodModel();
    m.id = _int(json['id']);
    m.title = (json['title'] ?? '').toString();
    m.accountType = _int(json['account_type']);
    m.accountTypeLabel = (json['account_type_label'] ?? '').toString();
    m.accountNumber = (json['account_number'] ?? '').toString();
    m.accountName = (json['account_name'] ?? '').toString();
    m.currencyCode = (json['currency_code'] ?? '').toString();
    m.currencySymbol = (json['currency_symbol'] ?? m.currencyCode).toString();
    m.currencyDecimals = _int(json['currency_decimals']);
    m.rate = _num(json['rate']);
    m.feePercent = _num(json['fee_percent']);
    m.minUsd = _num(json['min_usd']);
    m.maxUsd = _num(json['max_usd']);
    m.requireScreenshot = _int(json['require_screenshot']) == 1;
    m.instructions = (json['instructions'] ?? '').toString();
    return m;
  }

  /// Same rule as the server: usd x rate x (1 + fee%), rounded to the currency decimals.
  double localAmountFor(double usd) {
    double value = usd * rate * (1 + feePercent / 100);
    return double.parse(value.toStringAsFixed(currencyDecimals));
  }

  String formatLocal(double value) {
    String fixed = value.toStringAsFixed(currencyDecimals);
    List<String> parts = fixed.split('.');
    String whole = parts[0];
    String grouped = '';
    for (int i = 0; i < whole.length; i++) {
      int fromEnd = whole.length - i;
      grouped += whole[i];
      if (fromEnd > 1 && fromEnd % 3 == 1 && whole[i] != '-') {
        grouped += ',';
      }
    }
    String result = parts.length > 1 ? '$grouped.${parts[1]}' : grouped;
    return '$currencySymbol$result';
  }

  String get rateText {
    String r = rate == rate.roundToDouble()
        ? rate.toStringAsFixed(0)
        : rate.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '');
    return '$currencySymbol$r';
  }
}

class DepositRequestModel {
  int id = 0;
  String methodTitle = '';
  String accountTypeLabel = '';
  String currencySymbol = '';
  double usdAmount = 0;
  double localAmount = 0;
  double? creditedUsd;
  String trxId = '';
  int status = DepositStatus.pending;
  String statusLabel = '';
  String adminNote = '';
  String? proofUrl;
  int createdAt = 0;

  DepositRequestModel();

  factory DepositRequestModel.fromJson(dynamic json) {
    DepositRequestModel m = DepositRequestModel();
    m.id = _int(json['id']);
    m.methodTitle = (json['method_title'] ?? '').toString();
    m.accountTypeLabel = (json['account_type_label'] ?? '').toString();
    m.currencySymbol = (json['currency_symbol'] ?? '').toString();
    m.usdAmount = _num(json['usd_amount']);
    m.localAmount = _num(json['local_amount']);
    m.creditedUsd =
        json['credited_usd'] == null ? null : _num(json['credited_usd']);
    m.trxId = (json['trx_id'] ?? '').toString();
    m.status = _int(json['status']);
    m.statusLabel = (json['status_label'] ?? '').toString();
    m.adminNote = (json['admin_note'] ?? '').toString();
    m.proofUrl = json['proof_url']?.toString();
    m.createdAt = _int(json['created_at']);
    return m;
  }
}
