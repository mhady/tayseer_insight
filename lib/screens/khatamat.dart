import 'package:tayseer_insight/utils/log.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tayseer_insight/widgets/app_button.dart';
import 'package:tayseer_insight/widgets/app_scaffold.dart';

import 'package:tayseer_insight/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:tayseer_insight/widgets/TyseerButton.dart';
import '../audioPlayerQuraat.dart';

class Khatamat extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return KhatamatState();
  }
}

class KhatamatState extends State<Khatamat> {
  List<Map>? Khadmat_list;
  List<Map>? khetma_list;

  String ScreenMode = "khatamat";
  String khetmaName = "الخدمات";
  String playText = "";
  String playFileId = "";
  String khetmaHasDB = '0';
  String reader = "";
  String reviewer = "";
  int current_khatma_index = 0;
  int gridLength = 0;
  double childRatioLength = 0;
  var audioPlayerQ = null;

  Duration _duration = new Duration();
  Duration _position = new Duration();

  @override
  void initState() {
    audioPlayerQ = audioPlayerQuraat(
        onStateChanged: () {
          updateState();
        },
        oncompeleted: () {});
    getKhatmat();
  }

  void updateState() {
    setState(() {});
  }

  void getKhatmat() async {
    ScreenMode = "khatamat";
    khetma_list = null;
    var getKhatmaturl = globals.Khatmaturl;
    var response = await http.get(Uri.parse(getKhatmaturl));
    khetmaName = "الختمات";
    var fileContent_json =
        utf8.decode(response.bodyBytes).toString().replaceAll('khatma=', '');
    Khadmat_list = List<Map>.from(jsonDecode(fileContent_json) as List);
    var size = MediaQuery.of(context).size;

    if (size.width < 600) {
      gridLength = 1;
      childRatioLength = 3.1;
    } else if (size.width < 1200) {
      gridLength = 2;
      childRatioLength = 2.1;
    } else {
      gridLength = 3;
      childRatioLength = 1.8;
    }
    // if (Khadmat_list!.length == 9 || Khadmat_list!.length == 12) {
    //   gridLength = 1;
    //   childRatioLength = 2.1;
    // } else {
    //   gridLength = 2;
    //   childRatioLength = 2.0;
    // }
    setState(() {});
    //response.pipe(new File('foo.txt').openWrite())
    // });
  }

  void getkhetma(i) async {
    //https://ahmedsamir.quraat.info/MP3Files.json
    khetmaHasDB = '0';
    ScreenMode = "khetma";
    khetmaName = Khadmat_list![i]['name'];
    khetmaHasDB = Khadmat_list![i]['hasDB'];
    var khetmaPath = "https://" + Khadmat_list![i]['path'] + "/MP3Files.json";
    if (khetmaHasDB == '1')
      khetmaPath = "https://" +
          Khadmat_list![i]['path'] +
          "/MP3FilesWithReaderAuditor.json";

    try {
      var response = await http.get(Uri.parse(khetmaPath));
      var fileContent_json = utf8.decode(response.bodyBytes).toString();
      khetma_list = List<Map>.from(jsonDecode(fileContent_json) as List);
    } on FormatException catch (e) {
      log('The provided string is not valid JSON');

      var khetmaPath = "https://" + Khadmat_list![i]['path'] + "/MP3Files.json";
      var response = await http.get(Uri.parse(khetmaPath));
      var fileContent_json = utf8.decode(response.bodyBytes).toString();
      khetma_list = List<Map>.from(jsonDecode(fileContent_json) as List);
    }

    setState(() {});
  }

  void playkhetma(i) async {
    ScreenMode = "play";
    current_khatma_index = i;
    playText = khetma_list![i]['text'];
    playFileId = khetma_list![i]['file_id'];
    if (khetmaHasDB == '1') {
      reader = khetma_list![i]['reader_name'];
      reviewer = khetma_list![i]['auditor_name'];
    }
    audioPlayerQ.PlayGoogleDriveFile(playFileId);
    setState(() {});
  }

  getPrevoius() {
    if (current_khatma_index > 0) playkhetma(current_khatma_index - 1);
  }

  getNext() {
    if (current_khatma_index < khetma_list!.length)
      playkhetma(current_khatma_index + 1);
  }

  Widget getNextPrvius() {
    return AppButtonWrap(
      children: [
        AppButton(
          label: 'التالي',
          fontSize: 20.0,
          minHeight: 80,
          bold: true,
          onPressed: getNext,
        ),
        AppButton(
          label: 'السابق',
          fontSize: 20.0,
          minHeight: 80,
          bold: true,
          onPressed: getPrevoius,
        ),
      ],
    );
  }

  Widget getPlayerScrren() {
    return new Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Color(0xff22160B),
        image: DecorationImage(
          image: AssetImage("assets/images/islam.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(top: 5.0),
        child: Wrap(
          spacing: 10.0, // gap between adjacent chips
          runSpacing: 4.0, // gap between lines
          alignment: WrapAlignment.spaceEvenly,
          children: <Widget>[
///////////////////////////////SLIDER///////////////////////////////////////////////////////
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(bottom: 25.0),
              decoration: BoxDecoration(
                color: Color(0xff22160B),
              ),
              child: Text(
                playText,
                style: TextStyle(color: Colors.brown[100], fontSize: 27.0),
                textAlign: TextAlign.center,
              ),
            ),
            Readers_info(current_khatma_index),
            // audioPlayerQ.slider(),
//////////////////////////BUTTON (PLAY)//////////////////////////////
            audioPlayerQ.player_buttons(MediaQuery.of(context)),
            getNextPrvius(),
///////////////////////BUTTON (STOP)////////////////////////////////
          ],
        ),
      ),
    );
  }

///////////////////SLIDER WIDGET//////////////////////
  // Widget slider() {
  //   log('max is =' + this._duration.inSeconds.toString());
  //   return Padding(
  //     padding: const EdgeInsets.only(top: 40.0),
  //     child: Slider(
  //       value: this._position.inSeconds.toDouble(),
  //       min: 0.0,
  //       max: this._duration.inSeconds.toDouble(),
  //       activeColor: Color(0xff22160B),
  //       inactiveColor: Color(0xff22160B),
  //       onChanged: (double value) {
  //         log('seek the slider ');
  //         this._position = Duration(seconds: value.toInt());
  //         // setState(() {
  //         //   seekToSecond(value.toInt());
  //         //   value = value;
  //         // });
  //       },
  //       onChangeEnd: (double newvalue) {
  //         log('Ended change on $newvalue');
  //         setState(() {
  //           seekToSecond(newvalue.toInt());
  //           newvalue = newvalue;
  //         });
  //       },
  //     ),
  //   );
  // }

///////////////////SLIDER ONCHANGE//////////////////////
  void seekToSecond(int second) {
    Duration newDuration = Duration(seconds: second);

    audioPlayerQ.seek(newDuration);
  }

////////////////////////////////////////////////////
  Widget Readers_info(i) {
    if (ScreenMode == 'khetma' && khetmaHasDB == '1') {
      reader = khetma_list![i]['reader_name'];
      reviewer = khetma_list![i]['auditor_name'];
      return new Expanded(
          flex: 10,
          child: Container(
            child: Row(textDirection: TextDirection.rtl, children: [
              Expanded(
                flex: 4,
                child: Text("المراجع \n" + reviewer,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.0,
                    )),
              ),
              Expanded(
                flex: 2,
                child: Text("",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 15.0,
                    )),
              ),
              Expanded(
                flex: 4,
                child: Text("القارئ \n" + reader,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.0,
                    )),
              ),
            ]),
          ));
    }
    return new Container(
      width: 0,
      height: 0,
    );
  }

  Widget getPageContant() {
    if (Khadmat_list == null || Khadmat_list!.length == 0)
      return globals.GlobalUI().getLoadingContent();

    var grid_list_used = Khadmat_list;
    if (ScreenMode == 'khatamat') {
    } else if (ScreenMode == 'khetma') {
      if (khetma_list == null || khetma_list!.length == 0)
        return globals.GlobalUI().getLoadingContent();
      grid_list_used = khetma_list;
    } else if (ScreenMode == 'play') {
      return getPlayerScrren();
    }

    return new Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Color(0xff22160B),
        image: DecorationImage(
          image: AssetImage("assets/images/islam.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: GridView.builder(
          shrinkWrap: true,
          itemCount: grid_list_used!.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridLength, childAspectRatio: childRatioLength),

          // primary: false,
          padding: const EdgeInsets.all(5),
          itemBuilder: (BuildContext context, int index) {
            return Card(
              // elevation: 6.0,
              child: new ButtonTheme(
                // height: 70.0,
                height: 200,
                minWidth: 170.0,
                child: TextButton(
                  autofocus: index == 0 ? true : false,
                  onPressed: () {
                    audioPlayerQ.stop();
                    if (ScreenMode == 'khatamat')
                      getkhetma(index);
                    else
                      playkhetma(index);

                    setState(() {});
                    if (audioPlayerQ.isStarted) {
                      log(
                          '---------------------------------isStarted is true ');
                    }
                    //  showMyDialog(Khadmat_list![index]["sura_id"]);
                  },
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(
                        (ScreenMode == 'khatamat')
                            ? grid_list_used![index]["name"]
                            : grid_list_used![index]["text"],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22.0,
                        )),
                    Readers_info(index),
                  ]),
               style: OutlinedButton.styleFrom( 
                   
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                    //splashColor: Colors.grey,
                  ),
                  
                ),
              ),
            );
          }),
    );
  }
  // exist in saved preferences

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: khetmaName,
      onBack: () {
        audioPlayerQ.stop();
        if (ScreenMode == 'khatamat') {
          Navigator.of(context).pop();
        } else if (ScreenMode == 'khetma') {
          getKhatmat();
        } else {
          ScreenMode = 'khetma';
        }
      },
      body: getPageContant(),
      bottomBar: AppBottomBar(
        children: [
          TyseerButton(
            buttonHeight: 70,
            text: 'المفضلات',
            onPressed: () {
              audioPlayerQ.stop();
              Navigator.pushNamed(context, 'favorites');
            },
          ),
          TyseerButton(
            buttonHeight: 70,
            text: 'الإعدادات',
            onPressed: () {
              audioPlayerQ.stop();
              Navigator.pushNamed(context, 'settings');
            },
          ),
          TyseerButton(
            buttonHeight: 70,
            text: 'الرئيسية',
            onPressed: () => Navigator.pushNamed(context, 'Home'),
          ),
        ],
      ),
    );
  }
}
