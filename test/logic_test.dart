import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tayseer_insight/globals.dart' as globals;
import 'package:tayseer_insight/services/audio_url.dart';
import 'package:tayseer_insight/services/remote_json.dart';
import 'package:tayseer_insight/services/settings_store.dart';
import 'package:tayseer_insight/utils/aya_utils.dart';

void main() {
  group('ayah number helpers', () {
    test('normalizeDigits converts Arabic-Indic and Persian digits', () {
      expect(normalizeDigits('٠١٢٣٤٥٦٧٨٩'), '0123456789');
      expect(normalizeDigits('۰۱۲۳۴۵۶۷۸۹'), '0123456789');
      expect(normalizeDigits('12٣'), '123');
      expect(normalizeDigits('abc'), 'abc');
    });

    test('parseAyaNumber accepts valid input, rejects the rest', () {
      expect(parseAyaNumber('7'), 7);
      expect(parseAyaNumber(' ٢٥٥ '), 255);
      expect(parseAyaNumber(''), isNull);
      expect(parseAyaNumber('   '), isNull);
      expect(parseAyaNumber('0'), isNull);
      expect(parseAyaNumber('-3'), isNull);
      expect(parseAyaNumber('1.5'), isNull);
      expect(parseAyaNumber('abc'), isNull);
    });

    test('classifyAyaTarget guards both ends of a sura', () {
      expect(classifyAyaTarget(0, 7), AyaMove.beforeFirst);
      expect(classifyAyaTarget(1, 7), AyaMove.ok);
      expect(classifyAyaTarget(7, 7), AyaMove.ok);
      expect(classifyAyaTarget(8, 7), AyaMove.afterLast);
    });

    test('pad3 and spokenDuration', () {
      expect(pad3(7), '007');
      expect(pad3(114), '114');
      expect(spokenDuration(const Duration(seconds: 5)), '5 ثانية');
      expect(spokenDuration(const Duration(seconds: 65)), '1 دقيقة و5 ثانية');
      expect(spokenDuration(const Duration(minutes: 2)), '2 دقيقة');
      expect(spokenDuration(const Duration(seconds: 3725)), '1 ساعة و2 دقيقة و5 ثانية');
      expect(spokenDuration(Duration.zero), '0 ثانية');
    });
  });

  group('resolveAudioUrl', () {
    final readers = <Map>[
      {
        'folder': 'ATolbaHfs',
        'tosura': '114',
        'toaya': '006',
        'url': 'http://sound.quraat.info/',
        'file_name_format': 'tayseer',
      },
      {
        'folder': 'Partial',
        'tosura': '2',
        'toaya': '100',
        'url': 'http://sound.quraat.info/',
        'file_name_format': 'tayseer',
      },
      {
        'folder': 'Other',
        'tosura': '114',
        'toaya': '006',
        'url': 'http://example.com/q',
        'file_name_format': 'qmp3',
      },
    ];

    String url(String folder, int sora, int aya) =>
        resolveAudioUrl(readers: readers, folder: folder, sora: sora, aya: aya);

    test('normal reader uses its own folder', () {
      expect(url('ATolbaHfs', 2, 255), 'https://sound.quraat.info/ATolbaHfs/S002/S002A255.mp3');
    });

    test('recitation ends at tosura/toaya, afterwards falls back to default reader', () {
      expect(url('Partial', 1, 7), 'https://sound.quraat.info/Partial/S001/S001A007.mp3');
      expect(url('Partial', 2, 100), 'https://sound.quraat.info/Partial/S002/S002A100.mp3');
      expect(url('Partial', 2, 101), 'https://sound.quraat.info/ATolbaHfs/S002/S002A101.mp3');
      expect(url('Partial', 3, 1), 'https://sound.quraat.info/ATolbaHfs/S003/S003A001.mp3');
    });

    test('the default reader falls back only after its last ayah', () {
      expect(url('ATolbaHfs', 114, 6), 'https://sound.quraat.info/ATolbaHfs/S114/S114A006.mp3');
      expect(url('ATolbaHfs', 114, 7), 'https://sound.quraat.info/ATolbaHfs/S114/S114A007.mp3');
    });

    test('qmp3 readers use their own base url', () {
      expect(url('Other', 5, 12), 'http://example.com/q/005012.mp3');
    });

    test('an unknown reader folder no longer throws', () {
      expect(url('DoesNotExist', 1, 1), 'https://sound.quraat.info/ATolbaHfs/S001/S001A001.mp3');
    });
  });

  group('SettingsStore', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      globals.qre2Folder = 'ATolbaHfs';
      globals.tafseerFolder = 1;
      globals.myshawahed.clear();
    });

    test('defaults when nothing was saved', () async {
      await SettingsStore.load();
      expect(globals.qre2Folder, 'ATolbaHfs');
      expect(globals.tafseerFolder, 1);
      expect(globals.myshawahed.length, 5);
      expect(globals.myshawahed.every((e) => e['selected'] == 'true'), isTrue);
    });

    test('shawahed choices are restored after a restart (was never loaded)', () async {
      await SettingsStore.load();
      globals.myshawahed.firstWhere((e) => e['type'] == 'twgeh')['selected'] = 'false';
      await SettingsStore.saveShwahed(globals.myshawahed);

      globals.myshawahed.clear(); // simulate app restart
      await SettingsStore.load();
      expect(globals.myshawahed.length, 5);
      expect(globals.myshawahed.firstWhere((e) => e['type'] == 'twgeh')['selected'], 'false');
      expect(globals.myshawahed.firstWhere((e) => e['type'] == 'elsab3')['selected'], 'true');
    });

    test('tafseer choice is saved and restored (was never saved)', () async {
      await SettingsStore.saveTafseer(2);
      globals.tafseerFolder = 1; // simulate restart
      await SettingsStore.load();
      expect(globals.tafseerFolder, 2);
    });

    test('reader choice is saved and restored', () async {
      await SettingsStore.saveReader('Saleh');
      await SettingsStore.load();
      expect(globals.qre2Folder, 'Saleh');
    });

    test('reads the old storage format (a JSON object per item)', () async {
      SharedPreferences.setMockInitialValues({
        'shawahed_setting': [
          jsonEncode({'type': 'elsab3', 'value': 'شواهد السبع', 'selected': 'false'}),
        ],
      });
      await SettingsStore.load();
      expect(globals.myshawahed.firstWhere((e) => e['type'] == 'elsab3')['selected'], 'false');
      // Types missing from an older save are added back, selected.
      expect(globals.myshawahed.length, 5);
    });

    test('corrupt entries fall back to defaults instead of crashing', () async {
      SharedPreferences.setMockInitialValues({
        'shawahed_setting': ['not json', '{"nope":1}'],
        'tafseer_folder': -5,
      });
      await SettingsStore.load();
      expect(globals.myshawahed.length, 5);
      expect(globals.tafseerFolder, 1);
    });
  });

  group('fetchJsonList', () {
    http.Client clientReturning(String body, {int status = 200}) => MockClient(
          (request) async => http.Response.bytes(utf8.encode(body), status),
        );

    test('parses a list and strips the name= prefix', () async {
      final list = await fetchJsonList(
        'https://x/khedma.json',
        stripPrefix: 'khedma=',
        client: clientReturning('khedma=[{"name":"خدمة","path":"a.b"}]'),
      );
      expect(list.single['name'], 'خدمة');
    });

    test('non-200 becomes a RemoteDataException', () async {
      expect(
        () => fetchJsonList('https://x', client: clientReturning('nope', status: 404)),
        throwsA(isA<RemoteDataException>()),
      );
    });

    test('a JSON object (not a list) is rejected', () async {
      expect(
        () => fetchJsonList('https://x', client: clientReturning('{"a":1}')),
        throwsA(isA<RemoteDataException>()),
      );
    });

    test('invalid JSON surfaces as FormatException so callers can fall back', () async {
      expect(
        () => fetchJsonList('https://x', client: clientReturning('<html>')),
        throwsA(isA<FormatException>()),
      );
    });

    test('a hung request times out instead of loading forever', () async {
      final hung = MockClient((request) => Completer<http.Response>().future);
      expect(
        () => fetchJsonList('https://x',
            client: hung, timeout: const Duration(milliseconds: 50)),
        throwsA(isA<RemoteDataException>()),
      );
    });

    test('network failures become a RemoteDataException', () async {
      final broken = MockClient((request) async => throw http.ClientException('offline'));
      expect(
        () => fetchJsonList('https://x', client: broken),
        throwsA(isA<RemoteDataException>()),
      );
    });
  });
}
