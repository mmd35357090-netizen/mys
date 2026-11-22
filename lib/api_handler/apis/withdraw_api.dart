import 'package:foap/api_handler/api_wrapper.dart';
import 'package:foap/helper/imports/common_import.dart';

class WithdrawOption {
  final String method;
  final String title;
  final String currencyCode;
  final String currencySymbol;
  final int decimals;
  final double rate;
  final double feePercent;
  final double feeFixedUsd;
  final double minUsd;
  final double maxUsd;
  final String note;
  final bool hasAccount;
  final String accountMasked;

  WithdrawOption(
      {required this.method,
      required this.title,
      required this.currencyCode,
      required this.currencySymbol,
      required this.decimals,
      required this.rate,
      required this.feePercent,
      required this.feeFixedUsd,
      required this.minUsd,
      required this.maxUsd,
      required this.note,
      required this.hasAccount,
      required this.accountMasked});

  static double _d(dynamic v) => double.tryParse('$v') ?? 0;

  factory WithdrawOption.fromJson(Map<String, dynamic> j) => WithdrawOption(
        method: '${j['method']}',
        title: '${j['title']}',
        currencyCode: '${j['currency_code']}',
        currencySymbol: '${j['currency_symbol']}',
        decimals: int.tryParse('${j['currency_decimals']}') ?? 2,
        rate: _d(j['rate']),
        feePercent: _d(j['fee_percent']),
        feeFixedUsd: _d(j['fee_fixed_usd']),
        minUsd: _d(j['min_usd']),
        maxUsd: _d(j['max_usd']),
        note: '${j['note'] ?? ''}',
        hasAccount: '${j['has_account']}' == '1',
        accountMasked: '${j['account_masked'] ?? ''}',
      );

  double feeFor(double amount) =>
      double.parse((amount * feePercent / 100 + feeFixedUsd).toStringAsFixed(2));
  double netUsd(double amount) =>
      double.parse((amount - feeFor(amount)).toStringAsFixed(2));
  double netLocal(double amount) => double.parse(
      (netUsd(amount) * rate).toStringAsFixed(decimals));
}

class WithdrawOverview {
  final double balance;
  final bool blocked;
  final String blockMessage;
  final List<WithdrawOption> options;
  WithdrawOverview(this.balance, this.blocked, this.blockMessage, this.options);
}

class WithdrawResult {
  final bool ok;
  final String message;
  WithdrawResult(this.ok, this.message);
}

class WithdrawApi {
  static String lastError = '';

  static Future<WithdrawOverview?> overview() async {
    lastError = '';
    try {
      final r = await ApiWrapper().getApi(url: 'withdraw-options');
      if (r?.success == true && r!.data is Map) {
        final d = Map<String, dynamic>.from(r.data);
        return WithdrawOverview(
            double.tryParse('${d['balance']}') ?? 0,
            '${d['blocked']}' == '1',
            '${d['block_message'] ?? ''}',
            ((d['withdrawMethods'] ?? []) as List)
                .map((e) => WithdrawOption.fromJson(Map<String, dynamic>.from(e)))
                .toList());
      }
      lastError = (r?.message ?? '').isNotEmpty ? r!.message! : 'Could not load withdraw options';
    } catch (e) {
      lastError = 'Request failed: $e';
    }
    return null;
  }

  static Future<WithdrawResult> request(
      {required String method, required double amount}) async {
    final r = await ApiWrapper().postApi(
        url: 'withdraw-options/request',
        param: {'method': method, 'amount': amount.toStringAsFixed(2)});
    final msg = (r?.data is Map ? r?.data['message'] : null)?.toString() ??
        r?.message ??
        '';
    return WithdrawResult(r?.success == true, msg);
  }
}
