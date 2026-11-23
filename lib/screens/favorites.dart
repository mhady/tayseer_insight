import 'package:flutter/material.dart';
import 'package:tayseer_insight/globals.dart';
import 'package:tayseer_insight/services/favorites_store.dart';
import 'package:tayseer_insight/widgets/app_button.dart';
import 'package:tayseer_insight/widgets/app_scaffold.dart';

class Favorites extends StatefulWidget {
  const Favorites({super.key});

  @override
  State<StatefulWidget> createState() => FavoritesPageState();
}

class FavoritesPageState extends State<Favorites> {
  List<FavoriteEntry?> _entries = List.filled(FavoritesStore.slots, null);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await FavoritesStore.load();
    if (!mounted) return;
    setState(() => _entries = entries);
  }

  /// Sura/aya numbers are passed to the player as zero-padded 3-digit strings.
  String _pad(int n) => n.toString().padLeft(3, '0');

  void _open(int slot) {
    final entry = _entries[slot];
    if (entry == null) return;
    final args = AyaSoraNumber(aya: _pad(entry.aya), sora: _pad(entry.sora));
    Navigator.pushNamed(context, 'subPage', arguments: args);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'المفضلات',
      body: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: FavoritesStore.slots,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, slot) => AppButton(
          label: FavoritesStore.labelFor(_entries, slot),
          expand: true,
          minHeight: 70,
          autofocus: slot == 0,
          onPressed: () => _open(slot),
        ),
      ),
    );
  }
}
