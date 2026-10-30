import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../settings/settings_controller.dart';
import 'chapter_screen.dart';
import 'verse_reader_screen.dart';
import 'widgets/layout.dart';

class ChaptersScreen extends StatelessWidget {
  const ChaptersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.stringsOf(context);
    final settings = AppScope.settingsOf(context);
    final hindiUi = settings.language == AppLanguage.hindi;
    final content = AppScope.contentOf(context);
    final chapters = content.chapters;
    final lastRead = settings.lastReadId == null
        ? null
        : content.verseById(settings.lastReadId!);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(s.chapters)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          if (lastRead != null)
            ReadableWidth(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  color: scheme.primaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
                    leading: Icon(
                      Icons.bookmark_rounded,
                      color: scheme.onPrimaryContainer,
                    ),
                    title: Text(
                      s.continueReading,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      s.verseOf(lastRead.chapter, lastRead.number),
                      style: TextStyle(color: scheme.onPrimaryContainer),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_rounded,
                      color: scheme.onPrimaryContainer,
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            VerseReaderScreen(initialVerseId: lastRead.id),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          for (final c in chapters)
            ReadableWidth(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChapterScreen(chapter: c),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                      child: Row(
                        children: [
                          NumberBadge('${c.number}', large: true),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hindiUi ? c.hindi : c.english,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  c.sanskrit,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: scheme.primary,
                                  ),
                                ),
                                Text(
                                  s.verseCount(c.verseCount),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: scheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
