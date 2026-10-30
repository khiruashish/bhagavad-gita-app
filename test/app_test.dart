import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:gita_for_everyone/src/app_scope.dart';
import 'package:gita_for_everyone/src/audio/verse_speaker.dart';
import 'package:gita_for_everyone/src/content/models.dart';
import 'package:gita_for_everyone/src/ui/share/share_sheet.dart';
import 'package:gita_for_everyone/src/ui/widgets/verse_view.dart';

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
    'Next continues into the next chapter, and chapter buttons jump a chapter',
    (tester) async {
      useTallPhone(tester);
      final app = await buildApp(clock: () => DateTime(2026, 1, 1));
      await tester.pumpWidget(app.widget);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Chapters'));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Arjuna's Despair"));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('1.47'), 300);
      await tester.tap(find.text('1.47'));
      await tester.pumpAndSettle();
      expect(find.text('47 / 47'), findsOneWidget);

      // At the last verse of a chapter, Next is labelled with the next chapter.
      await tester.tap(find.text('Chapter 2'));
      await tester.pumpAndSettle();
      expect(find.text('Chapter 2 · Verse 1'), findsOneWidget);

      await tester.tap(find.byTooltip('Next chapter'));
      await tester.pumpAndSettle();
      expect(find.text('Chapter 3 · Verse 1'), findsOneWidget);

      await tester.tap(find.byTooltip('Previous chapter'));
      await tester.pumpAndSettle();
      expect(find.text('Chapter 2 · Verse 1'), findsOneWidget);

      await tester.tap(find.text('Previous'));
      await tester.pumpAndSettle();
      expect(find.text('Chapter 1 · Verse 47'), findsOneWidget);
      expect(app.settings.lastReadId, '1.47');
    },
  );

  testWidgets(
    'a chapter page moves to the next chapter and offers to continue reading',
    (tester) async {
      useTallPhone(tester);
      final app = await buildApp(
        prefs: {'lastRead': '2.47'},
        clock: () => DateTime(2026, 1, 1),
      );
      await tester.pumpWidget(app.widget);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Chapters'));
      await tester.pumpAndSettle();
      expect(find.text('Continue reading'), findsOneWidget);
      await tester.tap(find.text('Continue reading'));
      await tester.pumpAndSettle();
      expect(find.text('Chapter 2 · Verse 47'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Knowledge of the Self'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chapter 3'));
      await tester.pumpAndSettle();
      expect(find.text('The Path of Action'), findsOneWidget);
      await tester.tap(find.text('Start reading'));
      await tester.pumpAndSettle();
      expect(find.text('Chapter 3 · Verse 1'), findsOneWidget);
    },
  );

  testWidgets('the Quotes tab groups well-known verses by chapter', (
    tester,
  ) async {
    useTallPhone(tester);
    final app = await buildApp(clock: () => DateTime(2026, 1, 1));
    await tester.pumpWidget(app.widget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Quotes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('By chapter'));
    await tester.pumpAndSettle();
    expect(find.text('Where the story begins'), findsOneWidget);

    // Filter to chapter 2, then open a quote in the reader.
    await tester.tap(find.widgetWithText(ChoiceChip, '2'));
    await tester.pumpAndSettle();
    expect(find.text('Where the story begins'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Do the work, let go of the result'),
      300,
      scrollable: find.byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      ),
    );
    expect(
      find.textContaining('Your concern is with the doing alone'),
      findsOneWidget,
    );
    final card = find.ancestor(
      of: find.text('Do the work, let go of the result'),
      matching: find.byType(Card),
    );
    final read = find.descendant(of: card, matching: find.text('Read verse'));
    await tester.ensureVisible(read);
    await tester.pumpAndSettle();
    await tester.tap(read);
    await tester.pumpAndSettle();
    expect(find.text('Chapter 2 · Verse 47'), findsOneWidget);
  });

  testWidgets('Gita for my situation lists verses for a feeling', (
    tester,
  ) async {
    useTallPhone(tester);
    final app = await buildApp(clock: () => DateTime(2026, 1, 1));
    await tester.pumpWidget(app.widget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Quotes'));
    await tester.pumpAndSettle();
    expect(find.text('How are you feeling today?'), findsOneWidget);
    await tester.tap(find.text('Angry'));
    await tester.pumpAndSettle();
    expect(find.textContaining('See where anger starts'), findsOneWidget);
    expect(
      find.textContaining('Keep thinking about the things of the senses'),
      findsOneWidget,
    );
    // Each verse comes with its simple meaning.
    expect(find.byIcon(Icons.lightbulb_outline_rounded), findsWidgets);
  });

  testWidgets('a verse can be shared as a picture', (tester) async {
    useTallPhone(tester);
    final app = await buildApp(clock: () => DateTime(2026, 1, 1));
    final shared = <(int, String, String)>[];
    final original = imageSharer;
    imageSharer = (png, name, caption, origin) async =>
        shared.add((png.length, name, caption));
    addTearDown(() => imageSharer = original);
    await tester.pumpWidget(app.widget);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Share'));
    await tester.pumpAndSettle();
    expect(find.text('Share as image'), findsOneWidget);
    expect(find.byType(ShareCard), findsOneWidget);

    await tester.runAsync(() async {
      await tester.tap(find.widgetWithText(FilledButton, 'Share'));
      await Future<void>.delayed(const Duration(seconds: 1));
    });
    await tester.pumpAndSettle();
    expect(shared, hasLength(1));
    expect(shared.single.$1, greaterThan(1000));
    expect(shared.single.$2, 'bhagavad-gita-1-1.png');
    expect(shared.single.$3, endsWith('— Bhagavad Gita 1.1'));
    expect(find.byType(ShareCard), findsNothing);
  });

  testWidgets(
    'a verse without a translation yet shows the Sanskrit and says so',
    (tester) async {
      useTallPhone(tester);
      const untranslated = Verse(
        chapter: 9,
        number: 99,
        sanskrit: 'धर्मक्षेत्रे कुरुक्षेत्रे',
        iast: 'dharmakṣetre kurukṣetre',
      );
      final app = await buildApp(clock: () => DateTime(2026, 1, 1));
      await tester.pumpWidget(
        AppScope(
          content: realContent,
          settings: app.settings,
          speaker: app.speaker,
          child: const MaterialApp(
            home: Scaffold(body: VerseView(verse: untranslated)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Translation coming in a future update.'),
        findsOneWidget,
      );
      expect(find.text('धर्मक्षेत्रे कुरुक्षेत्रे'), findsOneWidget);
      expect(find.text('Hindi'), findsNothing);
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
