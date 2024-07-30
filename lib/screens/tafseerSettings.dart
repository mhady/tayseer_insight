import 'package:flutter/material.dart';
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
      print("*******_myTafseer: $_myTafseer");
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_myTafseer == null) return new Scaffold();

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
        title: Text("اختر التفسير",
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
                children: _myTafseer!
                    .map((t) => RadioListTile<String>(
                          autofocus: _myTafseer!.indexOf(t) == 0 ? true : false,
                          title: Text(t["tafseerType"].toString(),
                              style: TextStyle(
                                  fontSize: 23.0, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right),
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
            )),
          ],
        ),
      ),
    );
  }
}
