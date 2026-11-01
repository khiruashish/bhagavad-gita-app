import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../app_scope.dart';
import '../../content/models.dart';
import '../../settings/settings_controller.dart';
import '../widgets/actions.dart';
import 'share_sheet.dart';

/// Where an Android wallpaper goes.
enum WallpaperTarget { home, lock, both }

/// Sets the phone's wallpaper from a PNG (Android). Tests replace it.
typedef WallpaperSetter = Future<void> Function(
  Uint8List png,
  WallpaperTarget target,
);

Future<void> _setWithPlatform(Uint8List png, WallpaperTarget target) =>
    const MethodChannel('gita/wallpaper')
        .invokeMethod<void>('set', {'png': png, 'target': target.name});

WallpaperSetter wallpaperSetter = _setWithPlatform;

/// Colour styles for the wallpaper.
class WallpaperStyle {
  const WallpaperStyle(this.colors, this.ink, this.accent);

  final List<Color> colors;
  final Color ink;
  final Color accent;

  static const all = [
    WallpaperStyle(
      [Color(0xFF6E2A10), Color(0xFFB4501A), Color(0xFFD9822B)],
      Colors.white,
      Color(0xFFFFE3B8),
    ),
    WallpaperStyle(
      [Color(0xFF2E1A47), Color(0xFF7A2E66), Color(0xFFE07A5F)],
      Colors.white,
      Color(0xFFFFD6C2),
    ),
    WallpaperStyle(
      [Color(0xFF0B1626), Color(0xFF16324F), Color(0xFF2E5C7A)],
      Colors.white,
      Color(0xFFB8D8EE),
    ),
    WallpaperStyle(
      [Color(0xFFFFF4E6), Color(0xFFFBD9C4), Color(0xFFF2B8A0)],
      Color(0xFF3E1408),
      Color(0xFF9A3B12),
    ),
  ];
}

/// Opens a preview of [entry] as a wallpaper the size of this phone's screen.
Future<void> showWallpaperSheet(BuildContext context, QuoteEntry entry) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _WallpaperSheet(entry: entry),
  );
}

class _WallpaperSheet extends StatefulWidget {
  const _WallpaperSheet({required this.entry});

  final QuoteEntry entry;

  @override
  State<_WallpaperSheet> createState() => _WallpaperSheetState();
}

class _WallpaperSheetState extends State<_WallpaperSheet> {
  final _key = GlobalKey();
  var _style = 0;
  bool? _hindi;
  var _busy = false;

  /// The full screen in logical pixels, and the ratio to physical pixels, so
  /// the picture comes out at exactly the phone's resolution.
  (Size, double) _screen(BuildContext context) {
    final view = View.of(context);
    final ratio = view.devicePixelRatio;
    return (view.physicalSize / ratio, ratio);
  }

  Future<Uint8List> _capture(double ratio) async {
    final boundary =
        _key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: ratio);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return bytes!.buffer.asUint8List();
  }

  Future<void> _set(WallpaperTarget target) async {
    final s = AppScope.stringsOf(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    try {
      final png = await _capture(_screen(context).$2);
      await wallpaperSetter(png, target);
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(s.wallpaperSet)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(s.wallpaperFailed)));
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveImage(Rect? origin) async {
    final s = AppScope.stringsOf(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    try {
      final png = await _capture(_screen(context).$2);
      final v = widget.entry.verse;
      await imageSharer(
        png,
        'gita-wallpaper-${v.chapter}-${v.number}.png',
        '— Bhagavad Gita ${v.id}',
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
    final (screen, _) = _screen(context);
    // Android lets apps set the wallpaper; iPhone only lets people do it
    // themselves from Photos, so there the picture is saved or shared.
    final canSet = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              s.setAsWallpaper,
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
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < WallpaperStyle.all.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Semantics(
                      button: true,
                      selected: i == _style,
                      label: '${s.style} ${i + 1}',
                      child: InkResponse(
                        onTap: () => setState(() => _style = i),
                        radius: 28,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: WallpaperStyle.all[i].colors,
                            ),
                            border: Border.all(
                              width: i == _style ? 3 : 1,
                              color: i == _style
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outlineVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 380),
                child: AspectRatio(
                  aspectRatio: screen.aspectRatio,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: FittedBox(
                      child: RepaintBoundary(
                        key: _key,
                        child: WallpaperArt(
                          entry: widget.entry,
                          size: screen,
                          hindi: _hindi!,
                          style: WallpaperStyle.all[_style],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (canSet)
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (target, label) in [
                    (WallpaperTarget.home, s.homeScreen),
                    (WallpaperTarget.lock, s.lockScreen),
                    (WallpaperTarget.both, s.bothScreens),
                  ])
                    FilledButton.tonal(
                      onPressed: _busy ? null : () => _set(target),
                      child: Text(label),
                    ),
                ],
              )
            else ...[
              Builder(
                builder: (buttonContext) => FilledButton.icon(
                  onPressed: _busy
                      ? null
                      : () {
                          final box =
                              buttonContext.findRenderObject() as RenderBox?;
                          _saveImage(
                            box == null
                                ? null
                                : box.localToGlobal(Offset.zero) & box.size,
                          );
                        },
                  icon: const Icon(Icons.download_rounded),
                  label: Text(s.saveImage),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                s.iphoneWallpaperHint,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The wallpaper picture, laid out for a screen of [size] (logical pixels).
///
/// The quote sits in the middle half of the screen: the top quarter is left
/// for the clock on a lock screen and the bottom fifth for the dock and app
/// icons, on any phone shape. Text sizes follow the screen width and the
/// phone's text-size setting is ignored, so it looks the same when set.
class WallpaperArt extends StatelessWidget {
  const WallpaperArt({
    super.key,
    required this.entry,
    required this.size,
    required this.hindi,
    required this.style,
  });

  final QuoteEntry entry;
  final Size size;
  final bool hindi;
  final WallpaperStyle style;

  @override
  Widget build(BuildContext context) {
    final w = size.width;
    final text = hindi ? entry.hindi : entry.english;
    // Longer quotes get a smaller size, so they still fit the middle band.
    final quoteSize = w * (text.length > 160 ? 0.052 : 0.064);
    final base = Theme.of(context).textTheme;
    return MediaQuery.withNoTextScaling(
      child: SizedBox.fromSize(
        size: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: style.colors,
            ),
          ),
          child: Column(
            children: [
              const Spacer(flex: 27),
              Expanded(
                flex: 53,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: w * 0.82,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'ॐ',
                            style: sanskritStyle(base.headlineSmall)?.copyWith(
                              color: style.accent,
                              fontSize: w * 0.075,
                            ),
                          ),
                          SizedBox(height: w * 0.05),
                          Text(
                            '“$text”',
                            textAlign: TextAlign.center,
                            style: base.headlineSmall?.copyWith(
                              color: style.ink,
                              fontSize: quoteSize,
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: w * 0.05),
                          SizedBox(
                            width: w * 0.14,
                            child: Divider(
                              color: style.accent.withValues(alpha: 0.6),
                              thickness: 1.2,
                            ),
                          ),
                          SizedBox(height: w * 0.03),
                          Text(
                            entry.verse.sanskrit.split('\n').first,
                            textAlign: TextAlign.center,
                            style: sanskritStyle(base.bodyLarge)?.copyWith(
                              color: style.accent,
                              fontSize: w * 0.04,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: w * 0.025),
                          Text(
                            hindi
                                ? '— श्रीमद्भगवद्गीता ${entry.verse.id}'
                                : '— Bhagavad Gita ${entry.verse.id}',
                            style: base.labelLarge?.copyWith(
                              color: style.accent,
                              fontSize: w * 0.035,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 20),
            ],
          ),
        ),
      ),
    );
  }
}
