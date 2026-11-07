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
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColorConstants.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColorConstants.dividerColor),
      ),
      child: child,
    );
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
              minHeight: 8,
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
          Heading5Text('How it works', weight: TextWeight.bold),
          const SizedBox(height: 8),
          BodyLargeText(
              'The app shows ads in the feed. ${s.sharePercent.toStringAsFixed(0)}% of the real ad revenue is shared with eligible creators every month. '
              'You get a point when a different person sees an ad next to your post (one point per person per day). '
              'At the end of the month the shared amount is divided by points and paid to you as coins that you can convert to dollars.'),
        ]),
      ),
      _card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Heading5Text('Your eligibility', weight: TextWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: (s.eligible ? Colors.green : Colors.orange)
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20)),
              child: BodySmallText(s.eligible ? 'Eligible' : 'Not yet',
                  color: s.eligible ? Colors.green : Colors.orange,
                  weight: TextWeight.semiBold),
            ),
          ]),
          const SizedBox(height: 12),
          _progress('Followers', s.followers, s.followersNeeded),
          _progress('Posts', s.posts, s.postsNeeded),
          _progress('Account age (days)', s.accountDays, s.accountDaysNeeded),
        ]),
      ),
      _card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Heading5Text('This month', weight: TextWeight.bold),
          const SizedBox(height: 12),
          Row(children: [
            _stat('${s.thisMonthPoints}', 'Points'),
            _stat('${s.todayPoints}', 'Today'),
            _stat('${s.shareOfPoolPercent.toStringAsFixed(1)}%', 'Your share'),
          ]),
          const SizedBox(height: 10),
          BodySmallText(
              s.eligible
                  ? 'Your share is your points divided by the points of all creators (${s.allCreatorsPoints}). The final amount depends on what the ads really earn this month.'
                  : 'Points are paid only when you are eligible at the end of the month.',
              color: AppColorConstants.subHeadingTextColor),
        ]),
      ),
      if (s.lastPayoutCoins > 0)
        _card(
          child: Row(children: [
            const Icon(Icons.payments_outlined, color: Colors.green),
            const SizedBox(width: 10),
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
      child: Column(children: [
        Heading3Text(value, weight: TextWeight.bold),
        BodySmallText(label, color: AppColorConstants.subHeadingTextColor),
      ]),
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
