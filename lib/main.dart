import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app.dart';
import 'src/app_scope.dart';
import 'src/audio/verse_speaker.dart';
import 'src/content/models.dart';
import 'src/settings/settings_controller.dart';
import 'src/widget/widget_feed.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
      'Noto Serif Devanagari',
    ], await rootBundle.loadString('assets/fonts/OFL.txt'));
  });
  final (source, prefs) = await (
    rootBundle.loadString(GitaContent.assetPath),
    SharedPreferences.getInstance(),
  ).wait;
  final content = GitaContent.parse(source);
  final settings = SettingsController(prefs);
  WidgetFeed(settings, content).start();
  runApp(
    AppScope(
      content: content,
      settings: settings,
      speaker: DeviceVerseSpeaker(),
      child: const GitaApp(),
    ),
  );
}
