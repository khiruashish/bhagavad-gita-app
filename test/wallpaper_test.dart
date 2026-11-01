import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:gita_for_everyone/src/ui/quotes_screen.dart';
import 'package:gita_for_everyone/src/ui/share/wallpaper_sheet.dart';

import 'helpers.dart';

void main() {
  test('every quote in the app appears once, in reading order', () {
    final all = realContent.allQuotes;
    final ids = all.map((q) => q.verse.id).toList();
    expect(ids.toSet().length, ids.length);
    final expected = {
      for (final q in realContent.quotes) q.verse.id,
      for (final e in realContent.emotions)
        for (final q in e.quotes) q.verse.id,
    };
    expect(ids.toSet(), expected);
    final order = [for (final v in realContent.verses) v.id];
    expect(ids, [
      for (final id in order)
        if (expected.contains(id)) id,
    ]);
  });

  testWidgets(
    'a quote becomes a wallpaper at exactly the phone\'s screen size',
    (tester) async {
      useTallPhone(tester); // 1200 x 4800 physical pixels at 3x
      final app = await buildApp(clock: () => DateTime(2026, 1, 1));
      final set = <(Uint8List, WallpaperTarget)>[];
      final original = wallpaperSetter;
      wallpaperSetter = (png, target) async => set.add((png, target));
      addTearDown(() => wallpaperSetter = original);
      await tester.pumpWidget(app.widget);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Quotes'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Set as wallpaper').first);
      await tester.pumpAndSettle();
      expect(find.byType(WallpaperArt), findsOneWidget);
      expect(find.text('Home screen'), findsOneWidget);
      expect(find.text('Lock screen'), findsOneWidget);

      // Pick another colour style, then set it on both screens.
      await tester.tap(find.bySemanticsLabel('Style 3'));
      await tester.pump();
      await tester.runAsync(() async {
        await tester.tap(find.text('Both'));
        await Future<void>.delayed(const Duration(seconds: 2));
      });
      await tester.pumpAndSettle();
      expect(set, hasLength(1));
      expect(set.single.$2, WallpaperTarget.both);
      final image = await tester.runAsync(() async {
        final codec = await ui.instantiateImageCodec(set.single.$1);
        return (await codec.getNextFrame()).image;
      });
      expect(image!.width, 1200);
      expect(image.height, 4800);
      expect(find.text('Wallpaper set'), findsOneWidget);
      expect(find.byType(QuoteFeedCard), findsWidgets);
    },
  );
}
