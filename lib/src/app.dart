import 'package:flutter/material.dart';

import 'app_scope.dart';
import 'ui/home_shell.dart';

const _saffron = Color(0xFFE07A1F);

class GitaApp extends StatelessWidget {
  const GitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.settingsOf(context);
    return MaterialApp(
      title: AppScope.stringsOf(context).appTitle,
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      builder: (context, child) {
        // Respect the phone's own text size, then apply the in-app setting on top.
        final media = MediaQuery.of(context);
        final system = media.textScaler.scale(1);
        return MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(system * settings.textScale),
          ),
          child: child!,
        );
      },
      home: const HomeShell(),
    );
  }

  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _saffron,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: brightness == Brightness.light
          ? const Color(0xFFFFFBF5)
          : scheme.surface,
      cardTheme: const CardThemeData(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
    );
  }
}
