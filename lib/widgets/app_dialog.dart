import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:tayseer_insight/app/theme.dart';
import 'package:tayseer_insight/utils/announcer.dart';
import 'package:tayseer_insight/widgets/app_button.dart';

/// Generic accessible dialog: always has a title (so the screen reader names
/// it), scrolls when the text is large, and stacks its actions when they do
/// not fit side by side.
Future<T?> showAppDialog<T>(
  BuildContext context, {
  required String title,
  required Widget content,
  List<Widget> actions = const [],
  bool barrierDismissible = false,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => AlertDialog(
      semanticLabel: title,
      title: Text(title,
          textAlign: TextAlign.center, style: const TextStyle(fontSize: 26)),
      content: SingleChildScrollView(child: content),
      actionsAlignment: MainAxisAlignment.center,
      actionsOverflowAlignment: OverflowBarAlignment.center,
      actionsOverflowDirection: VerticalDirection.down,
      actionsOverflowButtonSpacing: 6,
      actions: actions,
    ),
  );
}

/// Dialog that shows long text (ayah, i'rab, tafseer, shawahed) with
/// Share / Copy / Close actions.
///
/// [source] is listened to, so text that finishes loading after the dialog
/// opened still appears. Copy confirms inline (and by announcement) instead of
/// opening a second dialog.
Future<void> showTextActionsDialog(
  BuildContext context, {
  required String title,
  required TextEditingController source,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _TextActionsDialog(title: title, source: source),
  );
}

class _TextActionsDialog extends StatefulWidget {
  const _TextActionsDialog({required this.title, required this.source});
  final String title;
  final TextEditingController source;

  @override
  State<_TextActionsDialog> createState() => _TextActionsDialogState();
}

class _TextActionsDialogState extends State<_TextActionsDialog> {
  bool _copied = false;

  void _share() {
    final box = context.findRenderObject() as RenderBox?;
    Share.share(
      widget.source.text,
      sharePositionOrigin:
          box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    );
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.source.text));
    if (!mounted) return;
    setState(() => _copied = true);
    Announcer.say(context, 'تم النسخ');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      semanticLabel: widget.title,
      title: Text(widget.title,
          textAlign: TextAlign.center, style: const TextStyle(fontSize: 26)),
      content: ValueListenableBuilder<TextEditingValue>(
        valueListenable: widget.source,
        builder: (context, value, _) => SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value.text,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              if (_copied)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Semantics(
                    liveRegion: true,
                    child: const Text('تم النسخ',
                        style: TextStyle(
                            color: AppColors.ink,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsOverflowAlignment: OverflowBarAlignment.center,
      actionsOverflowDirection: VerticalDirection.down,
      actionsOverflowButtonSpacing: 6,
      actions: [
        AppButton(label: 'مشاركة', fontSize: 20, minHeight: 52, onPressed: _share),
        AppButton(label: 'نسخ', fontSize: 20, minHeight: 52, onPressed: _copy),
        AppButton(
          label: 'خروج',
          fontSize: 20,
          minHeight: 52,
          autofocus: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
