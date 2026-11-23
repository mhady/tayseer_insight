import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tayseer_insight/app/theme.dart';
import 'package:tayseer_insight/utils/aya_utils.dart';
import 'package:tayseer_insight/utils/log.dart';
import 'package:tayseer_insight/widgets/app_button.dart';

/// Message shown/announced when audio cannot start (usually no connection).
const String audioErrorMessage = 'تعذر تشغيل الصوت. تأكد من الاتصال بالإنترنت.';

/// Plays one MP3 at a time (an ayah, a "khedma" or a "khatma" recording) and
/// renders the play/stop/seek controls.
///
/// Owner screens MUST call [dispose] from `State.dispose`; before this was
/// added, audio kept playing after leaving a screen and progress listeners
/// piled up on every play.
class audioPlayerQuraat {
  audioPlayerQuraat({
    required this.onStateChanged,
    required this.oncompeleted,
    this.onError,
  });

  final VoidCallback onStateChanged;
  final VoidCallback oncompeleted;

  /// Called when playback fails to start or breaks (with a user-facing message).
  final void Function(String message)? onError;

  /// Skip buttons only make sense for long recordings (khedma/khatma), not for
  /// a single ayah.
  static const Duration _skipButtonsMinDuration = Duration(seconds: 30);
  static const Duration _skipStep = Duration(seconds: 10);

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  FlutterSoundPlayer? _player;
  StreamSubscription<PlaybackDisposition>? _progressSub;
  bool _disposed = false;
  bool _dragging = false;

  /// Incremented by every play()/stop()/dispose(); an in-flight play() that
  /// finds its token stale quietly gives up.
  int _token = 0;

  bool isStarted = false;
  bool isPaused = false;
  bool isComplete = false;
  String audio_url = '';
  bool isLocal = false;

  /// Non-null after a failure, until the next play().
  String? errorMessage;

  /// Lets widget tests render the controls with a known position/length
  /// without starting the native player.
  @visibleForTesting
  void debugSetProgress({required Duration position, required Duration duration}) {
    _position = position;
    _duration = duration;
  }

  // ---------------------------------------------------------------- controls

  /// Play/pause + stop buttons, skip buttons (long audio only) and the slider.
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
                  label: isStarted ? 'إيقاف مؤقت' : 'تشغيل',
                  fontSize: 20.0,
                  minHeight: 80,
                  bold: true,
                  autofocus: true,
                  onPressed: _onPlayPressed,
                ),
                AppButton(
                  label: 'إيقاف تام',
                  fontSize: 20.0,
                  minHeight: 80,
                  bold: true,
                  onPressed: () => stop(),
                ),
              ],
            ),
            if (_duration >= _skipButtonsMinDuration)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: AppButtonWrap(
                  children: <Widget>[
                    AppButton(
                      label: 'تقديم 10 ثوان',
                      fontSize: 18,
                      minHeight: 64,
                      onPressed: () => seekBy(_skipStep),
                    ),
                    AppButton(
                      label: 'رجوع 10 ثوان',
                      fontSize: 18,
                      minHeight: 64,
                      onPressed: () => seekBy(-_skipStep),
                    ),
                  ],
                ),
              ),
            slider(),
          ],
        ),
      ),
    );
  }

  void _onPlayPressed() {
    if (isStarted) {
      pause();
    } else if (isPaused) {
      resume();
    } else if (audio_url.isNotEmpty) {
      play();
    } else {
      log('nothing to play');
    }
    onStateChanged();
  }

  /// Seek slider. It is spoken as a time ("الموضع دقيقة و5 ثانية من ...") rather
  /// than a percentage, and is disabled until the length of the audio is known.
  Widget slider() {
    final maxSeconds = _duration.inSeconds.toDouble();
    final enabled = maxSeconds > 0;
    final value = enabled
        ? _position.inSeconds.toDouble().clamp(0.0, maxSeconds).toDouble()
        : 0.0;
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 8, right: 8),
      child: Semantics(
        // The control's NAME; its value is the spoken time (below).
        label: 'موضع التشغيل',
        child: SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.ink,
            inactiveTrackColor: AppColors.ink.withValues(alpha: 0.3),
            thumbColor: AppColors.ink,
            overlayColor: AppColors.ink.withValues(alpha: 0.15),
            trackHeight: 6,
          ),
          child: Slider(
            value: value,
            min: 0.0,
            max: enabled ? maxSeconds : 1.0,
            // Only shown (and spoken) while dragging.
            label: _dragging ? spokenDuration(Duration(seconds: value.round())) : null,
            semanticFormatterCallback: (v) =>
                'الموضع ${spokenDuration(Duration(seconds: v.round()))} '
                'من ${spokenDuration(_duration)}',
            onChangeStart: enabled ? (_) => _dragging = true : null,
            onChanged: enabled
                ? (v) {
                    _position = Duration(seconds: v.round());
                    onStateChanged();
                  }
                : null,
            onChangeEnd: enabled
                ? (v) {
                    _dragging = false;
                    seek(Duration(seconds: v.round()));
                    onStateChanged();
                  }
                : null,
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ setup

  Future PlayGoogleDriveFile(fileID) async {
    audio_url = 'https://drive.google.com/uc?export=mp3&id=$fileID';
    await play();
  }

  void setIsLocal(bool isLocalSetting) => isLocal = isLocalSetting;

  void setPlayUrl(String url) {
    log('setPlayUrl: $url');
    audio_url = url;
  }

  // ---------------------------------------------------------------- playback

  Future<void> play({String onlineURL = ''}) async {
    if (_disposed) return;
    if (onlineURL.isNotEmpty) audio_url = onlineURL;
    if (audio_url.isEmpty) return;

    final token = ++_token;
    errorMessage = null;
    isComplete = false;
    try {
      await _release();
      if (_disposed || token != _token) return;
      _position = Duration.zero;
      _duration = Duration.zero;

      final player = await FlutterSoundPlayer().openPlayer();
      if (player == null) throw StateError('audio player could not be opened');
      if (_disposed || token != _token) {
        await player.closePlayer();
        return;
      }
      _player = player;

      Duration? length;
      if (isLocal) {
        final status = await Permission.storage.status;
        if (!status.isGranted) await Permission.storage.request();
        final Uint8List buffer = await File(audio_url).readAsBytes();
        length = await player.startPlayer(
          fromDataBuffer: buffer,
          codec: Codec.mp3,
          whenFinished: () => _onFinished(token),
        );
      } else {
        length = await player.startPlayer(
          fromURI: audio_url,
          codec: Codec.mp3,
          whenFinished: () => _onFinished(token),
        );
      }
      if (_disposed || token != _token) return;

      _duration = length ?? Duration.zero;
      isStarted = true;
      isPaused = false;

      await player.setSubscriptionDuration(const Duration(milliseconds: 300));
      _progressSub = player.onProgress?.listen((e) {
        if (_disposed || token != _token) return;
        if (!_dragging) _position = e.position;
        if (_duration == Duration.zero && e.duration > Duration.zero) {
          _duration = e.duration;
        }
        onStateChanged();
      });
      onStateChanged();
    } catch (e) {
      log('play failed: $e');
      if (_disposed || token != _token) return;
      await _release();
      isStarted = false;
      isPaused = false;
      errorMessage = audioErrorMessage;
      onError?.call(audioErrorMessage);
      onStateChanged();
    }
  }

  void _onFinished(int token) {
    if (_disposed || token != _token) return;
    isStarted = false;
    isPaused = false;
    isComplete = true;
    _position = _duration;
    onStateChanged();
    oncompeleted();
  }

  Future<void> seek(Duration newDuration) async {
    final player = _player;
    if (player == null || !player.isOpen()) return;
    try {
      await player.seekToPlayer(newDuration);
      _position = newDuration;
    } catch (e) {
      log('seek failed: $e');
    }
  }

  Future<void> seekBy(Duration delta) {
    var target = _position + delta;
    if (target < Duration.zero) target = Duration.zero;
    if (_duration > Duration.zero && target > _duration) target = _duration;
    return seek(target);
  }

  bool getIsStarted() => isStarted;
  Duration getDuration() => _duration;
  Duration getPosition() => _position;

  Future<void> pause() async {
    final player = _player;
    try {
      if (player != null && player.isOpen() && player.isPlaying) {
        await player.pausePlayer();
      }
    } catch (e) {
      log('pause failed: $e');
    }
    if (_disposed) return;
    isStarted = false;
    isPaused = true;
    onStateChanged();
  }

  Future<void> resume() async {
    final player = _player;
    if (!isPaused || player == null) return;
    try {
      await player.resumePlayer();
    } catch (e) {
      log('resume failed: $e');
      return;
    }
    if (_disposed) return;
    isPaused = false;
    isStarted = true;
    onStateChanged();
  }

  Future<void> stop() async {
    _token++; // cancels any play() still starting
    await _release();
    if (_disposed) return;
    isStarted = false;
    isPaused = false;
    _position = Duration.zero;
    onStateChanged();
  }

  /// Stops playback and frees the native player and its listener.
  Future<void> _release() async {
    await _progressSub?.cancel();
    _progressSub = null;
    final player = _player;
    _player = null;
    if (player == null) return;
    try {
      if (player.isOpen()) {
        await player.stopPlayer();
        await player.closePlayer();
      }
    } catch (e) {
      log('release failed: $e');
    }
  }

  /// Call from `State.dispose`. Safe to call more than once.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _token++;
    unawaited(_release());
  }
}
