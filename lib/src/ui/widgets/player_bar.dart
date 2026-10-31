import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../audio/chapter_player.dart';
import '../../audio/verse_speaker.dart';
import '../../settings/settings_controller.dart';

/// The mini player shown at the bottom of every screen while a chapter is
/// playing or paused.
///
/// It sits above the app's Navigator (see GitaApp), so it has no Overlay for
/// tooltips; buttons are labelled through their icons' semantics instead.
class PlayerBar extends StatelessWidget {
  const PlayerBar({super.key, required this.player, required this.onOpenVerse});

  final ChapterPlayer player;

  /// Opens the reader at the verse being played.
  final ValueChanged<String> onOpenVerse;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.stringsOf(context);
    final hindiUi = AppScope.settingsOf(context).language == AppLanguage.hindi;
    final content = AppScope.contentOf(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final verse = player.currentVerse!;
    final chapter = content.chapters[verse.chapter - 1];
    final part = player.currentPart;

    final String status;
    if (player.noVoice) {
      status = s.noVoiceShort;
    } else if (player.isFinished) {
      status = s.chapterComplete;
    } else if (!player.isPlaying) {
      status = s.paused;
    } else {
      status = switch (part?.language) {
        SpeechLanguage.sanskrit => s.sanskrit,
        SpeechLanguage.hindi => s.hindiLabel,
        SpeechLanguage.english => s.englishLabel,
        null => s.listenChapter,
      };
    }

    Widget button(IconData icon, String label, VoidCallback? onPressed) =>
        IconButton(
          icon: Icon(icon, semanticLabel: label),
          onPressed: onPressed,
        );

    return Material(
      color: scheme.surfaceContainerHigh,
      elevation: 3,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: (player.index + 1) / player.verseCount,
              minHeight: 3,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => onOpenVerse(verse.id),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.headphones_rounded,
                              color: scheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.nowPlaying(
                                      verse.chapter,
                                      verse.number,
                                      player.verseCount,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleSmall,
                                  ),
                                  Text(
                                    '${hindiUi ? chapter.hindi : chapter.english} · $status',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  button(
                    Icons.skip_previous_rounded,
                    s.previousVerse,
                    player.index > 0 ? player.previousVerse : null,
                  ),
                  IconButton.filled(
                    icon: Icon(
                      player.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      semanticLabel: player.isPlaying
                          ? s.pause
                          : player.isFinished
                          ? s.playNextChapter
                          : s.play,
                    ),
                    onPressed: player.togglePlay,
                  ),
                  button(
                    Icons.skip_next_rounded,
                    s.nextVerse,
                    player.index + 1 < player.verseCount
                        ? player.nextVerse
                        : null,
                  ),
                  button(Icons.close_rounded, s.closePlayer, player.close),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
