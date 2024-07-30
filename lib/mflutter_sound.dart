library tayseer_insight.globals;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_sound/flutter_sound.dart';
// import 'package:flutter_sound_web/flutter_sound_web.dart';

/*
flutterSoundHelper class
*/
class mflutter_sound {
  Duration _duration = new Duration();
  Duration _posituion = new Duration();

  FlutterSoundPlayer mPlayer = new FlutterSoundPlayer();
////////////////////////////INIT OF AUDIO PLAYER///////////////////////
  mflutter_sound() {}

  Future play(onlineURL) async {
    mPlayer = (await FlutterSoundPlayer().openPlayer())!;

    Duration? d = await mPlayer.startPlayer(
      fromURI: onlineURL,
      codec: Codec.mp3,
      whenFinished: () {
        print('I hope you enjoyed listening to this song');
      },
    );
    _duration = d!;

    return _duration;
  }

  listen(VoidCallback callbackfunc) {
    mPlayer.setSubscriptionDuration(Duration(milliseconds: 100));

    var _playerSubscription = mPlayer.onProgress!.listen((e) {
      Duration maxDuration = e.duration;
      Duration position = e.position;
      _duration = e.duration;
      _posituion = e.position;
      // print(' onProgress maxDuration' + maxDuration.toString());
      // print('onProgress position' + position.toString());
      callbackfunc();
    });
  }

  getPosition() {
    return _posituion;
  }

  Future<Duration?> getDuration(String onlineURL) async {
    // Duration t = await flutterSoundHelper.duration(onlineURL);
    // print('dttttttttttturation' + d.toString());

    return new Duration();
  }

  pause() async {
    mPlayer.pausePlayer();
  }

  resume() async {
    await mPlayer.resumePlayer();
  }

  getState() async {
    PlayerState theState = await mPlayer.getPlayerState();
    //   isStopped /// Player is stopped
    // isPlaying /// Player is playing
    // isPaused /// Player is paused
    if (mPlayer.isStopped) return 'Stopped';
    if (mPlayer.isPlaying) return 'Playing';
    if (mPlayer.isPaused) return 'Paused';
  }

  seek(Duration d) async {
    await mPlayer.seekToPlayer(d);
  }

  stop() async {
    mPlayer.stopPlayer();
  }
}
