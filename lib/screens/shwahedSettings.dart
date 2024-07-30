import 'package:flutter/material.dart';
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

  void saveShwahed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> _myshawahe = [];
    if (globals.myshawahed != null) {
      for (var i = 0; i < globals.myshawahed.length; i++) {
        _myshawahe.add(jsonEncode(globals.myshawahed[i]));
      }
    }
    prefs.setStringList('shawahed_setting', _myshawahe);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 0.0),
          child: new GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Text("الرجوع",
                style: TextStyle(fontSize: 16.0, color: Colors.brown[100])),
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xff22160B),
        title: Text("اختر الشواهد",
            style: TextStyle(
                color: Colors.brown[100],
                fontSize: 23.0,
                fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xff22160B),
          image: DecorationImage(
            image: AssetImage("assets/images/islam.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: <Widget>[
            Expanded(
                child: Container(
              child: Column(
                children: globals.myshawahed
                    .map((t) => CheckboxListTile(
                          autofocus:
                              globals.myshawahed.indexOf(t) == 0 ? true : false,
                          title: Text(t["value"].toString(),
                              style: TextStyle(
                                fontSize: 23.0,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right),
                          selected: t["selected"] == 'true',
                          value: t["selected"] == 'true',
                          controlAffinity: ListTileControlAffinity.trailing,
                          onChanged: (bool? val) {
                            setState(() {
                              changeShwahed(t, val!);
                              //globals.tafseerFolder = val;
                              //  Navigator.of(context).pop();
                            });
                          },
                          activeColor: Colors.brown[900],
                        ))
                    .toList(),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
