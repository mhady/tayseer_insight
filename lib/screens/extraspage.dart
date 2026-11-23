import 'package:flutter/material.dart';
import 'package:tayseer_insight/globals.dart' as globals;
import 'package:tayseer_insight/globals.dart';
import 'package:tayseer_insight/services/remote_json.dart';
import 'package:tayseer_insight/utils/announcer.dart';
import 'package:tayseer_insight/utils/log.dart';
import 'package:tayseer_insight/utils/nav.dart';
import 'package:tayseer_insight/widgets/TyseerButton.dart';
import 'package:tayseer_insight/widgets/app_scaffold.dart';
import 'package:tayseer_insight/widgets/choice_list.dart';
import 'package:tayseer_insight/widgets/loading_view.dart';
import 'package:tayseer_insight/widgets/track_player_panel.dart';

import '../audioPlayerQuraat.dart';

class Extras extends StatefulWidget {
  final AyaSoraNumber? AyaSora;

  const Extras({super.key, this.AyaSora});

  @override
  State<StatefulWidget> createState() => ExtrasState();
}

enum _Mode { list, items, play }

enum _Status { loading, ready, error }

/// "الخدمات": a list of services, each with a list of recordings, played by
/// [audioPlayerQuraat]. Also opened from an ayah (intro / teaching / jam3
/// recordings), in which case it jumps straight to that recording.
class ExtrasState extends State<Extras> {
  static const String _servicesTitle = 'الخدمات';

  late final audioPlayerQuraat _player;

  List<Map> _services = [];
  List<Map> _items = [];
  _Mode _mode = _Mode.list;
  _Status _status = _Status.loading;
  String _title = _servicesTitle;
  String _playText = '';
  int _current = 0;
  AyaSoraNumber? _args;
  bool _launchedFromAya = false;
  Future<void> Function() _retry = () async {};

  @override
  void initState() {
    super.initState();
    _player = audioPlayerQuraat(
      onStateChanged: () {
        if (mounted) setState(() {});
      },
      oncompeleted: () {},
      onError: (m) {
        if (mounted) Announcer.say(context, m);
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _args = ModalRoute.of(context)?.settings.arguments as AyaSoraNumber?;
      _start();
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------ data

  /// Runs [body] showing the loading view, then either the content or an error
  /// view with a retry button.
  Future<void> _run(Future<void> Function() body, Future<void> Function() retry) async {
    _retry = retry;
    setState(() => _status = _Status.loading);
    try {
      await body();
      if (mounted) setState(() => _status = _Status.ready);
    } catch (e, st) {
      log('extras load failed: $e\n$st');
      if (!mounted) return;
      setState(() => _status = _Status.error);
    }
  }

  Future<void> _start() => _run(() async {
        _services = await fetchJsonList(globals.Khadmaturl, stripPrefix: 'khedma=');
        _mode = _Mode.list;
        _title = _servicesTitle;
        final args = _args;
        _args = null; // only once
        if (args != null) await _openFromAya(args);
      }, _start);

  Future<void> _openService(int i) => _run(() async {
        _title = '${_services[i]['name']}';
        _items = await fetchJsonList('https://${_services[i]['path']}/MP3Files.json');
        _mode = _Mode.items;
      }, () => _openService(i));

  /// Finds the recording of the given ayah and plays it.
  Future<void> _openFromAya(AyaSoraNumber a) async {
    String path = '';
    String file = '';
    switch (a.Khadamat_fileType) {
      case 3: // intro soghra
        path = 'addons.quraat.info';
        file = 'S${a.sora}A${a.aya}I.mp3';
      case 4: // intro kobra
        path = 'addonk.quraat.info';
        file = 'S${a.sora}A${a.aya}I.mp3';
      case 5: // mo3alem
        path = 'learn.quraat.info';
        file = 'S${a.sora}A${a.aya}M';
      case 6: // jam3
        path = 'learn.quraat.info';
        file = 'S${a.sora}A${a.aya}J';
    }
    final i = _services.indexWhere((e) => e['path'] == path);
    if (i < 0) {
      _announce('لا يوجد تسجيل لهذه الآية');
      return;
    }
    _title = '${_services[i]['name']}';
    _items = await fetchJsonList('https://${_services[i]['path']}/MP3Files.json');
    _mode = _Mode.items;
    final j = _items.indexWhere((e) => '${e['file']}'.contains(file));
    if (j < 0) {
      _announce('لا يوجد تسجيل لهذه الآية');
      return;
    }
    _launchedFromAya = true;
    _play(j);
  }

  void _announce(String m) {
    if (mounted) Announcer.say(context, m);
  }

  // --------------------------------------------------------------- playing

  void _play(int i) {
    _mode = _Mode.play;
    _current = i;
    _playText = '${_items[i]['text']}';
    _player.PlayGoogleDriveFile(_items[i]['file_id']);
    if (mounted) setState(() {});
  }

  void _next() {
    if (_current + 1 < _items.length) {
      _play(_current + 1);
    } else {
      _announce('هذا آخر تسجيل');
    }
  }

  void _previous() {
    if (_current > 0) {
      _play(_current - 1);
    } else {
      _announce('هذا أول تسجيل');
    }
  }

  // ------------------------------------------------------------------ back

  bool get _canPopDirectly =>
      _status != _Status.ready ||
      _mode == _Mode.list ||
      (_mode == _Mode.play && _launchedFromAya);

  void _handleBack() {
    if (_canPopDirectly) {
      Navigator.of(context).pop();
      return;
    }
    _player.stop();
    setState(() {
      if (_mode == _Mode.items) {
        _mode = _Mode.list;
        _title = _servicesTitle;
      } else {
        _mode = _Mode.items; // from player back to the recordings list
      }
    });
  }

  // ----------------------------------------------------------------- build

  Widget _body() {
    switch (_status) {
      case _Status.loading:
        return const LoadingView();
      case _Status.error:
        return ErrorView(onRetry: _retry);
      case _Status.ready:
        switch (_mode) {
          case _Mode.list:
            return ChoiceList(
              labels: [for (final s in _services) '${s['name']}'],
              onSelected: (i) {
                _player.stop();
                _openService(i);
              },
            );
          case _Mode.items:
            return ChoiceList(
              labels: [for (final s in _items) '${s['text']}'],
              onSelected: _play,
            );
          case _Mode.play:
            return TrackPlayerPanel(
              title: _playText,
              player: _player,
              onNext: _next,
              onPrevious: _previous,
            );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canPopDirectly,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack();
      },
      child: AppScaffold(
        title: _title,
        onBack: _handleBack,
        body: _body(),
        bottomBar: AppBottomBar(
          children: [
            TyseerButton(
              buttonHeight: 70,
              text: 'المفضلات',
              onPressed: () {
                _player.pause();
                Navigator.pushNamed(context, 'favorites');
              },
            ),
            TyseerButton(
              buttonHeight: 70,
              text: 'الإعدادات',
              onPressed: () {
                _player.pause();
                Navigator.pushNamed(context, 'settings');
              },
            ),
            TyseerButton(
              buttonHeight: 70,
              text: 'الرئيسية',
              onPressed: () => goHome(context),
            ),
          ],
        ),
      ),
    );
  }
}
