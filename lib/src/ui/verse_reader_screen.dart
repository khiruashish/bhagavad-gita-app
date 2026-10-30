import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../audio/verse_speaker.dart';
import '../content/models.dart';
import '../settings/settings_controller.dart';
import 'widgets/verse_view.dart';

/// Reads the whole Gita verse by verse. Swiping or the Next button continues
/// into the following chapter; the top bar jumps a whole chapter at a time.
class VerseReaderScreen extends StatefulWidget {
  const VerseReaderScreen({super.key, required this.initialVerseId});

  final String initialVerseId;

  @override
  State<VerseReaderScreen> createState() => _VerseReaderScreenState();
}

class _VerseReaderScreenState extends State<VerseReaderScreen> {
  late List<Verse> _verses;
  late PageController _controller;
  late int _index;
  late VerseSpeaker _speaker;
  late SettingsController _settings;
  var _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Looked up here, not in dispose(), where ancestors can no longer be reached.
    _speaker = AppScope.speakerOf(context);
    _settings = AppScope.settingsOf(context);
    if (!_started) {
      _started = true;
      _verses = AppScope.contentOf(context).verses;
      _index = _verses
          .indexWhere((v) => v.id == widget.initialVerseId)
          .clamp(0, _verses.length - 1);
      _controller = PageController(initialPage: _index);
      _settings.setLastRead(_verses[_index].id);
    }
  }

  @override
  void dispose() {
    _speaker.stop();
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    if (index < 0 || index >= _verses.length || index == _index) return;
    if ((index - _index).abs() == 1) {
      _controller.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } else {
      _controller.jumpToPage(index);
    }
  }

  void _goToChapter(int chapter) =>
      _goTo(_verses.indexWhere((v) => v.chapter == chapter));

  @override
  Widget build(BuildContext context) {
    final s = AppScope.stringsOf(context);
    final content = AppScope.contentOf(context);
    final hindiUi = _settings.language == AppLanguage.hindi;
    final theme = Theme.of(context);
    final verse = _verses[_index];
    final chapter = content.chapters[verse.chapter - 1];
    final lastChapter = content.chapters.length;
    final atChapterEnd = verse.number == chapter.verseCount;
    final atEnd = _index == _verses.length - 1;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.chapterN(chapter.number),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              hindiUi ? chapter.hindi : chapter.english,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: s.previousChapter,
            icon: const Icon(Icons.skip_previous_rounded),
            onPressed: chapter.number > 1
                ? () => _goToChapter(chapter.number - 1)
                : null,
          ),
          IconButton(
            tooltip: s.nextChapter,
            icon: const Icon(Icons.skip_next_rounded),
            onPressed: chapter.number < lastChapter
                ? () => _goToChapter(chapter.number + 1)
                : null,
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: LinearProgressIndicator(
            value: verse.number / chapter.verseCount,
            minHeight: 3,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: _verses.length,
        onPageChanged: (i) {
          _speaker.stop();
          setState(() => _index = i);
          _settings.setLastRead(_verses[i].id);
        },
        itemBuilder: (context, i) => VerseView(verse: _verses[i]),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.navigationBarTheme.backgroundColor,
          border: Border(
            top: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _index > 0 ? () => _goTo(_index - 1) : null,
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: Text(s.previous),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '${verse.number} / ${chapter.verseCount}',
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: atEnd ? null : () => _goTo(_index + 1),
                    icon: const Icon(Icons.arrow_forward_rounded),
                    iconAlignment: IconAlignment.end,
                    label: Text(
                      atEnd
                          ? s.endOfGita
                          : atChapterEnd
                          ? s.chapterN(chapter.number + 1)
                          : s.next,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
