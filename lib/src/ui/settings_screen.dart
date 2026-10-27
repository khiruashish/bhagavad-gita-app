import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../settings/settings_controller.dart';

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
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.restart_alt_rounded),
            title: Text(s.restart),
            onTap: () => _confirmRestart(context),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: Text(s.about),
            subtitle: Text(s.aboutBody),
            isThreeLine: true,
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

  Future<void> _confirmRestart(BuildContext context) async {
    final s = AppScope.stringsOf(context);
    final settings = AppScope.settingsOf(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.restart),
        content: Text(s.restartConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(s.confirm),
          ),
        ],
      ),
    );
    if (ok == true) await settings.restartFromDayOne();
  }
}
