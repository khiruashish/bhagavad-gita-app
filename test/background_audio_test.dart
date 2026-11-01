import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gita_for_everyone/src/audio/background_audio.dart';

import 'helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('gita/audio');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  /// Sends a button press from the lock screen / notification to the app.
  Future<void> press(String action) async {
    await messenger.handlePlatformMessage(
      channel.name,
      channel.codec.encodeMethodCall(MethodCall('action', action)),
      (_) {},
    );
  }

  testWidgets('tells the platform what is playing, and obeys its buttons', (
    tester,
  ) async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

    final app = await buildApp(clock: () => DateTime(2026, 1, 1));
    final audio = BackgroundAudio(app.player, app.settings, realContent)
      ..start();
    addTearDown(audio.dispose);

    await app.player.playChapter(1);
    await tester.pump();
    final update = calls.last;
    expect(update.method, 'update');
    final state = update.arguments as Map;
    expect(state['title'], 'Chapter 1 · Verse 1 of 47');
    expect(state['subtitle'], "Arjuna's Despair");
    expect(state['playing'], isTrue);
    expect(state['hasPrevious'], isFalse);
    expect(state['hasNext'], isTrue);

    // Lock-screen pause, next verse and play reach the player.
    await press('pause');
    expect(app.player.isPlaying, isFalse);
    expect((calls.last.arguments as Map)['playing'], isFalse);
    await press('next');
    expect(app.player.currentVerse!.id, '1.2');
    expect((calls.last.arguments as Map)['title'], 'Chapter 1 · Verse 2 of 47');
    await press('play');
    expect(app.player.isPlaying, isTrue);

    // Nothing is re-sent when nothing changed.
    final count = calls.length;
    await app.settings.toggleBookmark('2.47');
    expect(calls.length, count);

    await press('stop');
    expect(app.player.isOpen, isFalse);
    expect(calls.last.method, 'stop');
  });
}
