package io.github.khiruashish.gita_for_everyone

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.graphics.drawable.Icon
import android.media.MediaMetadata
import android.media.session.MediaSession
import android.media.session.PlaybackState
import android.os.Build
import android.os.IBinder
import android.os.PowerManager

/**
 * Keeps chapter audio playing with the screen locked.
 *
 * A media-playback foreground service with a media notification and a
 * MediaSession, so the lock screen, notification shade and headset buttons can
 * pause, continue and skip verses. Speech itself is done by the app's
 * text-to-speech code; this service keeps the process running and, only while
 * audio is playing, holds a partial wake lock so the next verse starts on time.
 *
 * Driven from Dart through the "gita/audio" channel (BackgroundAudio).
 */
class ChapterAudioService : Service() {

    companion object {
        private const val CHANNEL_ID = "chapter_audio"
        private const val NOTIFICATION_ID = 4701
        private const val ACTION_UPDATE = "gita.audio.UPDATE"
        private const val ACTION_PLAY = "gita.audio.PLAY"
        private const val ACTION_PAUSE = "gita.audio.PAUSE"
        private const val ACTION_NEXT = "gita.audio.NEXT"
        private const val ACTION_PREVIOUS = "gita.audio.PREVIOUS"
        private const val ACTION_STOP = "gita.audio.STOP"

        /** Latest state from the app: title, subtitle, playing, buttons, labels. */
        private var state: Map<String, Any?>? = null

        /** Sends a button press back to Dart; set by MainActivity. */
        var onAction: ((String) -> Unit)? = null

        fun update(context: Context, newState: Map<String, Any?>) {
            state = newState
            val intent = Intent(context, ChapterAudioService::class.java).setAction(ACTION_UPDATE)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stop(context: Context) {
            state = null
            context.stopService(Intent(context, ChapterAudioService::class.java))
        }
    }

    private lateinit var session: MediaSession
    private var wakeLock: PowerManager.WakeLock? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        session = MediaSession(this, "GitaChapterAudio").apply {
            setCallback(object : MediaSession.Callback() {
                override fun onPlay() = send("play")
                override fun onPause() = send("pause")
                override fun onSkipToNext() = send("next")
                override fun onSkipToPrevious() = send("previous")
                override fun onStop() = send("stop")
            })
            isActive = true
        }
        val power = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = power.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "gita:chapterAudio")
            .apply { setReferenceCounted(false) }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val current = state
        if (current == null) {
            stopSelf()
            return START_NOT_STICKY
        }
        when (intent?.action) {
            ACTION_PLAY -> send("play")
            ACTION_PAUSE -> send("pause")
            ACTION_NEXT -> send("next")
            ACTION_PREVIOUS -> send("previous")
            ACTION_STOP -> send("stop")
        }
        show(current)
        return START_NOT_STICKY
    }

    /** The app was swiped away: there is no one left to speak, so stop. */
    override fun onTaskRemoved(rootIntent: Intent?) {
        stop(this)
        super.onTaskRemoved(rootIntent)
    }

    override fun onDestroy() {
        wakeLock?.let { if (it.isHeld) it.release() }
        session.isActive = false
        session.release()
        super.onDestroy()
    }

    private fun send(action: String) {
        val handler = onAction
        if (handler != null) handler(action) else if (action == "stop") stop(this)
    }

    private fun show(s: Map<String, Any?>) {
        val playing = s["playing"] as? Boolean ?: false
        val hasNext = s["hasNext"] as? Boolean ?: false
        val hasPrevious = s["hasPrevious"] as? Boolean ?: false
        @Suppress("UNCHECKED_CAST")
        val labels = (s["labels"] as? Map<String, String>) ?: emptyMap()
        val title = s["title"] as? String ?: ""
        val subtitle = s["subtitle"] as? String ?: ""

        session.setMetadata(
            MediaMetadata.Builder()
                .putString(MediaMetadata.METADATA_KEY_TITLE, title)
                .putString(MediaMetadata.METADATA_KEY_ARTIST, subtitle)
                .putString(MediaMetadata.METADATA_KEY_ALBUM, s["album"] as? String ?: "")
                .build(),
        )
        var actions = PlaybackState.ACTION_PLAY or PlaybackState.ACTION_PAUSE or
            PlaybackState.ACTION_PLAY_PAUSE or PlaybackState.ACTION_STOP
        if (hasNext) actions = actions or PlaybackState.ACTION_SKIP_TO_NEXT
        if (hasPrevious) actions = actions or PlaybackState.ACTION_SKIP_TO_PREVIOUS
        session.setPlaybackState(
            PlaybackState.Builder()
                .setActions(actions)
                .setState(
                    if (playing) PlaybackState.STATE_PLAYING else PlaybackState.STATE_PAUSED,
                    PlaybackState.PLAYBACK_POSITION_UNKNOWN,
                    if (playing) 1f else 0f,
                )
                .build(),
        )

        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            manager.createNotificationChannel(
                NotificationChannel(
                    CHANNEL_ID,
                    labels["channel"] ?: "Chapter audio",
                    NotificationManager.IMPORTANCE_LOW,
                ).apply { setShowBadge(false) },
            )
        }

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }
        builder
            .setSmallIcon(R.drawable.ic_stat_audio)
            .setContentTitle(title)
            .setContentText(subtitle)
            .setOngoing(true)
            .setShowWhen(false)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .setContentIntent(openAppIntent())
            .addAction(action(android.R.drawable.ic_media_previous, labels["previous"], ACTION_PREVIOUS))
            .addAction(
                if (playing) {
                    action(android.R.drawable.ic_media_pause, labels["pause"], ACTION_PAUSE)
                } else {
                    action(android.R.drawable.ic_media_play, labels["play"], ACTION_PLAY)
                },
            )
            .addAction(action(android.R.drawable.ic_media_next, labels["next"], ACTION_NEXT))
            .addAction(action(android.R.drawable.ic_menu_close_clear_cancel, labels["stop"], ACTION_STOP))
            .setStyle(
                Notification.MediaStyle()
                    .setMediaSession(session.sessionToken)
                    .setShowActionsInCompactView(0, 1, 2),
            )
        val notification = builder.build()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK)
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }

        // Keep the CPU awake between sentences only while audio plays; the
        // timeout is a safety net and is renewed with every verse.
        wakeLock?.let {
            if (playing) it.acquire(30 * 60 * 1000L) else if (it.isHeld) it.release()
        }
    }

    private fun action(icon: Int, label: String?, name: String): Notification.Action =
        Notification.Action.Builder(
            Icon.createWithResource(this, icon),
            label ?: "",
            PendingIntent.getService(
                this,
                name.hashCode(),
                Intent(this, ChapterAudioService::class.java).setAction(name),
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
            ),
        ).build()

    private fun openAppIntent(): PendingIntent {
        val open = packageManager.getLaunchIntentForPackage(packageName)
            ?: Intent(this, MainActivity::class.java)
        return PendingIntent.getActivity(
            this, 0, open, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
    }
}
