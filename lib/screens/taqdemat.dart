import 'package:flutter/material.dart';
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
      print("*******_myIntro: $_myIntro");
      ayaText = _myIntro!.map((t) => t["ayahtext"]).toList();
      print(ayaText);
      print(ayaText!.length);
      dataLength = _myIntro!.length;
      // for(var i=0;i<ayaText.length;i++){
      //    print(ayaText[i].split(" "));
      //     firstWord = ayaText[i].split(" ")[0];
      //    print(firstWord);
      //     secondWord = ayaText[i].split(" ")[1];
      //    print(secondWord);
      //  String thirdWord = ayaText[i].split(" ")[2];
      //  print(thirdWord);
      //  String fourthWord = ayaText[i].split(" ")[3];
      //  print(fourthWord);
      //   }
    });
  }

  void osoolNumber(int value) {
    int fileValue = 3;
    globals.OsoolNumber osoolID =
        new globals.OsoolNumber(id: value, file: fileValue);
    Navigator.pushNamed(context, 'osoolSubPage', arguments: osoolID);
  }

  Widget build(BuildContext context) {
    return Scaffold(
//////////////////APPBAR///////////////
        appBar: AppBar(
          leading: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 0.0),
            child: new GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Text("الرجوع",
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.brown[100],
                      fontWeight: FontWeight.bold)),
            ),
          ),
          centerTitle: true,
          backgroundColor: Color(0xff22160B),
          title: Text("التقدمات صغرى",
              style: TextStyle(
                  color: Colors.brown[100],
                  fontSize: 23.0,
                  fontWeight: FontWeight.bold)),
        ),
//////////////////BODY///////////////
        body: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Color(0xff22160B),
              image: DecorationImage(
                image: AssetImage("assets/images/islam.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: ListView.builder(
              itemCount: dataLength,
              // physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(0),
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    osoolNumber(int.parse(_myIntro![index]["ayah_index"]));
                  },
                  child: new Card(
                    color: Color(0xff22160B),
                    child: new Text(
                      get_string(index),
                      style: TextStyle(
                          color: Colors.brown[100],
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                  ),
                );
              },
            )));
  }
}
