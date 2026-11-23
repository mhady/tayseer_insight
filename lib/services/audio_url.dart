import 'package:collection/collection.dart';
import 'package:tayseer_insight/utils/aya_utils.dart';

const String defaultAudioBaseUrl = 'https://sound.quraat.info/';
const String defaultReaderFolder = 'ATolbaHfs';

/// Chooses the online MP3 address for one ayah.
///
/// Same rules the player used before (one copy instead of two identical
/// Android/iOS branches):
/// * a reader's recording only covers suras/ayat up to (`tosura`, `toaya`);
///   anything after that falls back to [defaultReaderFolder];
/// * readers in `qmp3` format have their own base `url`;
/// * an unknown reader folder falls back to the default reader instead of
///   throwing.
String resolveAudioUrl({
  required List<Map> readers,
  required String folder,
  required int sora,
  required int aya,
  String baseUrl = defaultAudioBaseUrl,
}) {
  final s = pad3(sora);
  final a = pad3(aya);
  String forFolder(String f) => '$baseUrl$f/S$s/S${s}A$a.mp3';

  final item = readers.firstWhereOrNull((e) => e['folder'] == folder);
  if (item == null) return forFolder(defaultReaderFolder);

  final toSura = int.tryParse('${item['tosura']}') ?? 114;
  final toAya = int.tryParse('${item['toaya']}') ?? 999;
  final format = item['file_name_format'];

  var url = forFolder(folder);
  if (format == 'tayseer') {
    url = toSura < sora ? forFolder(defaultReaderFolder) : forFolder(folder);
  } else if (format == 'qmp3') {
    url = '${item['url']}/$s$a.mp3';
  }

  if (toSura == sora) {
    url = toAya < aya ? forFolder(defaultReaderFolder) : forFolder(folder);
  }
  return url;
}
