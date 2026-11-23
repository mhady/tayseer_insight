import 'package:tayseer_insight/utils/log.dart';
import 'package:flutter/material.dart';
import 'package:tayseer_insight/widgets/app_scaffold.dart';
import 'package:tayseer_insight/app/theme.dart';

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tayseer_insight/globals.dart' as globals;
import 'package:tayseer_insight/widgets/loading_view.dart';
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
  //       log(true);
  //     });
  //   }
  // }

// List<Map> shikhList;
  List existList = [];
  Future _loadLocalJsonData() async {
    String jsonQARE2 = await rootBundle.loadString("assets/data/switch_n.json");
    setState(() {
      _myQare2 = List<Map>.from(jsonDecode(jsonQARE2) as List);
      log("*******_myQare2: $_myQare2");
      // List<dynamic> shikhList = new List<dynamic>.from(_myQare2);
      List<dynamic> shikhList = _myQare2!.map((t) => t["folder"]).toList();

      // shikhList=_myQare2.map((t) =>t["shikh"]).toList();
      if (defaultTargetPlatform == TargetPlatform.android) {
        //if (Platform.isAndroid) {
        log(shikhList);
        log(shikhList.length);
        int i = 0;
        shikhList.forEach((str) async {
          final dir = (await getExternalStorageDirectory())!.path;
          //  log(dir);
          String savedPath = '$dir' + "/Tayseer/Sound/" + str;
          log(savedPath);
          bool isExist = await Directory(savedPath).exists();
          log(isExist);
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
          log(existList);
        });
      }

      // log( _myQare2.map((t) =>t["shikh"].toString()));
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

    log(globals.qre2Folder);
    log(savedQare2);
  }

  @override
  Widget build(BuildContext context) {
    if (_myQare2 == null) return const LoadingView();
    return AppScaffold(
      title: 'اختر قارئ',
      body: SingleChildScrollView(
        child: Container(
          // Solid card behind the list so the text never sits on the ornate pattern.
          color: AppColors.parchment,
          child: Column(
            children: _myQare2!
                .map((t) => RadioListTile<String>(
                      autofocus: _myQare2!.indexOf(t) == 0,
                      title: RichText(
                        textAlign: TextAlign.start,
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                                text: checkLocal(t["folder"].toString()),
                                style: TextStyle(
                                    fontSize: 23.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[900])),
                            TextSpan(
                                text: '${t["shikh"]} - ${t["khatma"]} - ${t["text"]}',
                                style: TextStyle(
                                    fontSize: 23.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown[900])),
                          ],
                        ),
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
        ),
      ),
    );
  }
}
