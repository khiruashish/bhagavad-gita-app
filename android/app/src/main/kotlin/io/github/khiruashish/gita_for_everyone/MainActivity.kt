package io.github.khiruashish.gita_for_everyone

import android.app.WallpaperManager
import android.graphics.BitmapFactory
import android.os.Build
import android.os.Handler
import android.os.Looper
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

        MethodChannel(messenger, "gita/wallpaper").setMethodCallHandler { call, result ->
            if (call.method == "set") {
                val png = call.argument<ByteArray>("png")
                if (png == null) {
                    result.error("wallpaper", "no image", null)
                } else {
                    setWallpaper(png, call.argument<String>("target") ?: "both", result)
                }
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

    /** Sets a picture made by the app (WallpaperArt in Dart) as the wallpaper. */
    private fun setWallpaper(png: ByteArray, target: String, result: MethodChannel.Result) {
        val main = Handler(Looper.getMainLooper())
        Thread {
            try {
                val bitmap = BitmapFactory.decodeByteArray(png, 0, png.size)
                    ?: throw IllegalArgumentException("not an image")
                val manager = WallpaperManager.getInstance(applicationContext)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    val which = when (target) {
                        "home" -> WallpaperManager.FLAG_SYSTEM
                        "lock" -> WallpaperManager.FLAG_LOCK
                        else -> WallpaperManager.FLAG_SYSTEM or WallpaperManager.FLAG_LOCK
                    }
                    manager.setBitmap(bitmap, null, true, which)
                } else {
                    manager.setBitmap(bitmap)
                }
                main.post { result.success(null) }
            } catch (e: Exception) {
                main.post { result.error("wallpaper", e.message, null) }
            }
        }.start()
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
