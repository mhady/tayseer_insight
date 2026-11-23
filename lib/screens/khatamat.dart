import 'package:flutter/material.dart';
import 'package:tayseer_insight/globals.dart' as globals;
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

class Khatamat extends StatefulWidget {
  const Khatamat({super.key});

  @override
  State<StatefulWidget> createState() => KhatamatState();
}

enum _Mode { list, items, play }

enum _Status { loading, ready, error }

/// "الختمات": complete recitations (khatmas), each a list of recordings.
class KhatamatState extends State<Khatamat> {
  static const String _listTitle = 'الختمات';

  late final audioPlayerQuraat _player;

  List<Map> _khatamat = [];
  List<Map> _items = [];
  _Mode _mode = _Mode.list;
  _Status _status = _Status.loading;
  String _title = _listTitle;
  String _playText = '';
  bool _hasDb = false;
  int _current = 0;
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------ data

  Future<void> _run(Future<void> Function() body, Future<void> Function() retry) async {
    _retry = retry;
    setState(() => _status = _Status.loading);
    try {
      await body();
      if (mounted) setState(() => _status = _Status.ready);
    } catch (e, st) {
      log('khatamat load failed: $e\n$st');
      if (!mounted) return;
      setState(() => _status = _Status.error);
    }
  }

  Future<void> _start() => _run(() async {
        _khatamat = await fetchJsonList(globals.Khatmaturl, stripPrefix: 'khatma=');
        _mode = _Mode.list;
        _title = _listTitle;
        _items = [];
      }, _start);

  Future<void> _openKhatma(int i) => _run(() async {
        final k = _khatamat[i];
        _title = '${k['name']}';
        _hasDb = '${k['hasDB']}' == '1';
        final base = 'https://${k['path']}';
        if (_hasDb) {
          try {
            _items = await fetchJsonList('$base/MP3FilesWithReaderAuditor.json');
          } on FormatException {
            _hasDb = false; // file missing/invalid: fall back to the plain list
            _items = await fetchJsonList('$base/MP3Files.json');
          }
        } else {
          _items = await fetchJsonList('$base/MP3Files.json');
        }
        _mode = _Mode.items;
      }, () => _openKhatma(i));

  // --------------------------------------------------------------- playing

  String? _readerOf(int i) => _hasDb ? _items[i]['reader_name']?.toString() : null;
  String? _reviewerOf(int i) => _hasDb ? _items[i]['auditor_name']?.toString() : null;

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
    } else if (mounted) {
      Announcer.say(context, 'هذا آخر تسجيل');
    }
  }

  void _previous() {
    if (_current > 0) {
      _play(_current - 1);
    } else if (mounted) {
      Announcer.say(context, 'هذا أول تسجيل');
    }
  }

  // ------------------------------------------------------------------ back

  bool get _canPopDirectly => _status != _Status.ready || _mode == _Mode.list;

  void _handleBack() {
    if (_canPopDirectly) {
      Navigator.of(context).pop();
      return;
    }
    _player.stop();
    setState(() {
      if (_mode == _Mode.items) {
        _mode = _Mode.list;
        _title = _listTitle;
      } else {
        _mode = _Mode.items;
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
              labels: [for (final k in _khatamat) '${k['name']}'],
              fontSize: 22,
              onSelected: (i) {
                _player.stop();
                _openKhatma(i);
              },
            );
          case _Mode.items:
            return ChoiceList(
              labels: [for (final s in _items) '${s['text']}'],
              subtitles: _hasDb
                  ? [
                      for (var i = 0; i < _items.length; i++)
                        [
                          if ((_readerOf(i) ?? '').isNotEmpty) 'القارئ: ${_readerOf(i)}',
                          if ((_reviewerOf(i) ?? '').isNotEmpty)
                            'المراجع: ${_reviewerOf(i)}',
                        ].join(' - '),
                    ]
                  : null,
              fontSize: 22,
              onSelected: _play,
            );
          case _Mode.play:
            return TrackPlayerPanel(
              title: _playText,
              reader: _readerOf(_current),
              reviewer: _reviewerOf(_current),
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
                _player.stop();
                Navigator.pushNamed(context, 'favorites');
              },
            ),
            TyseerButton(
              buttonHeight: 70,
              text: 'الإعدادات',
              onPressed: () {
                _player.stop();
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
