import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_scope.dart';
import '../../audio/verse_speaker.dart';
import '../../content/models.dart';
import '../../settings/settings_controller.dart';
import 'layout.dart';
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
    final scheme = theme.colorScheme;
    final speaker = verse.speaker;
    final simple = hindiUi ? verse.simpleHindi : verse.simpleEnglish;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        ReadableWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ?header,
              Row(
                children: [
                  NumberBadge(verse.id),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.verseOf(verse.chapter, verse.number),
                          style: theme.textTheme.titleSmall,
                        ),
                        if (speaker != null)
                          Text(
                            hindiUi ? speaker.hindi : speaker.english,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: s.copy,
                    icon: const Icon(Icons.copy_rounded),
                    onPressed: () => _copy(context),
                  ),
                ],
              ),
              if (verse.isDraft)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 2),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          s.draftNotice,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              _SanskritCard(
                verse: verse,
                showTransliteration: settings.showTransliteration,
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
                // Readers see the translation in their app language first.
                for (final hindi in hindiUi ? [true, false] : [false, true])
                  _Translation(
                    title: hindi ? s.hindiLabel : s.englishLabel,
                    prefix: hindi ? speaker?.hindi : speaker?.english,
                    text: hindi ? verse.hindi! : verse.english!,
                    listenId: '${verse.id}-${hindi ? 'hi' : 'en'}',
                    language: hindi
                        ? SpeechLanguage.hindi
                        : SpeechLanguage.english,
                  ),
                if (simple != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Card(
                      color: scheme.tertiaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline_rounded,
                                  size: 20,
                                  color: scheme.onTertiaryContainer,
                                ),
                                const SizedBox(width: 8),
                                SectionLabel(
                                  s.simpleMeaning,
                                  color: scheme.onTertiaryContainer,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              simple,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                height: 1.6,
                                color: scheme.onTertiaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
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

class _SanskritCard extends StatelessWidget {
  const _SanskritCard({required this.verse, required this.showTransliteration});

  final Verse verse;
  final bool showTransliteration;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.stringsOf(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final speaker = verse.speaker;
    final ink = scheme.onPrimaryContainer;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primaryContainer,
            Color.alphaBlend(
              scheme.tertiaryContainer.withValues(alpha: 0.45),
              scheme.primaryContainer,
            ),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 12, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: SectionLabel(s.sanskrit, color: ink)),
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
                  color: ink.withValues(alpha: 0.8),
                ),
              ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SelectableText(
                verse.sanskrit,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  height: 1.9,
                  fontWeight: FontWeight.w600,
                  color: ink,
                ),
              ),
            ),
            if (showTransliteration) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 16, 48, 12),
                child: Divider(color: ink.withValues(alpha: 0.25)),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Column(
                  children: [
                    Text(
                      s.transliteration,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: ink.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      [
                        if (speaker != null) speaker.iast,
                        verse.iast,
                      ].join('\n'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                        height: 1.6,
                        color: ink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
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
      padding: const EdgeInsets.only(top: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 8, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: SectionLabel(title)),
                  ListenButton(id: listenId, text: full, language: language),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: SelectableText(
                  full,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
