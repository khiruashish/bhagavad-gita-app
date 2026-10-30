package io.github.khiruashish.gita_for_everyone

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // The app calls this after writing new widget data (WidgetFeed).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "gita/widget")
            .setMethodCallHandler { call, result ->
                if (call.method == "refresh") {
                    GitaWidgetProvider.refreshAll(applicationContext)
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }
}
