import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../content/models.dart';
import '../settings/settings_controller.dart';
import 'widgets/actions.dart';
import 'widgets/layout.dart';
import 'widgets/verse_card.dart';

/// Well-known verses, grouped by chapter, with a chapter filter.
class QuotesScreen extends StatefulWidget {
  const QuotesScreen({super.key});

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  /// The chapter shown, or null for all chapters.
  int? _chapter;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.stringsOf(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.quotes), actions: mainActions(context)),
      body: _byChapter(context),
    );
  }

  Widget _byChapter(BuildContext context) {
    final s = AppScope.stringsOf(context);
    final hindiUi = AppScope.settingsOf(context).language == AppLanguage.hindi;
    final content = AppScope.contentOf(context);
    final theme = Theme.of(context);

    final groups = <int, List<Quote>>{};
    for (final q in content.quotes) {
      if (_chapter == null || q.verse.chapter == _chapter) {
        groups.putIfAbsent(q.verse.chapter, () => []).add(q);
      }
    }
    final available = {for (final q in content.quotes) q.verse.chapter};

    return Column(
      children: [
        SizedBox(
          height: 60,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            children: [
              for (final c in [null, ...available])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c == null ? s.allChapters : '$c'),
                    selected: _chapter == c,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _chapter = c),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              for (final MapEntry(key: number, value: quotes) in groups.entries)
                ReadableWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 12, 4, 10),
                        child: Row(
                          children: [
                            NumberBadge('$number'),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                hindiUi
                                    ? content.chapters[number - 1].hindi
                                    : content.chapters[number - 1].english,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              s.quoteCount(quotes.length),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      for (final q in quotes)
                        VerseCard(
                          verse: q.verse,
                          topic: hindiUi ? q.topicHindi : q.topicEnglish,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
