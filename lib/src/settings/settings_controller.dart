import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { english, hindi }

/// What chapter audio reads for each verse.
enum ChapterAudioMode { sanskritAndMeaning, sanskritOnly, meaningOnly }

/// Reader preferences and reading progress. Stored only on the device.
class SettingsController extends ChangeNotifier {
  SettingsController(this._prefs, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now {
    if (_prefs.getString(_startKey) == null) _saveStart(_clock());
  }

  final SharedPreferences _prefs;
  final DateTime Function() _clock;

  static const _startKey = 'startDate';
  static const minTextScale = 0.85;
  static const maxTextScale = 1.6;

  DateTime get today => _clock();

  /// The calendar day the reader started (Day 1).
  DateTime get startDate => DateTime.parse(_prefs.getString(_startKey)!);

  AppLanguage get language =>
      AppLanguage.values[_prefs.getInt('language') ??
          AppLanguage.english.index];
  ThemeMode get themeMode =>
      ThemeMode.values[_prefs.getInt('themeMode') ?? ThemeMode.system.index];
  double get textScale => _prefs.getDouble('textScale') ?? 1.0;
  bool get showTransliteration => _prefs.getBool('showTransliteration') ?? true;
  bool get slowSpeech => _prefs.getBool('slowSpeech') ?? true;

  ChapterAudioMode get chapterAudioMode =>
      ChapterAudioMode.values[_prefs.getInt('chapterAudioMode') ??
          ChapterAudioMode.sanskritAndMeaning.index];
  Future<void> setChapterAudioMode(ChapterAudioMode v) =>
      _update(() => _prefs.setInt('chapterAudioMode', v.index));

  /// Where chapter audio was last playing, such as "1.12"; null when the
  /// chapter was finished or never played.
  String? get audioPosition => _prefs.getString('audioPosition');
  Future<void> setAudioPosition(String? id) {
    if (id == audioPosition) return Future.value();
    return _update(
      () => id == null
          ? _prefs.remove('audioPosition')
          : _prefs.setString('audioPosition', id),
    );
  }

  /// The verse last opened in the reader, such as "2.47", or null.
  String? get lastReadId => _prefs.getString('lastRead');

  Future<void> setLanguage(AppLanguage v) =>
      _update(() => _prefs.setInt('language', v.index));
  Future<void> setThemeMode(ThemeMode v) =>
      _update(() => _prefs.setInt('themeMode', v.index));
  Future<void> setTextScale(double v) => _update(
    () => _prefs.setDouble(
      'textScale',
      v.clamp(minTextScale, maxTextScale).toDouble(),
    ),
  );
  Future<void> setShowTransliteration(bool v) =>
      _update(() => _prefs.setBool('showTransliteration', v));
  Future<void> setSlowSpeech(bool v) =>
      _update(() => _prefs.setBool('slowSpeech', v));

  /// Verses the reader saved with the heart button.
  Set<String> get bookmarks => {...?_prefs.getStringList('bookmarks')};
  bool isBookmarked(String id) => bookmarks.contains(id);
  Future<void> toggleBookmark(String id) {
    final ids = bookmarks;
    if (!ids.remove(id)) ids.add(id);
    return _update(() => _prefs.setStringList('bookmarks', _sorted(ids)));
  }

  /// Verses opened in the reader or shown as the daily verse.
  Set<String> get readIds => {...?_prefs.getStringList('read')};
  Future<void> markRead(String id) {
    final ids = readIds;
    if (!ids.add(id)) return Future.value();
    return _update(() => _prefs.setStringList('read', _sorted(ids)));
  }

  /// Records a verse opened in the reader: last read, and counted as read.
  Future<void> recordOpened(String id) async {
    final ids = readIds;
    if (id == lastReadId && ids.contains(id)) return;
    ids.add(id);
    await _prefs.setString('lastRead', id);
    await _update(() => _prefs.setStringList('read', _sorted(ids)));
  }

  Future<void> clearReadingProgress() => _update(() => _prefs.remove('read'));

  /// Private notes, by verse id.
  Map<String, String> get notes {
    final raw = _prefs.getString('notes');
    if (raw == null) return {};
    return (jsonDecode(raw) as Map<String, dynamic>).cast<String, String>();
  }

  Future<void> setNote(String id, String text) {
    final all = notes;
    if (text.trim().isEmpty) {
      all.remove(id);
    } else {
      all[id] = text.trim();
    }
    return _update(() => _prefs.setString('notes', jsonEncode(all)));
  }

  /// Sorts verse ids like "2.47" in reading order.
  static List<String> _sorted(Set<String> ids) => ids.toList()
    ..sort((a, b) {
      final x = a.split('.').map(int.parse).toList();
      final y = b.split('.').map(int.parse).toList();
      return x[0] != y[0] ? x[0] - y[0] : x[1] - y[1];
    });

  Future<void> setLastRead(String id) => id == lastReadId
      ? Future.value()
      : _update(() => _prefs.setString('lastRead', id));

  /// Data for the home-screen widget (see WidgetFeed). Written without
  /// notifying listeners: nothing in the app shows it.
  Future<void> setWidgetFeed(String json) =>
      _prefs.setString('widget_days', json);

  /// Makes today Day 1 again.
  Future<void> restartFromDayOne() => _update(() => _saveStart(_clock()));

  Future<bool> _saveStart(DateTime d) {
    final date =
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    return _prefs.setString(_startKey, date);
  }

  Future<void> _update(Future<bool> Function() write) async {
    await write();
    notifyListeners();
  }
}
