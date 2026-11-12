import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/api_handler/apis/deposit_api.dart';
import 'package:foap/api_handler/apis/misc_api.dart';
import 'package:foap/model/deposit_model.dart';

/// Add money to the wallet by sending local money (bKash, Nagad, ...) to a
/// number set by the admin, then sending the transaction id and a screenshot.
/// The wallet stays in USD; the amount to send is converted with the admin's rate.
/// Pops with `true` when a request was sent.
class AddMoneyScreen extends StatefulWidget {
  /// Amount (USD) to start with, for example what is still missing at checkout.
  final double? initialUsd;

  const AddMoneyScreen({super.key, this.initialUsd});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  late final TextEditingController _amount = TextEditingController(
      text: widget.initialUsd != null && widget.initialUsd! > 0
          ? _plain(widget.initialUsd!)
          : '10');
  bool _initialApplied = false;
  final TextEditingController _trx = TextEditingController();
  final TextEditingController _sender = TextEditingController();
  final TextEditingController _note = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<DepositMethodModel> _methods = [];
  DepositMethodModel? _selected;
  File? _proof;
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadMethods();
  }

  @override
  void dispose() {
    _amount.dispose();
    _trx.dispose();
    _sender.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _loadMethods() async {
    if (mounted) setState(() => _loading = true);
    int? keepId = _selected?.id;
    await DepositApi.getMethods(resultCallback: (methods) {
      if (!mounted) return;
      setState(() {
        _methods = methods;
        _selected = methods.where((m) => m.id == keepId).isNotEmpty
            ? methods.firstWhere((m) => m.id == keepId)
            : (methods.isNotEmpty ? methods.first : null);
      });
    });
    _applyInitial();
    if (mounted) setState(() => _loading = false);
  }

  static String _plain(double v) {
    final fixed = v.toStringAsFixed(2);
    return fixed.endsWith('.00') ? fixed.substring(0, fixed.length - 3) : fixed;
  }

  // keep the suggested amount inside the limits of the chosen method (once)
  void _applyInitial() {
    final m = _selected;
    if (_initialApplied || m == null) return;
    _initialApplied = true;
    final start = widget.initialUsd;
    if (start == null || start <= 0) return;
    double v = start;
    if (v < m.minUsd) v = m.minUsd;
    if (v > m.maxUsd) v = m.maxUsd;
    _amount.text = _plain(v);
  }

  double? get _usd {
    String text = _amount.text.trim().replaceAll(',', '.');
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  String _usdText(double v) => '\$${v.toStringAsFixed(2)}';

  Future<void> _pickScreenshot() async {
    try {
      XFile? file = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 80, maxWidth: 1600);
      if (file != null && mounted) {
        setState(() => _proof = File(file.path));
      }
    } catch (e) {
      AppUtil.showToast(message: '${errorString.tr}: $e', isSuccess: false);
    }
  }

  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    AppUtil.showToast(message: depositCopied.tr, isSuccess: true);
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final DepositMethodModel? method = _selected;
    if (method == null) {
      AppUtil.showToast(message: depositChooseMethod.tr, isSuccess: false);
      return;
    }
    final double? usd = _usd;
    if (usd == null || usd <= 0) {
      AppUtil.showToast(message: depositEnterAmount.tr, isSuccess: false);
      return;
    }
    if (usd < method.minUsd || usd > method.maxUsd) {
      AppUtil.showToast(
          message: depositAmountRange.tr
              .replaceAll('{{min}}', _usdText(method.minUsd))
              .replaceAll('{{max}}', _usdText(method.maxUsd)),
          isSuccess: false);
      return;
    }
    final String trx = _trx.text.trim();
    if (trx.length < 4) {
      AppUtil.showToast(message: depositEnterTrx.tr, isSuccess: false);
      return;
    }
    final String sender = _sender.text.trim();
    if (sender.length < 5) {
      AppUtil.showToast(message: depositEnterSender.tr, isSuccess: false);
      return;
    }
    if (method.requireScreenshot && _proof == null) {
      AppUtil.showToast(message: depositScreenshotRequired.tr, isSuccess: false);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);

    String? proofName;
    if (_proof != null) {
      final Completer<String?> done = Completer<String?>();
      await MiscApi.uploadFile(_proof!.path,
          type: UploadMediaType.depositProof,
          mediaType: GalleryMediaType.photo, failureHandler: () {
        if (!done.isCompleted) done.complete(null);
      }, resultCallback: (fileName, fileUrl) {
        if (!done.isCompleted) done.complete(fileName);
      });
      proofName = await done.future.timeout(const Duration(seconds: 1),
          onTimeout: () => null);
      if (proofName == null || proofName.isEmpty) {
        // the reason was already shown by the upload call
        if (mounted) setState(() => _submitting = false);
        return;
      }
    }

    final result = await DepositApi.createRequest(
        methodId: method.id,
        usdAmount: usd,
        expectedLocalAmount: method.localAmountFor(usd),
        trxId: trx,
        senderNumber: sender,
        proofImage: proofName,
        note: _note.text.trim());

    if (!mounted) return;
    setState(() => _submitting = false);

    if (result.error == null) {
      await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
                title: Text(depositSent.tr),
                content: Text(depositSentMessage.tr),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(okString.tr))
                ],
              ));
      if (mounted) Navigator.of(context).pop(true);
    } else {
      AppUtil.showToast(message: result.error!, isSuccess: false);
      if (result.rateChanged) {
        await _loadMethods();
        AppUtil.showToast(message: depositRateChanged.tr, isSuccess: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            backNavigationBar(title: addMoneyString.tr),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_methods.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: BodyLargeText(depositNoMethods.tr, textAlign: TextAlign.center),
        ),
      );
    }

    final DepositMethodModel method = _selected!;
    final double? usdInput = _usd;
    final double usd =
        (usdInput != null && usdInput > 0) ? usdInput : 0.0;
    final bool valid = usd > 0;
    final double local = valid ? method.localAmountFor(usd) : 0;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(DesignConstants.horizontalPadding, 20,
          DesignConstants.horizontalPadding, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Heading6Text(depositChooseMethod.tr, weight: TextWeight.bold),
          const SizedBox(height: 10),
          for (final m in _methods) _methodCard(m),
          const SizedBox(height: 18),
          _label(depositAmountUsd.tr),
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              LengthLimitingTextInputFormatter(10),
            ],
            onChanged: (_) => setState(() {}),
            style: TextStyle(
                color: AppColorConstants.mainTextColor,
                fontSize: 20,
                fontWeight: FontWeight.bold),
            decoration: _decoration(prefix: '\$ '),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final v in [5, 10, 20, 50, 100])
                if (v >= method.minUsd && v <= method.maxUsd)
                  ChoiceChip(
                    label: Text('\$$v'),
                    selected: valid && usd == v.toDouble(),
                    onSelected: (_) {
                      _amount.text = v.toString();
                      setState(() {});
                    },
                  ),
            ],
          ),
          const SizedBox(height: 4),
          BodySmallText(
            depositMinMax.tr
                .replaceAll('{{min}}', _usdText(method.minUsd))
                .replaceAll('{{max}}', _usdText(method.maxUsd)),
            color: AppColorConstants.subHeadingTextColor,
          ),
          const SizedBox(height: 16),
          _summaryCard(method, usd, valid, local),
          const SizedBox(height: 16),
          _payToCard(method),
          const SizedBox(height: 20),
          _label(depositTrxId.tr),
          TextField(
            controller: _trx,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [LengthLimitingTextInputFormatter(100)],
            style: TextStyle(color: AppColorConstants.mainTextColor),
            decoration: _decoration(),
          ),
          const SizedBox(height: 14),
          _label(depositSenderNumber.tr),
          TextField(
            controller: _sender,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s]')),
              LengthLimitingTextInputFormatter(30),
            ],
            style: TextStyle(color: AppColorConstants.mainTextColor),
            decoration: _decoration(),
          ),
          const SizedBox(height: 14),
          _label(
              '${depositScreenshot.tr}${method.requireScreenshot ? ' *' : ''}'),
          _screenshotPicker(),
          const SizedBox(height: 14),
          _label(depositNote.tr),
          TextField(
            controller: _note,
            maxLines: 2,
            inputFormatters: [LengthLimitingTextInputFormatter(300)],
            style: TextStyle(color: AppColorConstants.mainTextColor),
            decoration: _decoration(),
          ),
          const SizedBox(height: 24),
          _submitting
              ? const Center(child: CircularProgressIndicator())
              : AppThemeButton(text: depositSubmit.tr, onPress: _submit),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: BodyMediumText(text, weight: TextWeight.medium),
      );

  InputDecoration _decoration({String? prefix}) => InputDecoration(
        filled: true,
        fillColor: AppColorConstants.cardColor,
        prefixText: prefix,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      );

  Widget _methodCard(DepositMethodModel m) {
    final bool selected = _selected?.id == m.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _selected = m),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColorConstants.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: selected
                    ? AppColorConstants.themeColor
                    : AppColorConstants.borderColor,
                width: selected ? 2 : 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BodyLargeText(m.title, weight: TextWeight.bold),
                    const SizedBox(height: 2),
                    BodySmallText(
                      '${m.accountTypeLabel} - ${m.currencyCode}',
                      color: AppColorConstants.subHeadingTextColor,
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected
                    ? AppColorConstants.themeColor
                    : AppColorConstants.subHeadingTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(
      DepositMethodModel m, double usd, bool valid, double local) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorConstants.themeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BodySmallText(depositYouWillPay.tr,
              color: AppColorConstants.subHeadingTextColor),
          const SizedBox(height: 4),
          Heading3Text(valid ? m.formatLocal(local) : '-',
              weight: TextWeight.bold, color: AppColorConstants.themeColor),
          const SizedBox(height: 8),
          Row(
            children: [
              BodyMediumText('${depositWalletCredit.tr}: '),
              BodyMediumText(valid ? _usdText(usd) : '-',
                  weight: TextWeight.bold),
            ],
          ),
          const SizedBox(height: 4),
          BodySmallText(
            '${depositRateLine.tr.replaceAll('{{rate}}', m.rateText)}'
            '${m.feePercent > 0 ? '  (${depositFeeLine.tr.replaceAll('{{fee}}', m.feePercent.toString())})' : ''}',
            color: AppColorConstants.subHeadingTextColor,
          ),
        ],
      ),
    );
  }

  Widget _payToCard(DepositMethodModel m) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorConstants.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BodySmallText('${depositSendTo.tr} (${m.title} - ${m.accountTypeLabel})',
              color: AppColorConstants.subHeadingTextColor),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  m.accountNumber,
                  style: TextStyle(
                      color: AppColorConstants.mainTextColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ),
              TextButton.icon(
                onPressed: () => _copy(m.accountNumber),
                icon: const Icon(Icons.copy, size: 18),
                label: Text(depositCopy.tr),
              ),
            ],
          ),
          if (m.accountName.isNotEmpty)
            BodyMediumText('${depositAccountHolder.tr}: ${m.accountName}'),
          if (m.instructions.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            BodyMediumText(depositHowTo.tr, weight: TextWeight.bold),
            const SizedBox(height: 4),
            BodyMediumText(m.instructions.trim()),
          ],
        ],
      ),
    );
  }

  Widget _screenshotPicker() {
    if (_proof != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(_proof!,
                height: 220, width: double.infinity, fit: BoxFit.cover),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: InkWell(
              onTap: () => setState(() => _proof = null),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                    color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      );
    }
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: _pickScreenshot,
      child: Container(
        height: 110,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColorConstants.cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColorConstants.borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                size: 34, color: AppColorConstants.themeColor),
            const SizedBox(height: 6),
            BodyMediumText(depositAddScreenshot.tr),
          ],
        ),
      ),
    );
  }
}
