import 'package:flutter/material.dart';
import '../components/custom_texts.dart';
import '../util/app_config_constants.dart';
import 'package:get/get.dart';

/// Rounded card that groups [MenuTile]s with thin dividers.
class MenuSection extends StatelessWidget {
  final List<Widget> tiles;
  const MenuSection({super.key, required this.tiles});

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = [];
    for (int i = 0; i < tiles.length; i++) {
      rows.add(tiles[i]);
      if (i != tiles.length - 1) {
        rows.add(Padding(
          padding: const EdgeInsets.only(left: 68),
          child: Divider(
              height: 1,
              thickness: 0.6,
              color: AppColorConstants.dividerColor.withValues(alpha: 0.6)),
        ));
      }
    }
    return Container(
      clipBehavior: Clip.antiAlias,
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
      child: Column(children: rows),
    );
  }
}

/// Settings-style row: coloured icon bubble, title, optional subtitle.
class MenuTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const MenuTile({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BodyLargeText(title.tr),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: BodySmallText(
                          subtitle!,
                          color: AppColorConstants.subHeadingTextColor,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 22, color: AppColorConstants.iconColor),
            ],
          ),
        ),
      ),
    );
  }
}

/// Same look as [MenuTile] but with a custom trailing widget (switch etc.)
class MenuRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const MenuRow({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.trailing,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BodyLargeText(title.tr),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: BodySmallText(
                          subtitle!,
                          color: AppColorConstants.subHeadingTextColor,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
