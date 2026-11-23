import 'package:flutter/material.dart';

/// Brand colours used across the app.
///
/// `ink` on `parchment` has a contrast ratio of about 11:1 (WCAG AAA).
class AppColors {
  AppColors._();

  /// Dark brown used for buttons, app bars and the background tint.
  static const Color ink = Color(0xff22160B);

  /// Light text colour on top of [ink] (same value as `Colors.brown[100]`).
  static const Color parchment = Color(0xffD7CCC8);
}

class AppTheme {
  AppTheme._();

  /// Minimum touch target recommended by Android (48dp) / WCAG 2.2 AAA (44px).
  static const double minTapTarget = 48;

  static ThemeData get light => ThemeData(
        primarySwatch: Colors.blue,
        materialTapTargetSize: MaterialTapTargetSize.padded,
      );

  /// The one button look used by the whole app: ink background, parchment text,
  /// square corners, and a *minimum* (never fixed) height so large system fonts
  /// can grow the button instead of clipping the label.
  static ButtonStyle buttonStyle({double minHeight = 64}) {
    return ElevatedButton.styleFrom(
      foregroundColor: AppColors.parchment,
      backgroundColor: AppColors.ink,
      disabledForegroundColor: AppColors.parchment.withValues(alpha: 0.6),
      disabledBackgroundColor: AppColors.ink.withValues(alpha: 0.6),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      minimumSize: Size(64, minHeight < minTapTarget ? minTapTarget : minHeight),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      tapTargetSize: MaterialTapTargetSize.padded,
      elevation: 0,
    );
  }

  /// Ratio of the user's chosen text size to the default (1.0 = default).
  static double textScale(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(16) / 16;
}
