import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../content/models.dart';
import '../settings/settings_controller.dart';
import 'widgets/layout.dart';
import 'widgets/verse_card.dart';

/// Icon for each situation in content/situations.json.
IconData situationIcon(String id) => switch (id) {
  'anxious' => Icons.waves_rounded,
  'angry' => Icons.local_fire_department_rounded,
  'grief' => Icons.water_drop_rounded,
  'pressure' => Icons.timer_rounded,
  'failure' => Icons.trending_down_rounded,
  'confused' => Icons.help_outline_rounded,
  'focus' => Icons.center_focus_strong_rounded,
  'lonely' => Icons.person_outline_rounded,
  'comparing' => Icons.compare_arrows_rounded,
  'afraid' => Icons.shield_rounded,
  'proud' => Icons.emoji_events_rounded,
  'lazy' => Icons.bedtime_rounded,
  _ => Icons.spa_rounded,
};

/// Verses for one feeling or situation, each with its simple meaning.
class SituationScreen extends StatelessWidget {
  const SituationScreen({super.key, required this.situation});

  final Situation situation;

  @override
  Widget build(BuildContext context) {
    final hindiUi = AppScope.settingsOf(context).language == AppLanguage.hindi;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final title = hindiUi ? situation.titleHindi : situation.titleEnglish;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          ReadableWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: scheme.secondaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Icon(
                          situationIcon(situation.id),
                          color: scheme.onSecondaryContainer,
                          size: 28,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            hindiUi
                                ? situation.introHindi
                                : situation.introEnglish,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: scheme.onSecondaryContainer,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                for (final v in situation.verses)
                  VerseCard(verse: v, showSimpleMeaning: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
