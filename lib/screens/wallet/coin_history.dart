import 'package:intl/intl.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/api_handler/apis/coin_history_api.dart';
import 'package:foap/model/coin_history_model.dart';
import 'package:flutter/services.dart';

/// Every coin movement of the user: bought with a package, earned (ads, gifts,
/// awards, subscriptions...) and spent (boost, gifts, live, podcast...).
class CoinHistoryScreen extends StatefulWidget {
  const CoinHistoryScreen({super.key});

  @override
  State<CoinHistoryScreen> createState() => _CoinHistoryScreenState();
}

class _CoinHistoryScreenState extends State<CoinHistoryScreen> {
  final ScrollController _scroll = ScrollController();
  final List<CoinHistoryEntry> _items = [];
  CoinSummary _summary = CoinSummary();
  String _filter = 'all';
  int _page = 1;
  bool _loading = false;
  bool _more = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 200) {
        _load();
      }
    });
    _load();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _reload(String filter) async {
    setState(() {
      _filter = filter;
      _items.clear();
      _page = 1;
      _more = true;
      _failed = false;
    });
    await _load();
  }

  Future<void> _load() async {
    if (_loading || !_more) return;
    setState(() => _loading = true);
    final String requested = _filter;
    await CoinHistoryApi.getHistory(
        filter: requested,
        page: _page,
        resultCallback: (summary, items, meta) {
          if (!mounted || requested != _filter) return;
          setState(() {
            _summary = summary;
            _items.addAll(items);
            _more = meta.currentPage < meta.pageCount;
            _page += 1;
          });
        },
        errorCallback: () {
          if (mounted) setState(() => _failed = true);
        });
    if (mounted) setState(() => _loading = false);
  }

  String _usd(double v) => '\$${v.toStringAsFixed(2)}';

  Future<void> _redeemDialog() async {
    final s = _summary;
    if (s.perCoinValue <= 0 || s.redeemable <= 0 || s.redeemable < s.minRedeem) {
      AppUtil.showToast(message: coinRedeemNotReadyString.tr, isSuccess: false);
      return;
    }
    final TextEditingController ctrl =
        TextEditingController(text: s.redeemable.toString());
    final int? coins = await showDialog<int>(
        context: context,
        builder: (ctx) => StatefulBuilder(builder: (ctx, setD) {
              final int v = int.tryParse(ctrl.text.trim()) ?? 0;
              final double usd = (v * s.perCoinValue * 100).floorToDouble() / 100;
              final bool ok = v >= s.minRedeem && v > 0 && v <= s.redeemable && usd >= 0.01;
              return AlertDialog(
                title: Text(coinRedeemTitleString.tr),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${coinRedeemableString.tr}: ${s.redeemable}'),
                    const SizedBox(height: 10),
                    TextField(
                      controller: ctrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setD(() {}),
                      decoration:
                          InputDecoration(suffixText: coinsString.tr),
                    ),
                    const SizedBox(height: 10),
                    Text('= ${_usd(usd)}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    if (s.minRedeem > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                            '${coinRedeemMinString.tr}: ${s.minRedeem}',
                            style: const TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(cancelString.tr)),
                  TextButton(
                      onPressed: ok ? () => Navigator.of(ctx).pop(v) : null,
                      child: Text(coinRedeemConfirmString.tr)),
                ],
              );
            }));
    ctrl.dispose();
    if (coins == null) return;
    await CoinHistoryApi.redeem(
        coins: coins,
        onSuccess: (m) {
          AppUtil.showToast(message: m, isSuccess: true);
          Get.find<UserProfileManager>().refreshProfile();
          _reload(_filter);
        },
        onError: (m) => AppUtil.showToast(message: m, isSuccess: false));
  }

  String _date(int ts) {
    if (ts <= 0) return '';
    return DateFormat('MMM dd, yyyy  hh:mm a')
        .format(DateTime.fromMillisecondsSinceEpoch(ts * 1000));
  }

  Widget _tile(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColorConstants.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            BodyLargeText('$value', weight: TextWeight.bold, color: color),
            const SizedBox(height: 2),
            BodySmallText(label,
                color: AppColorConstants.subHeadingTextColor,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _chip(String value, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: _filter == value,
        onSelected: (_) => _reload(value),
      ),
    );
  }

  Widget _row(CoinHistoryEntry e) {
    final bool plus = e.isCredit;
    final Color color =
        plus ? AppColorConstants.green : AppColorConstants.red;
    final IconData icon = e.category == 'bought'
        ? Icons.shopping_bag_outlined
        : e.category == 'earned'
            ? Icons.card_giftcard
            : e.category == 'refund'
                ? Icons.undo
                : Icons.local_fire_department_outlined;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
                color: color.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyLargeText(e.title, weight: TextWeight.medium),
                BodySmallText(_date(e.createdAt),
                    color: AppColorConstants.subHeadingTextColor),
              ],
            ),
          ),
          BodyLargeText('${plus ? '+' : '-'} ${e.coin}',
              weight: TextWeight.bold, color: color),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: coinHistoryString.tr),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _reload(_filter),
              child: ListView(
                controller: _scroll,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(DesignConstants.horizontalPadding,
                    16, DesignConstants.horizontalPadding, 40),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColorConstants.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColorConstants.themeColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BodySmallText(coinBalanceString.tr,
                            color: AppColorConstants.subHeadingTextColor),
                        const SizedBox(height: 4),
                        Heading3Text('${_summary.balance}',
                            weight: TextWeight.bold,
                            color: AppColorConstants.themeColor),
                        const SizedBox(height: 8),
                        BodySmallText(
                            '${coinRedeemableString.tr}: ${_summary.redeemable}   ·   ${coinLockedString.tr}: ${_summary.locked}',
                            color: AppColorConstants.subHeadingTextColor),
                        const SizedBox(height: 12),
                        AppThemeButton(
                            text: coinRedeemTitleString.tr,
                            onPress: _redeemDialog),
                        const SizedBox(height: 6),
                        BodySmallText(coinRedeemHintString.tr,
                            color: AppColorConstants.subHeadingTextColor),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _tile(coinBoughtString.tr, _summary.bought,
                          AppColorConstants.mainTextColor),
                      const SizedBox(width: 8),
                      _tile(coinEarnedString.tr, _summary.earned,
                          AppColorConstants.green),
                      const SizedBox(width: 8),
                      _tile(coinSpentString.tr, _summary.spent,
                          AppColorConstants.red),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _chip('all', allString.tr),
                        _chip('bought', coinBoughtString.tr),
                        _chip('earned', coinEarnedString.tr),
                        _chip('spent', coinSpentString.tr),
                        _chip('refund', coinRefundString.tr),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_items.isEmpty && !_loading)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                          child: BodyLargeText(
                              _failed
                                  ? pleaseTryAgainString.tr
                                  : coinHistoryEmptyString.tr,
                              textAlign: TextAlign.center)),
                    ),
                  for (final e in _items) _row(e),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
