import 'package:flutter/material.dart';
import '../components/custom_texts.dart';
import '../util/app_config_constants.dart';

/// Gradient ring around a profile picture (adds 6px to the size).
class ProfileAvatarRing extends StatelessWidget {
  final Widget child;
  const ProfileAvatarRing({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColorConstants.themeColor,
            const Color(0xFFEC4899),
            const Color(0xFFF59E0B),
          ],
        ),
        boxShadow: [
          BoxShadow(
              color: AppColorConstants.themeColor.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColorConstants.backgroundColor,
        ),
        child: child,
      ),
    );
  }
}

/// Small rounded label, e.g. the profile category.
class ProfileChip extends StatelessWidget {
  final String text;
  final IconData? icon;
  const ProfileChip({super.key, required this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColorConstants.themeColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: AppColorConstants.themeColor),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColorConstants.themeColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pin icon + place name.
class ProfileLocation extends StatelessWidget {
  final String text;
  const ProfileLocation({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_on_outlined,
            size: 15, color: AppColorConstants.subHeadingTextColor),
        const SizedBox(width: 3),
        Flexible(
          child: BodyMediumText(text,
              color: AppColorConstants.subHeadingTextColor, maxLines: 1),
        ),
      ],
    );
  }
}
