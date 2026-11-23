import 'package:tayseer_insight/utils/log.dart';
import 'package:flutter/material.dart';
import 'package:tayseer_insight/services/favorites_store.dart';
import 'package:tayseer_insight/utils/announcer.dart';
import 'package:tayseer_insight/widgets/TyseerButton.dart';
import 'package:tayseer_insight/widgets/app_button.dart';
import 'package:tayseer_insight/widgets/app_dialog.dart';
import 'package:tayseer_insight/widgets/app_scaffold.dart';

import 'package:tayseer_insight/globals.dart' as globals;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
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
    this.arguments,
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
        log('all data ready');
      });
    });
  }

  void updateState() {
    setState(() {});
  }

  void onPlayerCompletion() {
    log('onPlayerCompletion called  ');

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
  //   // log(_duration);
  // });

  // advancedPlayer.positionHandler = (p) => setState(() {
  //   if(p.inSeconds>=_duration.inSeconds){
  //     _position = new Duration(hours: 0,minutes: 0,seconds: 0);
  //     buttonValue.text="تشغيل";
  //   }
  //   else{
  //       _position = p;
  //   }

  // // log(_position);
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
    log('currrentSora=' +
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
          log(int.parse(item['tosura']));
          log(int.parse(sorsstr));
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
          log(int.parse(item['toaya']));
          log(int.parse(ayastr));
          onlineURL = globals.audioUrl +
              "ATolbaHfs" +
              "/S$sorsstr/S${sorsstr}A$ayastr.mp3";
        } else {
          onlineURL = globals.audioUrl +
              globals.qre2Folder +
              "/S$sorsstr/S${sorsstr}A$ayastr.mp3";
        }
      }
      log('onlineURL audio play file $onlineURL');
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
      log(audioFilePath);

      // initPlayer();

      // else{
      // AudioProvider audioProvider = new AudioProvider(onlineURL);
      //   log(onlineURL);
      // String localUrl = await audioProvider.load();
      //   // audioCache.play(localUrl);
      //   await advancedPlayer.play(localUrl);
      //   log(localUrl);
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
          log(int.parse(item['tosura']));
          log(int.parse(sorsstr));
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
          log(int.parse(item['toaya']));
          log(int.parse(ayastr));
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
      log(onlineURL);
      // String localUrl = await audioProvider.load();
      //   audioCache.clear(localUrl);
      //   // audioCache.clearCache();
      //   await audioCache.play(localUrl);
      //   log(localUrl);

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
    // log(globals.tafseerFolder);
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
      log("************************ayaaaaa$sharedAya");
      String sharedSora = ayaformat(currrentSora);
      String sharedURL = globals.audioUrl +
          globals.qre2Folder +
          "/S$sharedSora/S${sharedSora}A$sharedAya.mp3";
      urlValue.text = sharedURL;
      final item = _myAya!
          .firstWhere((e) => e['ayah'] == ayaValue && e['sura'] == soraValue);
      // log(item['tafseer']);
      // log(item['ayahtext']);
      tafseerValue.text = item['tafseer'];
      ayaofSuraValue.text = ayaValue;
      //  log(ayahtextValue.text.split(" ").length);

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
          // log(tafseerLines);
          tafseerLines!.add(oneLineString!);
          // log(oneLineString);
          oneLineString = " ";
          // log(tafseerSplited[i]);
        }
      }
      tafseerLines!.add(oneLineString!);
////////////SPLITING ARRAY///////////////
      tafseerLines!.forEach((str) {
        // log('${tafseerSplited.indexOf(str)}:$str');
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
      // log(item['tafseer']);
      // log(item['ayahtext']);
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
      // log("*******_mySora: $_mySora");
      String soraValue = this.format(this.ayaSora!.sora!);
      int sura = int.parse(soraValue);
      final item = _mySora!.firstWhere((e) => e['sura_order'] == sura);
      // log(item['sura_name']);
      // log(item['ayat']);
      lastAya = item['ayat'];
      // log(lastAya);
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
    // log(soraValue);
    // log(jsonSora);
    earabtextFields.clear();
    earabLines.clear();
    setState(() {
      earabtextFields.clear();
      earabLines.clear();
      _myAarab = List<Map>.from(jsonDecode(jsonSora) as List);
      // log("*******_myAarab: $_myAarab");
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
        // log("************SPlitedArray*******$earabSplited");
        // log(aarabSuraValue.text.split(" ").length/8);
        // tafseerSplitedValue = tafseerValue.text.split(" ").length;
        // oneLineString
        oneLineString = " ";
        for (var i = 0; i < earabSplited!.length; i++) {
          if (earabSplited![i] == " " || earabSplited![i] == "") continue;
          oneLineString = oneLineString! + " " + earabSplited![i];
          if (i == 0) continue;
          oneLine = i % 6;
          if (oneLine == 0) {
            // log(tafseerLines);
            earabLines.add(oneLineString!);
            // log(oneLineString);
            oneLineString = " ";
            // log(earabSplited[i]);
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
  /// Saves the current ayah into favourite [slot] (0-based).
  Future<void> _saveFavorite(int slot) async {
    _loadTafseerData();
    final label = '${suraNameValue.text}($currrentAya) '
        '${firstWord ?? ''} ${secondWord ?? ''} ${thirdWord ?? ''}';
    await FavoritesStore.save(slot,
        sora: currrentSora, aya: currrentAya, label: label);
    if (!mounted) return;
    Navigator.of(context).pop(); // close the picker
    Announcer.say(context, 'تمت الإضافة إلى المفضلات');
  }

  Future<void> _showFavoritesPicker() async {
    final entries = await FavoritesStore.load();
    if (!mounted) return;
    await showAppDialog<void>(
      context,
      title: 'من فضلك اختر المفضلة',
      barrierDismissible: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var slot = 0; slot < FavoritesStore.slots; slot++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: AppButton(
                label: FavoritesStore.labelFor(entries, slot),
                expand: true,
                fontSize: 18,
                minHeight: 56,
                autofocus: slot == 0,
                onPressed: () => _saveFavorite(slot),
              ),
            ),
        ],
      ),
      actions: [
        AppButton(
          label: 'خروج',
          fontSize: 20,
          minHeight: 52,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  void _shareAyah() {
    final box = context.findRenderObject() as RenderBox?;
    Share.share(
      ayahtextValue.text + '  ' + urlValue.text,
      sharePositionOrigin:
          box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    );
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
    //log(ayaSora.sora);
    //   setState(() async {
//currrentAya
//this.ayaSora.sora
    String jsonShwahed = await rootBundle.loadString("assets/data/shwahed/" +
        int.tryParse(currrentSora.toString()).toString() +
        ".json");

    int jsonLength = jsonShwahed.length;
    log(jsonLength);
    _myShwahed = List<Map>.from(jsonDecode(jsonShwahed) as List);
    log(_myShwahed!.length);
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
      //      log(_myShwahed);
      _shwahedExists = true;
      log(shwahedList!.length);

      shwahedValue.text = "";
      shwahedText = shwahedList!
          .map((t) => (" " + get_type(t["type"]) + ":" + t["Contents"]))
          .toList();
      log(shwahedText);
      shwahedText!.forEach((item) {
        log(item);
        shwahedValue.text += "\r\n " + item;
      });
      //  shwahedValue.text = shwahedText.toString();
      // //  log(shwahedList["Contents"]);
      // //  log(item["Contents"]);
      // //  log(item["Name"]);
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
  @override
  Widget build(BuildContext context) {
    RouteSettings settings = ModalRoute.of(context)!.settings;
    ayaSora = settings.arguments as AyaSoraNumber?;

    if (currrentAya == 0) {
      currrentAya = int.parse(ayaSora!.aya!);
      currrentSora = int.parse(ayaSora!.sora!);
      if (currrentAya == 0) {
        currrentAya = 1;
      }
      return globals.GlobalUI().getLoadingContent();
    }
    if (!data_ready) return globals.GlobalUI().getLoadingContent();

    return PopScope(
      // Stop the audio whenever this screen is left (back button or gesture).
      onPopInvokedWithResult: (didPop, result) => stop(),
      child: AppScaffold(
        title: 'تيسير القراءات',
        titleSize: 20,
        subtitle: 'سورة  ${suraNameValue.text} ( ${ayaofSuraValue.text} ) ',
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 5.0),
          child: Column(
            children: <Widget>[
              audioPlayerQ.player_buttons(MediaQuery.of(context)),
              AppButtonWrap(
                children: <Widget>[
                  AppButton(
                    label: 'التالي',
                    fontSize: 20.0,
                    minHeight: 80,
                    bold: true,
                    onPressed: playNext,
                  ),
                  AppButton(
                    label: 'السابق',
                    fontSize: 20.0,
                    minHeight: 80,
                    bold: true,
                    onPressed: playPrevoius,
                  ),
                  if (_tayseerExist)
                    AppButton(
                      label: 'التيسير المعلم',
                      onPressed: () => tayseerElmoalem(introTndex!),
                    ),
                  if (_gamaaExists)
                    AppButton(
                      label: 'كيفية الجمع',
                      onPressed: () => elgamaa(introTndex!),
                    ),
                  if (_introExists)
                    AppButton(
                      label: 'تقدمة - ص',
                      onPressed: () => osoolNumber(introTndex!),
                    ),
                  if (_introKExists)
                    AppButton(
                      label: 'تقدمة - ك',
                      onPressed: () => osoolNumberK(introTndex!),
                    ),
                  if (_shwahedExists)
                    AppButton(
                      label: 'الشواهد',
                      onPressed: () => showTextActionsDialog(context,
                          title: 'الشواهد', source: shwahedValue),
                    ),
                  AppButton(
                    label: 'نص الآية',
                    onPressed: () {
                      _loadAyaText();
                      showTextActionsDialog(context,
                          title: 'نص الآية', source: ayahtextValue);
                    },
                  ),
                  AppButton(
                    label: 'استماع متواصل',
                    onPressed: continuePlaying,
                  ),
                  AppButton(
                    label: 'الإعراب',
                    fontSize: 26,
                    onPressed: () {
                      _loadAarabData();
                      showTextActionsDialog(context,
                          title: 'الإعراب', source: aarabSuraValue);
                    },
                  ),
                  AppButton(
                    label: 'التفسير',
                    fontSize: 26,
                    onPressed: () {
                      _loadTafseerData();
                      showTextActionsDialog(context,
                          title: 'التفسير', source: tafseerValue);
                    },
                  ),
                  AppButton(
                    label: 'إضافة إلى المفضلات',
                    fontSize: 20,
                    onPressed: _showFavoritesPicker,
                  ),
                  AppButton(
                    label: 'مشاركة',
                    onPressed: _shareAyah,
                  ),
                ],
              ),
            ],
          ),
        ),
        bottomBar: AppBottomBar(
          children: [
            TyseerButton(
              buttonHeight: 70,
              text: 'المفضلات',
              onPressed: () {
                stop();
                Navigator.pushNamed(context, 'favorites');
              },
            ),
            TyseerButton(
              buttonHeight: 70,
              text: 'الإعدادات',
              onPressed: () {
                stop();
                Navigator.pushNamed(context, 'settings');
              },
            ),
            TyseerButton(
              buttonHeight: 70,
              text: 'الرئيسية',
              onPressed: () {
                stop();
                Navigator.pushNamed(context, 'Home');
              },
            ),
          ],
        ),
      ),
    );
  }
}
