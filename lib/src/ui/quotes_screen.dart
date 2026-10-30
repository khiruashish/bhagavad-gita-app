import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_scope.dart';
import '../content/models.dart';
import '../settings/settings_controller.dart';
import 'verse_reader_screen.dart';
import 'widgets/layout.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(s.quotes),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
                  for (final q in quotes) _QuoteCard(quote: q),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard({required this.quote});

  final Quote quote;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.stringsOf(context);
    final hindiUi = AppScope.settingsOf(context).language == AppLanguage.hindi;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final verse = quote.verse;
    final text = (hindiUi ? verse.hindi : verse.english)!;
    final sanskritLine = verse.sanskrit.split('\n').first;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 8, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.format_quote_rounded, color: scheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hindiUi ? quote.topicHindi : quote.topicEnglish,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  text,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  sanskritLine,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '— ${s.verseOf(verse.chapter, verse.number)}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: s.copy,
                    icon: const Icon(Icons.copy_rounded, size: 20),
                    onPressed: () => _copy(context, text),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            VerseReaderScreen(initialVerseId: verse.id),
                      ),
                    ),
                    child: Text(s.openVerse),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _copy(BuildContext context, String text) async {
    final s = AppScope.stringsOf(context);
    await Clipboard.setData(
      ClipboardData(text: '$text\n\n— Bhagavad Gita ${quote.verse.id}'),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(s.copied)));
    }
  }
}
