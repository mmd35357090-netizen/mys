import 'package:intl/intl.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/api_handler/apis/creator_pool_api.dart';
import 'package:foap/screens/wallet/creator_earnings.dart';
import 'package:foap/screens/settings_menu/creator_tools/subscription_plan.dart';
import 'package:foap/screens/settings_menu/creator_tools/not_elegible_for_subscription.dart';

/// Creator dashboard: one place for everything a creator earned and how the account performs.
/// Every number comes from the server (real payment, gift, subscription and post records).
class CreatorDashboardScreen extends StatefulWidget {
  const CreatorDashboardScreen({super.key});

  @override
  State<CreatorDashboardScreen> createState() => _CreatorDashboardScreenState();
}

class _CreatorDashboardScreenState extends State<CreatorDashboardScreen> {
  Map<String, dynamic>? _d;
  bool _failed = false;
  final NumberFormat _n = NumberFormat.decimalPattern();

  static const List<Color> _sourceColors = [
    Color(0xFF4169E1),
    Color(0xFF2E9E6B),
    Color(0xFFF2994A),
    Color(0xFF9B51E0),
    Color(0xFFEB5757),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    await CreatorDashboardApi.getDashboard(resultCallback: (m) {
      if (mounted) setState(() => _d = m);
    }, errorCallback: () {
      if (mounted) setState(() => _failed = true);
    });
  }

  // ---------- small helpers ----------
  int _i(dynamic v) => int.tryParse((v ?? 0).toString()) ?? 0;
  double _f(dynamic v) => double.tryParse((v ?? 0).toString()) ?? 0;
  Map _m(dynamic v) => v is Map ? v : {};
  List _l(dynamic v) => v is List ? v : [];
  String _usd(num coins, double perCoin) =>
      '\$${(coins * perCoin).toStringAsFixed(2)}';

  Widget _card({required Widget child, VoidCallback? onTap}) {
    final c = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColorConstants.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColorConstants.dividerColor),
      ),
      child: child,
    );
    return onTap == null ? c : InkWell(onTap: onTap, child: c);
  }

  Widget _title(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 6),
      child: Heading6Text(t, weight: TextWeight.bold));

  Widget _stat(String label, String value, {String? sub}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: AppColorConstants.themeColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          BodySmallText(label, color: AppColorConstants.subHeadingTextColor),
          const SizedBox(height: 4),
          Heading6Text(value, weight: TextWeight.bold),
          if (sub != null) ...[
            const SizedBox(height: 2),
            BodySmallText(sub, color: AppColorConstants.subHeadingTextColor),
          ],
        ]),
      ),
    );
  }

  // ---------- sections ----------
  Widget _header(Map d) {
    final double pc = _f(d['per_coin_value']);
    final e = _m(d['earnings']);
    final b = _m(d['balance']);
    final int total = _i(e['total_coins']);
    final int last30 = _i(e['last30_coins']);
    final int prev30 = _i(e['prev30_coins']);
    String change;
    Color changeColor = AppColorConstants.subHeadingTextColor;
    if (prev30 > 0) {
      final double pct = (last30 - prev30) * 100 / prev30;
      change = '${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(0)}% vs previous 30 days';
      changeColor = pct >= 0 ? Colors.green : Colors.red;
    } else {
      change = last30 > 0 ? 'First earnings in the last 30 days' : 'No earnings in the last 30 days';
    }
    return _card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        BodyMediumText('Total earned',
            color: AppColorConstants.subHeadingTextColor),
        const SizedBox(height: 4),
        Heading3Text('${_n.format(total)} coins', weight: TextWeight.bold),
        BodyMediumText('about ${_usd(total, pc)}',
            color: AppColorConstants.subHeadingTextColor),
        const SizedBox(height: 10),
        Row(children: [
          BodyLargeText('${_n.format(last30)} coins',
              weight: TextWeight.medium),
          const SizedBox(width: 8),
          Expanded(child: BodySmallText('last 30 days', color: AppColorConstants.subHeadingTextColor)),
        ]),
        const SizedBox(height: 2),
        BodySmallText(change, color: changeColor),
        const SizedBox(height: 14),
        if (_i(b['held_coins']) > 0) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10)),
            child: BodySmallText(
                '${_n.format(_i(b['held_coins']))} coins you earned in the last ${_i(b['hold_days'])} days can be turned into dollars after that waiting time.'),
          ),
        ],
        Row(children: [
          _stat('Coin balance', _n.format(_i(b['coins']))),
          _stat('Can withdraw', _usd(_i(b['redeemable_coins']), pc),
              sub: _f(b['withdraw_min_usd']) > 0
                  ? '${_n.format(_i(b['redeemable_coins']))} coins, min \$${_f(b['withdraw_min_usd']).toStringAsFixed(0)}'
                  : '${_n.format(_i(b['redeemable_coins']))} coins'),
        ]),
      ]),
    );
  }

  Widget _chart(Map d) {
    final List daily = _l(_m(d['earnings'])['daily']);
    int maxV = 0;
    for (final x in daily) {
      final v = _i(_m(x)['coins']);
      if (v > maxV) maxV = v;
    }
    return _card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: BodyLargeText('Earnings, last 30 days', weight: TextWeight.medium)),
          BodySmallText(maxV > 0 ? 'peak ${_n.format(maxV)}' : '',
              color: AppColorConstants.subHeadingTextColor),
        ]),
        const SizedBox(height: 14),
        SizedBox(
          height: 110,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final x in daily)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Container(
                      height: maxV == 0
                          ? 3
                          : (3 + 107 * _i(_m(x)['coins']) / maxV).toDouble(),
                      decoration: BoxDecoration(
                        color: _i(_m(x)['coins']) > 0
                            ? AppColorConstants.themeColor
                            : AppColorConstants.themeColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          BodySmallText('30 days ago', color: AppColorConstants.subHeadingTextColor),
          BodySmallText('Today', color: AppColorConstants.subHeadingTextColor),
        ]),
        if (maxV == 0) ...[
          const SizedBox(height: 8),
          BodySmallText('No earnings yet. Gifts, subscribers and the ad revenue share will appear here.',
              color: AppColorConstants.subHeadingTextColor),
        ],
      ]),
    );
  }

  Widget _sources(Map d) {
    final double pc = _f(d['per_coin_value']);
    final e = _m(d['earnings']);
    final List src = _l(e['by_source']);
    final int total = _i(e['total_coins']);
    return _card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        BodyLargeText('Where your earnings come from', weight: TextWeight.medium),
        const SizedBox(height: 12),
        for (int i = 0; i < src.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: _sourceColors[i % _sourceColors.length],
                        shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(child: BodyMediumText('${_m(src[i])['label']}')),
                BodyMediumText('${_n.format(_i(_m(src[i])['coins']))} coins',
                    weight: TextWeight.medium),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: total <= 0 ? 0 : _i(_m(src[i])['coins']) / total,
                  minHeight: 7,
                  backgroundColor: AppColorConstants.themeColor.withValues(alpha: 0.10),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      _sourceColors[i % _sourceColors.length]),
                ),
              ),
              const SizedBox(height: 3),
              BodySmallText(
                  '${_usd(_i(_m(src[i])['coins']), pc)}  ·  ${_n.format(_i(_m(src[i])['count']))} payments',
                  color: AppColorConstants.subHeadingTextColor),
            ]),
          ),
      ]),
    );
  }

  Widget _giftsAndSubs(Map d) {
    final g = _m(d['gifts']);
    final s = _m(d['subscriptions']);
    return Row(children: [
      Expanded(
        child: _card(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            BodySmallText('Gifts received', color: AppColorConstants.subHeadingTextColor),
            const SizedBox(height: 4),
            Heading5Text(_n.format(_i(g['count'])), weight: TextWeight.bold),
            BodySmallText('${_n.format(_i(g['last30_count']))} in last 30 days',
                color: AppColorConstants.subHeadingTextColor),
            BodySmallText('${_n.format(_i(g['coins']))} coins',
                color: AppColorConstants.subHeadingTextColor),
          ]),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _card(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            BodySmallText('Subscribers', color: AppColorConstants.subHeadingTextColor),
            const SizedBox(height: 4),
            Heading5Text(_n.format(_i(s['active'])), weight: TextWeight.bold),
            BodySmallText('active now, ${_n.format(_i(s['total']))} all time',
                color: AppColorConstants.subHeadingTextColor),
            BodySmallText('${_n.format(_i(s['coins']))} coins',
                color: AppColorConstants.subHeadingTextColor),
          ]),
        ),
      ),
    ]);
  }

  Widget _performance(Map d) {
    final p = _m(d['performance']);
    final int views = _i(p['views']);
    final int likes = _i(p['likes']);
    final int comments = _i(p['comments']);
    final String engagement = views > 0
        ? '${((likes + comments) * 100 / views).toStringAsFixed(1)}%'
        : '0%';
    final List top = _l(p['top_posts']);
    return _card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        BodyLargeText('Performance', weight: TextWeight.medium),
        const SizedBox(height: 12),
        Row(children: [
          _stat('Total views', _n.format(views)),
          _stat('Likes', _n.format(likes)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          _stat('Comments', _n.format(comments)),
          _stat('Engagement', engagement, sub: 'likes + comments / views'),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          _stat('Followers', _n.format(_i(p['followers'])),
              sub: '+${_n.format(_i(p['followers_new_30d']))} in 30 days'),
          _stat('Posts', _n.format(_i(p['posts']))),
        ]),
        if (top.isNotEmpty) ...[
          const SizedBox(height: 16),
          BodyMediumText('Top posts by views', weight: TextWeight.medium),
          const SizedBox(height: 8),
          for (int i = 0; i < top.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                SizedBox(width: 22, child: BodyMediumText('${i + 1}.')),
                Expanded(
                    child: BodyMediumText(
                        ('${_m(top[i])['title']}').trim().isEmpty
                            ? 'Post #${_m(top[i])['id']}'
                            : '${_m(top[i])['title']}',
                        maxLines: 1)),
                BodySmallText(
                    '${_n.format(_i(_m(top[i])['views']))} views  ·  ${_n.format(_i(_m(top[i])['likes']))} likes',
                    color: AppColorConstants.subHeadingTextColor),
              ]),
            ),
        ],
      ]),
    );
  }

  Widget _chip(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(20)),
        child: Text(text,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      );

  Widget _program(
      {required String title,
      required String text,
      required String chipText,
      required Color chipColor,
      double? progress,
      VoidCallback? onTap}) {
    return _card(
      onTap: onTap,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: BodyLargeText(title, weight: TextWeight.medium)),
          _chip(chipText, chipColor),
        ]),
        const SizedBox(height: 6),
        BodySmallText(text, color: AppColorConstants.subHeadingTextColor),
        if (progress != null) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: AppColorConstants.themeColor.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(chipColor),
            ),
          ),
        ],
      ]),
    );
  }

  double _ratio(num have, num need) =>
      need <= 0 ? 1 : (have / need).clamp(0.0, 1.0).toDouble();

  Widget _programs(Map d) {
    final pr = _m(d['programs']);
    final sub = _m(pr['subscription']);
    final sp = _m(sub['progress']);
    final bool subOk = _i(sub['allowed']) == 1;
    final double subRatio = (_ratio(_i(sp['followers']), _i(sp['followers_needed'])) +
            _ratio(_i(sp['posts']), _i(sp['posts_needed'])) +
            _ratio(_i(sp['views']), _i(sp['views_needed']))) /
        3;
    final ad = _m(pr['ad_share']);
    final el = _m(ad['eligibility']);
    final bool adOk = el['eligible'] == true;
    final double adRatio = (_ratio(_i(el['followers']), _i(el['followers_needed'])) +
            _ratio(_i(el['posts']), _i(el['posts_needed'])) +
            _ratio(_i(el['account_days']), _i(el['account_days_needed']))) /
        3;
    final bool adOn = ad['enabled'] == true;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _title('Ways to earn'),
      _program(
        title: 'Gifts',
        text: 'Fans send you gifts on your posts and live streams. Gifts turn into coins you can withdraw.',
        chipText: 'Active',
        chipColor: Colors.green,
      ),
      _program(
        title: 'Subscriptions',
        text: subOk
            ? 'Set your price and earn coins from every subscriber.'
            : 'Reach the follower, post and view goals to unlock subscriptions.',
        chipText: subOk ? 'Unlocked' : '${(subRatio * 100).round()}% done',
        chipColor: subOk ? Colors.green : AppColorConstants.themeColor,
        progress: subOk ? null : subRatio,
        onTap: () {
          if (subOk) {
            Get.to(() => const CreateSubscriptionPlan());
          } else {
            Get.to(() => const NotEligibleForSubscription());
          }
        },
      ),
      _program(
        title: 'Ad revenue share',
        text: !adOn
            ? 'Not running at the moment.'
            : adOk
                ? 'You share ${_f(ad['share_percent']).toStringAsFixed(0)}% of the ad revenue with other creators. This month: ${_n.format(_i(ad['this_month_points']))} points.'
                : 'Reach the follower, post and account-age goals to join the ad revenue share.',
        chipText: !adOn ? 'Off' : (adOk ? 'Eligible' : '${(adRatio * 100).round()}% done'),
        chipColor: !adOn
            ? Colors.grey
            : (adOk ? Colors.green : AppColorConstants.themeColor),
        progress: (adOn && !adOk) ? adRatio : null,
        onTap: () => Get.to(() => const CreatorEarningsScreen()),
      ),
      _program(
        title: 'Competition prizes',
        text: 'Win competitions and prize coins are added to your balance.',
        chipText: 'Active',
        chipColor: Colors.green,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(children: [
        backNavigationBar(title: 'Creator dashboard'),
        Expanded(
          child: _d == null
              ? Center(
                  child: _failed
                      ? Column(mainAxisSize: MainAxisSize.min, children: [
                          const BodyLargeText('Could not load the dashboard'),
                          const SizedBox(height: 12),
                          TextButton(onPressed: _load, child: const Text('Try again')),
                        ])
                      : const CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                        DesignConstants.horizontalPadding, 10,
                        DesignConstants.horizontalPadding, 30),
                    children: [
                      _header(_d!),
                      _chart(_d!),
                      _sources(_d!),
                      _giftsAndSubs(_d!),
                      _performance(_d!),
                      _programs(_d!),
                    ],
                  ),
                ),
        ),
      ]),
    );
  }
}
