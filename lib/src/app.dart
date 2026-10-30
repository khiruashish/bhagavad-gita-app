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
    final light = brightness == Brightness.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: _saffron,
      brightness: brightness,
    );
    final background = light ? const Color(0xFFFFFBF5) : scheme.surface;
    final base = ThemeData(colorScheme: scheme, brightness: brightness);
    return base.copyWith(
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 1,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        color: light ? Colors.white : scheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: light ? Colors.white : scheme.surfaceContainer,
        indicatorColor: scheme.primaryContainer,
        height: 68,
      ),
      listTileTheme: const ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.5),
        space: 1,
      ),
    );
  }
}
