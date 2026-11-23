import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tayseer_insight/app/theme.dart';
import 'package:tayseer_insight/screens/home.dart';
import 'package:tayseer_insight/screens/settings.dart';
import './screens/subpage.dart';
import './screens/favorites.dart';
import './screens/qare2Settings.dart';
import 'screens/tafseer_settings.dart';
import './screens/extraspage.dart';
import './screens/taqdemat.dart';
import './screens/sura_subpage.dart';
import './screens/farshiat_filter.dart';
import './screens/shwahedSettings.dart';
import './screens/khatamat.dart';

void main() => runApp(const TayseerApp());

class TayseerApp extends StatelessWidget {
  const TayseerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'تيسير القراءات للمكفوفين',
      theme: AppTheme.light,
      // Arabic locale => right-to-left layout, Arabic framework strings, and
      // swipe order / grid order that match how Arabic readers navigate.
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: 'Home',
      routes: {
        'Home': (context) => Home(),
        'settings': (context) => Settings(),
        'subPage': (context) => SubPage(),
        'favorites': (context) => Favorites(),
        'qare2Settings': (context) => Qare2Settings(),
        'tafseerSettings': (context) => TafseerSettings(),
        'extraspage': (context) => Extras(),
        'taqdemat': (context) => Taqdemat(),
        'suraSubpage': (context) => SuraPage(),
        'frashiatFilter': (context) => FarshiatFilter(),
        'shwahedSettings': (context) => ShwahedSettings(),
        'Khatamat': (context) => Khatamat(),
      },
    );
  }
}
