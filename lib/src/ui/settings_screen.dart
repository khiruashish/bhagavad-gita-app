import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../release_info.dart';
import '../settings/settings_controller.dart';
import 'about_screen.dart';
import 'saved_screen.dart';
import 'widgets/actions.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.stringsOf(context);
    final settings = AppScope.settingsOf(context);
    final theme = Theme.of(context);
    Widget header(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(s.settings)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          header(s.appLanguage),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<AppLanguage>(
              segments: const [
                ButtonSegment(
                  value: AppLanguage.english,
                  label: Text('English'),
                ),
                ButtonSegment(value: AppLanguage.hindi, label: Text('हिन्दी')),
              ],
              selected: {settings.language},
              onSelectionChanged: (v) => settings.setLanguage(v.first),
            ),
          ),
          header(s.theme),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(s.themeSystem),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(s.themeLight),
                ),
                ButtonSegment(value: ThemeMode.dark, label: Text(s.themeDark)),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (v) => settings.setThemeMode(v.first),
            ),
          ),
          header(s.textSize),
          Slider(
            value: settings.textScale,
            min: SettingsController.minTextScale,
            max: SettingsController.maxTextScale,
            divisions: 15,
            label: '${(settings.textScale * 100).round()}%',
            onChanged: settings.setTextScale,
          ),
          SwitchListTile(
            title: Text(s.showPronunciation),
            value: settings.showTransliteration,
            onChanged: settings.setShowTransliteration,
          ),
          SwitchListTile(
            title: Text(s.slowAudio),
            value: settings.slowSpeech,
            onChanged: settings.setSlowSpeech,
          ),
          header(s.chapterAudio),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<ChapterAudioMode>(
              segments: [
                ButtonSegment(
                  value: ChapterAudioMode.sanskritAndMeaning,
                  label: Text(s.audioSanskritAndMeaning),
                ),
                ButtonSegment(
                  value: ChapterAudioMode.sanskritOnly,
                  label: Text(s.audioSanskritOnly),
                ),
                ButtonSegment(
                  value: ChapterAudioMode.meaningOnly,
                  label: Text(s.audioMeaningOnly),
                ),
              ],
              selected: {settings.chapterAudioMode},
              onSelectionChanged: (v) => settings.setChapterAudioMode(v.first),
            ),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.restart_alt_rounded),
            title: Text(s.restart),
            onTap: () => _confirm(
              context,
              title: s.restart,
              body: s.restartConfirm,
              action: s.confirm,
              onConfirm: settings.restartFromDayOne,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.checklist_rounded),
            title: Text(s.resetProgress),
            onTap: () => _confirm(
              context,
              title: s.resetProgress,
              body: s.resetProgressConfirm,
              action: s.clear,
              onConfirm: settings.clearReadingProgress,
            ),
          ),
          header(s.more),
          ListTile(
            leading: const Icon(Icons.favorite_border_rounded),
            title: Text(s.myVerses),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const SavedScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: Text(s.aboutCredits),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const AboutScreen())),
          ),
          if (rateUrl(Theme.of(context).platform) case final url?)
            ListTile(
              leading: const Icon(Icons.star_outline_rounded),
              title: Text(s.rateApp),
              onTap: () => openLink(context, url),
            ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(s.licenses),
            onTap: () =>
                showLicensePage(context: context, applicationName: s.appTitle),
          ),
        ],
      ),
    );
  }

  Future<void> _confirm(
    BuildContext context, {
    required String title,
    required String body,
    required String action,
    required Future<void> Function() onConfirm,
  }) async {
    final s = AppScope.stringsOf(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    );
    if (ok == true) await onConfirm();
  }
}

/// The store page for rating the app, or null where it is not known yet.
Uri? rateUrl(TargetPlatform platform) => switch (platform) {
  TargetPlatform.iOS || TargetPlatform.macOS =>
    appStoreId.isEmpty
        ? null
        : Uri.parse(
            'https://apps.apple.com/app/id$appStoreId?action=write-review',
          ),
  _ => Uri.parse('https://play.google.com/store/apps/details?id=$androidAppId'),
};
