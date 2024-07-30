import 'package:flutter/material.dart';
import 'package:tayseer_insight/screens/home.dart';
import 'package:tayseer_insight/screens/settings.dart';
import './screens/subpage.dart';
import './screens/favorites.dart';
import './screens/qare2Settings.dart';
import 'screens/tafseer_settings.dart';
import './screens/extraspage.dart';
// import './screens/osoolpage.dart';
// import './screens/osoolSubpage.dart';
import 'package:tayseer_insight/globals.dart' as globals;
// import './screens/zyadat.dart';
import './screens/taqdemat.dart';
// import './screens/taqdemat_k.dart';
import './screens/sura_subpage.dart';
import './screens/farshiat_filter.dart';
import './screens/shwahedSettings.dart';
import './screens/Khatamat.dart';

void main() => runApp(new MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "تيسير القراءات للمكفوفين",
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        // home: Home(),
        initialRoute: 'Home',
        routes: {
          'Home': (context) => Home(),
          'settings': (context) => Settings(),
          'subPage': (context) => SubPage(),
          'favorites': (context) => Favorites(),
          'qare2Settings': (context) => Qare2Settings(),
          'tafseerSettings': (context) => TafseerSettings(),
          'extraspage': (context) => Extras(),
          // 'osoolpage': (context) => Osool(),
          // 'osoolSubPage': (context) => OsoolSubPage(),
          // 'zyadat': (context) => Zyadat(),
          'taqdemat': (context) => Taqdemat(),
          // 'taqdematKobra': (context) => TaqdematK(),
          'suraSubpage': (context) => SuraPage(),
          'frashiatFilter': (context) => FarshiatFilter(),
          'shwahedSettings': (context) => ShwahedSettings(),
          'Khatamat': (context) => Khatamat(),
        }));
