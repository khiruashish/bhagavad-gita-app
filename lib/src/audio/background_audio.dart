import 'dart:convert';

import 'package:flutter/services.dart';

import '../content/models.dart';
import '../l10n/strings.dart';
import '../settings/settings_controller.dart';
import 'chapter_player.dart';

/// Keeps chapter audio playing with the screen locked, and connects it to the
/// phone's own media controls.
///
/// While a chapter is loaded it tells the platform what is playing:
/// - Android (ChapterAudioService.kt): a media-playback foreground service with
///   a notification and lock-screen controls, holding the CPU awake only while
///   audio plays.
/// - iOS (AppDelegate.swift): Now Playing info and lock-screen controls; the
///   app's "audio" background mode keeps speech going.
///
/// Presses on those controls come back as `action` calls and drive the player.
class BackgroundAudio {
  BackgroundAudio(
    this._player,
    this._settings,
    this._content, {
    MethodChannel? channel,
  }) : _channel = channel ?? const MethodChannel('gita/audio');

  final ChapterPlayer _player;
  final SettingsController _settings;
  final GitaContent _content;
  final MethodChannel _channel;
  String? _lastSent;

  void start() {
    _channel.setMethodCallHandler(_onCall);
    _player.addListener(_sync);
    _settings.addListener(_sync);
  }

  void dispose() {
    _player.removeListener(_sync);
    _settings.removeListener(_sync);
    _channel.setMethodCallHandler(null);
  }

  /// What the notification and lock screen should show now; null when closed.
  Map<String, Object>? state() {
    final verse = _player.currentVerse;
    if (verse == null) return null;
    final s = Strings.of(_settings.language);
    final chapter = _content.chapters[verse.chapter - 1];
    return {
      'title': s.nowPlaying(verse.chapter, verse.number, _player.verseCount),
      'subtitle': _settings.language == AppLanguage.hindi
          ? chapter.hindi
          : chapter.english,
      'album': s.appTitle,
      'playing': _player.isPlaying,
      'hasPrevious': _player.index > 0,
      'hasNext': _player.index + 1 < _player.verseCount,
      'labels': {
        'play': s.play,
        'pause': s.pause,
        'previous': s.previousVerse,
        'next': s.nextVerse,
        'stop': s.closePlayer,
        'channel': s.chapterAudioChannel,
      },
    };
  }

  Future<void> _sync() async {
    final now = state();
    final key = now == null ? null : jsonEncode(now);
    if (key == _lastSent) return;
    _lastSent = key;
    try {
      if (now == null) {
        await _channel.invokeMethod<void>('stop');
      } else {
        await _channel.invokeMethod<void>('update', now);
      }
    } on MissingPluginException {
      // Platforms without background audio (web, tests).
    } on PlatformException {
      // Background audio is best effort; playback itself carries on.
    }
  }

  Future<Object?> _onCall(MethodCall call) async {
    if (call.method != 'action') return null;
    switch (call.arguments) {
      case 'play':
        await _player.resume();
      case 'pause':
        await _player.pause();
      case 'toggle':
        await _player.togglePlay();
      case 'next':
        await _player.nextVerse();
      case 'previous':
        await _player.previousVerse();
      case 'stop':
        await _player.close();
    }
    return null;
  }
}
