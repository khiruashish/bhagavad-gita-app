import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../daily/daily_plan.dart';
import 'widgets/verse_view.dart';

/// The daily verse: Day 1 shows the first verse, Day 2 the next, and so on.
class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  /// 0 shows today; -1 shows yesterday's verse, and so on.
  int _offset = 0;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.stringsOf(context);
    final settings = AppScope.settingsOf(context);
    final plan = DailyPlan(AppScope.contentOf(context).dailyVerses);
    final today = DailyPlan.dayNumber(settings.startDate, settings.today);
    final day = (today + _offset).clamp(1, today);
    final verse = plan.verseForDay(day);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(s.appTitle)),
      body: VerseView(
        key: ValueKey(verse.id),
        verse: verse,
        header: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text(s.day(day), style: theme.textTheme.headlineMedium),
              const Spacer(),
              if (day > 1)
                TextButton.icon(
                  onPressed: () => _move(context, -1),
                  icon: const Icon(Icons.chevron_left_rounded),
                  label: Text(s.previousDay),
                ),
              if (day < today)
                TextButton(
                  onPressed: () => _move(context, -_offset),
                  child: Text(s.backToToday),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _move(BuildContext context, int delta) {
    AppScope.speakerOf(context).stop();
    setState(() => _offset += delta);
  }
}
