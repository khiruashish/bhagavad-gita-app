import 'dart:convert';

import 'package:flutter/services.dart';

import '../content/models.dart';
import '../daily/daily_plan.dart';
import '../settings/settings_controller.dart';

/// Keeps the home-screen widget's data up to date.
///
/// The Android widget (GitaWidgetProvider.kt) cannot run Dart, so the app
/// writes the next [days] daily verses, in the reader's language, to
/// preferences. The widget picks today's entry by date, so it keeps working for
/// a month even if the app is not opened.
class WidgetFeed {
  WidgetFeed(this._settings, this._content, {MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('gita/widget');

  static const days = 30;
  static const maxTextLength = 240;

  final SettingsController _settings;
  final GitaContent _content;
  final MethodChannel _channel;
  String? _lastWritten;

  /// Writes the feed now and again whenever settings change.
  void start() {
    update();
    _settings.addListener(update);
  }

  Future<void> update() async {
    final json = jsonEncode(entries());
    if (json == _lastWritten) return;
    _lastWritten = json;
    await _settings.setWidgetFeed(json);
    try {
      await _channel.invokeMethod<void>('refresh');
    } on MissingPluginException {
      // iOS (no widget yet) and tests.
    } on PlatformException {
      // A widget refresh is best effort.
    }
  }

  /// One entry per day from today: date, day number, verse id and text.
  List<Map<String, Object>> entries() {
    final verses = _content.dailyVerses;
    if (verses.isEmpty) return const [];
    final plan = DailyPlan(verses);
    final hindi = _settings.language == AppLanguage.hindi;
    final today = _settings.today;
    return [
      for (var i = 0; i < days; i++)
        () {
          final date = DateTime(today.year, today.month, today.day + i);
          final day = DailyPlan.dayNumber(_settings.startDate, date);
          final verse = plan.verseForDay(day);
          var text = (hindi ? verse.hindi : verse.english)!;
          if (text.length > maxTextLength) {
            text = '${text.substring(0, maxTextLength - 1).trimRight()}…';
          }
          return {
            'date': _isoDate(date),
            'title': hindi
                ? 'दिन $day · ${verse.id}'
                : 'Day $day · ${verse.id}',
            'text': text,
          };
        }(),
    ];
  }

  static String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
