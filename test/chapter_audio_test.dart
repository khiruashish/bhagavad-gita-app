import 'package:flutter_test/flutter_test.dart';
import 'package:gita_for_everyone/src/audio/verse_speaker.dart';
import 'package:gita_for_everyone/src/settings/settings_controller.dart';

import 'helpers.dart';

/// Lets the current sentence end and the gap before the next one pass.
Future<void> finishSentence(WidgetTester tester, FakeSpeaker speaker) async {
  speaker.finish();
  await tester.pump(const Duration(seconds: 1));
  await tester.pump();
}

Future<TestApp> openChapterOne(WidgetTester tester) async {
  useTallPhone(tester);
  final app = await buildApp(clock: () => DateTime(2026, 1, 1));
  await tester.pumpWidget(app.widget);
  await tester.pumpAndSettle();
  await tester.tap(find.text('Chapters'));
  await tester.pumpAndSettle();
  await tester.tap(find.text("Arjuna's Despair"));
  await tester.pumpAndSettle();
  return app;
}

void main() {
  testWidgets(
    'a chapter plays verse after verse until paused, then continues',
    (tester) async {
      final app = await openChapterOne(tester);
      final speaker = app.speaker;

      await tester.tap(find.text('Listen to chapter'));
      await tester.pump();
      expect(speaker.spoken.last.$2, SpeechLanguage.sanskrit);
      expect(speaker.spoken.last.$1, startsWith('धृतराष्ट्र उवाच'));
      expect(find.text('Chapter 1 · Verse 1 of 47'), findsOneWidget);

      // Sanskrit, then the meaning in the app language, then the next verse.
      await finishSentence(tester, speaker);
      expect(speaker.spoken.last.$2, SpeechLanguage.english);
      expect(speaker.spoken.last.$1, startsWith('Dhritarashtra said: Sanjaya'));
      await finishSentence(tester, speaker);
      expect(speaker.spoken.last.$2, SpeechLanguage.sanskrit);
      expect(find.text('Chapter 1 · Verse 2 of 47'), findsOneWidget);

      // Pause: the voice stops and nothing more is read.
      await tester.tap(find.bySemanticsLabel('Pause').first);
      await tester.pump();
      expect(app.player.isPlaying, isFalse);
      expect(speaker.speaking.value, isNull);
      final count = speaker.spoken.length;
      await tester.pump(const Duration(seconds: 2));
      expect(speaker.spoken.length, count);
      expect(find.textContaining('Paused'), findsOneWidget);

      // Continue: verse 2 is read again from its start.
      await tester.tap(find.bySemanticsLabel('Play').first);
      await tester.pump();
      expect(app.player.isPlaying, isTrue);
      expect(speaker.spoken.length, count + 1);
      expect(speaker.spoken.last.$1, speaker.spoken[count - 1].$1);

      await tester.tap(find.bySemanticsLabel('Next verse'));
      await tester.pump();
      expect(find.text('Chapter 1 · Verse 3 of 47'), findsOneWidget);
      expect(app.settings.audioPosition, '1.3');
      expect(app.settings.readIds, containsAll(['1.1', '1.2', '1.3']));

      await tester.tap(find.bySemanticsLabel('Stop and close'));
      await tester.pump();
      expect(app.player.isOpen, isFalse);
      expect(find.text('Chapter 1 · Verse 3 of 47'), findsNothing);
    },
  );

  testWidgets('the chapter page offers to continue where listening stopped', (
    tester,
  ) async {
    useTallPhone(tester);
    final app = await buildApp(
      prefs: {'audioPosition': '1.12'},
      clock: () => DateTime(2026, 1, 1),
    );
    await tester.pumpWidget(app.widget);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chapters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Arjuna's Despair"));
    await tester.pumpAndSettle();

    expect(find.text('Start over'), findsOneWidget);
    await tester.tap(find.text('Continue from verse 12'));
    await tester.pump();
    expect(find.text('Chapter 1 · Verse 12 of 47'), findsOneWidget);
    await app.player.close();
  });

  testWidgets('at the end of a chapter it stops, and Play starts the next', (
    tester,
  ) async {
    final app = await openChapterOne(tester);
    await app.player.playChapter(1, startIndex: 46);
    await tester.pump();
    await finishSentence(tester, app.speaker);
    await finishSentence(tester, app.speaker);
    expect(app.player.isFinished, isTrue);
    expect(app.player.isPlaying, isFalse);
    expect(app.settings.audioPosition, isNull);
    expect(find.textContaining('Chapter complete'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Play next chapter'));
    await tester.pump();
    expect(app.player.chapter, 2);
    expect(find.text('Chapter 2 · Verse 1 of 72'), findsOneWidget);
    await app.player.close();
  });

  testWidgets('a single Listen button pauses chapter audio', (tester) async {
    final app = await openChapterOne(tester);
    await tester.tap(find.text('Listen to chapter'));
    await tester.pump();
    await app.speaker.speak(
      '2.47-en',
      'Your concern is with the doing alone',
      SpeechLanguage.english,
      slow: false,
    );
    await tester.pump();
    expect(app.player.isPlaying, isFalse);
    expect(app.player.isOpen, isTrue);
    await app.player.close();
  });

  testWidgets('chapter audio can read the Sanskrit only', (tester) async {
    final app = await openChapterOne(tester);
    await app.settings.setChapterAudioMode(ChapterAudioMode.sanskritOnly);
    await tester.tap(find.text('Listen to chapter'));
    await tester.pump();
    await finishSentence(tester, app.speaker);
    expect(app.speaker.spoken.map((e) => e.$2), [
      SpeechLanguage.sanskrit,
      SpeechLanguage.sanskrit,
    ]);
    expect(find.text('Chapter 1 · Verse 2 of 47'), findsOneWidget);
    await app.player.close();
  });

  testWidgets('the reader follows the verse being played', (tester) async {
    final app = await openChapterOne(tester);
    await tester.tap(find.text('Listen to chapter'));
    await tester.pump();
    // Tapping the player bar opens the verse being read.
    await tester.tap(find.text('Chapter 1 · Verse 1 of 47'));
    await tester.pumpAndSettle();
    expect(find.text('Chapter 1 · Verse 1'), findsOneWidget);

    await finishSentence(tester, app.speaker);
    await finishSentence(tester, app.speaker);
    await tester.pumpAndSettle();
    expect(find.text('Chapter 1 · Verse 2'), findsOneWidget);
    expect(app.player.isPlaying, isTrue);
    await app.player.close();
  });
}
