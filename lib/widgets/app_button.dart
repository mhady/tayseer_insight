import 'package:flutter/material.dart';
import 'package:tayseer_insight/app/theme.dart';

/// The app's standard button.
///
/// * Real [ElevatedButton], so TalkBack/VoiceOver announce a button and
///   keyboard / switch access can focus it.
/// * Height is a *minimum*, so it grows with the user's text size.
/// * [semanticLabel] lets the spoken text differ from the visible text.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.semanticLabel,
    this.fontSize = 23,
    this.minHeight = 64,
    this.autofocus = false,
    this.expand = false,
    this.bold = false,
    this.subtitle,
  });

  final String label;
  final VoidCallback? onPressed;

  /// What the screen reader says. Defaults to [label].
  final String? semanticLabel;
  final double fontSize;
  final double minHeight;
  final bool autofocus;

  /// Fill the available width.
  final bool expand;
  final bool bold;

  /// Optional smaller second line (e.g. reader name). Spoken after [label].
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: onPressed,
      autofocus: autofocus,
      style: AppTheme.buttonStyle(minHeight: minHeight),
      child: subtitle == null || subtitle!.isEmpty
          ? Text(
              label,
              textAlign: TextAlign.center,
              semanticsLabel: semanticLabel,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: bold ? FontWeight.bold : null,
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  textAlign: TextAlign.center,
                  semanticsLabel: semanticLabel,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: bold ? FontWeight.bold : null,
                  ),
                ),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: fontSize * 0.7),
                ),
              ],
            ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Lays buttons out in [maxColumns] equal columns, dropping to a single
/// full-width column when the user's text size is large or the screen is narrow.
class AppButtonWrap extends StatelessWidget {
  const AppButtonWrap({
    super.key,
    required this.children,
    this.maxColumns = 2,
    this.spacing = 4,
  });

  final List<Widget> children;
  final int maxColumns;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final available = constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : MediaQuery.sizeOf(context).width;
      var columns = maxColumns;
      if (AppTheme.textScale(context) > 1.4 || available < 300) columns = 1;
      final width = (available - spacing * (columns - 1)) / columns;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          for (final child in children) SizedBox(width: width, child: child),
        ],
      );
    });
  }
}
