import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../release_info.dart';
import 'widgets/actions.dart';
import 'widgets/layout.dart';

/// About the app, credits, licences and contact. Values still to be decided
/// by the owner (lib/src/release_info.dart) show as "To be added".
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.stringsOf(context);
    final theme = Theme.of(context);
    String orTodo(String v) => v.isEmpty ? s.toBeAdded : v;
    Widget section(String title, List<Widget> children) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(title),
              const SizedBox(height: 8),
              ...children,
            ],
          ),
        ),
      ),
    );
    Widget line(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(s.aboutCredits)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          ReadableWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.asset(
                          'assets/icon/icon.png',
                          width: 96,
                          height: 96,
                          semanticLabel: s.appTitle,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(s.appTitle, style: theme.textTheme.titleLarge),
                      Text(
                        '${s.version} $appVersion',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                section(s.about, [line(s.aboutBody)]),
                section(s.credits, [
                  line(s.creditSanskrit),
                  line(s.creditPronunciation),
                  line(s.creditTranslations),
                  line(
                    '${s.creditReviewers}: ${reviewers.isEmpty ? s.toBeAdded : reviewers.join(', ')}',
                  ),
                  if (contributors.isNotEmpty)
                    line('${s.creditContributors}: ${contributors.join(', ')}'),
                  line(s.creditIcon),
                  line(s.creditFont),
                ]),
                section(s.licencesTitle, [
                  line('${s.codeLicenceLabel}: ${orTodo(codeLicence)}'),
                  line('${s.contentLicenceLabel}: ${orTodo(contentLicence)}'),
                  line(orTodo(copyrightHolder)),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => showLicensePage(
                        context: context,
                        applicationName: s.appTitle,
                        applicationVersion: appVersion,
                      ),
                      child: Text(s.licenses),
                    ),
                  ),
                ]),
                section(s.contact, [
                  if (contactEmail.isEmpty)
                    line(s.toBeAdded)
                  else
                    _LinkRow(
                      icon: Icons.mail_outline_rounded,
                      label: contactEmail,
                      url: Uri(scheme: 'mailto', path: contactEmail),
                    ),
                  _LinkRow(
                    icon: Icons.code_rounded,
                    label: s.sourceCode,
                    url: Uri.parse(sourceCodeUrl),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.icon, required this.label, required this.url});

  final IconData icon;
  final String label;
  final Uri url;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon),
    title: Text(label),
    trailing: const Icon(Icons.open_in_new_rounded, size: 18),
    onTap: () => openLink(context, url),
  );
}
