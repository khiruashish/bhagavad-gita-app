import 'package:flutter_test/flutter_test.dart';
import 'package:gita_for_everyone/src/audio/verse_speaker.dart';

import 'helpers.dart';

void main() {
  testWidgets(
    'Day 1 shows the first verse in Sanskrit, Hindi and English with a simple meaning',
    (tester) async {
      useTallPhone(tester);
      final app = await buildApp(clock: () => DateTime(2026, 1, 1, 9));
      await tester.pumpWidget(app.widget);
      await tester.pumpAndSettle();

      expect(find.text('Day 1'), findsOneWidget);
      expect(find.text('Chapter 1 · Verse 1'), findsOneWidget);
      expect(find.textContaining('धर्मक्षेत्रे कुरुक्षेत्रे'), findsOneWidget);
      expect(
        find.textContaining('Dhritarashtra said: Sanjaya, tell me'),
        findsOneWidget,
      );
      expect(
        find.textContaining('धृतराष्ट्र ने कहा: संजय, बताओ'),
        findsOneWidget,
      );
      expect(find.text('In simple words'), findsOneWidget);
    },
  );

  testWidgets(
    'the next calendar day shows the next verse, and earlier days stay reachable',
    (tester) async {
      var now = DateTime(2026, 1, 1, 9);
      useTallPhone(tester);
      final app = await buildApp(clock: () => now);
      now = DateTime(2026, 1, 2, 7);
      await tester.pumpWidget(app.widget);
      await tester.pumpAndSettle();

      expect(find.text('Day 2'), findsOneWidget);
      expect(find.text('Chapter 1 · Verse 2'), findsOneWidget);

      await tester.tap(find.text('Previous day'));
      await tester.pumpAndSettle();
      expect(find.text('Day 1'), findsOneWidget);
      expect(find.text('Previous day'), findsNothing);

      await tester.tap(find.text('Back to today'));
      await tester.pumpAndSettle();
      expect(find.text('Day 2'), findsOneWidget);
    },
  );

  testWidgets(
    'listen buttons read the right language, and a missing voice is explained',
    (tester) async {
      useTallPhone(tester);
      final app = await buildApp(clock: () => DateTime(2026, 1, 1));
      await tester.pumpWidget(app.widget);
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Listen').first);
      await tester.pump();
      expect(app.speaker.spoken.single.$2, SpeechLanguage.sanskrit);
      expect(find.byTooltip('Stop'), findsOneWidget);

      await tester.tap(find.byTooltip('Stop'));
      await tester.pump();
      app.speaker.voiceInstalled = false;
      await tester.tap(find.byTooltip('Listen').at(1));
      await tester.pump();
      expect(find.textContaining('No voice for this language'), findsOneWidget);
    },
  );

  testWidgets('switching the app to Hindi changes the interface text', (
    tester,
  ) async {
    useTallPhone(tester);
    final app = await buildApp(clock: () => DateTime(2026, 1, 1));
    await tester.pumpWidget(app.widget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('हिन्दी'));
    await tester.pumpAndSettle();
    expect(find.text('सेटिंग्स'), findsWidgets);

    await tester.tap(find.text('आज'));
    await tester.pumpAndSettle();
    expect(find.text('दिन 1'), findsOneWidget);
  });

  testWidgets('chapters open and verses swipe', (tester) async {
    useTallPhone(tester);
    final app = await buildApp(clock: () => DateTime(2026, 1, 1));
    await tester.pumpWidget(app.widget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Chapters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Knowledge of the Self'));
    await tester.pumpAndSettle();
    expect(find.text('About this chapter'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('2.10'), 300);
    await tester.tap(find.text('2.10'));
    await tester.pumpAndSettle();
    expect(find.text('Chapter 2 · Verse 10'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Chapter 2 · Verse 11'), findsOneWidget);
  });

  testWidgets(
    'a verse without a translation yet shows the Sanskrit and says so',
    (tester) async {
      useTallPhone(tester);
      final firstUntranslated = realContent.verses.firstWhere(
        (v) => !v.isTranslated,
      );
      final app = await buildApp(clock: () => DateTime(2026, 1, 1));
      await tester.pumpWidget(app.widget);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Chapters'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.text(realContent.chapters[firstUntranslated.chapter - 1].english),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(firstUntranslated.id));
      await tester.pumpAndSettle();
      expect(
        find.text('Translation coming in a future update.'),
        findsOneWidget,
      );
      expect(
        find.textContaining(firstUntranslated.sanskrit.split('\n').first),
        findsOneWidget,
      );
    },
  );

  testWidgets('the Start here tab explains the Gita in plain words', (
    tester,
  ) async {
    useTallPhone(tester);
    final app = await buildApp(clock: () => DateTime(2026, 1, 1));
    await tester.pumpWidget(app.widget);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start here'));
    await tester.pumpAndSettle();
    expect(find.text('What is the Bhagavad Gita?'), findsOneWidget);
    expect(find.text('Key words'), findsOneWidget);
  });
}
