import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../content/models.dart';
import '../settings/settings_controller.dart';
import 'verse_reader_screen.dart';
import 'widgets/layout.dart';

class ChapterScreen extends StatelessWidget {
  const ChapterScreen({super.key, required this.chapter});

  final Chapter chapter;

  void _read(BuildContext context, String verseId) => Navigator.of(context)
      .push(
        MaterialPageRoute(
          builder: (_) => VerseReaderScreen(initialVerseId: verseId),
        ),
      );

  void _openChapter(BuildContext context, Chapter other) =>
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ChapterScreen(chapter: other)),
      );

  @override
  Widget build(BuildContext context) {
    final s = AppScope.stringsOf(context);
    final hindiUi = AppScope.settingsOf(context).language == AppLanguage.hindi;
    final content = AppScope.contentOf(context);
    final verses = content.versesOf(chapter.number);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final previous = chapter.number > 1
        ? content.chapters[chapter.number - 2]
        : null;
    final next = chapter.number < content.chapters.length
        ? content.chapters[chapter.number]
        : null;

    return Scaffold(
      appBar: AppBar(title: Text(s.chapterN(chapter.number))),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: verses.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            return ReadableWidth(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            NumberBadge('${chapter.number}', large: true),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hindiUi ? chapter.hindi : chapter.english,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${chapter.sanskrit} · ${s.verseCount(chapter.verseCount)}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: scheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SectionLabel(s.summary),
                        const SizedBox(height: 6),
                        Text(
                          hindiUi
                              ? chapter.summaryHindi
                              : chapter.summaryEnglish,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.55,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => _read(context, verses.first.id),
                          icon: const Icon(Icons.auto_stories_rounded),
                          label: Text(s.startReading),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          final v = verses[i - 1];
          final preview =
              (hindiUi ? v.hindi : v.english) ?? v.sanskrit.split('\n').first;
          return ReadableWidth(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              leading: SizedBox(width: 52, child: NumberBadge(v.id)),
              title: Text(
                preview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
              onTap: () => _read(context, v.id),
            ),
          );
        },
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.navigationBarTheme.backgroundColor,
          border: Border(top: BorderSide(color: scheme.outlineVariant)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: previous == null
                        ? null
                        : () => _openChapter(context, previous),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: Text(
                      previous == null
                          ? s.previousChapter
                          : s.chapterN(previous.number),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: next == null
                        ? null
                        : () => _openChapter(context, next),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    iconAlignment: IconAlignment.end,
                    label: Text(
                      next == null ? s.nextChapter : s.chapterN(next.number),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
