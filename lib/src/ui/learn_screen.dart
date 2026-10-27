import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../settings/settings_controller.dart';

/// Plain-language introduction for readers who are new to the Gita.
class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.stringsOf(context);
    final hindiUi = AppScope.settingsOf(context).language == AppLanguage.hindi;
    final content = AppScope.contentOf(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.learn)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          for (final section in content.learn) ...[
            Card(
              child: ExpansionTile(
                initiallyExpanded: section == content.learn.first,
                title: Text(
                  hindiUi ? section.titleHindi : section.titleEnglish,
                  style: theme.textTheme.titleMedium,
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hindiUi ? section.bodyHindi : section.bodyEnglish,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.55),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
            child: Text(s.glossary, style: theme.textTheme.titleLarge),
          ),
          for (final g in content.glossary)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              title: Text(
                '${g.term} · ${g.termHindi}',
                style: theme.textTheme.titleSmall,
              ),
              subtitle: Text(
                hindiUi ? g.hindi : g.english,
                style: theme.textTheme.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }
}
