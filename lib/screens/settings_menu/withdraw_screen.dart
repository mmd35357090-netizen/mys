import 'package:flutter/services.dart';
import 'package:foap/util/biometric_helper.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../api_handler/apis/withdraw_api.dart';
import '../profile/change_paypal_id.dart';

/// Withdraw: choose an amount, choose a method (rate + fee are set by the admin),
/// see exactly what you will receive, then confirm.
class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final UserProfileManager _userProfileManager = Get.find();
  final TextEditingController _amount = TextEditingController();

  WithdrawOverview? _data;
  String? _error;
  bool _loading = true;
  bool _busy = false;
  String? _selected;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final d = await WithdrawApi.overview();
    if (!mounted) return;
    setState(() {
      _data = d;
      _error = d == null ? WithdrawApi.lastError : null;
      _loading = false;
      if (d != null && d.options.isNotEmpty) {
        final keep = d.options.any((o) => o.method == _selected);
        if (!keep) {
          _selected = d.options.firstWhere((o) => o.hasAccount, orElse: () => d.options.first).method;
        }
      }
    });
  }

  WithdrawOption? get _opt {
    final d = _data;
    if (d == null || _selected == null) return null;
    for (final o in d.options) {
      if (o.method == _selected) return o;
    }
    return null;
  }

  double get _value => double.tryParse(_amount.text.trim()) ?? 0;

  String _money(double v, int dec) => v.toStringAsFixed(dec);

  /// null when the amount can be sent
  String? _problem() {
    final o = _opt;
    final d = _data!;
    final a = _value;
    if (o == null) return 'Choose a method';
    if (!o.hasAccount) return 'Add your ${o.title} account first';
    if (a <= 0) return 'Enter an amount';
    if (a + 0.0001 < o.minUsd) return 'Minimum is \$${_money(o.minUsd, 2)}';
    if (a > o.maxUsd + 0.0001) return 'Maximum is \$${_money(o.maxUsd, 2)}';
    if (a > d.balance + 0.004) return 'More than your balance';
    if (o.netUsd(a) <= 0) return 'Too small to cover the charge';
    return null;
  }

  Future<void> _submit() async {
    final o = _opt!;
    final a = _value;
    final yes = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
              title: const Text('Confirm withdrawal'),
              content: Text(
                  'Withdraw \$${_money(a, 2)} to ${o.title} (${o.accountMasked})?\n\n'
                  'Charge: \$${_money(o.feeFor(a), 2)}\n'
                  'You will receive: ${o.currencySymbol}${_money(o.netLocal(a), o.decimals)} ${o.currencyCode}'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Confirm')),
              ],
            ));
    if (yes != true) return;
    if (!await BiometricHelper.confirmIfEnabled(withdrawString.tr)) return;
    setState(() => _busy = true);
    final r = await WithdrawApi.request(method: o.method, amount: a);
    if (!mounted) return;
    setState(() => _busy = false);
    AppUtil.showToast(
        message: r.message.isEmpty ? (r.ok ? 'Withdrawal requested' : 'Failed') : r.message,
        isSuccess: r.ok);
    if (r.ok) {
      _userProfileManager.refreshProfile();
      Get.back();
    } else {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(children: [
        backNavigationBar(title: withdrawString.tr),
        Expanded(child: _body()),
      ]),
    );
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_data == null) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_error ?? 'Could not load', textAlign: TextAlign.center),
          const SizedBox(height: 12),
          TextButton(onPressed: _load, child: const Text('Retry')),
        ]),
      ));
    }
    final d = _data!;
    final o = _opt;
    final a = _value;
    final problem = _problem();
    final pad = DesignConstants.horizontalPadding;

    return ListView(padding: EdgeInsets.fromLTRB(pad, 8, pad, 40), children: [
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(colors: [
            AppColorConstants.themeColor,
            AppColorConstants.themeColor.withValues(alpha: 0.72)
          ]),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Available balance',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('\$${_money(d.balance < 0.005 ? 0 : d.balance, 2)}',
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
        ]),
      ),
      const SizedBox(height: 14),
      if (d.blocked)
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
              color: const Color(0xFFFFF1E0),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE07B00).withValues(alpha: 0.5))),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.lock_clock_rounded, color: Color(0xFFE07B00)),
            const SizedBox(width: 10),
            Expanded(child: Text(d.blockMessage, style: const TextStyle(color: Colors.black87))),
          ]),
        ),
      const Text('Amount (USD)', style: TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      TextField(
        controller: _amount,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d{0,7}(\.\d{0,2})?'))],
        onChanged: (_) => setState(() {}),
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          prefixText: '\$ ',
          hintText: '0.00',
          suffix: TextButton(
              onPressed: () {
                final cap = o == null ? d.balance : (d.balance < o.maxUsd ? d.balance : o.maxUsd);
                _amount.text = (cap < 0 ? 0 : cap).toStringAsFixed(2);
                setState(() {});
              },
              child: const Text('Max')),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      const SizedBox(height: 18),
      const Text('Receive with', style: TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      if (d.options.isEmpty)
        const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Withdrawals are not open right now. Please try later.'))
      else
        ...d.options.map((m) => _methodTile(m)),
      if (o != null) ...[
        const SizedBox(height: 14),
        _summary(o, a),
      ],
      const SizedBox(height: 18),
      if (o != null && !o.hasAccount)
        AppThemeButton(
            onPress: () async {
              await Get.to(() => const ChangePaypalId());
              _load();
            },
            text: 'Add ${o.title} account')
      else
        Opacity(
          opacity: (problem == null && !d.blocked && !_busy) ? 1 : 0.45,
          child: AppThemeButton(
              onPress: () {
                if (_busy || d.blocked) return;
                if (problem != null) {
                  AppUtil.showToast(message: problem, isSuccess: false);
                  return;
                }
                _submit();
              },
              text: _busy ? 'Please wait…' : (problem == null ? 'Withdraw' : problem)),
        ),
    ]);
  }

  Widget _methodTile(WithdrawOption m) {
    final sel = m.method == _selected;
    final rateText = m.rate == 1 && m.currencyCode.toUpperCase().startsWith('U')
        ? m.currencyCode
        : '1 USD = ${m.rate.toString().replaceAll(RegExp(r'\.0+$'), '')} ${m.currencyCode}';
    final feeText = [
      if (m.feePercent > 0) '${m.feePercent.toString().replaceAll(RegExp(r'\.0+$'), '')}%',
      if (m.feeFixedUsd > 0) '\$${m.feeFixedUsd.toStringAsFixed(2)}',
    ].join(' + ');
    return GestureDetector(
      onTap: () => setState(() => _selected = m.method),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColorConstants.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: sel ? AppColorConstants.themeColor : Colors.grey.withValues(alpha: 0.25),
              width: sel ? 2 : 1),
        ),
        child: Row(children: [
          Icon(sel ? Icons.radio_button_checked : Icons.radio_button_off,
              color: sel ? AppColorConstants.themeColor : Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              const SizedBox(height: 2),
              Text(
                  '$rateText  •  Charge: ${feeText.isEmpty ? 'none' : feeText}\n'
                  '\$${m.minUsd.toStringAsFixed(0)} – \$${m.maxUsd.toStringAsFixed(0)}'
                  '${m.hasAccount ? '  •  ${m.accountMasked}' : '  •  account not added'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.35)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _summary(WithdrawOption o, double a) {
    Widget row(String l, String v, {bool bold = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            Expanded(child: Text(l, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w500))),
            Text(v, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600, fontSize: bold ? 16 : 14)),
          ]),
        );
    final ok = a > 0 && o.netUsd(a) > 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColorConstants.themeColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        row('You withdraw', '\$${_money(a, 2)}'),
        row('Transfer charge', ok || a > 0 ? '− \$${_money(o.feeFor(a), 2)}' : '—'),
        row('After charge', ok ? '\$${_money(o.netUsd(a), 2)}' : '—'),
        if (o.rate != 1 || o.currencyCode.toUpperCase() != 'USD')
          row('Rate', '1 USD = ${o.rate.toString().replaceAll(RegExp(r'\.0+$'), '')} ${o.currencyCode}'),
        const Divider(height: 18),
        row('You will receive',
            ok ? '${o.currencySymbol}${_money(o.netLocal(a), o.decimals)} ${o.currencyCode}' : '—',
            bold: true),
        if (o.note.isNotEmpty)
          Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(o.note, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)))),
      ]),
    );
  }
}
