import 'dart:async';
import 'package:flutter/services.dart';
import 'package:foap/util/biometric_helper.dart';
import 'package:foap/helper/imports/common_import.dart';
import '../../api_handler/apis/payout_api.dart';

/// Payout methods: PayPal, bKash, Nagad, USDT, Binance UID.
/// Every change needs fingerprint/face (if on) + an email code, and puts withdrawals on hold for 7 days.
/// (The class keeps its old name so the profile page needs no change.)
class ChangePaypalId extends StatefulWidget {
  const ChangePaypalId({super.key});

  @override
  State<ChangePaypalId> createState() => _ChangePaypalIdState();
}

class _MethodMeta {
  final String key;
  final String label;
  final IconData icon;
  final Color color;
  final String fieldLabel;
  final String hint;
  final TextInputType keyboard;
  const _MethodMeta(this.key, this.label, this.icon, this.color, this.fieldLabel, this.hint,
      this.keyboard);
}

const List<_MethodMeta> _metas = [
  _MethodMeta('paypal', 'PayPal', Icons.payments_rounded, Color(0xFF0070BA), 'PayPal email',
      'name@example.com', TextInputType.emailAddress),
  _MethodMeta('bkash', 'bKash', Icons.phone_android_rounded, Color(0xFFE2136E),
      'bKash number (Personal)', '01XXXXXXXXX', TextInputType.phone),
  _MethodMeta('nagad', 'Nagad', Icons.phone_android_rounded, Color(0xFFF6921E),
      'Nagad number (Personal)', '01XXXXXXXXX', TextInputType.phone),
  _MethodMeta('usdt', 'USDT', Icons.currency_bitcoin_rounded, Color(0xFF26A17B),
      'USDT wallet address', 'Paste your address', TextInputType.text),
  _MethodMeta('binance', 'Binance UID', Icons.account_balance_wallet_rounded, Color(0xFFD9A400),
      'Binance Pay ID / UID', 'e.g. 123456789', TextInputType.number),
];

_MethodMeta _metaOf(String key) => _metas.firstWhere((m) => m.key == key, orElse: () => _metas.first);

class _ChangePaypalIdState extends State<ChangePaypalId> {
  PayoutOverview? _data;
  bool _loading = true;
  final UserProfileManager _userProfileManager = Get.find();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final d = await PayoutApi.overview();
    if (!mounted) return;
    setState(() {
      _data = d;
      _loading = false;
    });
  }

  // ---------- security: fingerprint/face -> email code -> action ----------
  Future<bool> _secure(Future<PayoutResult> Function(String otp) action, {String? done}) async {
    if (!await BiometricHelper.confirmIfEnabled(paymentDetailString.tr)) return false;
    final sent = await PayoutApi.sendOtp();
    if (!sent.ok) {
      AppUtil.showToast(message: sent.message.isEmpty ? 'Could not send the code' : sent.message, isSuccess: false);
      return false;
    }
    if (!mounted) return false;
    final code = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _OtpDialog(email: _data?.emailMasked ?? ''));
    if (code == null) return false;
    final r = await action(code);
    AppUtil.showToast(message: r.message.isEmpty ? (r.ok ? 'Done' : 'Failed') : r.message, isSuccess: r.ok);
    if (r.ok) {
      _userProfileManager.refreshProfile();
      await _load();
    }
    return r.ok;
  }

  Future<void> _openEditor({String? method}) async {
    final existing = _data?.methods ?? [];
    final res = await showModalBottomSheet<_EditorResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColorConstants.backgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _EditorSheet(
          initialMethod: method,
          hasOthers: existing.isNotEmpty,
          holdDays: _data?.holdDays ?? 7),
    );
    if (res == null) return;
    await _secure((otp) => PayoutApi.save(
        method: res.method,
        account: res.account,
        network: res.network,
        otp: otp,
        makeDefault: res.makeDefault));
  }

  Future<void> _confirm(String title, String text, VoidCallback onYes) async {
    final yes = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
              title: Text(title),
              content: Text(text),
              actions: [
                TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Continue')),
              ],
            ));
    if (yes == true) onYes();
  }

  // ---------- UI ----------
  Widget _holdBanner() {
    final d = _data!;
    if (d.holdActive) {
      final left = ((d.holdUntil - d.serverTime) / 86400).ceil();
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: const Color(0xFFFFF1E0),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE07B00).withValues(alpha: 0.5))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.lock_clock_rounded, color: Color(0xFFE07B00)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Withdrawals are on hold',
                  style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black87)),
              const SizedBox(height: 3),
              Text(
                  'You changed a payout method. For your security you can withdraw again on ${d.holdText} ($left day${left == 1 ? '' : 's'} left).',
                  style: const TextStyle(fontSize: 13, height: 1.35, color: Colors.black87)),
            ]),
          ),
        ]),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColorConstants.themeColor.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(16)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.verified_user_rounded, color: AppColorConstants.themeColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
              'Your money is protected. Any change to a payout method needs an email code'
              '${' (and your fingerprint/face if turned on)'} and puts withdrawals on hold for ${d.holdDays} days.',
              style: TextStyle(fontSize: 13, height: 1.35, color: AppColorConstants.mainTextColor)),
        ),
      ]),
    );
  }

  Widget _card(PayoutMethodItem m) {
    final meta = _metaOf(m.method);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
      decoration: BoxDecoration(
        color: AppColorConstants.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: m.isDefault
                ? AppColorConstants.themeColor.withValues(alpha: 0.6)
                : AppColorConstants.borderColor.withValues(alpha: 0.35)),
      ),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              color: meta.color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(13)),
          child: Icon(meta.icon, color: meta.color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(m.label + (m.network != null && m.network!.isNotEmpty ? ' · ${m.network}' : ''),
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColorConstants.mainTextColor)),
              if (m.isDefault) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: AppColorConstants.themeColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text('Default',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColorConstants.themeColor)),
                ),
              ],
            ]),
            const SizedBox(height: 3),
            Text(m.accountMasked,
                style: TextStyle(fontSize: 13.5, color: AppColorConstants.subHeadingTextColor)),
          ]),
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert_rounded, color: AppColorConstants.iconColor),
          onSelected: (v) {
            if (v == 'edit') {
              _openEditor(method: m.method);
            } else if (v == 'default') {
              _confirm('Make default?', 'Withdrawals will go to ${m.label}. This puts withdrawals on hold for ${_data!.holdDays} days.',
                  () => _secure((otp) => PayoutApi.makeDefault(id: m.id, otp: otp)));
            } else if (v == 'remove') {
              _confirm('Remove ${m.label}?', 'This puts withdrawals on hold for ${_data!.holdDays} days.',
                  () => _secure((otp) => PayoutApi.remove(id: m.id, otp: otp)));
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Replace account')),
            if (!m.isDefault) const PopupMenuItem(value: 'default', child: Text('Make default')),
            const PopupMenuItem(value: 'remove', child: Text('Remove')),
          ],
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(children: [
        backNavigationBar(title: paymentDetailString.tr),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _data == null
                  ? Center(
                      child: TextButton(
                          onPressed: () {
                            setState(() => _loading = true);
                            _load();
                          },
                          child: Text(
                              'Could not load. Tap to retry${PayoutApi.lastError.isEmpty ? '' : '\n\n${PayoutApi.lastError}'}',
                              textAlign: TextAlign.center)))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                        children: [
                          _holdBanner(),
                          const SizedBox(height: 20),
                          Text('YOUR PAYOUT METHODS',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.4,
                                  color: AppColorConstants.subHeadingTextColor)),
                          const SizedBox(height: 10),
                          if (_data!.methods.isEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 30),
                              alignment: Alignment.center,
                              child: Text('No payout method yet.\nAdd one to receive your earnings.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColorConstants.subHeadingTextColor)),
                            ),
                          for (final m in _data!.methods) _card(m),
                          const SizedBox(height: 6),
                          AppThemeButton(
                              onPress: () => _openEditor(), text: 'Add payout method'),
                        ],
                      ),
                    ),
        ),
      ]),
    );
  }
}

// =================== editor sheet (collects the details) ===================
class _EditorResult {
  final String method;
  final String account;
  final String? network;
  final bool makeDefault;
  _EditorResult(this.method, this.account, this.network, this.makeDefault);
}

class _EditorSheet extends StatefulWidget {
  final String? initialMethod;
  final bool hasOthers;
  final int holdDays;
  const _EditorSheet({this.initialMethod, required this.hasOthers, required this.holdDays});

  @override
  State<_EditorSheet> createState() => _EditorSheetState();
}

class _EditorSheetState extends State<_EditorSheet> {
  late String method = widget.initialMethod ?? 'bkash';
  String network = 'TRC20';
  bool makeDefault = false;
  final account = TextEditingController();
  final confirmAccount = TextEditingController();
  String? error;

  @override
  void dispose() {
    account.dispose();
    confirmAccount.dispose();
    super.dispose();
  }

  void _submit() {
    final a = account.text.trim();
    if (a.isEmpty) {
      setState(() => error = 'Please enter the account details.');
      return;
    }
    if (a != confirmAccount.text.trim()) {
      setState(() => error = 'The two entries do not match.');
      return;
    }
    Navigator.pop(context, _EditorResult(method, a, method == 'usdt' ? network : null, makeDefault));
  }

  @override
  Widget build(BuildContext context) {
    final meta = _metaOf(method);
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    InputDecoration deco(String label, String hint) => InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: AppColorConstants.cardColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColorConstants.borderColor.withValues(alpha: 0.5))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColorConstants.themeColor, width: 1.6)),
        );
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 18, 20, 20 + bottom),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColorConstants.disabledColor, borderRadius: BorderRadius.circular(4)))),
          const SizedBox(height: 16),
          Text(widget.initialMethod == null ? 'Add payout method' : 'Replace ${meta.label}',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800, color: AppColorConstants.mainTextColor)),
          const SizedBox(height: 14),
          if (widget.initialMethod == null)
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final m in _metas)
                ChoiceChip(
                  avatar: Icon(m.icon, size: 16, color: method == m.key ? Colors.white : m.color),
                  label: Text(m.label),
                  selected: method == m.key,
                  showCheckmark: false,
                  selectedColor: m.color,
                  backgroundColor: AppColorConstants.cardColor,
                  labelStyle: TextStyle(
                      color: method == m.key ? Colors.white : AppColorConstants.mainTextColor),
                  onSelected: (_) => setState(() {
                    method = m.key;
                    error = null;
                  }),
                ),
            ]),
          if (method == 'usdt') ...[
            const SizedBox(height: 14),
            Wrap(spacing: 8, children: [
              for (final n in ['TRC20', 'BEP20', 'ERC20'])
                ChoiceChip(
                  label: Text(n == 'TRC20' ? 'TRC20 (cheapest)' : n),
                  selected: network == n,
                  onSelected: (_) => setState(() => network = n),
                ),
            ]),
            const SizedBox(height: 6),
            Text('Send only on the network you pick. A wrong network loses the money.',
                style: TextStyle(fontSize: 12, color: AppColorConstants.red)),
          ],
          const SizedBox(height: 14),
          TextField(
              controller: account,
              keyboardType: meta.keyboard,
              inputFormatters: method == 'binance' ? [FilteringTextInputFormatter.digitsOnly] : null,
              decoration: deco(meta.fieldLabel, meta.hint)),
          const SizedBox(height: 12),
          TextField(
              controller: confirmAccount,
              keyboardType: meta.keyboard,
              inputFormatters: method == 'binance' ? [FilteringTextInputFormatter.digitsOnly] : null,
              decoration: deco('Type it again to confirm', meta.hint)),
          if (widget.hasOthers)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: makeDefault,
              onChanged: (v) => setState(() => makeDefault = v),
              title: const Text('Use as my default method'),
            ),
          if (error != null)
            Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(error!, style: TextStyle(color: AppColorConstants.red))),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFFFFF1E0), borderRadius: BorderRadius.circular(12)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFFE07B00)),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(
                      'After you save, withdrawals are on hold for ${widget.holdDays} days. Double-check the details: payments cannot be taken back.',
                      style: const TextStyle(fontSize: 12.5, height: 1.35, color: Colors.black87))),
            ]),
          ),
          const SizedBox(height: 14),
          AppThemeButton(onPress: _submit, text: 'Continue'),
        ]),
      ),
    );
  }
}

// =================== email code dialog ===================
class _OtpDialog extends StatefulWidget {
  final String email;
  const _OtpDialog({required this.email});

  @override
  State<_OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends State<_OtpDialog> {
  final code = TextEditingController();
  int wait = 60;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (t) {
      if (wait <= 1) {
        t.cancel();
      }
      if (mounted) setState(() => wait = wait > 0 ? wait - 1 : 0);
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    code.dispose();
    super.dispose();
  }

  Future<void> _resend() async {
    final r = await PayoutApi.sendOtp();
    AppUtil.showToast(message: r.message.isEmpty ? 'Code sent' : r.message, isSuccess: r.ok);
    if (r.ok && mounted) {
      setState(() => wait = 60);
      _t?.cancel();
      _t = Timer.periodic(const Duration(seconds: 1), (t) {
        if (wait <= 1) t.cancel();
        if (mounted) setState(() => wait = wait > 0 ? wait - 1 : 0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter the email code'),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('We sent a 6-digit code to ${widget.email}.'),
        const SizedBox(height: 14),
        TextField(
          controller: code,
          autofocus: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.w700),
          decoration: const InputDecoration(counterText: '', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
              onPressed: wait == 0 ? _resend : null,
              child: Text(wait == 0 ? 'Send again' : 'Send again in ${wait}s')),
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
            onPressed: () {
              if (code.text.trim().length == 6) Navigator.pop(context, code.text.trim());
            },
            child: const Text('Confirm')),
      ],
    );
  }
}
