import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app_scope.dart';
import '../saved_screen.dart';
import '../search_screen.dart';

/// Font family bundled for Sanskrit, so conjuncts render the same on every phone.
const sanskritFont = 'NotoSerifDevanagari';

/// [base] in the bundled Sanskrit font.
TextStyle? sanskritStyle(TextStyle? base) =>
    (base ?? const TextStyle()).copyWith(fontFamily: sanskritFont);

/// Heart button that saves a verse to "My verses".
class BookmarkButton extends StatelessWidget {
  const BookmarkButton({super.key, required this.verseId, this.size});

  final String verseId;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.stringsOf(context);
    final settings = AppScope.settingsOf(context);
    final saved = settings.isBookmarked(verseId);
    return IconButton(
      tooltip: saved ? s.unsave : s.save,
      isSelected: saved,
      icon: Icon(Icons.favorite_border_rounded, size: size),
      selectedIcon: Icon(
        Icons.favorite_rounded,
        size: size,
        color: Theme.of(context).colorScheme.error,
      ),
      onPressed: () => settings.toggleBookmark(verseId),
    );
  }
}

/// Opens a dialog to write or edit the private note for a verse.
Future<void> editNote(BuildContext context, String verseId) async {
  final settings = AppScope.settingsOf(context);
  final text = await showDialog<String>(
    context: context,
    builder: (_) =>
        _NoteDialog(verseId: verseId, initial: settings.notes[verseId]),
  );
  if (text != null) await settings.setNote(verseId, text);
}

class _NoteDialog extends StatefulWidget {
  const _NoteDialog({required this.verseId, this.initial});

  final String verseId;
  final String? initial;

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  // Owned here so it lives until the dialog has finished closing.
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.stringsOf(context);
    return AlertDialog(
      title: Text(widget.verseId),
      content: TextField(
        controller: _controller,
        autofocus: true,
        minLines: 3,
        maxLines: 8,
        maxLength: 2000,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: s.noteHint,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text(s.saveButton),
        ),
      ],
    );
  }
}

/// Search and "My verses" buttons for the top bar of the main tabs.
List<Widget> mainActions(BuildContext context) {
  final s = AppScope.stringsOf(context);
  return [
    IconButton(
      tooltip: s.search,
      icon: const Icon(Icons.search_rounded),
      onPressed: () =>
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const SearchScreen())),
    ),
    IconButton(
      tooltip: s.myVerses,
      icon: const Icon(Icons.favorite_border_rounded),
      onPressed: () =>
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const SavedScreen())),
    ),
    const SizedBox(width: 4),
  ];
}

/// Opens [url] outside the app (browser, store or mail), with a message if
/// nothing can handle it.
Future<void> openLink(BuildContext context, Uri url) async {
  final s = AppScope.stringsOf(context);
  final messenger = ScaffoldMessenger.of(context);
  var ok = false;
  try {
    ok = await launchUrl(url, mode: LaunchMode.externalApplication);
  } catch (_) {
    ok = false;
  }
  if (!ok) messenger.showSnackBar(SnackBar(content: Text(s.couldNotOpen)));
}
