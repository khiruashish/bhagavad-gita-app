import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../daily/daily_plan.dart';
import 'verse_reader_screen.dart';
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

    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(s.appTitle)),
      body: VerseView(
        key: ValueKey(verse.id),
        verse: verse,
        header: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Card(
            color: scheme.secondaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 8, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.wb_sunny_rounded,
                        color: scheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          s.day(day),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: scheme.onSecondaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: s.readChapter,
                        icon: const Icon(Icons.auto_stories_rounded),
                        color: scheme.onSecondaryContainer,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                VerseReaderScreen(initialVerseId: verse.id),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 4,
                    children: [
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
                ],
              ),
            ),
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
