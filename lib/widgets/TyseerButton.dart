import 'package:flutter/material.dart';
import 'package:tayseer_insight/widgets/app_button.dart';

/// Bottom-bar button. Thin wrapper over [AppButton]; place inside an
/// `AppBottomBar`, which handles the layout (no longer returns `Expanded`).
class TyseerButton extends StatelessWidget {
  final double buttonHeight;
  final String text;
  final VoidCallback onPressed;

  const TyseerButton({
    super.key,
    required this.buttonHeight,
    required this.text,
    required this.onPressed,
    @Deprecated('Width is now decided by AppBottomBar') double? buttonWidth,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: text,
      fontSize: 18,
      bold: true,
      minHeight: buttonHeight,
      onPressed: onPressed,
    );
  }
}
