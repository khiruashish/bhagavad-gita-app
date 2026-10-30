import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_scope.dart';
import '../../content/models.dart';
import '../../settings/settings_controller.dart';
import '../share/share_sheet.dart';
import '../verse_reader_screen.dart';

/// A compact verse for lists: optional topic line, translation, first Sanskrit
/// line, optional simple meaning, and copy / share / read actions.
class VerseCard extends StatelessWidget {
  const VerseCard({
    super.key,
    required this.verse,
    this.topic,
    this.showSimpleMeaning = false,
  });

  final Verse verse;
  final String? topic;
  final bool showSimpleMeaning;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.stringsOf(context);
    final hindiUi = AppScope.settingsOf(context).language == AppLanguage.hindi;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = (hindiUi ? verse.hindi : verse.english)!;
    final simple = hindiUi ? verse.simpleHindi : verse.simpleEnglish;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 8, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (topic != null) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.format_quote_rounded, color: scheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        topic!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  text,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text(
                  verse.sanskrit.split('\n').first,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
              ),
              if (showSimpleMeaning && simple != null)
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 12, 10, 0),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 18,
                        color: scheme.onTertiaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          simple,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                            color: scheme.onTertiaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '— ${s.verseOf(verse.chapter, verse.number)}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: s.copy,
                    icon: const Icon(Icons.copy_rounded, size: 20),
                    onPressed: () => _copy(context, text),
                  ),
                  IconButton(
                    tooltip: s.share,
                    icon: const Icon(Icons.share_rounded, size: 20),
                    onPressed: () => showShareSheet(context, verse),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            VerseReaderScreen(initialVerseId: verse.id),
                      ),
                    ),
                    child: Text(s.openVerse),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _copy(BuildContext context, String text) async {
    final s = AppScope.stringsOf(context);
    await Clipboard.setData(
      ClipboardData(text: '$text\n\n— Bhagavad Gita ${verse.id}'),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(s.copied)));
    }
  }
}
