import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../content/models.dart';
import '../settings/settings_controller.dart';
import 'situation_screen.dart';
import 'widgets/actions.dart';
import 'widgets/layout.dart';
import 'widgets/verse_card.dart';

/// Two ways in: verses for how you feel, or well-known verses by chapter.
class QuotesScreen extends StatefulWidget {
  const QuotesScreen({super.key});

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  var _bySituation = true;

  /// The chapter shown in the "By chapter" view, or null for all chapters.
  int? _chapter;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.stringsOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.quotes),
        actions: mainActions(context),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: true,
                    icon: const Icon(Icons.favorite_border_rounded),
                    label: Text(s.forMySituation),
                  ),
                  ButtonSegment(
                    value: false,
                    icon: const Icon(Icons.menu_book_outlined),
                    label: Text(s.byChapter),
                  ),
                ],
                selected: {_bySituation},
                showSelectedIcon: false,
                onSelectionChanged: (v) =>
                    setState(() => _bySituation = v.first),
              ),
            ),
          ),
        ),
      ),
      body: _bySituation ? const _Situations() : _byChapter(context),
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
          height: 52,
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

class _Situations extends StatelessWidget {
  const _Situations();

  @override
  Widget build(BuildContext context) {
    final s = AppScope.stringsOf(context);
    final hindiUi = AppScope.settingsOf(context).language == AppLanguage.hindi;
    final situations = AppScope.contentOf(context).situations;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        ReadableWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                s.howAreYouFeeling,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                s.situationHint,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, box) {
                  final columns = box.maxWidth > 560 ? 3 : 2;
                  final width = (box.maxWidth - 12 * (columns - 1)) / columns;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final sit in situations)
                        SizedBox(
                          width: width,
                          child: _SituationTile(
                            situation: sit,
                            title: hindiUi ? sit.titleHindi : sit.titleEnglish,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SituationTile extends StatelessWidget {
  const _SituationTile({required this.situation, required this.title});

  final Situation situation;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SituationScreen(situation: situation),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
                child: Icon(situationIcon(situation.id), size: 22),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 44,
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
