import 'package:foap/helper/imports/common_import.dart';

/// Shown when the creator can not use Subscription yet: three progress lines
/// (followers, posts, total views) and the list of what the creator gets after reaching them.
class NotEligibleForSubscription extends StatefulWidget {
  const NotEligibleForSubscription({super.key});

  @override
  State<NotEligibleForSubscription> createState() =>
      _NotEligibleForSubscriptionState();
}

class _NotEligibleForSubscriptionState
    extends State<NotEligibleForSubscription> {
  final UserProfileManager _userProfileManager = Get.find();

  @override
  void initState() {
    super.initState();
    // numbers are fresh every time this page opens
    _userProfileManager.refreshProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: subscriptionString.tr),
          Expanded(
            child: SingleChildScrollView(
              child: Obx(() {
                final p = _userProfileManager.user.value?.subscriptionProgress ??
                    [0, 0, 0, 0, 0, 0];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Heading5Text('Unlock Subscription',
                        weight: TextWeight.bold),
                    const SizedBox(height: 6),
                    BodyMediumText(
                        'Reach all three goals below to start earning from your subscribers.',
                        color: AppColorConstants.subHeadingTextColor),
                    const SizedBox(height: 24),
                    _line('Followers', p[0], p[1]),
                    _line('Posts', p[2], p[3]),
                    _line('Total views', p[4], p[5]),
                    const SizedBox(height: 14),
                    Heading6Text('What you get', weight: TextWeight.bold),
                    const SizedBox(height: 10),
                    _benefit('Set your own subscription price (in coins).'),
                    _benefit(
                        'Earn coins from every subscriber. Earned coins can be turned into dollars.'),
                    _benefit('See the list of people who subscribed to you.'),
                    const SizedBox(height: 30),
                  ],
                );
              }),
            ).hp(DesignConstants.horizontalPadding),
          ),
        ],
      ),
    );
  }

  Widget _line(String title, int have, int need) {
    final bool done = have >= need;
    final double value = need <= 0 ? 1 : (have / need).clamp(0.0, 1.0);
    final int left = need > have ? need - have : 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: BodyLargeText(title, weight: TextWeight.medium)),
              if (done)
                Icon(Icons.check_circle, color: Colors.green.shade600, size: 20)
              else
                BodyMediumText('$have / $need'),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 10,
              backgroundColor:
                  AppColorConstants.themeColor.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(
                  done ? Colors.green.shade600 : AppColorConstants.themeColor),
            ),
          ),
          const SizedBox(height: 6),
          BodySmallText(
              done
                  ? 'Done: $have (needed $need)'
                  : 'You have $have, $left more needed',
              color: AppColorConstants.subHeadingTextColor),
        ],
      ),
    );
  }

  Widget _benefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check, size: 18, color: AppColorConstants.themeColor),
          const SizedBox(width: 10),
          Expanded(child: BodyMediumText(text)),
        ],
      ),
    );
  }
}
