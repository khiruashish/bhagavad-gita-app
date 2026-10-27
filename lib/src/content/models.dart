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

/// Everything the app shows, parsed from the bundled `assets/content/gita.json`.
class GitaContent {
  GitaContent({
    required this.chapters,
    required this.verses,
    required this.learn,
    required this.glossary,
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
  final Map<String, Verse> _byId;

  Verse? verseById(String id) => _byId[id];

  List<Verse> versesOf(int chapter) => [
    for (final v in verses)
      if (v.chapter == chapter) v,
  ];

  factory GitaContent.parse(String source) {
    final j = jsonDecode(source) as Map<String, dynamic>;
    final learn = j['learn'] as Map<String, dynamic>;
    return GitaContent(
      chapters: [
        for (final c in j['chapters'] as List)
          Chapter.fromJson(c as Map<String, dynamic>),
      ],
      verses: [
        for (final v in j['verses'] as List)
          Verse.fromJson(v as Map<String, dynamic>),
      ],
      learn: [
        for (final s in learn['sections'] as List)
          LearnSection.fromJson(s as Map<String, dynamic>),
      ],
      glossary: [
        for (final g in learn['glossary'] as List)
          GlossaryEntry.fromJson(g as Map<String, dynamic>),
      ],
    );
  }
}
