import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum SpeechLanguage { sanskrit, hindi, english }

/// Reads verse text aloud. The default implementation uses the phone's own
/// text-to-speech voices, so no audio is downloaded and nothing leaves the device.
abstract class VerseSpeaker {
  /// Id of the text currently being spoken, or null when silent.
  ValueListenable<String?> get speaking;

  /// Speaks [text]; returns false when no voice for [language] is installed.
  Future<bool> speak(
    String id,
    String text,
    SpeechLanguage language, {
    required bool slow,
  });

  Future<void> stop();
}

class DeviceVerseSpeaker implements VerseSpeaker {
  DeviceVerseSpeaker() {
    _tts.setCompletionHandler(() => _speaking.value = null);
    // Stopping one sentence to start the next makes the engine report a
    // cancel, sometimes after the next sentence has begun. Those reports are
    // ignored; only a cancel the app did not ask for (say, a phone call)
    // marks the voice as silent.
    _tts.setCancelHandler(() {
      final ownStop = _stoppedAt;
      if (ownStop != null &&
          DateTime.now().difference(ownStop) < const Duration(seconds: 2)) {
        return;
      }
      _speaking.value = null;
    });
    _tts.setErrorHandler((_) => _speaking.value = null);
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      _tts.setSharedInstance(true);
      _tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
        IosTextToSpeechAudioCategoryOptions.duckOthers,
      ]);
    }
  }

  final FlutterTts _tts = FlutterTts();
  final ValueNotifier<String?> _speaking = ValueNotifier(null);
  DateTime? _stoppedAt;

  // Sanskrit is read with a Hindi voice: both use Devanagari and most phones ship one.
  static const _locales = {
    SpeechLanguage.sanskrit: ['hi-IN'],
    SpeechLanguage.hindi: ['hi-IN'],
    SpeechLanguage.english: ['en-IN', 'en-GB', 'en-US'],
  };

  @override
  ValueListenable<String?> get speaking => _speaking;

  @override
  Future<bool> speak(
    String id,
    String text,
    SpeechLanguage language, {
    required bool slow,
  }) async {
    await stop();
    String? locale;
    for (final candidate in _locales[language]!) {
      if (await _tts.isLanguageAvailable(candidate) == true) {
        locale = candidate;
        break;
      }
    }
    if (locale == null) return false;
    await _tts.setLanguage(locale);
    await _tts.setSpeechRate(slow ? 0.38 : 0.5);
    _speaking.value = id;
    await _tts.speak(text);
    return true;
  }

  @override
  Future<void> stop() async {
    _stoppedAt = DateTime.now();
    await _tts.stop();
    _speaking.value = null;
  }
}
