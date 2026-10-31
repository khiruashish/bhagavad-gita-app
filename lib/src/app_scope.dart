import 'package:flutter/widgets.dart';

import 'audio/chapter_player.dart';
import 'audio/verse_speaker.dart';
import 'content/models.dart';
import 'l10n/strings.dart';
import 'settings/settings_controller.dart';

/// Makes the content, settings and speaker available to every screen.
/// Widgets that read [settingsOf] rebuild when a setting changes.
class AppScope extends InheritedNotifier<SettingsController> {
  const AppScope({
    super.key,
    required this.content,
    required SettingsController settings,
    required this.speaker,
    this.player,
    required super.child,
  }) : super(notifier: settings);

  final GitaContent content;
  final VerseSpeaker speaker;

  /// Plays whole chapters aloud; shared so playback continues across screens.
  final ChapterPlayer? player;

  static AppScope _of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!;

  static GitaContent contentOf(BuildContext context) => _of(context).content;
  static VerseSpeaker speakerOf(BuildContext context) => _of(context).speaker;
  static ChapterPlayer playerOf(BuildContext context) => _of(context).player!;
  static ChapterPlayer? maybePlayerOf(BuildContext context) =>
      _of(context).player;

  /// Stops a single verse being read aloud, but leaves chapter audio playing.
  static void stopVerseSpeech(BuildContext context) {
    if (maybePlayerOf(context)?.isPlaying ?? false) return;
    speakerOf(context).stop();
  }

  static SettingsController settingsOf(BuildContext context) =>
      _of(context).notifier!;
  static Strings stringsOf(BuildContext context) =>
      Strings.of(settingsOf(context).language);
}
