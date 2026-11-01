package io.github.khiruashish.gita_for_everyone

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        // The app calls this after writing new widget data (WidgetFeed).
        MethodChannel(messenger, "gita/widget").setMethodCallHandler { call, result ->
            if (call.method == "refresh") {
                GitaWidgetProvider.refreshAll(applicationContext)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }

        // Chapter audio in the background (BackgroundAudio in Dart).
        val audio = MethodChannel(messenger, "gita/audio")
        ChapterAudioService.onAction = { action -> audio.invokeMethod("action", action) }
        audio.setMethodCallHandler { call, result ->
            when (call.method) {
                "update" -> {
                    @Suppress("UNCHECKED_CAST")
                    ChapterAudioService.update(applicationContext, call.arguments as Map<String, Any?>)
                    result.success(null)
                }
                "stop" -> {
                    ChapterAudioService.stop(applicationContext)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        // Leaving the app for good: the Dart side that speaks is going away too.
        if (isFinishing) {
            ChapterAudioService.onAction = null
            ChapterAudioService.stop(applicationContext)
        }
        super.onDestroy()
    }
}
