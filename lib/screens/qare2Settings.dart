import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tayseer_insight/globals.dart' as globals;
// import 'package:simple_permissions/simple_permissions.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

class Qare2Settings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return Qare2SettingsState();
  }
}

class Qare2SettingsState extends State<Qare2Settings> {
  bool _allowWriteFile = false;
  // String _mySelectedQARE2;
  List<Map>? _myQare2 = null;
// String _currVal = "ATolbaHfs";
  bool isLocal = false;
  String local = "محليآ - ";
  String? savedQare2 = "";
  @override
  void initState() {
    super.initState();
    _loadLocalJsonData();

    if (defaultTargetPlatform == TargetPlatform.android) {
      //if (Platform.isAndroid) {
      // requestWritePermission();

    }
    getQare2();
  }
///////////////////PERMISSION FOR ACCESSING INTERNAL STORAGE////////////

  // requestWritePermission() async {
  //   PermissionStatus permissionStatus = await SimplePermissions.requestPermission(Permission.ReadExternalStorage);
  //   if (permissionStatus == PermissionStatus.authorized) {
  //     setState(() {
  //       _allowWriteFile = true;
  //       print(true);
  //     });
  //   }
  // }

// List<Map> shikhList;
  List existList = [];
  Future _loadLocalJsonData() async {
    String jsonQARE2 = await rootBundle.loadString("assets/data/switch_n.json");
    setState(() {
      _myQare2 = List<Map>.from(jsonDecode(jsonQARE2) as List);
      print("*******_myQare2: $_myQare2");
      // List<dynamic> shikhList = new List<dynamic>.from(_myQare2);
      List<dynamic> shikhList = _myQare2!.map((t) => t["folder"]).toList();

      // shikhList=_myQare2.map((t) =>t["shikh"]).toList();
      if (defaultTargetPlatform == TargetPlatform.android) {
        //if (Platform.isAndroid) {
        print(shikhList);
        print(shikhList.length);
        int i = 0;
        shikhList.forEach((str) async {
          final dir = (await getExternalStorageDirectory())!.path;
          //  print(dir);
          String savedPath = '$dir' + "/Tayseer/Sound/" + str;
          print(savedPath);
          bool isExist = await Directory(savedPath).exists();
          print(isExist);
          if (isExist) {
            setState(() {
              existList.add([str, true]);
            });
          } else {
            setState(() {
              existList.add([str, false]);
            });
          }
          i++;
          print(existList);
        });
      }

      // print( _myQare2.map((t) =>t["shikh"].toString()));
    });
  }

  checkLocal(String shikhVAlue) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      // if (Platform.isAndroid) {
      if (existList.length > 0) {
        var el = existList.firstWhereOrNull((e) => e[0] == shikhVAlue);
        if (el != null && el[1] == true) {
          return local;
        } else {
          return " ";
        }
      } else {
        return " ";
      }
    }
  }

/////////////////////SAVE CHOOSEN QARE2 IN SHARED PREFRENCES////////////////////
  saveQare2() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('Qare2', globals.qre2Folder);
  }

/////////////////////GET CHOOSEN QARE2 IN SHARED PREFRENCES////////////////////
  getQare2() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    savedQare2 = prefs.getString('Qare2') ;
    if (savedQare2 == null) {
      savedQare2 = "ATolbaHfs";
    } else {
      globals.qre2Folder = savedQare2!;
    }

    print(globals.qre2Folder);
    print(savedQare2);
  }

  @override
  Widget build(BuildContext context) {
    if (_myQare2 == null) return new Scaffold();
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
        title: Text("اختر قارئ",
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
                child: SingleChildScrollView(
              child: Column(
                children: _myQare2!
                    .map((t) => RadioListTile(
                          autofocus: _myQare2!.indexOf(t) == 0 ? true : false,
                          title: Column(
                            // mainAxisAlignment: MainAxisAlignment.center,
                            // crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              new RichText(
                                textAlign: TextAlign.right,
                                text: new TextSpan(
                                  children: <TextSpan>[
                                    new TextSpan(
                                        text: this
                                            .checkLocal(t["folder"].toString()),
                                        style: TextStyle(
                                            fontSize: 23.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green[900])),
                                    new TextSpan(
                                        text: t["shikh"].toString() +
                                            ' - ' +
                                            t["khatma"].toString() +
                                            ' - ' +
                                            t["text"].toString(),
                                        style: TextStyle(
                                            fontSize: 23.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.brown[900])),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          groupValue: globals.qre2Folder,
                          value: t["folder"].toString(),
                          controlAffinity: ListTileControlAffinity.trailing,
                          onChanged: (val) {
                            setState(() {
                              globals.qre2Folder = val as String;
                              saveQare2();
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
