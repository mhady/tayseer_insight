import 'package:flutter/material.dart';
import 'package:tayseer_insight/app/theme.dart';
import 'package:tayseer_insight/widgets/app_button.dart';
import 'package:tayseer_insight/widgets/app_scaffold.dart';

/// Full-screen loading state. The message is a live region, so a screen reader
/// says "جاري التحميل" instead of staying silent. The animated GIF is purely
/// decorative and is hidden from assistive tech and from users who asked for
/// reduced motion.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message = 'جاري التحميل'});
  final String message;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Material(
      color: AppColors.ink,
      child: AppBackground(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  liveRegion: true,
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!reduceMotion)
                  ExcludeSemantics(
                    child: Image.asset('assets/images/Loading_icon.gif'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-screen error state with a retry button. Use instead of leaving the
/// user on an endless loading screen when a request fails.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    this.message = 'تعذر التحميل. تأكد من الاتصال بالإنترنت.',
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.ink,
      child: AppBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  liveRegion: true,
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'إعادة المحاولة',
                  autofocus: true,
                  onPressed: onRetry,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
