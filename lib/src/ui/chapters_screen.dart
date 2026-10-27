import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../settings/settings_controller.dart';
import 'chapter_screen.dart';

class ChaptersScreen extends StatelessWidget {
  const ChaptersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.stringsOf(context);
    final hindiUi = AppScope.settingsOf(context).language == AppLanguage.hindi;
    final chapters = AppScope.contentOf(context).chapters;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.chapters)),
      body: ListView.separated(
        itemCount: chapters.length,
        separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
        itemBuilder: (context, i) {
          final c = chapters[i];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              child: Text('${c.number}'),
            ),
            title: Text(hindiUi ? c.hindi : c.english),
            subtitle: Text('${c.sanskrit} · ${s.verseCount(c.verseCount)}'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ChapterScreen(chapter: c)),
            ),
          );
        },
      ),
    );
  }
}
