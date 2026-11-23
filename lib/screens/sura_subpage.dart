import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tayseer_insight/app/theme.dart';
import 'package:tayseer_insight/globals.dart';
import 'package:tayseer_insight/utils/aya_utils.dart';
import 'package:tayseer_insight/utils/log.dart';
import 'package:tayseer_insight/utils/nav.dart';
import 'package:tayseer_insight/widgets/TyseerButton.dart';
import 'package:tayseer_insight/widgets/app_button.dart';
import 'package:tayseer_insight/widgets/app_scaffold.dart';
import 'package:tayseer_insight/widgets/loading_view.dart';

class SuraPage extends StatefulWidget {
  const SuraPage({super.key});

  @override
  State<StatefulWidget> createState() => SuraPageState();
}

class RequiredSura {
  final int? id;
  RequiredSura({this.id});
}

class SuraPageState extends State<SuraPage> {
  List<Map>? _mySura;
  List<Map>? _suraData;
  List<dynamic>? title;
  int gridLength = 0;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadIntroData());
  }

  Future<void> _loadIntroData() async {
    try {
      final id = (ModalRoute.of(context)!.settings.arguments as RequiredSura).id!;
      final jsonSura = await rootBundle.loadString('assets/data/sura_jsons/$id.json');
      final jsonData = await rootBundle.loadString('assets/data/sura_data.json');
      final list = List<Map>.from(jsonDecode(jsonSura) as List);
      final data = List<Map>.from(jsonDecode(jsonData) as List);
      if (!mounted) return;
      setState(() {
        _mySura = list;
        _suraData = data;
        title = list.map((t) => t['page_title']).toList();
        // Groups with 9 or 12 suras fit three per row; the rest two.
        gridLength = (list.length == 9 || list.length == 12) ? 3 : 2;
        _failed = false;
      });
    } catch (e, st) {
      log('sura list failed: $e\n$st');
      if (mounted) setState(() => _failed = true);
    }
  }

  /// Number of ayat in the sura whose id is e.g. "002".
  int? _ayatOf(String suraId) {
    final order = int.tryParse(suraId);
    final item = _suraData?.where((e) => e['sura_order'] == order).firstOrNull;
    final ayat = item?['ayat'];
    return ayat is int ? ayat : null;
  }

  Future<void> _askForAya(String suraId) async {
    final ayat = _ayatOf(suraId);
    final aya = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _AyaNumberDialog(maxAya: ayat),
    );
    if (aya == null || !mounted) return;
    Navigator.pushNamed(
      context,
      'subPage',
      arguments: AyaSoraNumber(aya: pad3(aya), sora: suraId),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return AppScaffold(
        title: 'السور',
        body: ErrorView(
          onRetry: () {
            setState(() => _failed = false);
            _loadIntroData();
          },
        ),
      );
    }
    if (title == null || _mySura == null) return const LoadingView();
    final pageTitle = '${title![0]}';
    final suras = _mySura!;
    final scale = AppTheme.textScale(context);

    return AppScaffold(
      title: pageTitle,
      body: LayoutBuilder(builder: (context, constraints) {
        // One column at large text sizes so long sura names never clip.
        final columns = scale > 1.3 ? 1 : gridLength;
        final cellWidth = constraints.maxWidth / columns;
        final lines = scale > 1.3 ? 2 : 1;
        final cellHeight = MediaQuery.textScalerOf(context).scale(27) * 1.4 * lines + 28;
        return GridView.builder(
          itemCount: suras.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: cellWidth / (cellHeight < 72 ? 72 : cellHeight),
          ),
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.all(4),
            child: ElevatedButton(
              autofocus: index == 0,
              onPressed: () => _askForAya('${suras[index]['sura_id']}'),
              style: AppTheme.buttonStyle(minHeight: 70),
              child: Text(
                '${suras[index]['sura_name']}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 27.0),
              ),
            ),
          ),
        );
      }),
      bottomBar: AppBottomBar(
        children: [
          TyseerButton(
            buttonHeight: 70,
            text: 'المفضلات',
            onPressed: () => Navigator.pushNamed(context, 'favorites'),
          ),
          TyseerButton(
            buttonHeight: 70,
            text: 'الإعدادات',
            onPressed: () => Navigator.pushNamed(context, 'settings'),
          ),
          TyseerButton(
            buttonHeight: 70,
            text: 'الرئيسية',
            onPressed: () => goHome(context),
          ),
        ],
      ),
    );
  }
}

/// Asks for an ayah number. Accepts Arabic-Indic digits, shows the valid range
/// and reports problems as a spoken error instead of crashing.
class _AyaNumberDialog extends StatefulWidget {
  const _AyaNumberDialog({required this.maxAya});
  final int? maxAya;

  @override
  State<_AyaNumberDialog> createState() => _AyaNumberDialogState();
}

class _AyaNumberDialogState extends State<_AyaNumberDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = parseAyaNumber(_controller.text);
    final max = widget.maxAya;
    String? error;
    if (_controller.text.trim().isEmpty) {
      error = 'من فضلك أدخل رقم الآية';
    } else if (value == null) {
      error = 'رقم الآية غير صحيح';
    } else if (max != null && value > max) {
      error = 'رقم الآية يجب أن يكون بين 1 و $max';
    }
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final max = widget.maxAya;
    return AlertDialog(
      semanticLabel: 'رقم الآية',
      title: const Text('رقم الآية',
          textAlign: TextAlign.center, style: TextStyle(fontSize: 26)),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.go,
        maxLength: 3,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩۰-۹]')),
        ],
        style: const TextStyle(fontSize: 25),
        decoration: InputDecoration(
          labelText: max == null ? 'من فضلك ادخل رقم الآية' : 'رقم الآية (من 1 إلى $max)',
          labelStyle: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.ink),
          errorText: _error,
          errorStyle: const TextStyle(fontSize: 18),
          counterText: '',
        ),
        onChanged: (_) {
          if (_error != null) setState(() => _error = null);
        },
        onSubmitted: (_) => _submit(),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsOverflowAlignment: OverflowBarAlignment.center,
      actionsOverflowDirection: VerticalDirection.down,
      actionsOverflowButtonSpacing: 6,
      actions: [
        AppButton(label: 'ذهاب', fontSize: 21, minHeight: 56, onPressed: _submit),
        AppButton(
          label: 'الغاء',
          fontSize: 21,
          minHeight: 56,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
