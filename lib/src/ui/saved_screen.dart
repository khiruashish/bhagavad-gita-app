import 'package:flutter/material.dart';

import '../app_scope.dart';
import 'verse_reader_screen.dart';
import 'widgets/actions.dart';
import 'widgets/layout.dart';
import 'widgets/verse_card.dart';

/// "My verses": saved verses and private notes, all stored on the phone.
class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.stringsOf(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.myVerses),
          bottom: TabBar(
            tabs: [
              Tab(text: s.savedVerses),
              Tab(text: s.myNotes),
            ],
          ),
        ),
        body: const TabBarView(children: [_Saved(), _Notes()]),
      ),
    );
  }
}

class _Saved extends StatelessWidget {
  const _Saved();

  @override
  Widget build(BuildContext context) {
    final s = AppScope.stringsOf(context);
    final content = AppScope.contentOf(context);
    final ids = AppScope.settingsOf(context).bookmarks;
    final verses = [
      for (final v in content.verses)
        if (ids.contains(v.id) && v.isTranslated) v,
    ];
    if (verses.isEmpty) return _Empty(s.noSaved, Icons.favorite_border_rounded);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        for (final v in verses) ReadableWidth(child: VerseCard(verse: v)),
      ],
    );
  }
}

class _Notes extends StatelessWidget {
  const _Notes();

  @override
  Widget build(BuildContext context) {
    final s = AppScope.stringsOf(context);
    final content = AppScope.contentOf(context);
    final notes = AppScope.settingsOf(context).notes;
    final theme = Theme.of(context);
    final verses = [
      for (final v in content.verses)
        if (notes.containsKey(v.id)) v,
    ];
    if (verses.isEmpty) return _Empty(s.noNotes, Icons.edit_note_rounded);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        for (final v in verses)
          ReadableWidth(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 8, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          NumberBadge(v.id),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              s.verseOf(v.chapter, v.number),
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                          IconButton(
                            tooltip: s.editNote,
                            icon: const Icon(Icons.edit_rounded),
                            onPressed: () => editNote(context, v.id),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Text(
                          notes[v.id]!,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  VerseReaderScreen(initialVerseId: v.id),
                            ),
                          ),
                          child: Text(s.openVerse),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty(this.message, this.icon);

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
