import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_scope.dart';
import '../../audio/verse_speaker.dart';
import '../../content/models.dart';
import '../../settings/settings_controller.dart';
import 'listen_button.dart';

/// One verse: Sanskrit, pronunciation, Hindi, English and a simple explanation.
class VerseView extends StatelessWidget {
  const VerseView({super.key, required this.verse, this.header});

  final Verse verse;

  /// Optional widget shown above the verse (e.g. the day number).
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.stringsOf(context);
    final settings = AppScope.settingsOf(context);
    final hindiUi = settings.language == AppLanguage.hindi;
    final theme = Theme.of(context);
    final speaker = verse.speaker;
    final simple = hindiUi ? verse.simpleHindi : verse.simpleEnglish;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        ?header,
        Row(
          children: [
            Expanded(
              child: Text(
                s.verseOf(verse.chapter, verse.number),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            IconButton(
              tooltip: s.copy,
              icon: const Icon(Icons.copy_rounded),
              onPressed: () => _copy(context),
            ),
          ],
        ),
        if (verse.isDraft) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Chip(
              avatar: const Icon(Icons.edit_note_rounded, size: 18),
              label: Text(s.draftNotice),
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Card(
          color: theme.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        s.sanskrit,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    ListenButton(
                      id: '${verse.id}-sa',
                      text: verse.sanskrit,
                      language: SpeechLanguage.sanskrit,
                    ),
                  ],
                ),
                if (speaker != null)
                  Text(
                    speaker.sanskrit,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                const SizedBox(height: 8),
                SelectableText(
                  verse.sanskrit,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    height: 1.8,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                if (settings.showTransliteration) ...[
                  const SizedBox(height: 12),
                  Text(
                    s.transliteration,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    [if (speaker != null) speaker.iast, verse.iast].join('\n'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      height: 1.6,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (!verse.isTranslated)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Text(
              s.comingSoon,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          )
        else ...[
          _Translation(
            title: s.hindiLabel,
            prefix: speaker?.hindi,
            text: verse.hindi!,
            listenId: '${verse.id}-hi',
            language: SpeechLanguage.hindi,
          ),
          _Translation(
            title: s.englishLabel,
            prefix: speaker?.english,
            text: verse.english!,
            listenId: '${verse.id}-en',
            language: SpeechLanguage.english,
          ),
          if (simple != null)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Card(
                color: theme.colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            s.simpleMeaning,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        simple,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Future<void> _copy(BuildContext context) async {
    final s = AppScope.stringsOf(context);
    final text = [
      verse.sanskrit,
      if (verse.hindi != null) verse.hindi!,
      if (verse.english != null) verse.english!,
      '— Bhagavad Gita ${verse.id}',
    ].join('\n\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(s.copied)));
    }
  }
}

class _Translation extends StatelessWidget {
  const _Translation({
    required this.title,
    required this.text,
    required this.listenId,
    required this.language,
    this.prefix,
  });

  final String title;
  final String? prefix;
  final String text;
  final String listenId;
  final SpeechLanguage language;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final full = prefix == null ? text : '$prefix: $text';
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              ListenButton(id: listenId, text: full, language: language),
            ],
          ),
          SelectableText(
            full,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.55),
          ),
        ],
      ),
    );
  }
}
