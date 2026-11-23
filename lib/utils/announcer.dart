import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Speaks [message] through the active screen reader (TalkBack / VoiceOver).
/// Does nothing audible when no screen reader is running.
///
/// Kept in one place so the Flutter API can be swapped in a single line
/// (`SemanticsService.sendAnnouncement` on newer Flutter versions).
class Announcer {
  Announcer._();

  static Future<void> say(BuildContext context, String message) {
    // ignore: deprecated_member_use
    return SemanticsService.announce(message, Directionality.of(context));
  }
}
