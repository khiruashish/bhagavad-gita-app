import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  final c = realContent;

  test('all 18 chapters and 701 Sanskrit verses are bundled', () {
    expect(c.chapters, hasLength(18));
    expect(c.verses, hasLength(701));
    expect(c.versesOf(2), hasLength(72));
    expect(
      c.verses.every((v) => v.sanskrit.isNotEmpty && v.iast.isNotEmpty),
      isTrue,
    );
  });

  test('every verse in the daily sequence has both translations and simple meanings', () {
    expect(c.dailyVerses, isNotEmpty);
    for (final v in c.dailyVerses) {
      expect(v.hindi, isNotEmpty, reason: v.id);
      expect(v.english, isNotEmpty, reason: v.id);
      expect(v.simpleEnglish, isNotEmpty, reason: v.id);
      expect(v.simpleHindi, isNotEmpty, reason: v.id);
    }
  });

  test('speaker lines are separated from the verse text', () {
    final first = c.verseById('1.1')!;
    expect(first.speaker!.english, 'Dhritarashtra said');
    expect(first.sanskrit, startsWith('धर्मक्षेत्रे'));
    expect(first.iast, startsWith('dharmakṣetre'));
  });

  test('chapter names and the learn section are present in both languages', () {
    for (final ch in c.chapters) {
      expect(ch.english, isNotEmpty);
      expect(ch.hindi, isNotEmpty);
    }
    expect(c.learn, isNotEmpty);
    expect(c.glossary, isNotEmpty);
  });
}
