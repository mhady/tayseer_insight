import 'package:flutter/material.dart';
import 'package:tayseer_insight/widgets/app_button.dart';

/// Scrollable list of choices rendered as large buttons.
///
/// One column on phones, more on wide screens. Heights follow the text, so
/// long titles and large system fonts never clip (the old grids used fixed
/// aspect ratios).
class ChoiceList extends StatelessWidget {
  const ChoiceList({
    super.key,
    required this.labels,
    required this.onSelected,
    this.subtitles,
    this.fontSize = 24,
  });

  final List<String> labels;
  final List<String?>? subtitles;
  final void Function(int index) onSelected;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width < 600 ? 1 : (width < 1200 ? 2 : 3);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(5),
      child: AppButtonWrap(
        maxColumns: columns,
        spacing: 6,
        children: [
          for (var i = 0; i < labels.length; i++)
            AppButton(
              label: labels[i],
              subtitle: subtitles == null ? null : subtitles![i],
              fontSize: fontSize,
              minHeight: 72,
              autofocus: i == 0,
              onPressed: () => onSelected(i),
            ),
        ],
      ),
    );
  }
}
