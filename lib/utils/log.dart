import 'package:flutter/foundation.dart';

/// Debug-only logging. Replaces bare `print` so release builds stay quiet
/// and never dump whole JSON assets to logcat.
void log(Object? message) {
  if (kDebugMode) debugPrint(message?.toString());
}
