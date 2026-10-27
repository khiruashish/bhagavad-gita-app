import 'package:flutter_test/flutter_test.dart';
import 'package:gita_for_everyone/src/daily/daily_plan.dart';

import 'helpers.dart';

void main() {
  test('day number counts calendar days from the start, starting at 1', () {
    final start = DateTime(2026, 3, 1, 23, 59);
    expect(DailyPlan.dayNumber(start, DateTime(2026, 3, 1, 0, 1)), 1);
    expect(DailyPlan.dayNumber(start, DateTime(2026, 3, 2, 0, 0)), 2);
    expect(DailyPlan.dayNumber(start, DateTime(2026, 4, 1)), 32);
  });

  test(
    'daylight-saving changes and clocks set backwards never break the count',
    () {
      expect(
        DailyPlan.dayNumber(DateTime(2026, 3, 28), DateTime(2026, 3, 30)),
        3,
      );
      expect(
        DailyPlan.dayNumber(DateTime(2026, 10, 24), DateTime(2026, 10, 26)),
        3,
      );
      expect(
        DailyPlan.dayNumber(DateTime(2026, 5, 10), DateTime(2026, 5, 1)),
        1,
      );
    },
  );

  test('day 1 is verse 1.1, day 2 is 1.2, and the sequence wraps after the last verse', () {
    final plan = DailyPlan(realContent.dailyVerses);
    expect(plan.verseForDay(1).id, '1.1');
    expect(plan.verseForDay(2).id, '1.2');
    expect(plan.verseForDay(48).id, '2.1');
    final n = realContent.dailyVerses.length;
    expect(plan.verseForDay(n + 1).id, '1.1');
  });
}
