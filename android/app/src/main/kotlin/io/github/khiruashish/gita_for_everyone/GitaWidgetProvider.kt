package io.github.khiruashish.gita_for_everyone

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import org.json.JSONArray
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Home-screen widget showing today's verse.
 *
 * The Flutter app writes the next 30 daily verses to its preferences
 * ("flutter.widget_days", see lib/src/widget/widget_feed.dart); this picks the
 * entry for today's date. Nothing is fetched from the internet.
 */
class GitaWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        val views = buildViews(context)
        for (id in ids) manager.updateAppWidget(id, views)
    }

    companion object {
        private const val PREFS = "FlutterSharedPreferences"
        private const val KEY = "flutter.widget_days"

        /** Asks every placed widget to redraw; called by the app after writing new data. */
        fun refreshAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, GitaWidgetProvider::class.java))
            if (ids.isNotEmpty()) GitaWidgetProvider().onUpdate(context, manager, ids)
        }

        private fun buildViews(context: Context): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.gita_widget)
            val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
            var title = context.getString(R.string.widget_name)
            var text = context.getString(R.string.widget_empty)
            try {
                val raw = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(KEY, null)
                if (raw != null) {
                    val days = JSONArray(raw)
                    for (i in 0 until days.length()) {
                        val day = days.getJSONObject(i)
                        if (day.getString("date") == today) {
                            title = day.getString("title")
                            text = day.getString("text")
                            break
                        }
                    }
                }
            } catch (e: Exception) {
                // Malformed data: keep the "open the app" message.
            }
            views.setTextViewText(R.id.widget_title, title)
            views.setTextViewText(R.id.widget_text, text)

            val open = context.packageManager.getLaunchIntentForPackage(context.packageName)
                ?: Intent(context, MainActivity::class.java)
            val pending = PendingIntent.getActivity(
                context, 0, open,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            views.setOnClickPendingIntent(R.id.widget_root, pending)
            return views
        }
    }
}
