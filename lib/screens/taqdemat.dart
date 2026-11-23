import 'package:tayseer_insight/utils/log.dart';
import 'package:flutter/material.dart';
import 'package:tayseer_insight/widgets/app_scaffold.dart';
import 'package:tayseer_insight/app/theme.dart';

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tayseer_insight/globals.dart' as globals;
// import './osoolSubpage.dart';

class Taqdemat extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TaqdematState();
  }
}

class TaqdematState extends State<Taqdemat> {
  List<Map>? _myIntro;
  String? firstWord;
  String? secondWord;
  List<dynamic>? ayaText;
  int? dataLength = 0;
  @override
  void initState() {
    super.initState();
    _loadIntroData();
  }

  String get_string(int index) {
//return _myIntro[index]["sura_name"] + " " + _myIntro[index]["aya_number"].toString()+"  "+_myIntro[index]["ayahtext"].split(" ")[0]+ " " +_myIntro[index]["ayahtext"].split(" ")[1]+ " " +_myIntro[index]["ayahtext"].split(" ")[2]+ " " +_myIntro[index]["ayahtext"].split(" ")[3]

    var ayasplit = _myIntro![index]["ayahtext"].split(" ");
    String aya_text_part = "";
    if (ayasplit.length > 0) aya_text_part += ayasplit[0];
    if (ayasplit.length > 1) aya_text_part += " " + ayasplit[1];
    if (ayasplit.length > 2) aya_text_part += " " + ayasplit[2];
    if (ayasplit.length > 3) aya_text_part += " " + ayasplit[3];

    return _myIntro![index]["sura_name"] +
        " " +
        _myIntro![index]["aya_number"].toString() +
        "  " +
        aya_text_part;
  }

  Future _loadIntroData() async {
    String jsonINTRO =
        await rootBundle.loadString("assets/data/intro_soghra.json");
    setState(() {
      _myIntro = List<Map>.from(jsonDecode(jsonINTRO) as List);
      log("*******_myIntro: $_myIntro");
      ayaText = _myIntro!.map((t) => t["ayahtext"]).toList();
      log(ayaText);
      log(ayaText!.length);
      dataLength = _myIntro!.length;
      // for(var i=0;i<ayaText.length;i++){
      //    log(ayaText[i].split(" "));
      //     firstWord = ayaText[i].split(" ")[0];
      //    log(firstWord);
      //     secondWord = ayaText[i].split(" ")[1];
      //    log(secondWord);
      //  String thirdWord = ayaText[i].split(" ")[2];
      //  log(thirdWord);
      //  String fourthWord = ayaText[i].split(" ")[3];
      //  log(fourthWord);
      //   }
    });
  }

  void osoolNumber(int value) {
    int fileValue = 3;
    globals.OsoolNumber osoolID =
        new globals.OsoolNumber(id: value, file: fileValue);
    Navigator.pushNamed(context, 'osoolSubPage', arguments: osoolID);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'التقدمات صغرى',
      body: ListView.builder(
        itemCount: dataLength,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            color: AppColors.ink,
            child: InkWell(
              onTap: () => osoolNumber(int.parse(_myIntro![index]["ayah_index"])),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 64),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    get_string(index),
                    style: const TextStyle(
                        color: AppColors.parchment,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
