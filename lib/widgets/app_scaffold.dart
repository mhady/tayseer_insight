import 'package:flutter/material.dart';
import 'package:tayseer_insight/app/theme.dart';
import 'package:tayseer_insight/widgets/app_back_button.dart';

/// Parchment-pattern background used behind every screen. Purely decorative,
/// so it is not exposed to assistive technology.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.ink,
        image: DecorationImage(
          image: AssetImage('assets/images/islam.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}

/// Standard screen: ink app bar with an accessible back button, patterned body
/// and an optional bottom bar.
///
/// The [title] becomes the route name announced by the screen reader.
/// [subtitle] (optional) is shown under the title as a live region and its
/// height follows the user's text size.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.bottomBar,
    this.onBack,
    this.showBack = true,
    this.subtitle,
    this.subtitleLive = true,
    this.titleSize = 23,
  });

  final String title;
  final String? subtitle;

  /// Announce subtitle changes to screen readers. Turn off when the subtitle
  /// changes by itself (e.g. continuous playback).
  final bool subtitleLive;
  final Widget body;
  final Widget? bottomBar;

  /// Custom back action (e.g. stop audio first). Defaults to `maybePop`.
  final VoidCallback? onBack;
  final bool showBack;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final toolbarHeight = (scaler.scale(titleSize) * 1.5 + 12).clamp(56.0, 140.0);

    PreferredSizeWidget? bottom;
    if (subtitle != null) {
      final height = scaler.scale(17) * 1.6 + 10;
      bottom = PreferredSize(
        preferredSize: Size.fromHeight(height),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Semantics(
            liveRegion: subtitleLive,
            child: Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.parchment, fontSize: 17),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: showBack ? AppBackButton(onPressed: onBack) : null,
        leadingWidth: showBack ? AppBackButton.widthFor(context) : null,
        centerTitle: true,
        toolbarHeight: toolbarHeight,
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.parchment,
        title: Text(
          title,
          maxLines: 2,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.parchment,
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: bottom,
      ),
      body: AppBackground(child: body),
      bottomNavigationBar: bottomBar,
    );
  }
}

/// Bottom navigation strip. Children are laid out in one row, or in two
/// columns when the user's text size is large so labels never clip.
class AppBottomBar extends StatelessWidget {
  const AppBottomBar({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final stacked = AppTheme.textScale(context) > 1.3 && children.length > 2;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.ink,
        image: DecorationImage(
          image: AssetImage('assets/images/islam.png'),
          fit: BoxFit.cover,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 2),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: stacked
              ? LayoutBuilder(builder: (context, constraints) {
                  final width = (constraints.maxWidth - 2) / 2;
                  return Wrap(
                    spacing: 2,
                    runSpacing: 2,
                    children: [
                      for (final c in children) SizedBox(width: width, child: c),
                    ],
                  );
                })
              : Row(
                  children: [
                    for (final c in children) Expanded(child: c),
                  ],
                ),
        ),
      ),
    );
  }
}
