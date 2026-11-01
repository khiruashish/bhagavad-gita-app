import 'dart:math';

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../content/models.dart';
import '../settings/settings_controller.dart';
import 'widgets/actions.dart';
import 'widgets/layout.dart';
import 'widgets/verse_card.dart';

/// The Feelings tab: the best Gita quotes for how you feel right now.
class FeelingsScreen extends StatefulWidget {
  const FeelingsScreen({super.key});

  @override
  State<FeelingsScreen> createState() => _FeelingsScreenState();
}

class _FeelingsScreenState extends State<FeelingsScreen> {
  /// Index into all quotes for "A thought for you"; null picks one for today.
  int? _thought;
  final _random = Random();

  @override
  Widget build(BuildContext context) {
    final s = AppScope.stringsOf(context);
    final settings = AppScope.settingsOf(context);
    final hindiUi = settings.language == AppLanguage.hindi;
    final emotions = AppScope.contentOf(context).emotions;
    final theme = Theme.of(context);
    final all = [for (final e in emotions) ...e.quotes];
    final today = settings.today;
    final index = all.isEmpty
        ? null
        : (_thought ?? (today.year * 400 + today.month * 32 + today.day)) %
              all.length;

    Widget group(String title, bool hard) => Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: SectionLabel(title),
          ),
          LayoutBuilder(
            builder: (context, box) {
              final columns = box.maxWidth > 560 ? 3 : 2;
              final width = (box.maxWidth - 10 * (columns - 1)) / columns;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final e in emotions)
                    if (e.isHard == hard)
                      SizedBox(
                        width: width,
                        child: _EmotionTile(
                          emotion: e,
                          title: hindiUi ? e.titleHindi : e.titleEnglish,
                        ),
                      ),
                ],
              );
            },
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(s.feelings), actions: mainActions(context)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          ReadableWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (index != null)
                  _ThoughtCard(
                    quote: all[index],
                    onAnother: () => setState(() {
                      var next = _random.nextInt(all.length);
                      if (all.length > 1 && next == index) {
                        next = (next + 1) % all.length;
                      }
                      _thought = next;
                    }),
                  ),
                const SizedBox(height: 20),
                Text(
                  s.howAreYouFeeling,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s.feelingsHint,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                group(s.whenItIsHard, true),
                group(s.whenYouWantToGrow, false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "A thought for you": one quote, with a button for another.
class _ThoughtCard extends StatelessWidget {
  const _ThoughtCard({required this.quote, required this.onAnother});

  final EmotionQuote quote;
  final VoidCallback onAnother;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.stringsOf(context);
    final hindiUi = AppScope.settingsOf(context).language == AppLanguage.hindi;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      color: scheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: scheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SectionLabel(
                    s.thoughtForYou,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                TextButton.icon(
                  onPressed: onAnother,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(s.anotherThought),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                '“${hindiUi ? quote.hindi : quote.english}”',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: scheme.onPrimaryContainer,
                  height: 1.4,
                ),
              ),
            ),
            QuoteActions(quote: quote, color: scheme.onPrimaryContainer),
          ],
        ),
      ),
    );
  }
}

class _EmotionTile extends StatelessWidget {
  const _EmotionTile({required this.emotion, required this.title});

  final Emotion emotion;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => EmotionScreen(emotion: emotion)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
          child: Row(
            children: [
              ExcludeSemantics(
                child: Text(
                  emotion.emoji,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
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

/// The best quotes for one emotion.
class EmotionScreen extends StatelessWidget {
  const EmotionScreen({super.key, required this.emotion});

  final Emotion emotion;

  @override
  Widget build(BuildContext context) {
    final hindiUi = AppScope.settingsOf(context).language == AppLanguage.hindi;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(hindiUi ? emotion.titleHindi : emotion.titleEnglish),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          ReadableWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: scheme.secondaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        ExcludeSemantics(
                          child: Text(
                            emotion.emoji,
                            style: const TextStyle(fontSize: 34),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            hindiUi ? emotion.introHindi : emotion.introEnglish,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: scheme.onSecondaryContainer,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                for (final q in emotion.quotes) EmotionQuoteCard(quote: q),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
