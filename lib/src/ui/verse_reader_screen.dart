import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../audio/verse_speaker.dart';
import '../content/models.dart';
import 'widgets/verse_view.dart';

/// Swipe through the verses of one chapter.
class VerseReaderScreen extends StatefulWidget {
  const VerseReaderScreen({
    super.key,
    required this.verses,
    required this.initialIndex,
  });

  final List<Verse> verses;
  final int initialIndex;

  @override
  State<VerseReaderScreen> createState() => _VerseReaderScreenState();
}

class _VerseReaderScreenState extends State<VerseReaderScreen> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;
  late VerseSpeaker _speaker;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Looked up here, not in dispose(), where ancestors can no longer be reached.
    _speaker = AppScope.speakerOf(context);
  }

  @override
  void dispose() {
    _speaker.stop();
    _controller.dispose();
    super.dispose();
  }

  void _go(int delta) => _controller.animateToPage(
    _index + delta,
    duration: const Duration(milliseconds: 250),
    curve: Curves.easeOut,
  );

  @override
  Widget build(BuildContext context) {
    final s = AppScope.stringsOf(context);
    final verse = widget.verses[_index];
    return Scaffold(
      appBar: AppBar(title: Text(s.chapterN(verse.chapter))),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.verses.length,
        onPageChanged: (i) {
          _speaker.stop();
          setState(() => _index = i);
        },
        itemBuilder: (context, i) => VerseView(verse: widget.verses[i]),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: _index > 0 ? () => _go(-1) : null,
                icon: const Icon(Icons.chevron_left_rounded),
                label: Text(s.previous),
              ),
              const Spacer(),
              Text('${_index + 1} / ${widget.verses.length}'),
              const Spacer(),
              TextButton.icon(
                onPressed: _index < widget.verses.length - 1
                    ? () => _go(1)
                    : null,
                icon: const Icon(Icons.chevron_right_rounded),
                label: Text(s.next),
                iconAlignment: IconAlignment.end,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
