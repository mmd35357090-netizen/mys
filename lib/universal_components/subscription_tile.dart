import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:foap/api_handler/apis/subscription_api.dart';
import 'package:foap/components/avatar_view.dart';
import 'package:foap/components/custom_texts.dart';
import 'package:foap/util/app_config_constants.dart';

/// Card for one subscription.
/// [asCreator] true  -> "X subscribed to you" (earned coins)
/// [asCreator] false -> "You subscribed to X"  (paid coins)
class SubscriptionTile extends StatelessWidget {
  final SubscriptionInfo info;
  final bool asCreator;
  final VoidCallback? onTap;

  const SubscriptionTile(
      {super.key, required this.info, required this.asCreator, this.onTap});

  String _date(int unix) => unix <= 0
      ? '-'
      : DateFormat('d MMM yyyy')
          .format(DateTime.fromMillisecondsSinceEpoch(unix * 1000));

  @override
  Widget build(BuildContext context) {
    final bool active = info.isActive;
    final Color statusColor =
        active ? const Color(0xFF16A34A) : AppColorConstants.red;
    final Color coinColor = const Color(0xFFF59E0B);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColorConstants.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColorConstants.dividerColor.withValues(alpha: 0.5),
            width: 0.6),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    UserAvatarView(
                        user: info.user,
                        size: 28,
                        hideLiveIndicator: true,
                        hideOnlineIndicator: true),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BodyLargeText(info.user.userName,
                              weight: TextWeight.semiBold),
                          const SizedBox(height: 2),
                          BodySmallText(
                            asCreator
                                ? 'Subscribed to you'
                                : 'You subscribed',
                            color: AppColorConstants.subHeadingTextColor,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        active ? 'Active' : 'Expired',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: statusColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColorConstants.themeColor
                        .withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      _cell(
                          asCreator ? 'You earned' : 'You paid',
                          '${info.coins} coins',
                          icon: Icons.monetization_on_rounded,
                          iconColor: coinColor),
                      _divider(),
                      _cell('Since', _date(info.startedAt)),
                      _divider(),
                      _cell(
                          active ? 'Ends' : 'Ended', _date(info.expiryTime),
                          sub: active ? '${info.daysLeft} days left' : null),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 30,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: AppColorConstants.dividerColor.withValues(alpha: 0.7),
      );

  Widget _cell(String label, String value,
      {IconData? icon, Color? iconColor, String? sub}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BodySmallText(label, color: AppColorConstants.subHeadingTextColor),
          const SizedBox(height: 3),
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: iconColor),
                const SizedBox(width: 3),
              ],
              Flexible(
                child: BodyMediumText(value,
                    weight: TextWeight.bold, maxLines: 1),
              ),
            ],
          ),
          if (sub != null)
            BodySmallText(sub, color: AppColorConstants.subHeadingTextColor),
        ],
      ),
    );
  }
}
