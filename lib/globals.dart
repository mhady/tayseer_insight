library tayseer_insight.globals;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/services.dart' show rootBundle;

// import 'package:audioplayers/audioplayers.dart';

String audioUrl = "https://sound.quraat.info/";
String Khadmaturl = "https://quraat.info/sound/common_files/khedma.json";
String Khatmaturl = "https://quraat.info/sound/common_files/khatma.json";
String qre2Folder = "ATolbaHfs";
int tafseerFolder = 1;
List<Map> myshawahed = [];
List<Map> AyaTextList = [];
// _myshawahed= [];

// String firstFavorite = "المفضلة الأولي";
// String secondFavorite = "المفضلة الثانية";
// String thirdFavorite = "المفضلة الثالثة";
// String forthFavorite = "المفضلة الرابعة";
// String fifthFavorite = "المفضلة الخامسة";
class GlobalUI {
  Widget getLoadingContent() {
    return new Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xff22160B),
          image: DecorationImage(
            image: AssetImage("assets/images/islam.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('جاري التحميل',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.0,
                )),
            Image.asset(
              "assets/images/Loading_icon.gif",
              alignment: Alignment.center,
              // width: double.infinity,
              // height: 600,
            ),
          ],
        )
        //       Image.asset("assets/cristmas.gif",width: 200,
        // height: 200,)
        );
  }
}

class AyaSoraNumber {
  final String? aya;
  final String? sora;
  int? Khadamat_fileType;
  AyaSoraNumber({this.aya, this.sora});
}

class AdaptiveTextSize {
  const AdaptiveTextSize();

  getadaptiveTextSize(BuildContext context, dynamic value) {
    // 720 is medium screen height
    dynamic newSize = (value / 400) * MediaQuery.of(context).size.width;
    var maxSize = (15).toDouble();
    return newSize > maxSize ? maxSize : newSize;
  }
}

class OsoolNumber {
  final int? id;
  final int? file;
  OsoolNumber({this.id, this.file});
}

class LoadData {
  Future getAyaTextList() async {
    String jsonAYA =
        await rootBundle.loadString("assets/data/tafseer_json/1.json");

    AyaTextList = List<Map>.from(jsonDecode(jsonAYA) as List);
  }
}
