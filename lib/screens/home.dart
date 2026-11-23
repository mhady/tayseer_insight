import 'package:tayseer_insight/utils/log.dart';
import 'package:flutter/material.dart';

import 'package:tayseer_insight/app/theme.dart';
import 'package:tayseer_insight/services/settings_store.dart';
import 'package:tayseer_insight/widgets/loading_view.dart';
import 'package:tayseer_insight/widgets/TyseerButton.dart';
import 'package:tayseer_insight/widgets/app_scaffold.dart';
import '../globals.dart';
import './sura_subpage.dart';
import 'package:tayseer_insight/globals.dart' as globals;

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

/* 
var focusNode = FocusNode();
var textField = TextField(focusNode: focusNode);

FocusScope.of(context).requestFocus(focusNode);
// or 
focusNode.requestFocus();
*/

/// The twelve groups of suras shown on the home screen: id, first sura, last sura.
const List<(int, String, String)> _suraGroups = [
  (1, 'الفاتحة', 'الأنفال'),
  (2, 'التوبة', 'النحل'),
  (3, 'الإسراء', 'النور'),
  (4, 'الفرقان', 'السجدة'),
  (5, 'الأحزاب', 'غافر'),
  (6, 'فصلت', 'الفتح'),
  (7, 'الحجرات', 'الحديد'),
  (8, 'المجادلة', 'التحريم'),
  (9, 'الملك', 'النبأ'),
  (10, 'النازعات', 'البلد'),
  (11, 'الشمس', 'التكاثر'),
  (12, 'العصر', 'الناس'),
];

class HomeState extends State<Home> {
  bool data_ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  /// Restores the saved settings (reader, tafseer, shawahed) and loads the
  /// ayah text. Shows an error with a retry button if loading fails instead of
  /// staying on the loading screen forever.
  Future<void> _boot() async {
    try {
      await SettingsStore.load();
      await globals.LoadData().getAyaTextList();
      if (!mounted) return;
      setState(() {
        data_ready = true;
        _failed = false;
      });
    } catch (e, st) {
      log('home boot failed: $e\n$st');
      if (mounted) setState(() => _failed = true);
    }
  }

  void suraSubpage(int value) {
    RequiredSura requiredSura = RequiredSura(id: value);
    Navigator.pushNamed(context, 'suraSubpage', arguments: requiredSura);
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return AppScaffold(
        title: 'تيسير القراءات',
        showBack: false,
        body: ErrorView(
          message: 'تعذر تحميل بيانات التطبيق.',
          onRetry: () {
            setState(() => _failed = false);
            _boot();
          },
        ),
      );
    }
    if (!data_ready) return globals.GlobalUI().getLoadingContent();
    final scale = AppTheme.textScale(context);
    return AppScaffold(
      title: 'تيسير القراءات',
      showBack: false,
      titleSize: 18,
      body: LayoutBuilder(builder: (context, constraints) {
        // Fewer, taller cells when the user has chosen a larger text size,
        // so the two-line labels never clip.
        final columns = scale > 2.0 ? 1 : (scale > 1.3 ? 2 : 3);
        const gap = 9.0;
        const pad = 5.0;
        final cellWidth =
            (constraints.maxWidth - pad * 2 - gap * (columns - 1)) / columns;
        final lines = scale > 1.3 ? 3 : 2;
        final cellHeight = MediaQuery.textScalerOf(context).scale(18) * 1.4 * lines + 28;
        return GridView.builder(
          padding: const EdgeInsets.all(pad),
          itemCount: _suraGroups.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: gap,
            mainAxisSpacing: gap,
            childAspectRatio: cellWidth / (cellHeight < 72 ? 72 : cellHeight),
          ),
          itemBuilder: (context, index) {
            final (id, from, to) = _suraGroups[index];
            return ElevatedButton(
              autofocus: index == 0,
              onPressed: () => suraSubpage(id),
              style: AppTheme.buttonStyle(minHeight: 72),
              child: Text(
                '$from\nالى $to',
                textAlign: TextAlign.center,
                semanticsLabel: 'من سورة $from إلى سورة $to',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          },
        );
      }),
      bottomBar: AppBottomBar(
        children: [
          TyseerButton(
            buttonHeight: 70,
            text: 'المفضلات',
            onPressed: () => Navigator.pushNamed(context, 'favorites'),
          ),
          TyseerButton(
            buttonHeight: 70,
            text: 'الإعدادات',
            onPressed: () => Navigator.pushNamed(context, 'settings'),
          ),
          TyseerButton(
            buttonHeight: 70,
            text: 'الختمات',
            onPressed: () => Navigator.pushNamed(context, 'Khatamat'),
          ),
          TyseerButton(
            buttonHeight: 70,
            text: 'الخدمات',
            onPressed: () => Navigator.pushNamed(context, 'extraspage'),
          ),
        ],
      ),
    );
  }
}
