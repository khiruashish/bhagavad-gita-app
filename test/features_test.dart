import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gita_for_everyone/src/release_info.dart';
import 'package:gita_for_everyone/src/settings/settings_controller.dart';
import 'package:gita_for_everyone/src/ui/search_screen.dart';
import 'package:gita_for_everyone/src/widget/widget_feed.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

Future<TestApp> _start(
  WidgetTester tester, {
  Map<String, Object>? prefs,
}) async {
  useTallPhone(tester);
  final app = await buildApp(
    prefs: prefs ?? const {},
    clock: () => DateTime(2026, 1, 1, 9),
  );
  await tester.pumpWidget(app.widget);
  await tester.pumpAndSettle();
  return app;
}

void main() {
  group('settings', () {
    test('bookmarks, reading progress and notes persist', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final s = SettingsController(prefs);
      await s.toggleBookmark('2.47');
      await s.toggleBookmark('10.8');
      await s.toggleBookmark('2.7');
      await s.toggleBookmark('10.8');
      await s.recordOpened('3.5');
      await s.markRead('2.10');
      await s.setNote('2.47', '  Do the work.  ');
      await s.setNote('1.1', 'temporary');
      await s.setNote('1.1', '   ');

      final again = SettingsController(prefs);
      expect(again.bookmarks, {'2.7', '2.47'});
      expect(prefs.getStringList('bookmarks'), ['2.7', '2.47']);
      expect(again.readIds, {'2.10', '3.5'});
      expect(again.lastReadId, '3.5');
      expect(again.notes, {'2.47': 'Do the work.'});

      await again.clearReadingProgress();
      expect(again.readIds, isEmpty);
      expect(again.bookmarks, hasLength(2));
    });
  });

  group('search', () {
    test('ignores case and Sanskrit diacritics', () {
      expect(foldForSearch('Karmaṇyevādhikāraste'), 'karmanyevadhikaraste');
      final hits = searchVerses(realContent.verses, 'karmanyeva').toList();
      expect(hits.map((v) => v.id), contains('2.47'));
      // Matches in the meaning come before matches only in the Sanskrit.
      final karma = searchVerses(realContent.verses, 'karma');
      expect(karma.first.id, isNot('1.15'));
      expect(karma.map((v) => v.id), contains('1.15'));
    });

    test('needs every word, and searches Hindi too', () {
      final both = searchVerses(realContent.verses, 'anger desire').toList();
      expect(both, isNotEmpty);
      for (final v in both) {
        final text = '${v.english} ${v.simpleEnglish}'.toLowerCase();
        expect(text, allOf(contains('anger'), contains('desire')));
      }
      expect(searchVerses(realContent.verses, 'क्रोध'), isNotEmpty);
    });

    testWidgets('a verse number jumps straight to the verse', (tester) async {
      await _start(tester);
      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '2 47');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Go to verse 2.47'));
      await tester.pumpAndSettle();
      expect(find.text('Chapter 2 · Verse 47'), findsOneWidget);
    });

    testWidgets('words list matching verses', (tester) async {
      await _start(tester);
      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'lotus leaf');
      await tester.pumpAndSettle();
      expect(find.textContaining('lotus leaf'), findsWidgets);
      expect(find.text('— Chapter 5 · Verse 10'), findsOneWidget);
    });
  });

  testWidgets('a saved verse appears in My verses', (tester) async {
    final app = await _start(tester);
    await tester.tap(find.byTooltip('Save verse'));
    await tester.pumpAndSettle();
    expect(app.settings.bookmarks, {'1.1'});
    expect(find.byTooltip('Remove from saved'), findsOneWidget);

    await tester.tap(find.byTooltip('My verses'));
    await tester.pumpAndSettle();
    expect(find.text('— Chapter 1 · Verse 1'), findsOneWidget);
    await tester.tap(find.text('My notes'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Notes you write'), findsOneWidget);
  });

  testWidgets('the daily verse has a reflection question and a private note', (
    tester,
  ) async {
    final app = await _start(tester);
    expect(
      find.text(
        realContent.reflectionFor(realContent.verseById('1.1')!)!.english,
      ),
      findsOneWidget,
    );
    await tester.ensureVisible(find.text('Write a note'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Write a note'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Start with courage.');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(app.settings.notes, {'1.1': 'Start with courage.'});
    expect(find.text('Start with courage.'), findsOneWidget);
    expect(find.text('Edit note'), findsOneWidget);
  });

  testWidgets('verses read show a tick and chapter progress', (tester) async {
    final app = await _start(
      tester,
      prefs: {
        'read': ['2.1', '2.2', '2.3'],
      },
    );
    expect(app.settings.readIds, contains('1.1')); // the daily verse counts
    await tester.tap(find.text('Chapters'));
    await tester.pumpAndSettle();
    expect(find.text('3 of 72 read'), findsOneWidget);
    expect(find.text('1 of 47 read'), findsOneWidget);
    await tester.tap(find.text('Knowledge of the Self'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle_rounded), findsNWidgets(3));
  });

  testWidgets('About shows credits and what is still to be added', (
    tester,
  ) async {
    await _start(tester);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('About & credits'), 200);
    await tester.tap(find.text('About & credits'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Sanskrit text: public domain'), findsOneWidget);
    expect(find.textContaining('Noto Serif Devanagari'), findsOneWidget);
    if (missingReleaseInfo.isNotEmpty) {
      expect(find.textContaining('To be added'), findsWidgets);
    }
  });

  test('the version shown in the app matches pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(
      r'^version:\s*([\d.]+)\+',
      multiLine: true,
    ).firstMatch(pubspec)![1];
    expect(appVersion, version);
    // Not a failure: a reminder of what the owner still has to fill in.
    if (missingReleaseInfo.isNotEmpty) {
      // ignore: avoid_print
      print('Release info still to add: ${missingReleaseInfo.join(', ')}');
    }
  });

  group('home-screen widget feed', () {
    test('lists the next 30 daily verses in the reader\'s language', () async {
      SharedPreferences.setMockInitialValues({'startDate': '2026-01-01'});
      final prefs = await SharedPreferences.getInstance();
      final settings = SettingsController(
        prefs,
        clock: () => DateTime(2026, 1, 3, 22),
      );
      final feed = WidgetFeed(settings, realContent);
      final entries = feed.entries();
      expect(entries, hasLength(WidgetFeed.days));
      expect(entries.first['date'], '2026-01-03');
      expect(entries.first['title'], 'Day 3 · 1.3');
      expect(entries[1]['date'], '2026-01-04');
      expect(
        entries.every(
          (e) => (e['text'] as String).length <= WidgetFeed.maxTextLength,
        ),
        isTrue,
      );

      await feed.update();
      final stored = jsonDecode(prefs.getString('widget_days')!) as List;
      expect(stored, hasLength(WidgetFeed.days));

      await settings.setLanguage(AppLanguage.hindi);
      expect(feed.entries().first['title'], 'दिन 3 · 1.3');
    });
  });

  testWidgets('main screens meet accessibility guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await _start(tester);
    for (final tab in ['Today', 'Chapters', 'Quotes', 'Settings']) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
    }
    handle.dispose();
  });
}
