import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gita_for_everyone/src/settings/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('the first launch becomes Day 1 and is remembered', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final first = SettingsController(
      prefs,
      clock: () => DateTime(2026, 1, 5, 21),
    );
    expect(first.startDate, DateTime(2026, 1, 5));
    final later = SettingsController(prefs, clock: () => DateTime(2026, 2, 1));
    expect(later.startDate, DateTime(2026, 1, 5));
  });

  test('restart makes today Day 1', () async {
    SharedPreferences.setMockInitialValues({'startDate': '2025-12-01'});
    final s = SettingsController(
      await SharedPreferences.getInstance(),
      clock: () => DateTime(2026, 1, 9),
    );
    await s.restartFromDayOne();
    expect(s.startDate, DateTime(2026, 1, 9));
  });

  test(
    'preferences have friendly defaults, persist, and text size is clamped',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final s = SettingsController(prefs);
      expect(s.language, AppLanguage.english);
      expect(s.themeMode, ThemeMode.system);
      expect(s.showTransliteration, isTrue);
      await s.setLanguage(AppLanguage.hindi);
      await s.setTextScale(9);
      final again = SettingsController(prefs);
      expect(again.language, AppLanguage.hindi);
      expect(again.textScale, SettingsController.maxTextScale);
    },
  );
}
