import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { english, hindi }

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
