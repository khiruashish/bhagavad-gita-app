import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../content/models.dart';
import '../settings/settings_controller.dart';
import 'verse_reader_screen.dart';

class ChapterScreen extends StatelessWidget {
  const ChapterScreen({super.key, required this.chapter});

  final Chapter chapter;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.stringsOf(context);
    final hindiUi = AppScope.settingsOf(context).language == AppLanguage.hindi;
    final verses = AppScope.contentOf(context).versesOf(chapter.number);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(s.chapterN(chapter.number))),
      body: ListView.builder(
        itemCount: verses.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hindiUi ? chapter.hindi : chapter.english,
                    style: theme.textTheme.headlineSmall,
                  ),
                  Text(
                    chapter.sanskrit,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(s.summary, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    hindiUi ? chapter.summaryHindi : chapter.summaryEnglish,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                ],
              ),
            );
          }
          final v = verses[i - 1];
          final preview =
              (hindiUi ? v.hindi : v.english) ?? v.sanskrit.split('\n').first;
          return ListTile(
            leading: SizedBox(
              width: 44,
              child: Text(v.id, style: theme.textTheme.labelLarge),
            ),
            title: Text(preview, maxLines: 2, overflow: TextOverflow.ellipsis),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    VerseReaderScreen(verses: verses, initialIndex: i - 1),
              ),
            ),
          );
        },
      ),
    );
  }
}
