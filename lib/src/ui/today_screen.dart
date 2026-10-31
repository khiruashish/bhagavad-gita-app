import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../daily/daily_plan.dart';
import '../settings/settings_controller.dart';
import 'verse_reader_screen.dart';
import 'widgets/actions.dart';
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
  String? _marked;

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
    if (_marked != verse.id) {
      _marked = verse.id;
      // Counted as read once shown; saved after this frame, not during build.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => settings.markRead(verse.id),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(s.appTitle), actions: mainActions(context)),
      body: VerseView(
        key: ValueKey(verse.id),
        verse: verse,
        footer: _Reflection(verseId: verse.id),
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
    AppScope.stopVerseSpeech(context);
    setState(() => _offset += delta);
  }
}

/// A question to think about, with a private note saved on the phone.
class _Reflection extends StatelessWidget {
  const _Reflection({required this.verseId});

  final String verseId;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.stringsOf(context);
    final settings = AppScope.settingsOf(context);
    final content = AppScope.contentOf(context);
    final reflection = content.reflectionFor(content.verseById(verseId)!);
    if (reflection == null) return const SizedBox.shrink();
    final hindiUi = settings.language == AppLanguage.hindi;
    final note = settings.notes[verseId];
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.self_improvement_rounded, color: scheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    s.reflect,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                hindiUi ? reflection.hindi : reflection.english,
                style: theme.textTheme.titleMedium?.copyWith(height: 1.4),
              ),
              if (note != null) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(note, style: theme.textTheme.bodyMedium),
                ),
              ],
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => editNote(context, verseId),
                  icon: Icon(
                    note == null ? Icons.edit_note_rounded : Icons.edit_rounded,
                  ),
                  label: Text(note == null ? s.writeNote : s.editNote),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
