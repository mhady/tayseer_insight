import 'package:tayseer_insight/utils/log.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tayseer_insight/app/theme.dart';
import 'package:tayseer_insight/widgets/TyseerButton.dart';
import 'package:tayseer_insight/widgets/app_scaffold.dart';
import '../globals.dart';
import './sura_subpage.dart';
import 'package:tayseer_insight/globals.dart' as globals;
import 'dart:convert';

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
  @override
  void initState() {
    super.initState();
    getQare2();
    getShwahed();
    _asyncMethod();
  }

  _asyncMethod() async {
    // log('getAyaTextList called  ');
    await globals.LoadData().getAyaTextList();
    setState(() {
      data_ready = true;
      // log('getAyaTextList end  ');
      // log(globals.AyaTextList);
    });
  }

  void suraSubpage(int value) {
    RequiredSura requiredSura = new RequiredSura(id: value);
    Navigator.pushNamed(context, 'suraSubpage', arguments: requiredSura);
  }

  Future loadShwahedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getStringList('shawahed_setting');
  }

  void getShwahed() async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? _myshawahed = null; //prefs.getStringList('shawahed_setting');

    loadShwahedData().then((data) {
      setState(() {
        _myshawahed = data;
      });
    });

    if (_myshawahed != null && _myshawahed!.length > 0) {
      // exist in saved preferences
      if (globals.myshawahed.length == 0) //not loaded
      {
        for (String i in _myshawahed!) {
          var item = List<Map>.from(jsonDecode("[" + i + "]") as List);
          globals.myshawahed.add({
            'type': item[0]['type'],
            'value': item[0]['value'],
            'selected': item[0]['selected']
          });
        }
      }
    } else {
      if (globals.myshawahed.length == 0) //not loaded
      {
        globals.myshawahed.add(
            {"type": "elsab3", "value": "شواهد السبع", "selected": "true"});
        globals.myshawahed.add(
            {"type": "elthalath", "value": "شواهد الثلاث", "selected": "true"});
        globals.myshawahed.add(
            {"type": "ershadat", "value": " متشابهات", "selected": "true"});
        globals.myshawahed
            .add({"type": "twgeh", "value": "توجيهات", "selected": "true"});
        globals.myshawahed
            .add({"type": "3adAlay", "value": "عد الآي", "selected": "true"});
      }
    }
  }

  void getQare2() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedQare2 = prefs.getString('Qare2');
    if (savedQare2 == null) {
      savedQare2 = "ATolbaHfs";
    } else {
      globals.qre2Folder = savedQare2;
    }

    log(globals.qre2Folder);
    log(savedQare2);
  }

  Widget build(BuildContext context) {
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
