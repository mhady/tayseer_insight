import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tayseer_insight/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:tayseer_insight/widgets/TyseerButton.dart';
import '../audioPlayerQuraat.dart';
import 'package:tayseer_insight/globals.dart';

class Extras extends StatefulWidget {
  final AyaSoraNumber? AyaSora;

  Extras({this.AyaSora});
  @override
  State<StatefulWidget> createState() {
    return ExtrasState();
  }
}

class ExtrasState extends State<Extras> {
  List<Map>? Khadmat_list;
  List<Map>? khedma_list;

  String ScreenMode = "khadamat";
  String KhedmaName = "الخدمات";
  String playText = "";
  String playFileId = "";
  int current_khedma_index = 0;

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

    getKhadmat();
  }

  void updateState() {
    setState(() {});
  }

  void getKhadmat() async {
    ScreenMode = "khadamat";
    var getKhadmaturl = globals.Khadmaturl;
    var response = await http.get(Uri.parse(getKhadmaturl));
    KhedmaName = "الخدمات";
    var fileContent_json =
        utf8.decode(response.bodyBytes).toString().replaceAll('khedma=', '');
    Khadmat_list = List<Map>.from(jsonDecode(fileContent_json) as List);
    var size = MediaQuery.of(context).size;

    if (size.width < 400) {
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

  void getKhedma(i) async {
    //https://ahmedsamir.quraat.info/MP3Files.json
    ScreenMode = "khedma";
    KhedmaName = Khadmat_list![i]['name'];
    var KhedmaPath = "https://" + Khadmat_list![i]['path'] + "/MP3Files.json";
    var response = await http.get(Uri.parse(KhedmaPath));

    var fileContent_json = utf8.decode(response.bodyBytes).toString();
    khedma_list = List<Map>.from(jsonDecode(fileContent_json) as List);
    setState(() {});
  }

  void playKhedma(i) async {
    ScreenMode = "play";
    current_khedma_index = i;
    playText = khedma_list![i]['text'];
    playFileId = khedma_list![i]['file_id'];
    audioPlayerQ.PlayGoogleDriveFile(playFileId);
    setState(() {});
  }
  //
  //

  getPrevoius() {
    if (current_khedma_index > 0) playKhedma(current_khedma_index - 1);
  }

  getNext() {
    if (current_khedma_index < khedma_list!.length)
      playKhedma(current_khedma_index + 1);
  }

  Widget getNextPrvius() {
    return new Wrap(
      children: [
//////////////////////////BUTTON (NEXT)//////////////////////////////
        Container(
          decoration: BoxDecoration(
            color: Colors.brown[200],
          ),
          child: new ButtonTheme(
            height: 80.0,
            minWidth: MediaQuery.of(context).size.width / 2.05,
            child: OutlinedButton(
              onPressed: () {
                // _loadAarabData();
                getNext();
              },
              style: OutlinedButton.styleFrom( 
                      side: BorderSide(
                      color: Color(0xff22160B), //Color of the border
                      style: BorderStyle.solid, //Style of the border
                      width: 0.8, //width of the border
                    ),
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                  ),
             
              child: Text("التالي",
                  style:
                      TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)
                      ),
              
             
            ),
          ),
        ),
///////////////////////BUTTON (PREVIOUS)////////////////////////////////
        Container(
          decoration: new BoxDecoration(
            color: Colors.brown[200],
          ),
          child: new ButtonTheme(
            height: 80.0,
            minWidth: MediaQuery.of(context).size.width / 2.05,
            child: OutlinedButton(
              onPressed: () {
                // _loadAarabData();
                getPrevoius();
              },
               style: OutlinedButton.styleFrom( 
                      side: BorderSide(
                      color: Color(0xff22160B), //Color of the border
                      style: BorderStyle.solid, //Style of the border
                      width: 0.8, //width of the border
                    ),
                     foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                  ),
            
              child: Text("السابق",
                  style:
                      TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                        
              
            ),
          ),
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
            // Container(
            //   width: MediaQuery.of(context).size.width,
            //   padding: EdgeInsets.only(bottom: 25.0),
            //   // child: isLoading ? CircularProgressIndicator() :slider(),

            //   //   child: isLoading ? AlertDialog(
            //   //       content:Container(
            //   //         child:SingleChildScrollView(
            //   //           scrollDirection: Axis.vertical,
            //   //           child:Text( "جارى التحميل",style: TextStyle(fontSize: 23.0,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
            //   //         )
            //   //       ),
            //   // ) :
            // ),

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

              //   child: isLoading ? AlertDialog(
              //       content:Container(
              //         child:SingleChildScrollView(
              //           scrollDirection: Axis.vertical,
              //           child:Text( "جارى التحميل",style: TextStyle(fontSize: 23.0,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
              //         )
              //       ),
              // ) :
            ),
            //////////////////////////BUTTON (PLAY)//////////////////////////////
            audioPlayerQ.player_buttons(MediaQuery.of(context)),
            getNextPrvius(),
///////////////////////BUTTON (STOP)////////////////////////////////
          ],
        ),
      ),
    );
  }

  Widget getPageContant() {
    if (Khadmat_list == null || Khadmat_list!.length == 0)
      return globals.GlobalUI().getLoadingContent();

    var grid_list_used = Khadmat_list;
    if (ScreenMode == 'khadamat') {
    } else if (ScreenMode == 'khedma') {
      if (khedma_list == null || khedma_list!.length == 0)
        return globals.GlobalUI().getLoadingContent();
      grid_list_used = khedma_list;
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
                    audioPlayerQ.pause();
                    if (ScreenMode == 'khadamat')
                      getKhedma(index);
                    else
                      playKhedma(index);

                    setState(() {});
                    if (audioPlayerQ.isStarted) {
                      print(
                          '---------------------------------isStarted is true ');
                    }
                    //  showMyDialog(Khadmat_list![index]["sura_id"]);
                  },
                  child: Text(
                      (ScreenMode == 'khadamat')
                          ? grid_list_used![index]["name"]
                          : grid_list_used![index]["text"],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24.0,
                      )),
                       style: TextButton.styleFrom(
                        
                   foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                   shape:  RoundedRectangleBorder(
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

///////////////////SLIDER WIDGET//////////////////////
  Widget slider() {
    print('max is =' + this._duration.inSeconds.toString());
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Slider(
          value: this._position.inSeconds.toDouble(),
          min: 0.0,
          max: this._duration.inSeconds.toDouble(),
          activeColor: Color(0xff22160B),
          inactiveColor: Color(0xff22160B),
          onChanged: (double value) {
            setState(() {
              seekToSecond(value.toInt());
              value = value;
            });
          }),
    );
  }

  ///////////////////SLIDER ONCHANGE//////////////////////
  void seekToSecond(int second) {
    Duration newDuration = Duration(seconds: second);

    audioPlayerQ.seek(newDuration);
  }

  Future<void> process_agruments(AyaSoraNumber AyaSora) async {
    // find targeted json file
    String json_file_Path = "";
    String file_name = "";
    if (AyaSora.Khadamat_fileType == 3) {
      json_file_Path = "addons.quraat.info";
      file_name = "S${AyaSora.sora}A${AyaSora.aya}I.mp3"; //"S002A055I.mp3
    } // soghra
    if (AyaSora.Khadamat_fileType == 4) {
      json_file_Path = "addonk.quraat.info";
      file_name = "S${AyaSora.sora}A${AyaSora.aya}I.mp3"; ////"S002A055I.mp3
    } // Kobra
    if (AyaSora.Khadamat_fileType == 5) {
      json_file_Path = "learn.quraat.info";
      file_name = "S${AyaSora.sora}A${AyaSora.aya}M"; // S001A006M
    } // mo3alem
    if (AyaSora.Khadamat_fileType == 6) {
      json_file_Path = "learn.quraat.info";
      file_name = "S${AyaSora.sora}A${AyaSora.aya}J"; //S002A002J
    } // elgam3

    int i = Khadmat_list!
        .indexWhere((element) => element['path'] == json_file_Path);
    if (i >= 0) {
      KhedmaName = Khadmat_list![i]['name'];
      var KhedmaPath = "https://" + Khadmat_list![i]['path'] + "/MP3Files.json";
      var response = await http.get(Uri.parse(KhedmaPath));
      var fileContent_json = utf8.decode(response.bodyBytes).toString();
      khedma_list = List<Map>.from(jsonDecode(fileContent_json) as List);

      //
      //
      //  find trgeted audio file and its i

      int j = khedma_list!
          .indexWhere((element) => element['file'].contains(file_name));
      if (j >= 0) {
        // play khedma number i ...
        playKhedma(j);
      }
    }
  }

  Widget build(BuildContext context) {
    RouteSettings settings = ModalRoute.of(context)!.settings;
    AyaSoraNumber? AyaSora = settings.arguments as AyaSoraNumber?;
    if (AyaSora != null) {
      if (ScreenMode != "play") {
        process_agruments(AyaSora);
        return globals.GlobalUI().getLoadingContent();
      }
    }
    return Scaffold(
//////////////////APPBAR///////////////
        appBar: AppBar(
          leading: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 0.0),
            child: new GestureDetector(
              onTap: () {
                audioPlayerQ.pause();
                if (ScreenMode == 'khadamat' || ScreenMode == "play")
                  Navigator.of(context).pop();
                else if (ScreenMode == 'khedma')
                  getKhadmat();
                else {
                  ScreenMode = 'khedma';
                }
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
          title: Text(KhedmaName,
              style: TextStyle(
                  color: Colors.brown[100],
                  fontSize: 23.0,
                  fontWeight: FontWeight.bold)),
        ),
//////////////////BODY///////////////
        body: getPageContant(),
        /////////////////////////////////////////FOOTER//////////////////////////////////////////////
        bottomNavigationBar: Container(
            decoration: BoxDecoration(
              //  color: Color(0xff22160B),
              image: DecorationImage(
                image: AssetImage("assets/images/islam.png"),
                fit: BoxFit.cover,
              ),
            ),
            width: MediaQuery.of(context).size.width,
            // color: Colors.white,
            margin: const EdgeInsets.only(bottom: 2.0),
            child: Padding(
              padding: const EdgeInsets.all(1),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
//////////////////BUTTON (FAVORITES)///////////////
                  TyseerButton(
                        buttonHeight: 70,
                        buttonWidth: MediaQuery.of(context).size.width / 3,
                        text: "المفضلات",
                        onPressed: () {
                       audioPlayerQ.pause();
                        audioPlayerQ.pause();
                        Navigator.pushNamed(context, 'favorites');
                        }),
                   
//////////////////BUTTON (SETTINGS)///////////////
                   TyseerButton(
                        buttonHeight: 70,
                        buttonWidth: MediaQuery.of(context).size.width / 3,
                        text: "الإعدادات",
                        onPressed: () {
                       audioPlayerQ.pause();
                        Navigator.pushNamed(context, 'settings');
                        }),
                   
//////////////////BUTTON (HOME)///////////////`
                  TyseerButton(
                        buttonHeight: 70,
                        buttonWidth: MediaQuery.of(context).size.width / 3,
                        text: "الرئيسية",
                        onPressed: () {
                        Navigator.pushNamed(context, 'Home');
                        }),
                   
                ],
              ),
            )));
  }
}
