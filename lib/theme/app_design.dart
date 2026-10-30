import 'package:flutter/material.dart';
import 'package:foap/theme/theme.dart';
import 'package:foap/util/app_config_constants.dart';

/// Central design tokens. Use these instead of hard-coded numbers so every
/// screen shares the same rhythm.
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double pill = 999;

  static BorderRadius get card => BorderRadius.circular(lg);
  static BorderRadius get input => BorderRadius.circular(md);
  static BorderRadius get button => BorderRadius.circular(md);
}

/// Soft, layered shadows instead of one harsh shadow.
class AppElevation {
  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  /// Dark surfaces separate with a hairline border, not with shadows.
  static List<BoxShadow> get none => const [];
}

/// Typography scale (size / weight / line height).
class AppText {
  static TextStyle _base(double size, FontWeight weight, double height,
          {double letterSpacing = 0}) =>
      TextStyle(
        fontFamily: AppTheme.fontName,
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle get display => _base(28, FontWeight.w700, 1.2);
  static TextStyle get title => _base(20, FontWeight.w600, 1.3);
  static TextStyle get subtitle => _base(16, FontWeight.w600, 1.35);
  static TextStyle get body => _base(14, FontWeight.w400, 1.45);
  static TextStyle get bodyStrong => _base(14, FontWeight.w600, 1.45);
  static TextStyle get caption => _base(12, FontWeight.w400, 1.4);
  static TextStyle get button =>
      _base(15, FontWeight.w600, 1.2, letterSpacing: 0.2);
}

class AppThemeBuilder {
  static ThemeData build({required bool dark}) {
    final Color primary = AppColorConstants.themeColor;
    final Color bg = AppColorConstants.backgroundColor;
    final Color surface = AppColorConstants.cardColor;
    final Color text = AppColorConstants.mainTextColor;
    final Color border = AppColorConstants.borderColor;

    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: dark ? Brightness.dark : Brightness.light,
    ).copyWith(
      primary: primary,
      surface: surface,
      onSurface: text,
      outline: border,
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: AppRadius.input,
      borderSide: BorderSide(color: border),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      fontFamily: AppTheme.fontName,
      colorScheme: scheme,
      primaryColor: primary,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppText.subtitle.copyWith(color: text),
      ),
      dividerTheme: DividerThemeData(
        color: AppColorConstants.dividerColor,
        thickness: 0.5,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: AppText.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          minimumSize: const Size.fromHeight(48),
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
          textStyle: AppText.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: AppText.bodyStrong,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        hintStyle: AppText.body
            .copyWith(color: AppColorConstants.inputFieldPlaceholderTextColor),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: AppColorConstants.red),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg + 4)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
      ),
      textTheme: TextTheme(
        displaySmall: AppText.display,
        titleLarge: AppText.title,
        titleMedium: AppText.subtitle,
        bodyMedium: AppText.body,
        bodySmall: AppText.caption,
        labelLarge: AppText.button,
      ).apply(bodyColor: text, displayColor: text),
    );
  }
}
