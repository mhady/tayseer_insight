import 'package:flutter/material.dart';
import 'package:tayseer_insight/widgets/app_scaffold.dart';
import 'package:tayseer_insight/app/theme.dart';
import 'package:tayseer_insight/services/settings_store.dart';

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tayseer_insight/globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

class ShwahedSettings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ShwahedSettingsState();
  }
}

class ShwahedSettingsState extends State<ShwahedSettings> {
  @override
  void initState() {
    super.initState();

    //  _myshawahed=["شواهد السبع","شواهد الثلاث" , "ارشادات", "توجيهات", "عد الاي"];
  }

  void changeShwahed(var item, bool val) async {
    for (var i = 0; i < globals.myshawahed.length; i++) {
      if (item['type'] == globals.myshawahed[i]['type'])
        globals.myshawahed[i]['selected'] = val
            .toString(); //(!(globals.myshawahed[i]['selected'].parseBool())).toString()  ;
    }

    saveShwahed();
  }

  void saveShwahed() => SettingsStore.saveShwahed(globals.myshawahed);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'اختر الشواهد',
      body: SingleChildScrollView(
        child: Container(
          color: AppColors.parchment,
          child: Column(
            children: globals.myshawahed
                .map((t) => CheckboxListTile(
                      autofocus: globals.myshawahed.indexOf(t) == 0,
                      title: Text(
                        t["value"].toString(),
                        style: const TextStyle(
                          fontSize: 23.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                      selected: t["selected"] == 'true',
                      value: t["selected"] == 'true',
                      controlAffinity: ListTileControlAffinity.trailing,
                      onChanged: (bool? val) {
                        setState(() {
                          changeShwahed(t, val!);
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
