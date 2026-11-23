import 'package:flutter/material.dart';
import 'package:tayseer_insight/app/theme.dart';
import 'package:tayseer_insight/audioPlayerQuraat.dart';
import 'package:tayseer_insight/widgets/app_button.dart';

/// Player screen body shared by Khadamat and Khatamat: the title of the
/// current recording (a live region, so changing track is announced), optional
/// reader / reviewer, the player controls and Next / Previous.
class TrackPlayerPanel extends StatelessWidget {
  const TrackPlayerPanel({
    super.key,
    required this.title,
    required this.player,
    required this.onNext,
    required this.onPrevious,
    this.reader,
    this.reviewer,
  });

  final String title;
  final String? reader;
  final String? reviewer;
  final audioPlayerQuraat player;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  @override
  Widget build(BuildContext context) {
    final people = [
      if (reader != null && reader!.isNotEmpty) 'القارئ: $reader',
      if (reviewer != null && reviewer!.isNotEmpty) 'المراجع: $reviewer',
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 5.0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.ink,
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 20),
            child: Column(
              children: [
                Semantics(
                  liveRegion: true,
                  header: true,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.parchment, fontSize: 27.0),
                  ),
                ),
                for (final line in people)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      line,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.parchment, fontSize: 18.0),
                    ),
                  ),
              ],
            ),
          ),
          player.player_buttons(MediaQuery.of(context)),
          AppButtonWrap(
            children: [
              AppButton(
                label: 'التالي',
                fontSize: 20.0,
                minHeight: 80,
                bold: true,
                onPressed: onNext,
              ),
              AppButton(
                label: 'السابق',
                fontSize: 20.0,
                minHeight: 80,
                bold: true,
                onPressed: onPrevious,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
