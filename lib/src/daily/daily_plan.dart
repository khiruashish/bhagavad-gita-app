import '../content/models.dart';

/// Day 1 is the day the reader started; each new calendar day shows the next verse.
class DailyPlan {
  const DailyPlan(this.verses);

  /// The verses in the daily sequence (translated verses, in reading order).
  final List<Verse> verses;

  /// 1-based day number of [today] counted from [start], using calendar dates only
  /// so that time zones and daylight-saving changes never skip or repeat a day.
  static int dayNumber(DateTime start, DateTime today) {
    final a = DateTime.utc(start.year, start.month, start.day);
    final b = DateTime.utc(today.year, today.month, today.day);
    final days = b.difference(a).inDays;
    return days < 0 ? 1 : days + 1;
  }

  /// The verse for [day]. After the last verse the sequence starts again from the first.
  Verse verseForDay(int day) => verses[(day - 1) % verses.length];
}
