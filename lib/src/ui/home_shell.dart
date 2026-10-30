import 'package:flutter/material.dart';

import '../app_scope.dart';
import 'chapters_screen.dart';
import 'learn_screen.dart';
import 'quotes_screen.dart';
import 'settings_screen.dart';
import 'today_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _tabs = [
    TodayScreen(),
    ChaptersScreen(),
    QuotesScreen(),
    LearnScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final s = AppScope.stringsOf(context);
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          AppScope.speakerOf(context).stop();
          setState(() => _index = i);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.wb_sunny_outlined),
            selectedIcon: const Icon(Icons.wb_sunny),
            label: s.today,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: s.chapters,
          ),
          NavigationDestination(
            icon: const Icon(Icons.format_quote_outlined),
            selectedIcon: const Icon(Icons.format_quote),
            label: s.quotes,
          ),
          NavigationDestination(
            icon: const Icon(Icons.school_outlined),
            selectedIcon: const Icon(Icons.school),
            label: s.learn,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: s.settings,
          ),
        ],
      ),
    );
  }
}
