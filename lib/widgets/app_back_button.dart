import 'package:flutter/material.dart';
import 'package:tayseer_insight/app/theme.dart';

/// "الرجوع" back control for [AppBar.leading].
///
/// Replaces the old `GestureDetector(Text)` which had no button role, no
/// keyboard focus and a tap area of roughly 40x20dp.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onPressed});

  /// Defaults to `Navigator.maybePop`, so `PopScope` guards are respected.
  final VoidCallback? onPressed;

  static const String label = 'الرجوع';

  /// Width to give [AppBar.leadingWidth] so the label never wraps or clips,
  /// even at large text sizes.
  static double widthFor(BuildContext context) {
    final textWidth = MediaQuery.textScalerOf(context).scale(16) * 4.5;
    final width = textWidth + 24;
    return width < 88 ? 88 : (width > 220 ? 220 : width);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.parchment,
        minimumSize: const Size(AppTheme.minTapTarget, AppTheme.minTapTarget),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
      child: const Text(
        label,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.visible,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
