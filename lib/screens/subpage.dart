import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:share/share.dart';
import 'package:tayseer_insight/globals.dart' as globals;
import 'package:tayseer_insight/globals.dart';
import 'package:tayseer_insight/services/audio_url.dart';
import 'package:tayseer_insight/services/favorites_store.dart';
import 'package:tayseer_insight/utils/announcer.dart';
import 'package:tayseer_insight/utils/aya_utils.dart';
import 'package:tayseer_insight/utils/log.dart';
import 'package:tayseer_insight/utils/nav.dart';
import 'package:tayseer_insight/widgets/TyseerButton.dart';
import 'package:tayseer_insight/widgets/app_button.dart';
import 'package:tayseer_insight/widgets/app_dialog.dart';
import 'package:tayseer_insight/widgets/app_scaffold.dart';
import 'package:tayseer_insight/widgets/loading_view.dart';

import '../audioPlayerQuraat.dart';

class SubPage extends StatefulWidget {
  final AyaSoraNumber? arguments;
  const SubPage({super.key, this.arguments});

  @override
  State<StatefulWidget> createState() => SubPageState();
}

class SubPageState extends State<SubPage> {
  late final audioPlayerQuraat audioPlayerQ;

  int currrentAya = 0;
  int currrentSora = 0;
  bool continuosReading = false;
  AyaSoraNumber? ayaSora;
  int? lastAya;
  String? firstWord;
  String? secondWord;
  String? thirdWord;
  int? introTndex;

  bool _introExists = false;
  bool _tayseerExist = false;
  bool _introKExists = false;
  bool _gamaaExists = false;
  bool _shwahedExists = false;

  bool data_ready = false;
  bool _loadFailed = false;

  // ---- navigation is serialised: rapid taps on Next/Previous are queued and
  // only the newest target is loaded, so data never mixes between ayat.
  bool _navBusy = false;
  int? _wantedAya;

  // ---- text shown in the dialogs (dialogs listen to these controllers)
  final TextEditingController tafseerValue = TextEditingController();
  final TextEditingController ayahtextValue = TextEditingController();
  final TextEditingController suraNameValue = TextEditingController();
  final TextEditingController ayaofSuraValue = TextEditingController();
  final TextEditingController aarabSuraValue = TextEditingController();
  final TextEditingController urlValue = TextEditingController();
  final TextEditingController shwahedValue = TextEditingController();

  // ---- data caches: these JSON assets are large (the tafseer file is several
  // MB) and used to be re-read and re-parsed on every navigation.
  List<Map>? _readers;
  List<Map>? _mySora;
  List<Map>? _myAya;
  int? _myAyaFolder;
  List<Map>? _myAarab;
  int? _myAarabSora;
  List<Map>? _myShwahed;
  int? _myShwahedSora;
  List<Map>? _myOsool;
  List<Map>? _myOsoolK;
  List<Map>? _myTayseer;
  List<Map>? _myGamaa;

  @override
  void initState() {
    super.initState();
    audioPlayerQ = audioPlayerQuraat(
      onStateChanged: _refresh,
      oncompeleted: onPlayerCompletion,
      onError: _onAudioError,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialLoad());
  }

  @override
  void dispose() {
    audioPlayerQ.dispose();
    for (final c in [
      tafseerValue,
      ayahtextValue,
      suraNameValue,
      ayaofSuraValue,
      aarabSuraValue,
      urlValue,
      shwahedValue,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _announce(String message) {
    if (mounted) Announcer.say(context, message);
  }

  void _onAudioError(String message) {
    if (!mounted) return;
    Announcer.say(context, message);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _initialLoad() async {
    try {
      await _loadAyah();
      if (!mounted) return;
      setState(() {
        data_ready = true;
        _loadFailed = false;
      });
    } catch (e, st) {
      log('initial load failed: $e\n$st');
      if (mounted) setState(() => _loadFailed = true);
    }
  }

  // -------------------------------------------------------------- navigation

  /// Moves to [target], queueing if a load is already running.
  Future<void> _goToAya(int target) async {
    _wantedAya = target;
    if (_navBusy) return;
    _navBusy = true;
    try {
      while (_wantedAya != null && mounted) {
        currrentAya = _wantedAya!;
        _wantedAya = null;
        await _loadAyah();
      }
    } catch (e, st) {
      log('navigation failed: $e\n$st');
      _announce('تعذر تحميل بيانات الآية');
    } finally {
      _navBusy = false;
    }
  }

  /// "التالي": announces instead of failing silently on the last ayah.
  Future<void> playNext() async {
    final base = _wantedAya ?? currrentAya;
    if (classifyAyaTarget(base + 1, lastAya ?? base) == AyaMove.afterLast) {
      _announce('هذه آخر آية في السورة');
      return;
    }
    await _moveTo(base + 1);
  }

  /// "السابق": announces instead of failing silently on the first ayah.
  Future<void> playPrevoius() async {
    final base = _wantedAya ?? currrentAya;
    if (classifyAyaTarget(base - 1, lastAya ?? base) == AyaMove.beforeFirst) {
      _announce('هذه أول آية في السورة');
      return;
    }
    await _moveTo(base - 1);
  }

  Future<void> _moveTo(int target) async {
    // If audio was running in continuous mode, keep going from the new ayah.
    final resume = continuosReading && audioPlayerQ.isStarted;
    await audioPlayerQ.stop();
    await _goToAya(target);
    if (resume && mounted && !_navBusy) await audioPlayerQ.play();
  }

  /// Called by the player when an ayah finishes.
  Future<void> onPlayerCompletion() async {
    if (!continuosReading || !mounted) return;
    final last = lastAya ?? currrentAya;
    if (currrentAya >= last) {
      setState(() => continuosReading = false);
      _announce('انتهت السورة');
      return;
    }
    await _goToAya(currrentAya + 1);
    if (mounted && continuosReading && !_navBusy) await audioPlayerQ.play();
  }

  /// "استماع متواصل" is a real on/off switch now (it could never be turned off).
  Future<void> toggleContinuous() async {
    if (continuosReading) {
      setState(() => continuosReading = false);
      _announce('تم إيقاف الاستماع المتواصل');
      return;
    }
    setState(() => continuosReading = true);
    _announce('تم تفعيل الاستماع المتواصل');
    if (!audioPlayerQ.isStarted) {
      await setPlayUrl();
      await audioPlayerQ.play();
    }
  }

  Future<void> stop() => audioPlayerQ.stop();

  // -------------------------------------------------------------- data load

  /// Loads everything for [currrentSora] / [currrentAya]. Valid ayah numbers
  /// are enforced here, so a bad number can no longer crash the screen.
  Future<void> _loadAyah() async {
    await _loadSoraData();
    final last = lastAya ?? 1;
    if (currrentAya > last) currrentAya = last;
    if (currrentAya < 1) currrentAya = 1;
    ayaofSuraValue.text = currrentAya.toString();

    _loadAyaText();
    _updateShareUrl();
    await Future.wait([
      _loadAarabData(),
      _loadTafseerData(),
      checkOsool(),
      _checkShwahed(),
    ]);
    await setPlayUrl();
    if (!mounted) return;
    setState(() {});
    if (data_ready) _announceExtras();
  }

  Future<List<Map>> _loadList(String asset) async =>
      List<Map>.from(jsonDecode(await rootBundle.loadString(asset)) as List);

  Future<void> _loadSoraData() async {
    _mySora ??= await _loadList('assets/data/sura_data.json');
    final item = _mySora!.firstWhereOrNull((e) => e['sura_order'] == currrentSora);
    if (item == null) throw StateError('sura $currrentSora not found');
    lastAya = item['ayat'];
    suraNameValue.text = item['sura_name'];
  }

  void _loadAyaText() {
    final item = globals.AyaTextList.firstWhereOrNull(
        (e) => e['ayah'] == '$currrentAya' && e['sura'] == '$currrentSora');
    ayahtextValue.text = item?['ayahtext']?.toString() ?? '';
    // First three words label the favourite.
    final words = ayahtextValue.text.split(' ').where((w) => w.isNotEmpty).toList();
    firstWord = words.isNotEmpty ? words[0] : ' ';
    secondWord = words.length > 1 ? words[1] : ' ';
    thirdWord = words.length > 2 ? words[2] : ' ';
  }

  void _updateShareUrl() {
    final a = pad3(currrentAya);
    final s = pad3(currrentSora);
    urlValue.text = '${globals.audioUrl}${globals.qre2Folder}/S$s/S${s}A$a.mp3';
  }

  Future<void> _loadAarabData() async {
    final sora = currrentSora;
    if (_myAarabSora != sora || _myAarab == null) {
      final list = await _loadList('assets/data/e3rab_jsons/$sora.json');
      _myAarab = list;
      _myAarabSora = sora;
    }
    if (!mounted) return;
    final item = _myAarab!
        .firstWhereOrNull((e) => e['aya'] == currrentAya && e['sora'] == sora);
    final text = item?['e3rab']?.toString() ?? '';
    aarabSuraValue.text = text.isEmpty ? 'لا يوجد اعراب لهذه الايه' : text;
  }

  Future<void> _loadTafseerData() async {
    final folder = globals.tafseerFolder;
    if (_myAyaFolder != folder || _myAya == null) {
      // Folder 1 is the same file already loaded at startup for the ayah text.
      _myAya = (folder == 1 && globals.AyaTextList.isNotEmpty)
          ? globals.AyaTextList
          : await _loadList('assets/data/tafseer_json/$folder.json');
      _myAyaFolder = folder;
    }
    if (!mounted) return;
    final item = _myAya!.firstWhereOrNull(
        (e) => e['ayah'] == '$currrentAya' && e['sura'] == '$currrentSora');
    tafseerValue.text = item?['tafseer']?.toString() ?? 'لا يوجد تفسير لهذه الآية';
  }

  String get_type(String type) {
    if (type == '3adAlay') type = '';
    if (type == 'elsab3') type = 'شواهد السبع';
    if (type == 'elthalath') type = 'شواهد الثلاث';
    if (type == 'ershadat') type = 'ارشادات';
    if (type == 'twgeh') type = 'توجيهات';
    return type;
  }

  Future<void> _checkShwahed() async {
    if (_myShwahedSora != currrentSora || _myShwahed == null) {
      _myShwahed = await _loadList('assets/data/shwahed/$currrentSora.json');
      _myShwahedSora = currrentSora;
    }
    if (!mounted) return;
    final allowed = [
      for (final s in globals.myshawahed)
        if (s['selected'] == 'true') s['type'],
    ];
    final list = _myShwahed!
        .where((e) =>
            e['sura'] == currrentSora.toString() &&
            e['aya'] == currrentAya.toString() &&
            allowed.contains(e['type']))
        .toList();
    _shwahedExists = list.isNotEmpty;
    final buffer = StringBuffer();
    for (final t in list) {
      buffer.write('\r\n  ${get_type(t["type"])}:${t["Contents"]}');
    }
    shwahedValue.text = buffer.toString();
  }

  /// Which optional buttons exist for the current ayah.
  Future<void> checkOsool() async {
    _myOsool ??= await _loadList('assets/data/intro_soghra.json');
    _myOsoolK ??= await _loadList('assets/data/intro_kobra.json');
    _myTayseer ??= await _loadList('assets/data/eltayseer_elmo3alem.json');
    _myGamaa ??= await _loadList('assets/data/elgam3.json');
    if (!mounted) return;

    final soghra = _myOsool!.firstWhereOrNull(
        (e) => e['sura_order'] == currrentSora && e['aya_number'] == currrentAya);
    _introExists = soghra != null;
    if (soghra != null) introTndex = int.tryParse('${soghra["ayah_index"]}');

    final kobra = _myOsoolK!.firstWhereOrNull(
        (e) => e['sura_order'] == currrentSora && e['aya_number'] == currrentAya);
    _introKExists = kobra != null;
    if (kobra != null) introTndex = int.tryParse('${kobra["ayah_index"]}');

    final tayseer = _myTayseer!
        .firstWhereOrNull((e) => e['sura'] == currrentSora && e['aya'] == currrentAya);
    _tayseerExist = tayseer != null;
    if (tayseer != null) introTndex = tayseer['id'];

    final gamaa = _myGamaa!
        .firstWhereOrNull((e) => e['sura'] == currrentSora && e['aya'] == currrentAya);
    _gamaaExists = gamaa != null;
    if (gamaa != null) introTndex = gamaa['id'];
  }

  /// Tells a screen-reader user which extra buttons this ayah has (they used
  /// to appear and disappear silently). Skipped during continuous listening
  /// so speech does not talk over the recitation.
  void _announceExtras() {
    if (continuosReading) return;
    final extras = <String>[
      if (_shwahedExists) 'الشواهد',
      if (_introExists) 'تقدمة صغرى',
      if (_introKExists) 'تقدمة كبرى',
      if (_tayseerExist) 'التيسير المعلم',
      if (_gamaaExists) 'كيفية الجمع',
    ];
    if (extras.isNotEmpty) _announce('متاح لهذه الآية: ${extras.join('، ')}');
  }

  // ------------------------------------------------------------------ audio

  Future<void> setPlayUrl() async {
    if (currrentSora == 0 || currrentAya == 0) return;
    audioPlayerQ.setIsLocal(false);
    _readers ??= await _loadList('assets/data/switch_n.json');
    var path = resolveAudioUrl(
      readers: _readers!,
      folder: globals.qre2Folder,
      sora: currrentSora,
      aya: currrentAya,
      baseUrl: globals.audioUrl,
    );

    // Prefer a downloaded copy when one exists (Android only).
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        final s = pad3(currrentSora);
        final a = pad3(currrentAya);
        final dirs = await ExternalPath.getExternalStorageDirectories();
        for (final root in dirs) {
          final local = '$root/Tayseer/Sound/${globals.qre2Folder}/S$s/S${s}A$a.mp3';
          if (await File(local).exists()) {
            path = local;
            audioPlayerQ.setIsLocal(true);
            break;
          }
        }
      } catch (e) {
        log('local audio lookup failed: $e');
      }
    }
    audioPlayerQ.setPlayUrl(path);
  }

  // -------------------------------------------------------------- favourites

  /// Saves the current ayah into favourite [slot] (0-based).
  Future<void> _saveFavorite(int slot) async {
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
      '${ayahtextValue.text}  ${urlValue.text}',
      sharePositionOrigin:
          box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    );
  }

  // ------------------------------------------------------- extras (khedma)

  /// Opens the "Khadamat" screen for the CURRENT ayah. (It used to pass the
  /// ayah the screen was first opened with, so after pressing Next the intro
  /// audio belonged to the wrong ayah.)
  void _openExtras(int fileType) {
    stop();
    final args = AyaSoraNumber(aya: pad3(currrentAya), sora: pad3(currrentSora))
      ..Khadamat_fileType = fileType;
    Navigator.pushNamed(context, 'extraspage', arguments: args);
  }

  // ------------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    final settings = ModalRoute.of(context)!.settings;
    ayaSora = settings.arguments as AyaSoraNumber?;

    if (ayaSora == null) {
      return AppScaffold(
        title: 'تيسير القراءات',
        body: ErrorView(
          message: 'تعذر فتح الآية.',
          onRetry: () => Navigator.of(context).maybePop(),
        ),
      );
    }

    if (currrentAya == 0) {
      currrentAya = int.tryParse(ayaSora!.aya!) ?? 1;
      currrentSora = int.tryParse(ayaSora!.sora!) ?? 1;
      if (currrentAya == 0) currrentAya = 1;
      return globals.GlobalUI().getLoadingContent();
    }

    if (_loadFailed) {
      return AppScaffold(
        title: 'تيسير القراءات',
        body: ErrorView(
          message: 'تعذر تحميل بيانات الآية.',
          onRetry: () {
            setState(() => _loadFailed = false);
            _initialLoad();
          },
        ),
      );
    }
    if (!data_ready) return globals.GlobalUI().getLoadingContent();

    return PopScope(
      // Stop the audio whenever this screen is left (button or gesture).
      onPopInvokedWithResult: (didPop, result) => stop(),
      child: AppScaffold(
        title: 'تيسير القراءات',
        titleSize: 20,
        subtitle: 'سورة ${suraNameValue.text}، الآية ${ayaofSuraValue.text}'
            ' من ${lastAya ?? ''}',
        // While reading continuously the ayah changes by itself; do not let the
        // screen reader speak over the recitation.
        subtitleLive: !continuosReading,
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
                      onPressed: () => _openExtras(5),
                    ),
                  if (_gamaaExists)
                    AppButton(
                      label: 'كيفية الجمع',
                      onPressed: () => _openExtras(6),
                    ),
                  if (_introExists)
                    AppButton(
                      label: 'تقدمة - ص',
                      semanticLabel: 'تقدمة صغرى',
                      onPressed: () => _openExtras(3),
                    ),
                  if (_introKExists)
                    AppButton(
                      label: 'تقدمة - ك',
                      semanticLabel: 'تقدمة كبرى',
                      onPressed: () => _openExtras(4),
                    ),
                  if (_shwahedExists)
                    AppButton(
                      label: 'الشواهد',
                      onPressed: () => showTextActionsDialog(context,
                          title: 'الشواهد', source: shwahedValue),
                    ),
                  AppButton(
                    label: 'نص الآية',
                    onPressed: () => showTextActionsDialog(context,
                        title: 'نص الآية', source: ayahtextValue),
                  ),
                  AppButton(
                    label: continuosReading
                        ? 'إيقاف الاستماع المتواصل'
                        : 'استماع متواصل',
                    onPressed: toggleContinuous,
                  ),
                  AppButton(
                    label: 'الإعراب',
                    fontSize: 26,
                    onPressed: () => showTextActionsDialog(context,
                        title: 'الإعراب', source: aarabSuraValue),
                  ),
                  AppButton(
                    label: 'التفسير',
                    fontSize: 26,
                    onPressed: () {
                      // Pick up a tafseer chosen in Settings since this
                      // screen opened; the dialog updates when it loads.
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
              onPressed: () => goHome(context),
            ),
          ],
        ),
      ),
    );
  }
}
