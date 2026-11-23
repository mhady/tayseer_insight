/// Pure helpers for ayah numbers, bounds and spoken durations.
library;

/// Converts Arabic-Indic (٠-٩) and Eastern/Persian (۰-۹) digits to ASCII.
///
/// Arabic keyboards can emit these digits, and `int.parse` rejects them.
String normalizeDigits(String input) {
  final buffer = StringBuffer();
  for (final unit in input.runes) {
    if (unit >= 0x0660 && unit <= 0x0669) {
      buffer.writeCharCode(0x30 + (unit - 0x0660));
    } else if (unit >= 0x06F0 && unit <= 0x06F9) {
      buffer.writeCharCode(0x30 + (unit - 0x06F0));
    } else {
      buffer.writeCharCode(unit);
    }
  }
  return buffer.toString();
}

/// Parses an ayah number typed by the user. Returns `null` for empty or
/// non-numeric input, or for 0.
int? parseAyaNumber(String raw) {
  final text = normalizeDigits(raw.trim());
  if (text.isEmpty || !RegExp(r'^\d+$').hasMatch(text)) return null;
  final value = int.tryParse(text);
  if (value == null || value < 1) return null;
  return value;
}

/// Zero-pads to three digits (`7` → `007`), the format used by audio file names.
String pad3(int n) => n.toString().padLeft(3, '0');

enum AyaMove { ok, beforeFirst, afterLast }

/// Whether [target] is a valid ayah in a sura that has [lastAya] ayat.
AyaMove classifyAyaTarget(int target, int lastAya) {
  if (target < 1) return AyaMove.beforeFirst;
  if (target > lastAya) return AyaMove.afterLast;
  return AyaMove.ok;
}

/// Duration as words for a screen reader ("دقيقتان" style grammar is avoided
/// on purpose; plain numbers are read correctly by Arabic TTS voices).
String spokenDuration(Duration d) {
  final total = d.inSeconds < 0 ? 0 : d.inSeconds;
  final hours = total ~/ 3600;
  final minutes = (total % 3600) ~/ 60;
  final seconds = total % 60;
  final parts = <String>[
    if (hours > 0) '$hours ساعة',
    if (minutes > 0) '$minutes دقيقة',
    if (seconds > 0 || (hours == 0 && minutes == 0)) '$seconds ثانية',
  ];
  return parts.join(' و');
}
