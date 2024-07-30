library tayseer_insight.globals;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:permission_handler/permission_handler.dart';

// import 'mflutter_sound.dart';

// import 'package:flutter/foundation.dart' show kIsWeb;

// import 'mflutter_sound.dart';
import 'package:flutter_sound/flutter_sound.dart';

/*
audioPlayerQuraat class
*/
class audioPlayerQuraat {
  Duration _duration = new Duration();
  Duration _position = new Duration();

  FlutterSoundPlayer webdPlayer = new FlutterSoundPlayer();
  bool isStarted = false;
  bool isPaused = false;
  bool isComplete = false;
  VoidCallback onStateChanged;
  VoidCallback oncompeleted;
  bool kIsWeb = true; //try all as web
  String audio_url = "";

  bool isLocal = false;
////////////////////////////INIT OF AUDIO PLAYER///////////////////////
  audioPlayerQuraat(
      {required this.onStateChanged, required this.oncompeleted}) {
    this._position = Duration(seconds: 0);
    if (kIsWeb) {
      // running on the web!

    } else {
      //
    }
  }

  Widget player_buttons(MediaQueryData AppMediaQueryData) {
    return SingleChildScrollView(
        padding: EdgeInsets.only(top: 5.0),
        child: Wrap(
          spacing: 0.0, // gap between adjacent chips
          runSpacing: 4.0, // gap between lines
          alignment: WrapAlignment.spaceEvenly,
          children: <Widget>[
//////////////////////////BUTTON (PLAY)//////////////////////////////
            Container(
              decoration: BoxDecoration(
                color: Colors.brown[200],
              ),
              child: new ButtonTheme(
                height: 80.0,
                minWidth: AppMediaQueryData.size.width / 2.1,
                child: OutlinedButton(
                  autofocus: true,
                  onPressed: () {
                    if (isStarted)
                      pause();
                    else {
                      if (isPaused) {
                        resume();
                      } else {
                        if (audio_url.length > 0)
                          play();
                        else {
                          print('nothing to play ');
                        }
                        //PlayGoogleDriveFile(playFileId);
                      }
                    }
                    this.onStateChanged();
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
                  child: Text((isStarted) ? "ايقاف مؤقت" : "تشغيل",
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold)),
                
                ),
              ),
            ),
///////////////////////BUTTON (STOP)////////////////////////////////
            Container(
              decoration: new BoxDecoration(
                color: Colors.brown[200],
              ),
              child: ButtonTheme(
                height: 80.0,
                minWidth: AppMediaQueryData.size.width / 2.1,
                child: OutlinedButton(
                  onPressed: () {
                    stop();
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
                  child: Text("إيقاف",
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold)),
                  
                ),
              ),
            ),
///////////////////////////////SLIDER///////////////////////////////////////////////////////
            Container(
              width: AppMediaQueryData.size.width,
              child: slider(),
            )
          ],
        ));

    //
    //
    //
    return new ButtonTheme(
      height: 80.0,
      minWidth: AppMediaQueryData.size.width / 2.1,
      child: OutlinedButton(
        onPressed: () {
          if (isStarted)
            pause();
          else {
            if (isPaused) {
              resume();
            } else {
              // PlayGoogleDriveFile(playFileId);
              play();
            }
          }
          this.onStateChanged();

          ;
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
        child: Text((isStarted) ? "ايقاف " : "تشغيل",
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
      
      ),
    );
  }

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
          print('seek the slider with value=' + value.toString());
          this._position = Duration(seconds: value.toInt());
          // setState(() {
          //   seekToSecond(value.toInt());
          //   value = value;
          // });
        },
        onChangeEnd: (double newvalue) {
          print('Ended change on $newvalue');

          Duration newDuration = Duration(seconds: newvalue.toInt());

          this.seek(newDuration);
          this.onStateChanged();
          // setState(() {
          //   seekToSecond(newvalue.toInt());
          //   newvalue = newvalue;
          // });
        },
      ),
    );
  }

  void onPlayerCompletion() {
    print('onPlayerCompletion called  ');
    this.isStarted = false;
    isComplete = true;
    this.oncompeleted();
    // buttonValue.text = "تشغيل";
  }

  Future PlayGoogleDriveFile(fileID) async {
    audio_url = "https://drive.google.com/uc?export=mp3&id=" + fileID;
    play();
  }

//
//
  setIsLocal(isLocal_setting) {
    isLocal = isLocal_setting;
  }

  setPlayUrl(onlineURL) {
    print("setPlayUrl :" + onlineURL);
    audio_url = onlineURL;
  }

///////////////////PLAY AUDIO//////////////////////
  Future play({String onlineURL = ''}) async {
    if (onlineURL == '') onlineURL = audio_url;
    audio_url = onlineURL;
    if (kIsWeb) {
      // running on the web!
      await stop();
      this._position = Duration(seconds: 0);
      webdPlayer.closePlayer();

      webdPlayer = (await FlutterSoundPlayer().openPlayer())!;
      print('play...' + audio_url);
      if (isLocal) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }
        final file = new File('${audio_url}');
        Uint8List buffer = await file.readAsBytes();
        // await file.writeAsBytes((await loadAsset()).buffer.asUint8List());
// final result = await audioPlayer.play(file.path, isLocal: true);
//         // Load a local audio file and get it as a buffer
        // Uint8List buffer =
        //     (await rootBundle.load(audio_url)).buffer.asUint8List();

//        webdPlayer = (await FlutterSoundPlayer()).startPlayerFromBuffer(
//           buffer,
//           codec: Codec.mp3,
//           whenFinished: () {
//             // print('I hope you enjoyed listening to this song');
//             onPlayerCompletion();
//           },
//         );
        Duration? d = await webdPlayer.startPlayer(
          // fromURI: audio_url,
          fromDataBuffer: buffer,
          codec: Codec.mp3,
          whenFinished: () {
            // print('I hope you enjoyed listening to this song');
            onPlayerCompletion();
          },
        );
        _duration = d!;
      } else {
        Duration? d = await webdPlayer.startPlayer(
          fromURI: audio_url,
          codec: Codec.mp3,
          whenFinished: () {
            // print('I hope you enjoyed listening to this song');
            onPlayerCompletion();
          },
        );
        _duration = d!;
      }

      print('ddddddddd _duration=' + _duration.toString());
      webdPlayer.setSubscriptionDuration(Duration(milliseconds: 300));
      webdPlayer.onProgress!.listen((e) {
        // Duration maxDuration = e.duration;
        // Duration position = e.position;
        _position = e.position;
        this.isStarted = true;
        isComplete = false;
        // print(' onProgress maxDuration' + maxDuration.toString());
        // print('onProgress position' + position.toString());
        this.onStateChanged();
      });

      this.onStateChanged();
    } else {}
  }

  seek(Duration newDuration) {
    if (kIsWeb) {
      webdPlayer.seekToPlayer(newDuration);
    } else {}
  }

  bool getIsStarted() {
    if (kIsWeb) {
      return this.isStarted;
      // webdPlayer.;
    } else {
      return this.isStarted;
    }
  }

  Duration getDuration() {
    // print('getDuration =' + _duration.toString());
    return _duration;
  }

  Duration getPosition() {
    return _position;
  }

///////////////////PAUSE AUDIO//////////////////////
  pause() async {
    if (kIsWeb) {
      if (webdPlayer.isOpen() )
      if(webdPlayer.isPlaying) await webdPlayer.pausePlayer();
      this.isStarted = false;
      this.isPaused = true;
      this.onStateChanged();
    } else {}
  }

///////////////////STOP AUDIO//////////////////////
  stop() async {
    if (kIsWeb) {
      await webdPlayer.stopPlayer();
      isStarted = false;
      isPaused = false;
      this.onStateChanged();
    } else {}
  }

  resume() async {
    if (kIsWeb) {
      if (isPaused) webdPlayer.resumePlayer();
    } else {}
  }
}
