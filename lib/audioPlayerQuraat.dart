library tayseer_insight.globals;

import 'package:tayseer_insight/utils/log.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tayseer_insight/widgets/app_button.dart';
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

  /// Play/pause + stop buttons and the seek slider.
  Widget player_buttons(MediaQueryData AppMediaQueryData) {
    return SizedBox(
      width: AppMediaQueryData.size.width,
      child: Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: Column(
          children: <Widget>[
            AppButtonWrap(
              children: <Widget>[
                AppButton(
                  label: isStarted ? 'ايقاف مؤقت' : 'تشغيل',
                  fontSize: 20.0,
                  minHeight: 80,
                  bold: true,
                  autofocus: true,
                  onPressed: () {
                    if (isStarted) {
                      pause();
                    } else if (isPaused) {
                      resume();
                    } else if (audio_url.isNotEmpty) {
                      play();
                    } else {
                      log('nothing to play ');
                    }
                    onStateChanged();
                  },
                ),
                AppButton(
                  label: 'إيقاف',
                  fontSize: 20.0,
                  minHeight: 80,
                  bold: true,
                  onPressed: () => stop(),
                ),
              ],
            ),
            slider(),
          ],
        ),
      ),
    );
  }

  Widget slider() {
    log('max is =' + this._duration.inSeconds.toString());
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Slider(
        value: this._position.inSeconds.toDouble(),
        min: 0.0,
        max: this._duration.inSeconds.toDouble(),
        activeColor: Color(0xff22160B),
        inactiveColor: Color(0xff22160B),
        onChanged: (double value) {
          log('seek the slider with value=' + value.toString());
          this._position = Duration(seconds: value.toInt());
          // setState(() {
          //   seekToSecond(value.toInt());
          //   value = value;
          // });
        },
        onChangeEnd: (double newvalue) {
          log('Ended change on $newvalue');

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
    log('onPlayerCompletion called  ');
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
    log("setPlayUrl :" + onlineURL);
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
      log('play...' + audio_url);
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
//             // log('I hope you enjoyed listening to this song');
//             onPlayerCompletion();
//           },
//         );
        Duration? d = await webdPlayer.startPlayer(
          // fromURI: audio_url,
          fromDataBuffer: buffer,
          codec: Codec.mp3,
          whenFinished: () {
            // log('I hope you enjoyed listening to this song');
            onPlayerCompletion();
          },
        );
        _duration = d!;
      } else {
        Duration? d = await webdPlayer.startPlayer(
          fromURI: audio_url,
          codec: Codec.mp3,
          whenFinished: () {
            // log('I hope you enjoyed listening to this song');
            onPlayerCompletion();
          },
        );
        _duration = d!;
      }

      log('ddddddddd _duration=' + _duration.toString());
      webdPlayer.setSubscriptionDuration(Duration(milliseconds: 300));
      webdPlayer.onProgress!.listen((e) {
        // Duration maxDuration = e.duration;
        // Duration position = e.position;
        _position = e.position;
        this.isStarted = true;
        isComplete = false;
        // log(' onProgress maxDuration' + maxDuration.toString());
        // log('onProgress position' + position.toString());
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
    // log('getDuration =' + _duration.toString());
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
