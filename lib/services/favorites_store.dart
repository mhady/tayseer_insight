import 'package:shared_preferences/shared_preferences.dart';

/// One saved favourite: sura + aya numbers and the label shown on its button.
class FavoriteEntry {
  const FavoriteEntry({required this.sora, required this.aya, required this.label});
  final int sora;
  final int aya;
  final String label;
}

/// Reads/writes the five favourite slots.
///
/// Storage format is unchanged from earlier versions
/// (`favoriteN` = `[sora, aya, label]` as a string list), so existing users
/// keep their favourites.
class FavoritesStore {
  FavoritesStore._();

  static const int slots = 5;

  static const List<String> emptyLabels = [
    'المفضلة الأولى',
    'المفضلة الثانية',
    'المفضلة الثالثة',
    'المفضلة الرابعة',
    'المفضلة الخامسة',
  ];

  static String _key(int slot) => 'favorite${slot + 1}';

  /// Returns [slots] items; `null` means the slot is empty.
  static Future<List<FavoriteEntry?>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return List.generate(slots, (slot) {
      final raw = prefs.getStringList(_key(slot));
      if (raw == null || raw.length < 3) return null;
      final sora = int.tryParse(raw[0]);
      final aya = int.tryParse(raw[1]);
      if (sora == null || aya == null) return null;
      return FavoriteEntry(sora: sora, aya: aya, label: raw[2]);
    });
  }

  static Future<void> save(
    int slot, {
    required int sora,
    required int aya,
    required String label,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key(slot), [sora.toString(), aya.toString(), label]);
  }

  /// Label for a slot: the saved label, or the "empty" placeholder.
  static String labelFor(List<FavoriteEntry?> entries, int slot) =>
      entries[slot]?.label ?? emptyLabels[slot];
}
