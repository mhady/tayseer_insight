import 'package:tayseer_insight/utils/log.dart';
import 'package:flutter/material.dart';
import 'package:tayseer_insight/widgets/app_scaffold.dart';
import 'package:tayseer_insight/app/theme.dart';
import 'package:tayseer_insight/widgets/loading_view.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tayseer_insight/globals.dart' as globals;

class TafseerSettings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TafseerSettingsState();
  }
}

class TafseerSettingsState extends State<TafseerSettings> {
  List<Map>? _myTafseer;
  @override
  void initState() {
    super.initState();
    _loadLocalJsonData();
  }

  Future _loadLocalJsonData() async {
    String jsonQARE2 =
        await rootBundle.loadString("assets/data/tafseerat.json");
    setState(() {
      _myTafseer = List<Map>.from(jsonDecode(jsonQARE2) as List);
      log("*******_myTafseer: $_myTafseer");
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_myTafseer == null) return const LoadingView();

    return AppScaffold(
      title: 'اختر التفسير',
      body: SingleChildScrollView(
        child: Container(
          color: AppColors.parchment,
          child: Column(
            children: _myTafseer!
                .map((t) => RadioListTile<String>(
                      autofocus: _myTafseer!.indexOf(t) == 0,
                      title: Text(
                        t["tafseerType"].toString(),
                        style: const TextStyle(
                          fontSize: 23.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                      groupValue: globals.tafseerFolder.toString(),
                      value: t["tafseerFolder"].toString(),
                      controlAffinity: ListTileControlAffinity.trailing,
                      onChanged: (val) {
                        setState(() {
                          globals.tafseerFolder = int.parse(val as String);
                          Navigator.of(context).pop();
                        });
                      },
                      activeColor: Colors.brown[900],
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}
