import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tayseer_insight/globals.dart' as globals;
import 'package:tayseer_insight/utils/log.dart';

/// Loads and saves the user's choices (reader, tafseer, shawahed types) and
/// mirrors them into [globals] so the rest of the app can keep reading them.
///
/// Fixes two bugs: shawahed choices were saved but never restored, and the
/// tafseer choice was never saved at all.
class SettingsStore {
  SettingsStore._();

  static const _kReader = 'Qare2';
  static const _kTafseer = 'tafseer_folder';
  static const _kShwahed = 'shawahed_setting';

  static List<Map> defaultShwahed() => [
        {"type": "elsab3", "value": "شواهد السبع", "selected": "true"},
        {"type": "elthalath", "value": "شواهد الثلاث", "selected": "true"},
        {"type": "ershadat", "value": " متشابهات", "selected": "true"},
        {"type": "twgeh", "value": "توجيهات", "selected": "true"},
        {"type": "3adAlay", "value": "عد الآي", "selected": "true"},
      ];

  /// Reads everything from storage into [globals]. Never throws: a corrupt
  /// entry falls back to the default for that setting only.
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final reader = prefs.getString(_kReader);
    if (reader != null && reader.isNotEmpty) globals.qre2Folder = reader;

    final tafseer = prefs.getInt(_kTafseer);
    if (tafseer != null && tafseer > 0) globals.tafseerFolder = tafseer;

    globals.myshawahed
      ..clear()
      ..addAll(parseShwahed(prefs.getStringList(_kShwahed)));
  }

  /// Parses the saved list; falls back to the defaults if it is missing or
  /// unreadable. Types added in newer app versions are appended as selected.
  static List<Map> parseShwahed(List<String>? saved) {
    final defaults = defaultShwahed();
    if (saved == null || saved.isEmpty) return defaults;
    final parsed = <Map>[];
    for (final raw in saved) {
      try {
        final decoded = jsonDecode(raw);
        final item = decoded is List && decoded.isNotEmpty ? decoded.first : decoded;
        if (item is Map && item['type'] != null) {
          parsed.add({
            'type': item['type'],
            'value': item['value'],
            'selected': item['selected'].toString(),
          });
        }
      } catch (e) {
        log('ignoring unreadable shawahed entry: $e');
      }
    }
    if (parsed.isEmpty) return defaults;
    for (final d in defaults) {
      if (!parsed.any((p) => p['type'] == d['type'])) parsed.add(d);
    }
    return parsed;
  }

  static Future<void> saveReader(String folder) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kReader, folder);
  }

  static Future<void> saveTafseer(int folder) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kTafseer, folder);
  }

  static Future<void> saveShwahed(List<Map> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kShwahed, [for (final i in items) jsonEncode(i)]);
  }
}
