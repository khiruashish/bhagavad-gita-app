import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../audio/verse_speaker.dart';

/// Speaker button that reads [text] aloud, or stops if it is already reading it.
class ListenButton extends StatelessWidget {
  const ListenButton({
    super.key,
    required this.id,
    required this.text,
    required this.language,
  });

  final String id;
  final String text;
  final SpeechLanguage language;

  @override
  Widget build(BuildContext context) {
    final speaker = AppScope.speakerOf(context);
    final s = AppScope.stringsOf(context);
    return ValueListenableBuilder<String?>(
      valueListenable: speaker.speaking,
      builder: (context, current, _) {
        final playing = current == id;
        return IconButton.filledTonal(
          tooltip: playing ? s.stop : s.listen,
          icon: Icon(playing ? Icons.stop_rounded : Icons.volume_up_rounded),
          onPressed: () async {
            if (playing) {
              await speaker.stop();
              return;
            }
            final ok = await speaker.speak(
              id,
              text,
              language,
              slow: AppScope.settingsOf(context).slowSpeech,
            );
            if (!ok && context.mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(s.noVoice)));
            }
          },
        );
      },
    );
  }
}
