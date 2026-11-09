import 'package:intl/intl.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:foap/api_handler/apis/creator_pool_api.dart';

/// Shows a creator whether he qualifies for the ad revenue share, how many points he has this month
/// and what he was paid last time.
class CreatorEarningsScreen extends StatefulWidget {
  const CreatorEarningsScreen({super.key});

  @override
  State<CreatorEarningsScreen> createState() => _CreatorEarningsScreenState();
}

class _CreatorEarningsScreenState extends State<CreatorEarningsScreen> {
  CreatorStatus? _status;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    await CreatorStatusApi.getStatus(resultCallback: (s) {
      if (mounted) setState(() => _status = s);
    }, errorCallback: () {
      if (mounted) setState(() => _failed = true);
    });
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColorConstants.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColorConstants.dividerColor.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 5))
        ],
      ),
      child: child,
    );
  }

  Widget _heading(IconData icon, Color color, String text, {Widget? trailing}) {
    return Row(children: [
      Container(
        height: 38,
        width: 38,
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(13)),
        child: Icon(icon, color: color, size: 20),
      ),
      const SizedBox(width: 12),
      Expanded(child: Heading5Text(text, weight: TextWeight.bold)),
      if (trailing != null) trailing,
    ]);
  }

  Widget _progress(String label, int value, int needed) {
    final double ratio =
        needed <= 0 ? 1 : (value / needed).clamp(0.0, 1.0).toDouble();
    final bool done = value >= needed;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: BodyLargeText(label, weight: TextWeight.medium)),
          BodyLargeText('$value / $needed',
              color: done ? Colors.green : AppColorConstants.subHeadingTextColor),
          if (done)
            const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.check_circle, color: Colors.green, size: 18)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              color: done ? Colors.green : AppColorConstants.themeColor,
              backgroundColor: AppColorConstants.dividerColor),
        ),
      ]),
    );
  }

  Widget _body(CreatorStatus s) {
    if (!s.enabled) {
      return _card(
          child: BodyLargeText(
              'The ad revenue share is not active yet. Please check again soon.'));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _heading(Icons.lightbulb_rounded, const Color(0xFFF2994A), 'How it works'),
          const SizedBox(height: 12),
          BodyLargeText(
              '${s.googleEnabled ? 'Google ads: ${s.sharePercent.toStringAsFixed(0)}% of the real ad revenue is shared with eligible creators every month. ' : ''}'
              '${s.ownEnabled ? 'In-app promotions: ${s.ownSharePercent.toStringAsFixed(0)}% of the money advertisers really spend goes to a separate creator pool. ' : ''}'
              'You get a point when a different person sees an ad right after looking at your post (one point per person per day, in each pool). '
              'At the end of the month each pool is divided by points and paid to you as coins that you can convert to dollars.'),
        ]),
      ),
      _card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _heading(
            Icons.verified_user_rounded,
            const Color(0xFF2E9E6B),
            'Your eligibility',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: (s.eligible ? Colors.green : Colors.orange)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20)),
              child: BodySmallText(s.eligible ? 'Eligible' : 'Not yet',
                  color: s.eligible ? Colors.green : Colors.orange,
                  weight: TextWeight.semiBold),
            ),
          ),
          const SizedBox(height: 12),
          _progress('Followers', s.followers, s.followersNeeded),
          _progress('Posts', s.posts, s.postsNeeded),
          _progress('Account age (days)', s.accountDays, s.accountDaysNeeded),
        ]),
      ),
      _card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _heading(Icons.insights_rounded, AppColorConstants.themeColor, 'This month'),
          const SizedBox(height: 14),
          Row(children: [
            _stat('${s.thisMonthPoints}', 'Points'),
            _stat('${s.todayPoints}', 'Today'),
            _stat('${s.shareOfPoolPercent.toStringAsFixed(1)}%', 'Your share'),
          ]),
          if (s.ownEnabled) ...[
            const SizedBox(height: 12),
            BodySmallText('In-app promotions',
                color: AppColorConstants.subHeadingTextColor),
            const SizedBox(height: 6),
            Row(children: [
              _stat('${s.ownThisMonthPoints}', 'Points'),
              _stat('${s.ownTodayPoints}', 'Today'),
              _stat('${s.ownShareOfPoolPercent.toStringAsFixed(1)}%', 'Your share'),
            ]),
          ],
          const SizedBox(height: 10),
          BodySmallText(
              s.eligible
                  ? 'Your share is your points divided by the points of all creators in the same pool (Google ads: ${s.allCreatorsPoints}${s.ownEnabled ? ', in-app promotions: ${s.ownAllCreatorsPoints}' : ''}). The final amount depends on what the ads really earn this month.'
                  : 'Points are paid only when you are eligible at the end of the month.',
              color: AppColorConstants.subHeadingTextColor),
        ]),
      ),
      if (s.lastPayoutCoins > 0)
        _card(
          child: Row(children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(13)),
              child: const Icon(Icons.payments_rounded, color: Colors.green, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: BodyLargeText(
                    'Last payout: ${s.lastPayoutCoins} coins'
                    '${s.lastPayoutTime > 0 ? ' on ${DateFormat('MMM dd, yyyy').format(DateTime.fromMillisecondsSinceEpoch(s.lastPayoutTime * 1000))}' : ''}',
                    weight: TextWeight.medium)),
          ]),
        ),
    ]);
  }

  Widget _stat(String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
            color: AppColorConstants.themeColor.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14)),
        child: Column(children: [
          Heading3Text(value, weight: TextWeight.bold),
          BodySmallText(label, color: AppColorConstants.subHeadingTextColor),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(children: [
        backNavigationBar(title: 'Ad earnings'),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(DesignConstants.horizontalPadding,
                  16, DesignConstants.horizontalPadding, 40),
              children: [
                if (_status != null)
                  _body(_status!)
                else if (_failed)
                  Center(
                      child: BodyLargeText(
                          'Could not load. Pull down to try again.'))
                else
                  const Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Center(child: CircularProgressIndicator())),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
