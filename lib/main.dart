import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app.dart';
import 'src/app_scope.dart';
import 'src/audio/verse_speaker.dart';
import 'src/content/models.dart';
import 'src/settings/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final (source, prefs) = await (
    rootBundle.loadString(GitaContent.assetPath),
    SharedPreferences.getInstance(),
  ).wait;
  runApp(
    AppScope(
      content: GitaContent.parse(source),
      settings: SettingsController(prefs),
      speaker: DeviceVerseSpeaker(),
      child: const GitaApp(),
    ),
  );
}
