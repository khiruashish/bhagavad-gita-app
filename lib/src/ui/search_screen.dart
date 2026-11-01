import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../content/models.dart';
import 'verse_reader_screen.dart';
import 'widgets/layout.dart';
import 'widgets/verse_card.dart';

/// Finds verses by number ("2.47", "2 47", "2:47") or by words in the English,
/// Hindi, simple meanings or Roman-letter Sanskrit.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  var _query = '';

  static const _maxResults = 100;
  static final _verseNumber = RegExp(r'^\s*(\d{1,2})\s*[.:\s]\s*(\d{1,2})\s*$');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.stringsOf(context);
    final content = AppScope.contentOf(context);
    final theme = Theme.of(context);
    final query = _query.trim();
    final match = _verseNumber.firstMatch(query);
    final jump = match == null
        ? null
        : content.verseById('${int.parse(match[1]!)}.${int.parse(match[2]!)}');
    final found = query.length < 2 || match != null
        ? const <Verse>[]
        : searchVerses(content.verses, query);
    final results = found.take(_maxResults).toList();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: s.searchHint,
            border: InputBorder.none,
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              tooltip: s.clear,
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                _controller.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          ReadableWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (query.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      s.searchTips,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else if (jump != null)
                  Card(
                    color: theme.colorScheme.primaryContainer,
                    child: ListTile(
                      leading: const Icon(Icons.arrow_forward_rounded),
                      title: Text(s.goToVerse(jump.id)),
                      subtitle: Text(s.verseOf(jump.chapter, jump.number)),
                      onTap: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) =>
                              VerseReaderScreen(initialVerseId: jump.id),
                        ),
                      ),
                    ),
                  )
                else if (match != null ||
                    (query.length >= 2 && results.isEmpty))
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(s.noResults, style: theme.textTheme.bodyLarge),
                  )
                else if (results.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                    child: Text(
                      found.length > results.length
                          ? s.firstResults(results.length, found.length)
                          : s.resultCount(results.length),
                      style: theme.textTheme.labelLarge,
                    ),
                  ),
                  for (final v in results) VerseCard(verse: v),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Verses whose text contains every word of [query]. Matches in the
/// translations and simple meanings come first, then matches found only in the
/// Sanskrit or its Roman-letter form, each group in reading order. Matching
/// ignores case and the diacritics of Roman-letter Sanskrit, so "karma" finds
/// "karmaṇy…".
List<Verse> searchVerses(List<Verse> verses, String query) {
  final words = foldForSearch(query)
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return const [];
  bool matches(Iterable<String?> fields) {
    final text = foldForSearch(fields.whereType<String>().join(' '));
    return words.every(text.contains);
  }

  final meaning = <Verse>[];
  final sanskritOnly = <Verse>[];
  for (final v in verses) {
    if (!v.isTranslated) continue;
    if (matches([v.english, v.hindi, v.simpleEnglish, v.simpleHindi])) {
      meaning.add(v);
    } else if (matches([v.iast, v.sanskrit])) {
      sanskritOnly.add(v);
    }
  }
  return [...meaning, ...sanskritOnly];
}

const _diacritics = {
  'ā': 'a', 'ī': 'i', 'ū': 'u', 'ṛ': 'r', 'ṝ': 'r', 'ḷ': 'l', 'ṅ': 'n', //
  'ñ': 'n', 'ṭ': 't', 'ḍ': 'd', 'ṇ': 'n', 'ś': 's', 'ṣ': 's', 'ṃ': 'm',
  'ḥ': 'h', 'm̐': 'm',
};

/// Lower case, with Sanskrit diacritics removed (ā → a, ś → s, ...).
String foldForSearch(String text) {
  var out = text.toLowerCase();
  for (final MapEntry(:key, :value) in _diacritics.entries) {
    out = out.replaceAll(key, value);
  }
  // A combining dot below or above, as some keyboards type it.
  return out.replaceAll(RegExp('[̣̇̐]'), '');
}
