import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

import '../../app_scope.dart';
import '../../content/models.dart';
import '../../settings/settings_controller.dart';
import '../widgets/actions.dart';

/// Sends a PNG and a caption to the phone's share sheet. Tests replace it.
typedef ImageSharer = Future<void> Function(
  Uint8List png,
  String fileName,
  String caption,
  Rect? origin,
);

Future<void> _shareWithPlatform(
  Uint8List png,
  String fileName,
  String caption,
  Rect? origin,
) async {
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile.fromData(png, mimeType: 'image/png')],
      fileNameOverrides: [fileName],
      text: caption,
      sharePositionOrigin: origin,
    ),
  );
}

ImageSharer imageSharer = _shareWithPlatform;

/// Opens a preview of the verse as a picture card, with a Share button.
Future<void> showShareSheet(BuildContext context, Verse verse) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _ShareSheet(verse: verse),
  );
}

class _ShareSheet extends StatefulWidget {
  const _ShareSheet({required this.verse});

  final Verse verse;

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  final _cardKey = GlobalKey();
  bool? _hindi;
  var _busy = false;

  Future<void> _share(Rect? origin) async {
    final s = AppScope.stringsOf(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    try {
      final boundary =
          _cardKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      final verse = widget.verse;
      final text = _hindi! ? verse.hindi! : verse.english!;
      await imageSharer(
        bytes!.buffer.asUint8List(),
        'bhagavad-gita-${verse.chapter}-${verse.number}.png',
        '$text\n\n— Bhagavad Gita ${verse.id}',
        origin,
      );
      navigator.pop();
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(s.shareFailed)));
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.stringsOf(context);
    final theme = Theme.of(context);
    _hindi ??= AppScope.settingsOf(context).language == AppLanguage.hindi;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              s.shareAsImage,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Center(
              child: SegmentedButton<bool>(
                segments: [
                  ButtonSegment(value: true, label: Text(s.hindiLabel)),
                  ButtonSegment(value: false, label: Text(s.englishLabel)),
                ],
                selected: {_hindi!},
                showSelectedIcon: false,
                onSelectionChanged: (v) => setState(() => _hindi = v.first),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 420),
                child: AspectRatio(
                  aspectRatio: ShareCard.size.aspectRatio,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: FittedBox(
                      child: RepaintBoundary(
                        key: _cardKey,
                        child: ShareCard(verse: widget.verse, hindi: _hindi!),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Builder(
              builder: (buttonContext) => FilledButton.icon(
                onPressed: _busy
                    ? null
                    : () {
                        final box =
                            buttonContext.findRenderObject() as RenderBox?;
                        _share(
                          box == null
                              ? null
                              : box.localToGlobal(Offset.zero) & box.size,
                        );
                      },
                icon: const Icon(Icons.share_rounded),
                label: Text(s.share),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The picture that gets shared: 4:5, the shape WhatsApp and Instagram show best.
class ShareCard extends StatelessWidget {
  const ShareCard({super.key, required this.verse, required this.hindi});

  /// Logical size; captured at 3x, this is 1080 x 1350 pixels.
  static const size = Size(360, 450);

  final Verse verse;
  final bool hindi;

  @override
  Widget build(BuildContext context) {
    const cream = Color(0xFFFFF3E0);
    final speaker = verse.speaker;
    final translation = hindi ? verse.hindi! : verse.english!;
    final base = Theme.of(context).textTheme;
    // Fixed sizes, so the picture looks the same whatever the phone's text size.
    return MediaQuery.withNoTextScaling(
      child: SizedBox.fromSize(
        size: size,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6E2A10), Color(0xFFB4501A), Color(0xFFD9822B)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 26, 28, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'ॐ',
                  textAlign: TextAlign.center,
                  style: sanskritStyle(base.headlineSmall)
                      ?.copyWith(color: cream.withValues(alpha: 0.85)),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        width: size.width - 56,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              verse.sanskrit,
                              textAlign: TextAlign.center,
                              style: sanskritStyle(base.titleMedium)?.copyWith(
                                color: cream,
                                fontWeight: FontWeight.w600,
                                height: 1.7,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: SizedBox(
                                width: 48,
                                child: Divider(
                                  color: cream.withValues(alpha: 0.5),
                                  thickness: 1,
                                ),
                              ),
                            ),
                            Text(
                              speaker == null
                                  ? translation
                                  : '${hindi ? speaker.hindi : speaker.english}: $translation',
                              textAlign: TextAlign.center,
                              style: base.bodyLarge?.copyWith(
                                color: Colors.white,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  hindi
                      ? 'श्रीमद्भगवद्गीता ${verse.id}'
                      : 'Bhagavad Gita ${verse.id}',
                  textAlign: TextAlign.center,
                  style: base.titleSmall?.copyWith(
                    color: cream,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hindi ? 'सबके लिए गीता' : 'Gita for Everyone',
                  textAlign: TextAlign.center,
                  style: base.labelSmall?.copyWith(
                    color: cream.withValues(alpha: 0.75),
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
