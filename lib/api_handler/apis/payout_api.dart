import 'package:foap/api_handler/api_wrapper.dart';
import 'package:foap/helper/imports/common_import.dart';

class PayoutMethodItem {
  final int id;
  final String method;
  final String label;
  final String? network;
  final String accountMasked;
  final bool isDefault;

  PayoutMethodItem(
      {required this.id,
      required this.method,
      required this.label,
      required this.network,
      required this.accountMasked,
      required this.isDefault});

  factory PayoutMethodItem.fromJson(Map<String, dynamic> j) => PayoutMethodItem(
        id: int.tryParse('${j['id']}') ?? 0,
        method: '${j['method']}',
        label: '${j['label']}',
        network: j['network']?.toString(),
        accountMasked: '${j['account_masked']}',
        isDefault: '${j['is_default']}' == '1',
      );
}

class PayoutOverview {
  final List<PayoutMethodItem> methods;
  final bool holdActive;
  final String holdText;
  final int holdUntil;
  final int serverTime;
  final int holdDays;
  final String emailMasked;

  PayoutOverview(
      {required this.methods,
      required this.holdActive,
      required this.holdText,
      required this.holdUntil,
      required this.serverTime,
      required this.holdDays,
      required this.emailMasked});

  factory PayoutOverview.fromJson(Map<String, dynamic> d) => PayoutOverview(
        methods: ((d['payoutMethods'] ?? []) as List)
            .map((e) => PayoutMethodItem.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        holdActive: '${d['hold_active']}' == '1',
        holdText: '${d['hold_text'] ?? ''}',
        holdUntil: int.tryParse('${d['hold_until']}') ?? 0,
        serverTime: int.tryParse('${d['server_time']}') ?? 0,
        holdDays: int.tryParse('${d['hold_days']}') ?? 7,
        emailMasked: '${d['email_masked'] ?? ''}',
      );
}

class PayoutResult {
  final bool ok;
  final String message;
  PayoutResult(this.ok, this.message);
}

class PayoutApi {
  /// why the last overview() failed (shown on the screen so the problem can be found)
  static String lastError = '';

  static Future<PayoutOverview?> overview() async {
    lastError = '';
    try {
      final r = await ApiWrapper().getApi(url: 'payout-methods');
      if (r?.success == true && r!.data is Map) {
        return PayoutOverview.fromJson(Map<String, dynamic>.from(r.data));
      }
      lastError = (r?.message ?? '').isNotEmpty
          ? r!.message!
          : 'Server answered without payout data${r?.data is Map ? ' (${(r!.data as Map).keys.take(3).join(', ')})' : ''}';
    } catch (e) {
      lastError = 'Request failed: $e';
    }
    return null;
  }

  static Future<PayoutResult> _post(String path, Map<String, dynamic> body) async {
    final r = await ApiWrapper().postApi(url: 'payout-methods/$path', param: body);
    final msg = (r?.data is Map ? r?.data['message'] : null)?.toString() ??
        r?.message ??
        '';
    return PayoutResult(r?.success == true, msg);
  }

  static Future<PayoutResult> sendOtp() => _post('send-otp', {});

  static Future<PayoutResult> save(
          {required String method,
          required String account,
          String? network,
          required String otp,
          required bool makeDefault}) =>
      _post('save', {
        'method': method,
        'account': account,
        'network': network ?? '',
        'otp': otp,
        'make_default': makeDefault ? 1 : 0,
      });

  static Future<PayoutResult> remove({required int id, required String otp}) =>
      _post('remove', {'id': id, 'otp': otp});

  static Future<PayoutResult> makeDefault({required int id, required String otp}) =>
      _post('make-default', {'id': id, 'otp': otp});
}
