import 'package:flutter/material.dart';

import 'package:tayseer_insight/globals.dart' as globals;
import 'dart:convert';
import 'package:flutter/services.dart'
    show Clipboard, ClipboardData, rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:simple_permissions/simple_permissions.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
// import 'package:share_plus/share_plus.dart';
// import './osoolSubpage.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import '../audioPlayerQuraat.dart';
import 'package:external_path/external_path.dart';
import 'package:tayseer_insight/globals.dart';

class SubPage extends StatefulWidget {
  final AyaSoraNumber? arguments;
  SubPage({
    @required this.arguments,
  });
  @override
  State<StatefulWidget> createState() {
    return SubPageState();
  }
}

class Tafseer {
  final String ayahtext;
  final String tafseer;
  Tafseer(this.ayahtext, this.tafseer);
}

class SubPageState extends State<SubPage> {
  Duration _duration = new Duration();
  Duration _position = new Duration();
  Duration Current_position = new Duration();

  var audioPlayerQ = null;

  // AudioCache audioCache;
  int currrentAya = 0;
  int currrentSora = 0;
  bool continuosReading = false;
  AyaSoraNumber? ayaSora;
  int? lastAya;
  String? firstWord;
  String? secondWord;
  String? thirdWord;
  String? firstsharedFavorite;
  String? secondsharedFavorite;
  String? thirdsharedFavorite;
  String? fourthsharedFavorite;
  String? fifthsharedFavorite;
  int? ayatextLength;
  int? tafseerFolder;
  int? introTndex;
  String? osoolSora;
  bool _allowWriteFile = false;
  bool _introExists = false;
  bool _tayseerExist = false;
  bool _introKExists = false;

  bool _gamaaExists = false;

  bool _shwahedExists = true;
  String? osoolURL;
  List<Map>? myQare2;
  List<Map>? _myOsool;
  List<Map>? _myOsoolK;
  List<Map>? _myShwahed;
  List<Map>? _myTayseer;
  List<Map>? _myGamaa;
  String format(String ayaAndSoraNumber) {
    int n = int.parse(ayaAndSoraNumber);
    String r = '';
    r = n.toString();
    return r;
  }

  bool data_ready = false;
  @override
  void initState() {
    super.initState();
    setState(() {
      data_ready = false;
    });
    audioPlayerQ = audioPlayerQuraat(onStateChanged: () {
      updateState();
    }, oncompeleted: () {
      onPlayerCompletion();
    });
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      //  ayaSora = widget.arguments;
      await _loadAarabData();
      await _loadSoraData();
      await _loadTafseerData();
      await getFavorites();

      await _loadAyaText();

      if (defaultTargetPlatform == TargetPlatform.android) {
        //!isweb && Platform.isAndroid) {
        // requestWritePermission();
      }
      await checkOsool();
      await _checkShwahed();

      setState(() {
        data_ready = true;
        setPlayUrl();
        print('all data ready');
      });
    });
  }

  void updateState() {
    setState(() {});
  }

  void onPlayerCompletion() {
    print('onPlayerCompletion called  ');

    if (this.continuosReading) {
      if (lastAya == currrentAya) {
        ////CHECK IF THE REQIESTED AYA IS EQUAL LAST AYA OF SURA

        audioPlayerQ.stop();
        return;
      }
      // if (audioPlayerQ.isStopped == true) {
      //   audioPlayerQ.stop();
      //   return;
      // }
      else {
        playNext();

        audioPlayerQ.play();
      }
    }
  }
  // advancedPlayer.durationHandler = (d) => setState(() {
  //   _duration = d;
  //   // print(_duration);
  // });

  // advancedPlayer.positionHandler = (p) => setState(() {
  //   if(p.inSeconds>=_duration.inSeconds){
  //     _position = new Duration(hours: 0,minutes: 0,seconds: 0);
  //     buttonValue.text="تشغيل";
  //   }
  //   else{
  //       _position = p;
  //   }

  // // print(_position);
  //    if(isStopped== true){
  //      isStarted=false;
  //   buttonValue.text="تشغيل";

  //       stop();
  //       return;
  //     }
  // });

  //   advancedPlayer.completionHandler=(){
  //     isStarted=false;
  //     buttonValue.text="تشغيل";
  //   if(this.continuosReading)
  //       {
  //     if(lastAya==currrentAya){
  //       isStarted=false;
  //     buttonValue.text="تشغيل";
  //         stop();
  //       return;
  //       }
  //     if(isStopped== true){
  //       isStarted=false;
  //     buttonValue.text="تشغيل";
  //         stop();
  //       return;
  //       }
  //     else{
  //        currrentAya  = currrentAya+1;
  //       play();     //////////// PLAY NEXT AYA///////////////////
  //       }

  //     }
  //   };
  // }
  continuePlaying() {
    continuosReading = true;
    setPlayUrl();
    audioPlayerQ.play();
  }

///////////////////////PLAY PREVIOUS AYA////////////////////////
  playPrevoius() async {
    _loadTafseerData();
    checkOsool();

    //  stop();
    currrentAya = currrentAya - 1;
    _loadAyaText();
    _checkShwahed();
    stop();
    //  await play();
  }

///////////////////////PLAY NEXT AYA////////////////////////
  playNext() async {
    _loadTafseerData();
    checkOsool();

    //  stop();
    currrentAya = currrentAya + 1;
    //
    _loadAyaText();
    _checkShwahed();
    setPlayUrl();
    if (!continuosReading) stop();
    // await  play();
  }

///////////////////REFORMATE AYA AND SORA//////////////////////
  String ayaformat(int ayaAndSoraNumber) {
    int n = ayaAndSoraNumber;
    String r = '';
    if (n <= 9)
      r = "00" + n.toString();
    else if (n > 9 && n <= 99)
      r = "0" + n.toString();
    else if (n > 99) r = n.toString();
    return r;
  }

  Directory findRoot(FileSystemEntity entity) {
    final Directory parent = entity.parent;
    if (parent.path == entity.path) return parent;
    return findRoot(parent);
  }

///////////////////PLAY AUDIO//////////////////////
  setPlayUrl() async {
    if (currrentSora == 0 || currrentAya == 0) return;
    audioPlayerQ.setIsLocal(false);
    String audioFilePath = "";
    print('currrentSora=' +
        currrentSora.toString() +
        " currrentAya =" +
        currrentAya.toString());
    ///////////////CHECK PLATFORM TYPE////////////////
    if (defaultTargetPlatform == TargetPlatform.android) {
      //Platform.isAndroid) {

      String ayastr = ayaformat(currrentAya);
      String sorsstr = ayaformat(currrentSora);
      String jsonQARE2 =
          await rootBundle.loadString("assets/data/switch_n.json");
      String onlineURL = globals.audioUrl +
          globals.qre2Folder +
          "/S$sorsstr/S${sorsstr}A$ayastr.mp3";
      // String localURL = '${dir.path}'+"/Tayseer/Sound/"+globals.qre2Folder+"/S$sorsstr/S${sorsstr}A$ayastr.mp3";
      myQare2 = List<Map>.from(jsonDecode(jsonQARE2) as List);
      final item =
          myQare2!.firstWhere((e) => e['folder'] == globals.qre2Folder);
      if (item['file_name_format'] == "tayseer") {
        if (int.parse(item['tosura']) < int.parse(sorsstr)) {
          print(int.parse(item['tosura']));
          print(int.parse(sorsstr));
          onlineURL = globals.audioUrl +
              "ATolbaHfs" +
              "/S$sorsstr/S${sorsstr}A$ayastr.mp3";
        } else {
          onlineURL = globals.audioUrl +
              globals.qre2Folder +
              "/S$sorsstr/S${sorsstr}A$ayastr.mp3";
        }
      } else if (item['file_name_format'] == "qmp3") {
        // $scope.telawa_reader_local_folder + sura_num  + ayah_num + ".mp3";
        onlineURL = item['url'] + "/$sorsstr$ayastr.mp3";
      }

      if (int.parse(item['tosura']) == int.parse(sorsstr)) {
        if (int.parse(item['toaya']) < int.parse(ayastr)) {
          //globals.qre2Folder = "ATolbaHfs";
          print(int.parse(item['toaya']));
          print(int.parse(ayastr));
          onlineURL = globals.audioUrl +
              "ATolbaHfs" +
              "/S$sorsstr/S${sorsstr}A$ayastr.mp3";
        } else {
          onlineURL = globals.audioUrl +
              globals.qre2Folder +
              "/S$sorsstr/S${sorsstr}A$ayastr.mp3";
        }
      }
      print('onlineURL audio play file $onlineURL');
      audioFilePath = onlineURL;
      //  onlineURL='http://sound.quraat.info/Taha/S002/S002A271.mp3';

      // local path example
      // /Tayseer/Sound/ATolbaHfs/S017/S017A044.mp3
      // final dir = await getExternalStorageDirectory();
      // try main root path
      // final dir = findRoot(await getApplicationDocumentsDirectory());
      // String localURL = '${dir.path}' +
      //     "/Tayseer/Sound/" +
      //     globals.qre2Folder +
      //     "/S$sorsstr/S${sorsstr}A$ayastr.mp3";
      // bool isExist = await File(localURL).exists();
      // if (isExist) {
      //   audioFilePath = localURL;
      //   audioPlayerQ.setIsLocal(true);
      // }
      // try main root path
      final dirs_external = await ExternalPath.getExternalStorageDirectories();
      // findRoot((await getExternalStorageDirectory())!);
      for (var path_external in dirs_external) {
        // var index = dirs_external.indexOf(path_external);
        String localURL_external = '${path_external}' +
            "/Tayseer/Sound/" +
            globals.qre2Folder +
            "/S$sorsstr/S${sorsstr}A$ayastr.mp3";
        bool isExist_external = await File(localURL_external).exists();
        if (isExist_external) {
          audioFilePath = localURL_external;
          audioPlayerQ.setIsLocal(true);
          break;
        }
      }

      audioPlayerQ.setPlayUrl(audioFilePath);
      print(audioFilePath);

      // initPlayer();

      // else{
      // AudioProvider audioProvider = new AudioProvider(onlineURL);
      //   print(onlineURL);
      // String localUrl = await audioProvider.load();
      //   // audioCache.play(localUrl);
      //   await advancedPlayer.play(localUrl);
      //   print(localUrl);
      // }

      // setState(() {
      //   isStarted = true;
      //   isStopped = false;
      //   buttonValue.text = "إيقاف مؤقت";
      //   ayaofSuraValue.text = format(ayastr);
      //   // _loadTafseerData();
      // });
    } else //if (Platform.isIOS)
    {
      String ayastr = ayaformat(currrentAya);
      String sorsstr = ayaformat(currrentSora);
      String jsonQARE2 =
          await rootBundle.loadString("assets/data/switch_n.json");
      String onlineURL = globals.audioUrl +
          globals.qre2Folder +
          "/S$sorsstr/S${sorsstr}A$ayastr.mp3";
      myQare2 = List<Map>.from(jsonDecode(jsonQARE2) as List);
      final item =
          myQare2!.firstWhere((e) => e['folder'] == globals.qre2Folder);
      if (item['file_name_format'] == "tayseer") {
        if (int.parse(item['tosura']) < int.parse(sorsstr)) {
          print(int.parse(item['tosura']));
          print(int.parse(sorsstr));
          onlineURL = globals.audioUrl +
              "ATolbaHfs" +
              "/S$sorsstr/S${sorsstr}A$ayastr.mp3";
        } else {
          onlineURL = globals.audioUrl +
              globals.qre2Folder +
              "/S$sorsstr/S${sorsstr}A$ayastr.mp3";
        }
      } else if (item['file_name_format'] == "qmp3") {
        // $scope.telawa_reader_local_folder + sura_num  + ayah_num + ".mp3";
        onlineURL = item['url'] + "/$sorsstr$ayastr.mp3";
      }

      if (int.parse(item['tosura']) == int.parse(sorsstr)) {
        if (int.parse(item['toaya']) < int.parse(ayastr)) {
          print(int.parse(item['toaya']));
          print(int.parse(ayastr));
          onlineURL = globals.audioUrl +
              "ATolbaHfs" +
              "/S$sorsstr/S${sorsstr}A$ayastr.mp3";
        } else {
          onlineURL = globals.audioUrl +
              globals.qre2Folder +
              "/S$sorsstr/S${sorsstr}A$ayastr.mp3";
        }
      }
      //  AudioProvider audioProvider = new AudioProvider(onlineURL);
      audioPlayerQ.setPlayUrl(onlineURL);
      print(onlineURL);
      // String localUrl = await audioProvider.load();
      //   audioCache.clear(localUrl);
      //   // audioCache.clearCache();
      //   await audioCache.play(localUrl);
      //   print(localUrl);

      // setState(() {
      //   isStarted = true;
      //   isStopped = false;
      //   buttonValue.text = "إيقاف مؤقت";
      //   ayaofSuraValue.text = format(ayastr);
      //   // _loadTafseerData();
      // });
    }
  }

///////////////////PAUSE AUDIO//////////////////////
  pause() async {
    audioPlayerQ.pause();
  }

///////////////////STOP AUDIO//////////////////////
  stop() async {
    audioPlayerQ.stop();
  }

//////////////////////TAFSEER DATA//////////////////////
  List<Map>? _myAya;
  List<String>? tafseerSplited;
  List<String>? tafseerLines = [];
  String? tafseerSplitedValue;
  int? oneLine;
  String? oneLineString;
// This list of controllers can be used to set and get the text from/to the TextFields
  List textEditingControllers = <TextEditingController>[];
  List textFields = <Text>[];
  Future _loadTafseerData() async {
    if (tafseerFolder == globals.tafseerFolder) {
      if (tafseerLines!.length > 0) {
        //already loaded
        return;
      }
    }
    tafseerLines!.clear();
    // print(globals.tafseerFolder);
    tafseerFolder = globals.tafseerFolder;
    String jsonAYA = await rootBundle
        .loadString("assets/data/tafseer_json/$tafseerFolder.json");
    setState(() {
      tafseerLines!.clear();
      textFields.clear();
      _myAya = List<Map>.from(jsonDecode(jsonAYA) as List);
      _loadSoraData();
      if (currrentAya > lastAya!) {
        currrentAya = lastAya!;
      }
      String ayaValue = (currrentAya).toString();
      String soraValue = format(ayaSora!.sora!);
      String sharedAya = ayaformat(currrentAya);
      print("************************ayaaaaa$sharedAya");
      String sharedSora = ayaformat(currrentSora);
      String sharedURL = globals.audioUrl +
          globals.qre2Folder +
          "/S$sharedSora/S${sharedSora}A$sharedAya.mp3";
      urlValue.text = sharedURL;
      final item = _myAya!
          .firstWhere((e) => e['ayah'] == ayaValue && e['sura'] == soraValue);
      // print(item['tafseer']);
      // print(item['ayahtext']);
      tafseerValue.text = item['tafseer'];
      ayaofSuraValue.text = ayaValue;
      //  print(ayahtextValue.text.split(" ").length);

//////////SPLIT AYAH WORDS TO SHOW IN FAVORITES LIST///////////////
      ayatextLength = ayahtextValue.text.split(" ").length;
      if (ayatextLength! >= 1) {
        firstWord = ayahtextValue.text.split(" ")[0];
      } else {
        firstWord = " ";
      }
      if (ayatextLength! >= 2) {
        secondWord = ayahtextValue.text.split(" ")[1];
      } else {
        secondWord = " ";
      }
      if (ayatextLength! >= 3) {
        thirdWord = ayahtextValue.text.split(" ")[2];
      } else {
        thirdWord = " ";
      }

      /// tafseer as one line  SHOULD BE FLAG LATER
      var textEditingController =
          new TextEditingController(text: tafseerValue.text);
      textEditingControllers.add(textEditingController);
      return textFields.add(new Text(
        textEditingController.text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 17.0,
          fontWeight: FontWeight.bold,
        ),
      ));

//////////SPLIT TAFSEER TO BE READ LINE BY LINE
      tafseerSplited = tafseerValue.text.split(" ");
      oneLineString = " ";
      for (var i = 0; i < tafseerSplited!.length; i++) {
        if (tafseerSplited![i] == " " || tafseerSplited![i] == "") continue;
        oneLineString = oneLineString! + " " + tafseerSplited![i];
        if (i == 0) continue;
        oneLine = i % 6;
        if (oneLine == 0) {
          // print(tafseerLines);
          tafseerLines!.add(oneLineString!);
          // print(oneLineString);
          oneLineString = " ";
          // print(tafseerSplited[i]);
        }
      }
      tafseerLines!.add(oneLineString!);
////////////SPLITING ARRAY///////////////
      tafseerLines!.forEach((str) {
        // print('${tafseerSplited.indexOf(str)}:$str');
        var textEditingController = new TextEditingController(text: str);
        textEditingControllers.add(textEditingController);
        return textFields.add(new Text(
          textEditingController.text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.bold,
          ),
        ));
      });
    });
  }

//////////////////////////AYA TEXT//////////////////////
  List<String>? ayahSplited;
  List<String> ayahLines = [];
  String? ayahSplitedValue;
  List ayahtextEditingControllers = <TextEditingController>[];
  List ayahtextFields = <Text>[];
  Future _loadAyaText() async {
    // String jsonAYA =
    //     await rootBundle.loadString("assets/data/tafseer_json/1.json");
    ayahtextFields.clear();
    ayahLines.clear();
    setState(() {
      ayahtextFields.clear();
      ayahLines.clear();
      // _myAya = List<Map>.from(jsonDecode(jsonAYA) as List);
      // globals.AyaTextList;
      String ayaValue = (currrentAya).toString();
      String soraValue = this.format(this.ayaSora!.sora!);
      final item = globals.AyaTextList.firstWhere(
          (e) => e['ayah'] == ayaValue && e['sura'] == soraValue);
      // print(item['tafseer']);
      // print(item['ayahtext']);
      // tafseerValue.text = item['tafseer'];
      ayahtextValue.text = item['ayahtext'];

      /// AYAH text as one line  SHOULD BE FLAG LATER
      var ayahtextEditingController =
          new TextEditingController(text: ayahtextValue.text);
      textEditingControllers.add(ayahtextEditingController);
      return ayahtextFields.add(new Text(
        ayahtextEditingController.text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 17.0,
          fontWeight: FontWeight.bold,
        ),
      ));

//////////SPLIT AYAH TO BE READ LINE BY LINE
      ayahSplited = ayahtextValue.text.split(" ");
      oneLineString = " ";
      for (var i = 0; i < ayahSplited!.length; i++) {
        oneLineString = oneLineString! + " " + ayahSplited![i];
        if (i == 0) continue;
        oneLine = i % 6;
        if (oneLine == 0) {
          ayahLines.add(oneLineString!);
          oneLineString = " ";
        }
      }
      ayahLines.add(oneLineString!);
////////////////////SPLITING ARRAY//////////////////
      ayahLines.forEach((str) {
        var ayahtextEditingController = new TextEditingController(text: str);
        textEditingControllers.add(ayahtextEditingController);
        return ayahtextFields.add(new Text(
          ayahtextEditingController.text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.bold,
          ),
        ));
      });
    });
  }

/////////////////////////////////////////SORA DATA//////////////////////////////////
  List<Map>? _mySora;
  Future _loadSoraData() async {
    _loadAarabData();
    String jsonSora = await rootBundle.loadString("assets/data/sura_data.json");
    setState(() {
      _mySora = List<Map>.from(jsonDecode(jsonSora) as List);
      // print("*******_mySora: $_mySora");
      String soraValue = this.format(this.ayaSora!.sora!);
      int sura = int.parse(soraValue);
      final item = _mySora!.firstWhere((e) => e['sura_order'] == sura);
      // print(item['sura_name']);
      // print(item['ayat']);
      lastAya = item['ayat'];
      // print(lastAya);
      suraNameValue.text = item['sura_name'];
    });
  }

////////////////////////////////////EARAB DATA////////////////////////////////////////
  List<Map>? _myAarab;
  List<String>? earabSplited;
  List<String> earabLines = [];
  String? earabSplitedValue;
  List earabtextEditingControllers = <TextEditingController>[];
  List earabtextFields = <Text>[];
  Future _loadAarabData() async {
    String soraValue = this.format(this.ayaSora!.sora!);
    // String ayaValue=this.format(this.ayaSora.aya);
    String jsonSora = await rootBundle
        .loadString("assets/data/e3rab_jsons/$currrentSora.json");
    // print(soraValue);
    // print(jsonSora);
    earabtextFields.clear();
    earabLines.clear();
    setState(() {
      earabtextFields.clear();
      earabLines.clear();
      _myAarab = List<Map>.from(jsonDecode(jsonSora) as List);
      // print("*******_myAarab: $_myAarab");
      int sura = int.parse(soraValue);
      // int aya = int.parse(ayaValue);
      final item = _myAarab!
          .firstWhere((e) => e['aya'] == currrentAya && e['sora'] == sura);
      if (item['e3rab'] == "") {
        aarabSuraValue.text = "لا يوجد اعراب لهذه الايه";
      } else {
        aarabSuraValue.text = item['e3rab'];

        ///EARAB AS ONE LINE
        var earabtextEditingController =
            new TextEditingController(text: aarabSuraValue.text);
        textEditingControllers.add(earabtextEditingController);
        return earabtextFields.add(new Text(
          earabtextEditingController.text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.bold,
          ),
        ));

        ///
//////////SPLIT EARAB TO BE READ LINE BY LINE   SHOULD BE FLAG LATER
        earabSplited = aarabSuraValue.text.split(" ");
        // print("************SPlitedArray*******$earabSplited");
        // print(aarabSuraValue.text.split(" ").length/8);
        // tafseerSplitedValue = tafseerValue.text.split(" ").length;
        // oneLineString
        oneLineString = " ";
        for (var i = 0; i < earabSplited!.length; i++) {
          if (earabSplited![i] == " " || earabSplited![i] == "") continue;
          oneLineString = oneLineString! + " " + earabSplited![i];
          if (i == 0) continue;
          oneLine = i % 6;
          if (oneLine == 0) {
            // print(tafseerLines);
            earabLines.add(oneLineString!);
            // print(oneLineString);
            oneLineString = " ";
            // print(earabSplited[i]);
          }
        }
        ;
        earabLines.add(oneLineString!);
////////////////////SPLITING ARRAY//////////////////
        earabLines.forEach((str) {
          var earabtextEditingController = new TextEditingController(text: str);
          textEditingControllers.add(earabtextEditingController);
          return earabtextFields.add(new Text(
            earabtextEditingController.text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.bold,
            ),
          ));
        });
      }
    });
  }

  TextEditingController tafseerValue = new TextEditingController();
  TextEditingController ayahtextValue = new TextEditingController();
  TextEditingController suraNameValue = new TextEditingController();
  TextEditingController ayaofSuraValue = new TextEditingController();
  TextEditingController aarabSuraValue = new TextEditingController();
  TextEditingController buttonValue = new TextEditingController();
  TextEditingController urlValue = new TextEditingController();
  TextEditingController shwahedValue = new TextEditingController();
  ///////////////////////////////FAVORITES///////////////////////////////////////////////////////
  TextEditingController firstFavorite = TextEditingController();
  TextEditingController secondFavorite = TextEditingController();
  TextEditingController thirdFavorite = TextEditingController();
  TextEditingController forthFavorite = TextEditingController();
  TextEditingController fifthFavorite = TextEditingController();
///////////////////////////////SAVING FAVORITES///////////////////////////////////////////////////////
  saveFirstFavorite() async {
    _loadTafseerData();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favorite1', [
      currrentSora.toString(),
      currrentAya.toString(),
      suraNameValue.text +
          "(" +
          currrentAya.toString() +
          ")-" +
          firstWord! +
          " " +
          secondWord! +
          " " +
          thirdWord!
    ]);
    setState(() {
      firstsharedFavorite = prefs.getStringList('favorite1')![2];
      firstFavorite.text = firstsharedFavorite!;
      Navigator.of(context).pop();
    });
  }

  saveSecondFavorite() async {
    _loadTafseerData();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favorite2', [
      currrentSora.toString(),
      currrentAya.toString(),
      suraNameValue.text +
          "(" +
          currrentAya.toString() +
          ")-" +
          firstWord! +
          " " +
          secondWord! +
          " " +
          thirdWord!
    ]);
    setState(() {
      secondsharedFavorite = prefs.getStringList('favorite2')![2];
      secondFavorite.text = secondsharedFavorite!;
      Navigator.of(context).pop();
    });
  }

  saveThirdFavorite() async {
    _loadTafseerData();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favorite3', [
      currrentSora.toString(),
      currrentAya.toString(),
      suraNameValue.text +
          "(" +
          currrentAya.toString() +
          ") " +
          firstWord! +
          " " +
          secondWord! +
          " " +
          thirdWord!
    ]);
    setState(() {
      thirdsharedFavorite = prefs.getStringList('favorite3')![2];
      thirdFavorite.text = thirdsharedFavorite!;
      Navigator.of(context).pop();
    });
  }

  saveForthFavorite() async {
    _loadTafseerData();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favorite4', [
      currrentSora.toString(),
      currrentAya.toString(),
      suraNameValue.text +
          "(" +
          currrentAya.toString() +
          ") " +
          firstWord! +
          " " +
          secondWord! +
          " " +
          thirdWord!
    ]);
    setState(() {
      fourthsharedFavorite = prefs.getStringList('favorite4')![2];
      forthFavorite.text = fourthsharedFavorite!;
      Navigator.of(context).pop();
    });
  }

  saveFifthFavorite() async {
    _loadTafseerData();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favorite5', [
      currrentSora.toString(),
      currrentAya.toString(),
      suraNameValue.text +
          "(" +
          currrentAya.toString() +
          ") " +
          firstWord! +
          " " +
          secondWord! +
          " " +
          thirdWord!
    ]);
    setState(() {
      fifthsharedFavorite = prefs.getStringList('favorite5')![2];
      fifthFavorite.text = fifthsharedFavorite!;
      Navigator.of(context).pop();
    });
  }

  ///////////////////////////////GET FAVORITES///////////////////////////////////////////////////////
  getFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList('favorite1') == null) {
      firstsharedFavorite = "المفضلة الأولي";
    } else {
      firstsharedFavorite = prefs.getStringList('favorite1')![2];
    }
    if (prefs.getStringList('favorite2') == null) {
      secondsharedFavorite = "المفضلة الثانية";
    } else {
      secondsharedFavorite = prefs.getStringList('favorite2')![2];
    }
    if (prefs.getStringList('favorite3') == null) {
      thirdsharedFavorite = "المفضلة الثالثة";
    } else {
      thirdsharedFavorite = prefs.getStringList('favorite3')![2];
    }
    if (prefs.getStringList('favorite4') == null) {
      fourthsharedFavorite = "المفضلة الرابعة";
    } else {
      fourthsharedFavorite = prefs.getStringList('favorite4')![2];
    }
    if (prefs.getStringList('favorite5') == null) {
      fifthsharedFavorite = "المفضلة الخامسة";
    } else {
      fifthsharedFavorite = prefs.getStringList('favorite5')![2];
    }
    setState(() {
      firstFavorite.text = firstsharedFavorite!;
      secondFavorite.text = secondsharedFavorite!;
      thirdFavorite.text = thirdsharedFavorite!;
      forthFavorite.text = fourthsharedFavorite!;
      fifthFavorite.text = fifthsharedFavorite!;
    });
  }

  String get_type(String type) {
    if (type == '3adAlay') type = ''; //type='عد الاي';
    if (type == 'elsab3') type = 'شواهد السبع';
    if (type == 'elthalath') type = 'شواهد الثلاث';
    if (type == 'ershadat') type = 'ارشادات';
    if (type == 'twgeh') type = 'توجيهات';
    return type;
  }

  List? shwahedList;
  List<dynamic>? shwahedText;

  Future _checkShwahed() async {
    //print(ayaSora.sora);
    //   setState(() async {
//currrentAya
//this.ayaSora.sora
    String jsonShwahed = await rootBundle.loadString("assets/data/shwahed/" +
        int.tryParse(currrentSora.toString()).toString() +
        ".json");

    int jsonLength = jsonShwahed.length;
    print(jsonLength);
    _myShwahed = List<Map>.from(jsonDecode(jsonShwahed) as List);
    print(_myShwahed!.length);
    // e['sura'] == currrentSora.toString() &&
    var allowed_types = [];
    for (var i = 0; i < globals.myshawahed.length; i++) {
      if (globals.myshawahed[i]['selected'] == 'true')
        allowed_types.add(globals.myshawahed[i]['type']);
    }
    shwahedList = _myShwahed!
        .where((e) =>
            e['sura'] == currrentSora.toString() &&
            e['aya'] == currrentAya.toString() &&
            allowed_types.contains(e['type']))
        .toList();
    if (shwahedList!.length == 0) {
      _shwahedExists = false;
    } else {
      //      print(_myShwahed);
      _shwahedExists = true;
      print(shwahedList!.length);

      shwahedValue.text = "";
      shwahedText = shwahedList!
          .map((t) => (" " + get_type(t["type"]) + ":" + t["Contents"]))
          .toList();
      print(shwahedText);
      shwahedText!.forEach((item) {
        print(item);
        shwahedValue.text += "\r\n " + item;
      });
      //  shwahedValue.text = shwahedText.toString();
      // //  print(shwahedList["Contents"]);
      // //  print(item["Contents"]);
      // //  print(item["Name"]);
      //    _shwahedExists = true;
    }
    //});
  }

//////////CHECK OSOOL TO SHOW BUTTONS////////////////
  Future checkOsool() async {
    String jsonOsool =
        await rootBundle.loadString("assets/data/intro_soghra.json");
    String jsonOsoolK =
        await rootBundle.loadString("assets/data/intro_kobra.json");
    String jsonTayseer =
        await rootBundle.loadString("assets/data/eltayseer_elmo3alem.json");
    String jsonElgamaa = await rootBundle
        .loadString("assets/data/elgam3.json"); //eltayseer_elmo3alem.json");
    // setState(() {
    _myOsool = List<Map>.from(jsonDecode(jsonOsool) as List);
    var item = _myOsool!.firstWhereOrNull(
        (e) => e['sura_order'] == currrentSora && e['aya_number'] == currrentAya
        // , orElse: () => null
        );
    if (item == null) {
      _introExists = false;
    } else {
      introTndex = int.parse(item["ayah_index"]);
      _introExists = true;
    }
    _myOsoolK = List<Map>.from(jsonDecode(jsonOsoolK) as List);
    var itemK = _myOsoolK!.firstWhereOrNull(
        (e) => e['sura_order'] == currrentSora && e['aya_number'] == currrentAya
        // , orElse: () => null
        );
    if (itemK == null) {
      _introKExists = false;
    } else {
      introTndex = int.parse(itemK["ayah_index"]);
      _introKExists = true;
    }
    _myTayseer = List<Map>.from(jsonDecode(jsonTayseer) as List);
    var itemT = _myTayseer!.firstWhereOrNull(
        (e) => e['sura'] == currrentSora && e['aya'] == currrentAya
        // , orElse: () => null
        );
    if (itemT == null) {
      _tayseerExist = false;
    } else {
      introTndex = itemT["id"];
      _tayseerExist = true;
    }
    _myGamaa = List<Map>.from(jsonDecode(jsonElgamaa) as List);
    var itemG = _myGamaa!.firstWhereOrNull(
        (e) => e['sura'] == currrentSora && e['aya'] == currrentAya
        // , orElse: () => null
        );
    if (itemG == null) {
      _gamaaExists = false;
    } else {
      introTndex = itemG["id"];
      _gamaaExists = true;
    }
    //   });
  }

  ///
  ///

//////////PLAY OSOOL FUNCTIONS////////////////
  void osoolNumber(int value) {
    stop();
    int fileValue = 3;
    // globals.OsoolNumber osoolID =
    // new globals.OsoolNumber(id: value, file: fileValue);
    ayaSora?.Khadamat_fileType = fileValue;
    Navigator.pushNamed(context, 'extraspage', arguments: ayaSora);
  }

  void osoolNumberK(int value) {
    stop();
    int fileValue = 4;
    ayaSora?.Khadamat_fileType = fileValue;
    Navigator.pushNamed(context, 'extraspage', arguments: ayaSora);
  }

  void tayseerElmoalem(int value) {
    int fileValue = 5;
    ayaSora?.Khadamat_fileType = fileValue;
    Navigator.pushNamed(context, 'extraspage', arguments: ayaSora);
  }

  void elgamaa(int value) {
    int fileValue = 6;
    ayaSora?.Khadamat_fileType = fileValue;
    Navigator.pushNamed(context, 'extraspage', arguments: ayaSora);
  }

///////////////////////////////START OF MAIN///////////////////////////////////////////////////////
  Widget build(BuildContext context) {
    RouteSettings settings = ModalRoute.of(context)!.settings;
    ayaSora = settings.arguments as AyaSoraNumber?;

    if (currrentAya == 0) {
      currrentAya = int.parse(ayaSora!.aya!);
      currrentSora = int.parse(ayaSora!.sora!);
      if (currrentAya == 0) {
        currrentAya = 1;
      }

      //  _checkShwahed();
      return globals.GlobalUI().getLoadingContent();
    }
    if (!data_ready) return globals.GlobalUI().getLoadingContent();
    // setPlayUrl();
    return Scaffold(
        ///////////////////////////////APP BAR///////////////////////////////////////////////////////
        appBar: AppBar(
          leading: Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 0.0),
            child: new GestureDetector(
              onTap: () {
                stop();
                Navigator.of(context).pop();
              },
              child: Text("الرجوع",
                  style: TextStyle(fontSize: 16.0, color: Colors.brown[100])),
            ),
          ),
          centerTitle: true,
          backgroundColor: Color(0xff22160B),
          title: Text("تيسيرالقراءات",
              style: TextStyle(color: Colors.brown[100], fontSize: 20.0)),
          bottom: PreferredSize(
            child: Text(
                "سورة  " +
                    suraNameValue.text +
                    " ( " +
                    ayaofSuraValue.text +
                    " ) ",
                style: TextStyle(color: Colors.brown[100], fontSize: 17.0)),
            preferredSize: Size.fromHeight(15),
          ),
        ),
        body: WillPopScope(
          onWillPop: () {
            stop();
            Navigator.of(context).pop();
            return Future.value(true);
          },
          child: Container(
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
                spacing: 0.0, // gap between adjacent chips
                runSpacing: 4.0, // gap between lines
                alignment: WrapAlignment.spaceEvenly,
                children: <Widget>[
//////////////////////////BUTTON (PLAY)//////////////////////////////
                  audioPlayerQ.player_buttons(MediaQuery.of(context)),

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
                          playNext();
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
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                        child: Text("التالي",
                            style: TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold)),
                       
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
                          playPrevoius();
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
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                        child: Text("السابق",
                            style: TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold)),
                       
                      ),
                    ),
                  ),

                  ///////////////////////////////ELTAYSEER ELMO3ALEM///////////////////////////////////////////////////////
                  Visibility(
                    maintainSize: false,
                    maintainAnimation: false,
                    maintainState: false,
                    visible: _tayseerExist,
                    child: Container(
                      padding: EdgeInsets.only(left: 5.0),
                      child: new ButtonTheme(
                        height: 70.0,
                        minWidth: MediaQuery.of(context).size.width / 2.1,
                        child: ElevatedButton(
                          onPressed: () {
                            tayseerElmoalem(introTndex!);
                          },
                          child: Text("التيسير المعلم",
                              style: TextStyle(
                                fontSize: 23.0,
                              )),
                              style: OutlinedButton.styleFrom( 
                     
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                        ),
                      ),
                    ),
                  ),

                  ///////////////////////////////ELGAMAA3///////////////////////////////////////////////////////
                  Visibility(
                    maintainSize: false,
                    maintainAnimation: false,
                    maintainState: false,
                    visible: _gamaaExists,
                    child: Container(
                      padding: EdgeInsets.only(left: 5.0),
                      child: new ButtonTheme(
                        height: 70.0,
                        minWidth: MediaQuery.of(context).size.width / 2.1,
                        child: ElevatedButton(
                          onPressed: () {
                            elgamaa(introTndex!);
                          },
                          child: Text("كيفية الجمع",
                              style: TextStyle(
                                fontSize: 23.0,
                              )),
                                style: OutlinedButton.styleFrom( 
                      
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                        ),
                      ),
                    ),
                  ),

                  ///////////////////////////////INTRO SOGHRA///////////////////////////////////////////////////////
                  Visibility(
                    maintainSize: false,
                    maintainAnimation: false,
                    maintainState: false,
                    visible: _introExists,
                    child: Container(
                      child: new ButtonTheme(
                        height: 70.0,
                        minWidth: MediaQuery.of(context).size.width / 2.1,
                        child: ElevatedButton(
                          onPressed: () {
                            osoolNumber(introTndex!);
                          },
                          child: Text("تقدمة - ص",
                              style: TextStyle(
                                fontSize: 23.0,
                              )),
                     style: OutlinedButton.styleFrom( 
                      
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                        ),
                      ),
                    ),
                  ),

                  ///////////////////////////////INTRO KOBRA///////////////////////////////////////////////////////
                  Visibility(
                    maintainSize: false,
                    maintainAnimation: false,
                    maintainState: false,
                    visible: _introKExists,
                    child: Container(
                      child: new ButtonTheme(
                        height: 70.0,
                        minWidth: MediaQuery.of(context).size.width / 2.1,
                        child: ElevatedButton(
                          onPressed: () {
                            osoolNumberK(introTndex!);
                          },
                          child: Text("تقدمة - ك",
                              style: TextStyle(
                                fontSize: 23.0,
                              )),
                               style: OutlinedButton.styleFrom( 
                      
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                        ),
                      ),
                    ),
                  ),

///////////////////////////////SHWAHED///////////////////////////////////////////////////////
                  Visibility(
                    maintainSize: false,
                    maintainAnimation: false,
                    maintainState: false,
                    visible: _shwahedExists,
                    child: Container(
                      // padding: EdgeInsets.only(left: 2.0),
                      child: new ButtonTheme(
                        height: 70.0,
                        minWidth: MediaQuery.of(context).size.width / 2.1,
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog<bool>(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return AlertDialog(
//////////////////POPUP CONTAINER TEXT FIELD (نص الشواهد)///////////////
                                    content: Container(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: Column(
                                            // children: ayahtextFields,
                                            children: [
                                              Text(
                                                shwahedValue.text,
                                                style: TextStyle(
                                                    color: Color(0xff22160B),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20.0),
                                                textAlign: TextAlign.right,
                                              ),
                                            ]),
                                      ),
                                    ),
                                    actions: <Widget>[
                                      //////////// ACTIONS FOR SHWAHED
///////////SHARE BUTTON//////////////////
                                      new ButtonTheme(
                                        height: 50.0,
                                        minWidth:
                                            MediaQuery.of(context).size.width /
                                                5,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            final RenderBox box =
                                                context.findRenderObject()
                                                    as RenderBox;
                                            Share.share(shwahedValue.text,
                                                // subject: subject,
                                                sharePositionOrigin:
                                                    box.localToGlobal(
                                                            Offset.zero) &
                                                        box.size);
                                          },
                                          child: Text("مشاركة",
                                              style: TextStyle(fontSize: 23.0)),
                                                 style: OutlinedButton.styleFrom( 
                       
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                                        ),
                                      ),
///////////COPY BUTTON//////////////////
                                      new ButtonTheme(
                                        height: 50.0,
                                        minWidth:
                                            MediaQuery.of(context).size.width /
                                                4.2,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Clipboard.setData(new ClipboardData(
                                                text: shwahedValue.text));
                                            showDialog<bool>(
                                                context: context,
                                                barrierDismissible: false,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text("تم النسخ",
                                                        style: TextStyle(
                                                          fontSize: 26.0,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center),
                                                    content: Container(
                                                        child:
                                                            SingleChildScrollView(
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      // child:Text("تم النسخ",style: TextStyle(fontSize: 23.0,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                                                    )),
                                                    actions: <Widget>[
                                                      new ButtonTheme(
                                                        height: 60.0,
                                                        minWidth: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            1.5,
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: Text("رجوع",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      23.0)),
                                                              style: OutlinedButton.styleFrom( 
                      
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                });
                                          },
                                          child: Text("نسخ",
                                              style: TextStyle(fontSize: 23.0)),
                                                style: OutlinedButton.styleFrom( 
                       
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                                        ),
                                      ),
                                      new ButtonTheme(
                                        height: 50.0,
                                        minWidth:
                                            MediaQuery.of(context).size.width /
                                                5,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text("خروج",
                                              style: TextStyle(fontSize: 23.0)),
                                                 style: OutlinedButton.styleFrom( 
                      
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                                        ),
                                      ),
                                    ],
                                  );
                                });
                          },
                          child: Text("الشواهد",
                              style: TextStyle(
                                fontSize: 23.0,
                              )),
                               style: OutlinedButton.styleFrom( 
                       
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                        ),
                      ),
                    ),
                  ),

                  ///////////////////////////////TEXT OF AYA///////////////////////////////////////////////////////
                  Container(
                    // padding: EdgeInsets.only(left: 25.0),
                    child: new ButtonTheme(
                      height: 70.0,
                      minWidth: MediaQuery.of(context).size.width / 2.1,
                      child: ElevatedButton(
                        onPressed: () {
                          // _loadTafseerData();
                          _loadAyaText();

                          showDialog<bool>(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("نص الآية",
                                      style: TextStyle(
                                        fontSize: 26.0,
                                      ),
                                      textAlign: TextAlign.center),
//////////////////POPUP CONTAINER TEXT FIELD (نص الآية)///////////////
                                  content: Container(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: Column(
                                        children:
                                            ayahtextFields as List<Widget>,
                                        //     children: [
                                        //         Text(ayahtextValue.text,
                                        //         style: TextStyle(color: Color(0xff22160B),fontWeight: FontWeight.bold,fontSize: 20.0),
                                        //         textAlign: TextAlign.right,
                                        //     ),
                                        // ]
                                      ),
                                    ),
                                  ),
                                  actions: <Widget>[
                                    new ButtonTheme(
                                      height: 50.0,
                                      minWidth:
                                          MediaQuery.of(context).size.width / 5,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // shareUrl();
                                          final RenderBox box = context
                                              .findRenderObject() as RenderBox;
                                          Share.share(ayahtextValue.text,
                                              // subject: subject,
                                              sharePositionOrigin:
                                                  box.localToGlobal(
                                                          Offset.zero) &
                                                      box.size);
                                        },
                                        child: Text("مشاركة",
                                            style: TextStyle(fontSize: 23.0)),
                                                style: OutlinedButton.styleFrom( 
                       
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                                      ),
                                    ),
                                    new ButtonTheme(
                                      height: 50.0,
                                      minWidth:
                                          MediaQuery.of(context).size.width / 5,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Clipboard.setData(new ClipboardData(
                                              text: ayahtextValue.text));
                                          showDialog<bool>(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text("تم النسخ",
                                                      style: TextStyle(
                                                        fontSize: 26.0,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center),
                                                  content: Container(
                                                      child:
                                                          SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    // child:Text("تم النسخ",style: TextStyle(fontSize: 23.0,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                                                  )),
                                                  actions: <Widget>[
                                                    new ButtonTheme(
                                                      height: 60.0,
                                                      minWidth:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              1.5,
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text("رجوع",
                                                            style: TextStyle(
                                                                fontSize:
                                                                    23.0)),
                                                                 style: OutlinedButton.styleFrom( 
                      
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              });
                                        },
                                        child: Text("نسخ",
                                            style: TextStyle(fontSize: 23.0)),
                                             style: OutlinedButton.styleFrom( 
                     
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                                      ),
                                    ),
                                    new ButtonTheme(
                                      height: 50.0,
                                      minWidth:
                                          MediaQuery.of(context).size.width / 5,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("خروج",
                                            style: TextStyle(fontSize: 23.0)),
                                                style: OutlinedButton.styleFrom( 
                      
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                                      ),
                                    ),
                                  ],
                                );
                              });
                        },
                        child: Text("نص الآية",
                            style: TextStyle(
                              fontSize: 23.0,
                            )),
                             style: OutlinedButton.styleFrom( 
                      
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                      ),
                    ),
                  ),

///////////////////////////////CONTINUES LISTENING///////////////////////////////////////////////////////
                  Container(
                    // padding: EdgeInsets.only(top: 25.0),
                    child: new ButtonTheme(
                      height: 70.0,
                      minWidth: MediaQuery.of(context).size.width / 2.1,
                      child: ElevatedButton(
                        onPressed: () {
                          continuePlaying();
                        },
                        child: Text("استماع متواصل",
                            style: TextStyle(
                              fontSize: 23.0,
                            )),
                            style: OutlinedButton.styleFrom( 
                      
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                      ),
                    ),
                  ),
///////////////////////////////BUTTON (الأعراب)///////////////////////////////////////////////////////
                  Container(
                    child: new ButtonTheme(
                      height: 70.0,
                      minWidth: MediaQuery.of(context).size.width / 2.1,
                      child: ElevatedButton(
                        onPressed: () {
                          _loadAarabData();
                          showDialog<bool>(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("الإعراب",
                                      style: TextStyle(
                                        fontSize: 26.0,
                                      ),
                                      textAlign: TextAlign.center),
//////////////////POPUP CONTAINER TEXT FIELD (الأعراب)///////////////
                                  content: Container(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: Column(
                                        children:
                                            earabtextFields as List<Widget>,
                                        //     children: [
                                        //             Text(aarabSuraValue.text,
                                        //         style: TextStyle(color: Color(0xff22160B),fontWeight: FontWeight.bold,fontSize: 20.0),
                                        //         textAlign: TextAlign.right,
                                        //        ),
                                        // ]
                                      ),
                                    ),
                                  ),
                                  actions: <Widget>[
///////////SHARE BUTTON//////////////////
                                    new ButtonTheme(
                                      height: 40.0,
                                      minWidth:
                                          MediaQuery.of(context).size.width / 5,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          final RenderBox box = context
                                              .findRenderObject() as RenderBox;
                                          Share.share(aarabSuraValue.text,
                                              // subject: subject,
                                              sharePositionOrigin:
                                                  box.localToGlobal(
                                                          Offset.zero) &
                                                      box.size);
                                        },
                                        child: Text("مشاركة",
                                            style: TextStyle(fontSize: 23.0)),
                                               style: OutlinedButton.styleFrom( 
                      
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                                      ),
                                    ),
///////////COPY BUTTON//////////////////
                                    new ButtonTheme(
                                      height: 50.0,
                                      minWidth:
                                          MediaQuery.of(context).size.width / 5,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Clipboard.setData(new ClipboardData(
                                              text: aarabSuraValue.text));
                                          showDialog<bool>(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text("تم النسخ",
                                                      style: TextStyle(
                                                        fontSize: 26.0,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center),
                                                  content: Container(
                                                      child:
                                                          SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    // child:Text("تم النسخ",style: TextStyle(fontSize: 23.0,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                                                  )),
                                                  actions: <Widget>[
                                                    new ButtonTheme(
                                                      height: 60.0,
                                                      minWidth:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              1.5,
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text("رجوع",
                                                            style: TextStyle(
                                                                fontSize:
                                                                    23.0)),
                                                              style: OutlinedButton.styleFrom( 
                      
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              });
                                        },
                                        child: Text("نسخ",
                                            style: TextStyle(fontSize: 23.0)),
                                             style: OutlinedButton.styleFrom( 
                      
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                                      ),
                                    ),
                                    new ButtonTheme(
                                      height: 40.0,
                                      minWidth:
                                          MediaQuery.of(context).size.width / 5,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("خروج",
                                            style: TextStyle(fontSize: 23.0)),
                                              style: OutlinedButton.styleFrom( 
                    
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                                      ),
                                    ),
                                  ],
                                );
                              });
                        },
                        child: Text("الإعراب",
                            style: TextStyle(
                              fontSize: 26.0,
                            )),
                                style: OutlinedButton.styleFrom( 
                       
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                      ),
                    ),
                  ),
                  ///////////////////////////////TAFSEER OF AYA///////////////////////////////////////////////////////
                  Container(
                    child: new ButtonTheme(
                      height: 70.0,
                      minWidth: MediaQuery.of(context).size.width / 2.1,
                      child: ElevatedButton(
                        onPressed: () {
                          _loadTafseerData();
                          // _loadSplittedTafseer();
                          showDialog<bool>(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("التفسير",
                                      style: TextStyle(
                                        fontSize: 26.0,
                                      ),
                                      textAlign: TextAlign.center),
//////////////////POPUP CONTAINER TEXT FIELD (التفسير)///////////////
                                  content: Container(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: Column(
                                          children: textFields as List<Widget>
                                          // children: [
                                          //  Column(
                                          //    mainAxisAlignment: MainAxisAlignment.center,
                                          //    children:  textFields
                                          //    ),
                                          //   ElevatedButton(
                                          // child: Text("Print Values"),
                                          //   onPressed: (){
                                          //   tafseerSplited.forEach((str){
                                          //     print(textEditingControllers[str].text);
                                          //   });
                                          // })
                                          // textFields,
                                          //       Text(tafseerValue.text,
                                          //   style: TextStyle(color: Color(0xff22160B),fontWeight: FontWeight.bold,fontSize: 20.0),
                                          //   textAlign: TextAlign.right,
                                          //  ),
                                          // ]
                                          ),
                                    ),
                                  ),
                                  actions: <Widget>[
///////////SHARE BUTTON//////////////////
                                    new ButtonTheme(
                                      height: 50.0,
                                      minWidth:
                                          MediaQuery.of(context).size.width / 5,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          final RenderBox box = context
                                              .findRenderObject() as RenderBox;
                                          Share.share(tafseerValue.text,
                                              // subject: subject,
                                              sharePositionOrigin:
                                                  box.localToGlobal(
                                                          Offset.zero) &
                                                      box.size);
                                        },
                                        child: Text("مشاركة",
                                            style: TextStyle(fontSize: 23.0)),
                                              style: OutlinedButton.styleFrom( 
                      
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                                      ),
                                    ),
///////////COPY BUTTON//////////////////
                                    new ButtonTheme(
                                      height: 50.0,
                                      minWidth:
                                          MediaQuery.of(context).size.width /
                                              4.2,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Clipboard.setData(new ClipboardData(
                                              text: tafseerValue.text));
                                          showDialog<bool>(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text("تم النسخ",
                                                      style: TextStyle(
                                                        fontSize: 26.0,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center),
                                                  content: Container(
                                                      child:
                                                          SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    // child:Text("تم النسخ",style: TextStyle(fontSize: 23.0,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                                                  )),
                                                  actions: <Widget>[
                                                    new ButtonTheme(
                                                      height: 60.0,
                                                      minWidth:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              1.5,
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text("رجوع",
                                                            style: TextStyle(
                                                                fontSize:
                                                                    23.0)),
                                                                style: OutlinedButton.styleFrom( 
                       
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              });
                                        },
                                        child: Text("نسخ",
                                            style: TextStyle(fontSize: 23.0)),
                                              style: OutlinedButton.styleFrom( 
                      
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                                      ),
                                    ),
                                    new ButtonTheme(
                                      height: 50.0,
                                      minWidth:
                                          MediaQuery.of(context).size.width / 5,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("خروج",
                                            style: TextStyle(fontSize: 23.0)),
                                               style: OutlinedButton.styleFrom( 
                      
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                                      ),
                                    ),
                                  ],
                                );
                              });
                        },
                        child: Text("التفسير",
                            style: TextStyle(
                              fontSize: 26.0,
                            )),
                               style: OutlinedButton.styleFrom( 
                      
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                      ),
                    ),
                  ),
///////////////////////////////FAVORITES///////////////////////////////////////////////////////
                  Container(
                    child: new ButtonTheme(
                      height: 70.0,
                      minWidth: MediaQuery.of(context).size.width / 2.1,
                      child: ElevatedButton(
                        onPressed: () {
                          getFavorites();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Container(
                                  height:
                                      MediaQuery.of(context).size.height / 1.5,
                                  child: SingleChildScrollView(
                                    child: Wrap(
                                        spacing:
                                            10.0, // gap between adjacent chips
                                        runSpacing: 4.0, // gap between lines
                                        children: <Widget>[
                                          Column(
                                            children: <Widget>[
///////////////////////////////HEADER OF FAVORITES//////////////////////////////////////////////////////
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    bottom: BorderSide(
                                                      color: Colors.grey,
                                                      width: 2.0,
                                                    ),
                                                  ),
                                                ),
                                                child: Text(
                                                    'من فضلك اختر المفضلة',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 23.0,
                                                    )),
                                              ),
///////////////////////////////FIRST FAVORITES//////////////////////////////////////////////////////
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 5.0, top: 6.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      new ButtonTheme(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            11,
                                                        minWidth: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            2,
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            saveFirstFavorite();
                                                          },
                                                          child: Text(
                                                              firstFavorite
                                                                  .text,
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                              style: TextStyle(
                                                                fontSize: 18.0,
                                                              )),
                                                               style: OutlinedButton.styleFrom( 
                   
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
///////////////////////////////SECOND FAVORITES//////////////////////////////////////////////////////
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 5.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      new ButtonTheme(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            11,
                                                        minWidth: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            2,
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            saveSecondFavorite();
                                                          },
                                                          child: Text(
                                                              secondFavorite
                                                                  .text,
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                              style: TextStyle(
                                                                fontSize: 18.0,
                                                              )),
                                                                 style: OutlinedButton.styleFrom( 
                      
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
///////////////////////////////THIRD FAVORITES//////////////////////////////////////////////////////
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 5.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      new ButtonTheme(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            11,
                                                        minWidth: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            2,
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            saveThirdFavorite();
                                                          },
                                                          child: Text(
                                                              thirdFavorite
                                                                  .text,
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                              style: TextStyle(
                                                                fontSize: 18.0,
                                                              )),
                                                                style: OutlinedButton.styleFrom( 
                    
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
///////////////////////////////FOURTH FAVORITES//////////////////////////////////////////////////////
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 5.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      new ButtonTheme(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            11,
                                                        minWidth: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            2,
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            saveForthFavorite();
                                                          },
                                                          child: Text(
                                                              forthFavorite
                                                                  .text,
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                              style: TextStyle(
                                                                fontSize: 18.0,
                                                              )),
                                                                 style: OutlinedButton.styleFrom( 
                     
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
///////////////////////////////FIFTH FAVORITES//////////////////////////////////////////////////////
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 5.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      new ButtonTheme(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height /
                                                            11,
                                                        minWidth: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            2,
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            saveFifthFavorite();
                                                          },
                                                          child: Text(
                                                              fifthFavorite
                                                                  .text,
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                              style: TextStyle(
                                                                fontSize: 18.0,
                                                              )),
                                                                style: OutlinedButton.styleFrom( 
                       
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
///////////////////////////////EXIT BUTTON OF FAVORITES//////////////////////////////////////////////////////
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(top: 5.0),
                                                child: new ButtonTheme(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      11,
                                                  minWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          1.5,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text(
                                                      "خروج",
                                                      style: TextStyle(
                                                          fontSize: 23.0),
                                                    ),
                                                        style: OutlinedButton.styleFrom( 
                     
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ]),
                                  ),
                                ),
                              );
                            },
                          );
///////////////////////////////ADD FAVORITES MAIN BUTTON//////////////////////////////////////////////////////
                        },
                        child: Text("إضافة إلى المفضلات",
                            style: TextStyle(
                              fontSize: 20.0,
                            )),
                                style: OutlinedButton.styleFrom( 
                     
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                      ),
                    ),
                  ),
///////////////////////////////SHARE URL///////////////////////////////////////////////////////
                  Container(
                    // padding: EdgeInsets.only(top: 25.0),
                    child: new ButtonTheme(
                      height: 70.0,
                      minWidth: MediaQuery.of(context).size.width / 2.1,
                      child: ElevatedButton(
                        onPressed: () {
                          final RenderBox box =
                              context.findRenderObject() as RenderBox;
                          Share.share(ayahtextValue.text + "  " + urlValue.text,
                              // subject: subject,
                              sharePositionOrigin:
                                  box.localToGlobal(Offset.zero) & box.size);
                        },
                        child: Text("مشاركة",
                            style: TextStyle(
                              fontSize: 23.0,
                            )),
                                style: OutlinedButton.styleFrom( 
                      
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        /////////////////////////////////////////FOOTER//////////////////////////////////////////////
        bottomNavigationBar: Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.brown[100],
            margin: const EdgeInsets.only(bottom: 2.0),
            child: Padding(
              padding: const EdgeInsets.all(1),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
//////////////////BUTTON (FAVORITES)///////////////
                  new ButtonTheme(
                    minWidth: MediaQuery.of(context).size.width / 3.1,
                    height: 70.0,
                    child: TextButton(
                      onPressed: () {
                        stop();
                        Navigator.pushNamed(context, 'favorites');
                      },
                      child: Text("المفضلات",
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold)),
                             style: OutlinedButton.styleFrom( 
                      
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                    ),
                  ),
//////////////////BUTTON (SETTINGS)///////////////
                  new ButtonTheme(
                    height: 70.0,
                    minWidth: MediaQuery.of(context).size.width / 3.1,
                    child: TextButton(
                      onPressed: () {
                        stop();
                        Navigator.pushNamed(context, 'settings');
                      },
                      child: Text("الإعدادات",
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold)),
                             style: OutlinedButton.styleFrom( 
                      
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                    ),
                  ),
//////////////////BUTTON (HOME)///////////////
                  new ButtonTheme(
                    // padding: const EdgeInsets.only(left:1.0),
                    height: 70.0,
                    minWidth: MediaQuery.of(context).size.width / 3.1,
                    child: TextButton(
                      onPressed: () {
                        stop();
                        Navigator.pushNamed(context, 'Home');
                      },
                      child: Text("الرئيسية",
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold)),
                             style: OutlinedButton.styleFrom( 
                       
                    foregroundColor : Colors.brown[100], // Text Color
                   backgroundColor: Color(0xff22160B), 
                    //splashColor: Colors.grey,
                    shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Sharp corners
            ),
                  ),
                    ),
                  ),
                ],
              ),
            )));
  }
}
