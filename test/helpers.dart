import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gita_for_everyone/src/app.dart';
import 'package:gita_for_everyone/src/app_scope.dart';
import 'package:gita_for_everyone/src/audio/chapter_player.dart';
import 'package:gita_for_everyone/src/audio/verse_speaker.dart';
import 'package:gita_for_everyone/src/content/models.dart';
import 'package:gita_for_everyone/src/settings/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The real bundled content, read from disk (tests run from the package root).
final realContent = GitaContent.parse(
  File(GitaContent.assetPath).readAsStringSync(),
);

class FakeSpeaker implements VerseSpeaker {
  final spoken = <(String, SpeechLanguage)>[];
  bool voiceInstalled = true;
  final _speaking = ValueNotifier<String?>(null);

  @override
  ValueListenable<String?> get speaking => _speaking;

  @override
  Future<bool> speak(
    String id,
    String text,
    SpeechLanguage language, {
    required bool slow,
  }) async {
    if (!voiceInstalled) return false;
    spoken.add((text, language));
    _speaking.value = id;
    return true;
  }

  @override
  Future<void> stop() async => _speaking.value = null;

  /// Simulates the current sentence coming to an end.
  void finish() => _speaking.value = null;
}

class TestApp {
  TestApp(this.widget, this.settings, this.speaker, this.player);

  final Widget widget;
  final SettingsController settings;
  final FakeSpeaker speaker;
  final ChapterPlayer player;
}

/// Builds the app with in-memory preferences and a controllable clock.
Future<TestApp> buildApp({
  Map<String, Object> prefs = const {},
  DateTime Function()? clock,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final settings = SettingsController(
    await SharedPreferences.getInstance(),
    clock: clock,
  );
  final speaker = FakeSpeaker();
  final player = ChapterPlayer(
    speaker: speaker,
    content: realContent,
    settings: settings,
  );
  return TestApp(
    AppScope(
      content: realContent,
      settings: settings,
      speaker: speaker,
      player: player,
      child: const GitaApp(),
    ),
    settings,
    speaker,
    player,
  );
}

/// A tall phone screen (400 x 1600 logical pixels) so a whole verse fits without scrolling.
void useTallPhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 4800);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}
