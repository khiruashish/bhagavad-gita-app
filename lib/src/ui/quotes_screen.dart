import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../content/models.dart';
import '../settings/settings_controller.dart';
import 'share/share_sheet.dart';
import 'share/wallpaper_sheet.dart';
import 'verse_reader_screen.dart';
import 'widgets/actions.dart';
import 'widgets/layout.dart';

/// Every quote in the app in one feed, filterable by chapter. Each can be
/// saved, shared as a picture or set as the phone's wallpaper.
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
    final all = AppScope.contentOf(context).allQuotes;
    final shown = [
      for (final q in all)
        if (_chapter == null || q.verse.chapter == _chapter) q,
    ];
    final chapters = {for (final q in all) q.verse.chapter};
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(s.quotes), actions: mainActions(context)),
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              children: [
                for (final c in [null, ...chapters])
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
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: shown.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return ReadableWidth(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
                      child: Text(
                        _chapter == null
                            ? s.quoteCount(shown.length)
                            : '${s.chapterN(_chapter!)} · ${s.quoteCount(shown.length)}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }
                final entry = shown[i - 1];
                return ReadableWidth(
                  child: QuoteFeedCard(
                    entry: entry,
                    // A gentle rotation of colours down the feed.
                    style: WallpaperStyle
                        .all[entry.verse.number % WallpaperStyle.all.length],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// A large quote card in the feed.
class QuoteFeedCard extends StatelessWidget {
  const QuoteFeedCard({super.key, required this.entry, required this.style});

  final QuoteEntry entry;
  final WallpaperStyle style;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.stringsOf(context);
    final hindiUi = AppScope.settingsOf(context).language == AppLanguage.hindi;
    final theme = Theme.of(context);
    final verse = entry.verse;
    final text = hindiUi ? entry.hindi : entry.english;
    final saved = AppScope.settingsOf(context).isBookmarked(verse.id);

    Widget action(IconData icon, String label, VoidCallback onPressed) =>
        IconButton(
          tooltip: label,
          icon: Icon(icon, color: style.ink),
          onPressed: onPressed,
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: style.colors,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 8, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: style.ink.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  hindiUi ? entry.labelHindi : entry.labelEnglish,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: style.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  '“$text”',
                  style:
                      (text.length > 160
                              ? theme.textTheme.titleMedium
                              : theme.textTheme.titleLarge)
                          ?.copyWith(color: style.ink, height: 1.45),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  verse.sanskrit.split('\n').first,
                  style: sanskritStyle(theme.textTheme.bodyMedium)
                      ?.copyWith(color: style.accent, height: 1.5),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '— ${s.verseOf(verse.chapter, verse.number)}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: style.accent,
                      ),
                    ),
                  ),
                  action(
                    saved
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    saved ? s.unsave : s.save,
                    () => AppScope.settingsOf(context).toggleBookmark(verse.id),
                  ),
                  action(
                    Icons.share_rounded,
                    s.share,
                    () => showShareSheet(
                      context,
                      verse,
                      quote: EmotionQuote(
                        verse: verse,
                        english: entry.english,
                        hindi: entry.hindi,
                      ),
                    ),
                  ),
                  action(
                    Icons.wallpaper_rounded,
                    s.setAsWallpaper,
                    () => showWallpaperSheet(context, entry),
                  ),
                  action(
                    Icons.menu_book_rounded,
                    s.openVerse,
                    () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            VerseReaderScreen(initialVerseId: verse.id),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
