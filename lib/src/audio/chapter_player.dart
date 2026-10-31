import 'dart:async';

import 'package:flutter/foundation.dart';

import '../content/models.dart';
import '../settings/settings_controller.dart';
import 'verse_speaker.dart';

/// One spoken piece of a verse: its Sanskrit, or its translation.
class AudioPart {
  const AudioPart(this.id, this.text, this.language);

  final String id;
  final String text;
  final SpeechLanguage language;
}

/// Plays a whole chapter aloud, verse after verse, until paused, stopped or the
/// chapter ends. Pausing stops the current sentence; continuing starts that
/// sentence again.
///
/// It drives the shared [VerseSpeaker] and moves on when the speaker falls
/// silent. If something else starts speaking (a Listen button), it pauses.
class ChapterPlayer extends ChangeNotifier {
  ChapterPlayer({
    required this.speaker,
    required this.content,
    required this.settings,
    this.gap = const Duration(milliseconds: 700),
  }) {
    speaker.speaking.addListener(_onSpeaking);
  }

  final VerseSpeaker speaker;
  final GitaContent content;
  final SettingsController settings;

  /// Pause between sentences, so verses do not run into each other.
  final Duration gap;

  int? _chapter;
  List<Verse> _verses = const [];
  int _index = 0;
  int _part = 0;
  bool _playing = false;
  bool _finished = false;
  bool _noVoice = false;
  bool _starting = false;
  String? _spokenId;
  Timer? _gapTimer;

  /// The chapter loaded in the player, or null when it is closed.
  int? get chapter => _chapter;
  bool get isOpen => _chapter != null;
  bool get isPlaying => _playing;

  /// True after the last verse of the chapter has been read.
  bool get isFinished => _finished;

  /// True when playback stopped because no voice is installed.
  bool get noVoice => _noVoice;
  int get verseCount => _verses.length;

  /// 0-based position of the current verse in the chapter.
  int get index => _index;
  Verse? get currentVerse => isOpen ? _verses[_index] : null;

  /// The part being read now, or null between parts.
  AudioPart? get currentPart {
    final verse = currentVerse;
    if (verse == null) return null;
    final parts = partsOf(verse);
    return _part < parts.length ? parts[_part] : null;
  }

  /// The pieces read for [verse] under the current settings.
  List<AudioPart> partsOf(Verse verse) {
    final mode = settings.chapterAudioMode;
    final hindi = settings.language == AppLanguage.hindi;
    final speaker = verse.speaker;
    return [
      if (mode != ChapterAudioMode.meaningOnly || !verse.isTranslated)
        AudioPart(
          '${verse.id}-sa',
          speaker == null
              ? verse.sanskrit
              : '${speaker.sanskrit}\n${verse.sanskrit}',
          SpeechLanguage.sanskrit,
        ),
      if (mode != ChapterAudioMode.sanskritOnly && verse.isTranslated)
        AudioPart(
          '${verse.id}-${hindi ? 'hi' : 'en'}',
          [
            if (speaker != null) hindi ? speaker.hindi : speaker.english,
            hindi ? verse.hindi! : verse.english!,
          ].join(': '),
          hindi ? SpeechLanguage.hindi : SpeechLanguage.english,
        ),
    ];
  }

  /// Starts [chapter] from the verse at [startIndex] (0-based).
  Future<void> playChapter(int chapter, {int startIndex = 0}) async {
    _chapter = chapter;
    _verses = content.versesOf(chapter);
    _index = startIndex.clamp(0, _verses.length - 1);
    _part = 0;
    _finished = false;
    _noVoice = false;
    _playing = true;
    notifyListeners();
    await _speakCurrent();
  }

  Future<void> pause() async {
    if (!_playing) return;
    _playing = false;
    _gapTimer?.cancel();
    _spokenId = null;
    notifyListeners();
    await speaker.stop();
  }

  /// Continues after a pause, or plays the next chapter once this one is done.
  Future<void> resume() async {
    if (!isOpen) return;
    if (_finished) {
      final next = _chapter! < content.chapters.length ? _chapter! + 1 : 1;
      await playChapter(next);
      return;
    }
    _playing = true;
    _noVoice = false;
    notifyListeners();
    await _speakCurrent();
  }

  Future<void> togglePlay() => _playing ? pause() : resume();

  Future<void> nextVerse() => _jumpTo(_index + 1);

  /// Moves playback to [verseId] if it is in the loaded chapter.
  Future<void> goToVerse(String verseId) async {
    final i = _verses.indexWhere((v) => v.id == verseId);
    if (i >= 0) await _jumpTo(i);
  }

  Future<void> previousVerse() => _jumpTo(_index - 1);

  /// Stops and closes the player.
  Future<void> close() async {
    _gapTimer?.cancel();
    final wasOpen = isOpen;
    _playing = false;
    _chapter = null;
    _spokenId = null;
    _verses = const [];
    if (wasOpen) notifyListeners();
    await speaker.stop();
  }

  Future<void> _jumpTo(int index) async {
    if (!isOpen || index < 0 || index >= _verses.length) return;
    _gapTimer?.cancel();
    _index = index;
    _part = 0;
    _finished = false;
    _saveProgress();
    notifyListeners();
    if (_playing) {
      await _speakCurrent();
    } else {
      _spokenId = null;
      await speaker.stop();
    }
  }

  Future<void> _speakCurrent() async {
    if (!_playing || !isOpen) return;
    final part = currentPart;
    if (part == null) return _advance();
    if (_part == 0) _saveProgress();
    _starting = true;
    final ok = await speaker.speak(
      part.id,
      part.text,
      part.language,
      slow: settings.slowSpeech,
    );
    _starting = false;
    if (!_playing) return;
    if (!ok) {
      _playing = false;
      _noVoice = true;
      notifyListeners();
      return;
    }
    _spokenId = part.id;
    // A very short sentence may already have finished.
    if (speaker.speaking.value == null) _scheduleNext();
  }

  void _onSpeaking() {
    if (_starting || !_playing || _spokenId == null) return;
    final now = speaker.speaking.value;
    if (now == null) {
      _scheduleNext();
    } else if (now != _spokenId) {
      // Another Listen button took over the voice.
      _playing = false;
      _spokenId = null;
      _gapTimer?.cancel();
      notifyListeners();
    }
  }

  void _scheduleNext() {
    _spokenId = null;
    _gapTimer?.cancel();
    _gapTimer = Timer(gap, _advance);
  }

  void _advance() {
    if (!_playing || !isOpen) return;
    final parts = partsOf(_verses[_index]);
    if (_part + 1 < parts.length) {
      _part++;
    } else if (_index + 1 < _verses.length) {
      _index++;
      _part = 0;
    } else {
      _playing = false;
      _finished = true;
      settings.setAudioPosition(null);
      notifyListeners();
      return;
    }
    notifyListeners();
    _speakCurrent();
  }

  void _saveProgress() {
    final verse = currentVerse;
    if (verse == null) return;
    settings.setAudioPosition(verse.id);
    settings.markRead(verse.id);
  }

  @override
  void dispose() {
    _gapTimer?.cancel();
    speaker.speaking.removeListener(_onSpeaking);
    super.dispose();
  }
}
