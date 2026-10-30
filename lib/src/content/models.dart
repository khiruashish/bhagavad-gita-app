import 'dart:convert';

/// Who is speaking at the start of a verse, e.g. "Arjuna said".
class Speaker {
  const Speaker({
    required this.sanskrit,
    required this.iast,
    required this.english,
    required this.hindi,
  });

  final String sanskrit;
  final String iast;
  final String english;
  final String hindi;

  factory Speaker.fromJson(Map<String, dynamic> j) => Speaker(
    sanskrit: j['sanskrit'] as String,
    iast: j['iast'] as String,
    english: j['english'] as String,
    hindi: j['hindi'] as String,
  );
}

class Verse {
  const Verse({
    required this.chapter,
    required this.number,
    required this.sanskrit,
    required this.iast,
    this.speaker,
    this.english,
    this.hindi,
    this.simpleEnglish,
    this.simpleHindi,
    this.isDraft = false,
  });

  final int chapter;
  final int number;
  final String sanskrit;
  final String iast;
  final Speaker? speaker;
  final String? english;
  final String? hindi;
  final String? simpleEnglish;
  final String? simpleHindi;

  /// True while the translation has not yet been checked by a reviewer.
  final bool isDraft;

  /// Stable id such as `2.47`.
  String get id => '$chapter.$number';

  bool get isTranslated => english != null && hindi != null;

  factory Verse.fromJson(Map<String, dynamic> j) => Verse(
    chapter: j['chapter'] as int,
    number: j['verse'] as int,
    sanskrit: j['sanskrit'] as String,
    iast: j['iast'] as String,
    speaker: j['speaker'] == null
        ? null
        : Speaker.fromJson(j['speaker'] as Map<String, dynamic>),
    english: j['english'] as String?,
    hindi: j['hindi'] as String?,
    simpleEnglish: j['simpleEnglish'] as String?,
    simpleHindi: j['simpleHindi'] as String?,
    isDraft: j['status'] == 'draft',
  );
}

class Chapter {
  const Chapter({
    required this.number,
    required this.sanskrit,
    required this.english,
    required this.hindi,
    required this.summaryEnglish,
    required this.summaryHindi,
    required this.verseCount,
  });

  final int number;
  final String sanskrit;
  final String english;
  final String hindi;
  final String summaryEnglish;
  final String summaryHindi;
  final int verseCount;

  factory Chapter.fromJson(Map<String, dynamic> j) => Chapter(
    number: j['number'] as int,
    sanskrit: j['sanskrit'] as String,
    english: j['english'] as String,
    hindi: j['hindi'] as String,
    summaryEnglish: j['summaryEnglish'] as String,
    summaryHindi: j['summaryHindi'] as String,
    verseCount: j['verseCount'] as int,
  );
}

class LearnSection {
  const LearnSection({
    required this.titleEnglish,
    required this.titleHindi,
    required this.bodyEnglish,
    required this.bodyHindi,
  });

  final String titleEnglish;
  final String titleHindi;
  final String bodyEnglish;
  final String bodyHindi;

  factory LearnSection.fromJson(Map<String, dynamic> j) => LearnSection(
    titleEnglish: j['titleEnglish'] as String,
    titleHindi: j['titleHindi'] as String,
    bodyEnglish: j['bodyEnglish'] as String,
    bodyHindi: j['bodyHindi'] as String,
  );
}

class GlossaryEntry {
  const GlossaryEntry({
    required this.term,
    required this.termHindi,
    required this.english,
    required this.hindi,
  });

  final String term;
  final String termHindi;
  final String english;
  final String hindi;

  factory GlossaryEntry.fromJson(Map<String, dynamic> j) => GlossaryEntry(
    term: j['term'] as String,
    termHindi: j['termHindi'] as String,
    english: j['english'] as String,
    hindi: j['hindi'] as String,
  );
}

/// A well-known verse picked for the Quotes tab, with a short topic line.
class Quote {
  const Quote({
    required this.verse,
    required this.topicEnglish,
    required this.topicHindi,
  });

  final Verse verse;
  final String topicEnglish;
  final String topicHindi;
}

/// A short, memorable line written from one verse, for the Feelings tab.
class EmotionQuote {
  const EmotionQuote({
    required this.verse,
    required this.english,
    required this.hindi,
  });

  final Verse verse;
  final String english;
  final String hindi;
}

/// A human emotion with the verses that speak to it most.
class Emotion {
  const Emotion({
    required this.id,
    required this.emoji,
    required this.isHard,
    required this.titleEnglish,
    required this.titleHindi,
    required this.introEnglish,
    required this.introHindi,
    required this.quotes,
  });

  final String id;
  final String emoji;

  /// True for difficult feelings; false for those a reader wants to grow.
  final bool isHard;
  final String titleEnglish;
  final String titleHindi;
  final String introEnglish;
  final String introHindi;
  final List<EmotionQuote> quotes;
}

/// A question to think about after reading a verse.
class Reflection {
  const Reflection({required this.english, required this.hindi});

  final String english;
  final String hindi;
}

/// Everything the app shows, parsed from the bundled `assets/content/gita.json`.
class GitaContent {
  GitaContent({
    required this.chapters,
    required this.verses,
    required this.learn,
    required this.glossary,
    this.quotes = const [],
    this.emotions = const [],
    this.reflections = const {},
  }) : dailyVerses = [
         for (final v in verses)
           if (v.isTranslated) v,
       ],
       _byId = {for (final v in verses) v.id: v};

  static const assetPath = 'assets/content/gita.json';

  final List<Chapter> chapters;

  /// All 701 verses in reading order.
  final List<Verse> verses;

  /// Verses with a translation, in reading order: the daily sequence.
  final List<Verse> dailyVerses;
  final List<LearnSection> learn;
  final List<GlossaryEntry> glossary;

  /// Well-known verses in reading order, for the Quotes tab.
  final List<Quote> quotes;

  /// The Feelings tab: emotions with their best quotes.
  final List<Emotion> emotions;

  /// Reflection questions by chapter number.
  final Map<int, List<Reflection>> reflections;
  final Map<String, Verse> _byId;

  /// The reflection question shown with [verse], rotating through its chapter's
  /// questions; null when the chapter has none.
  Reflection? reflectionFor(Verse verse) {
    final questions = reflections[verse.chapter];
    if (questions == null || questions.isEmpty) return null;
    return questions[(verse.number - 1) % questions.length];
  }

  Verse? verseById(String id) => _byId[id];

  List<Verse> versesOf(int chapter) => [
    for (final v in verses)
      if (v.chapter == chapter) v,
  ];

  factory GitaContent.parse(String source) {
    final j = jsonDecode(source) as Map<String, dynamic>;
    final learn = j['learn'] as Map<String, dynamic>;
    final verses = [
      for (final v in j['verses'] as List)
        Verse.fromJson(v as Map<String, dynamic>),
    ];
    final byId = {for (final v in verses) v.id: v};
    return GitaContent(
      chapters: [
        for (final c in j['chapters'] as List)
          Chapter.fromJson(c as Map<String, dynamic>),
      ],
      verses: verses,
      learn: [
        for (final s in learn['sections'] as List)
          LearnSection.fromJson(s as Map<String, dynamic>),
      ],
      glossary: [
        for (final g in learn['glossary'] as List)
          GlossaryEntry.fromJson(g as Map<String, dynamic>),
      ],
      quotes: [
        for (final q in (j['quotes'] as List?) ?? const [])
          if (byId[(q as Map<String, dynamic>)['id']] case final verse?)
            Quote(
              verse: verse,
              topicEnglish: q['topicEnglish'] as String,
              topicHindi: q['topicHindi'] as String,
            ),
      ],
      emotions: [
        for (final x in (j['emotions'] as List?) ?? const [])
          if (x case final Map<String, dynamic> m)
            Emotion(
              id: m['id'] as String,
              emoji: m['emoji'] as String,
              isHard: m['group'] == 'hard',
              titleEnglish: m['titleEnglish'] as String,
              titleHindi: m['titleHindi'] as String,
              introEnglish: m['introEnglish'] as String,
              introHindi: m['introHindi'] as String,
              quotes: [
                for (final q in m['quotes'] as List)
                  if (byId[(q as Map<String, dynamic>)['verse']]
                      case final verse?)
                    EmotionQuote(
                      verse: verse,
                      english: q['english'] as String,
                      hindi: q['hindi'] as String,
                    ),
              ],
            ),
      ],
      reflections: {
        for (final MapEntry(:key, :value)
            in ((j['reflections'] as Map<String, dynamic>?) ?? const {})
                .entries)
          int.parse(key): [
            for (final q in value as List)
              Reflection(
                english: (q as Map<String, dynamic>)['english'] as String,
                hindi: q['hindi'] as String,
              ),
          ],
      },
    );
  }
}
