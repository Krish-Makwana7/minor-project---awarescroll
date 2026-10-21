package com.awarescroll.services

import android.app.Notification
import android.app.PendingIntent
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import com.awarescroll.AwareScrollApp
import com.awarescroll.R
import com.awarescroll.data.local.UsageSessionEntity
import com.awarescroll.ui.MainActivity
import kotlinx.coroutines.*
import java.util.UUID

class UsageMonitorService : Service() {

    private val serviceScope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    private var isMonitoring = false
    private var activeSessionStartTime: Long? = null
    private var currentIntentionId: String? = null
    private var intendedLimitMinutes: Int = 15
    private var reminderDelivered = false

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action
        if (action == ACTION_STOP) {
            stopMonitoring()
            stopSelf()
            return START_NOT_STICKY
        }

        currentIntentionId = intent?.getStringExtra(EXTRA_INTENTION_ID)
        intendedLimitMinutes = intent?.getIntExtra(EXTRA_LIMIT_MINUTES, 15) ?: 15

        startForeground(NOTIFICATION_ID, buildForegroundNotification("AwareScroll Active", "Monitoring Instagram intention boundaries"))
        startMonitoring()

        return START_STICKY
    }

    private fun startMonitoring() {
        if (isMonitoring) return
        isMonitoring = true

        serviceScope.launch {
            val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
            if (usageStatsManager == null) {
                isMonitoring = false
                return@launch
            }

            var lastCheckTime = System.currentTimeMillis()

            while (isMonitoring) {
                delay(3000) // Poll every 3 seconds
                val now = System.currentTimeMillis()

                val events = usageStatsManager.queryEvents(lastCheckTime, now)
                val event = UsageEvents.Event()

                while (events.hasNextEvent()) {
                    events.getNextEvent(event)
                    if (event.packageName == INSTAGRAM_PACKAGE) {
                        when (event.eventType) {
                            UsageEvents.Event.ACTIVITY_RESUMED -> {
                                if (activeSessionStartTime == null) {
                                    activeSessionStartTime = event.timeStamp
                                    reminderDelivered = false
                                }
                            }
                            UsageEvents.Event.ACTIVITY_PAUSED -> {
                                activeSessionStartTime?.let { start ->
                                    val durationMinutes = (event.timeStamp - start) / 60000.0
                                    saveCompletedSession(start, event.timeStamp, durationMinutes)
                                }
                                activeSessionStartTime = null
                            }
                        }
                    }
                }
                lastCheckTime = now

                // Check if current session exceeded intended limit
                activeSessionStartTime?.let { start ->
                    val elapsedMinutes = (now - start) / 60000.0
                    if (elapsedMinutes >= intendedLimitMinutes && !reminderDelivered) {
                        reminderDelivered = true
                        deliverReflectionNotification(elapsedMinutes.toInt())
                    }
                }
            }
        }
    }

    private fun deliverReflectionNotification(minutes: Int) {
        val notifyIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra(EXTRA_SHOW_REFLECTION, true)
            putExtra(EXTRA_ELAPSED_MINUTES, minutes)
        }
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            notifyIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
        )

        val notification = NotificationCompat.Builder(this, AwareScrollApp.CHANNEL_AWARESCROLL_LIMIT)
            .setContentTitle("Limit Reached ($minutes min)")
            .setContentText("You stated an intention of $intendedLimitMinutes min. Take a moment to reflect.")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setColor(0xFFFF9F43.toInt()) // Warm Accent #FF9F43
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .build()

        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager
        notificationManager.notify(NOTIFICATION_ALERT_ID, notification)
    }

    private fun saveCompletedSession(start: Long, end: Long, durationMinutes: Double) {
        serviceScope.launch {
            val session = UsageSessionEntity(
                id = UUID.randomUUID().toString(),
                intentionId = currentIntentionId,
                startTime = start,
                endTime = end,
                actualDurationMinutes = durationMinutes,
                exceededLimit = durationMinutes > intendedLimitMinutes,
                reminderCount = if (reminderDelivered) 1 else 0,
                timeOfDayBucket = determineTimeBucket(start)
            )
            AwareScrollApp.instance.repository.recordUsageSession(session)
        }
    }

    private fun determineTimeBucket(timestamp: Long): String {
        val cal = java.util.Calendar.getInstance().apply { timeInMillis = timestamp }
        val hour = cal.get(java.util.Calendar.HOUR_OF_DAY)
        return when {
            hour in 5..11 -> "morning"
            hour in 12..16 -> "afternoon"
            hour in 17..21 -> "evening"
            else -> "night"
        }
    }

    private fun buildForegroundNotification(title: String, text: String): Notification {
        return NotificationCompat.Builder(this, AwareScrollApp.CHANNEL_FOCUSLOCK_SESSION)
            .setContentTitle(title)
            .setContentText(text)
            .setSmallIcon(android.R.drawable.ic_menu_recent_history)
            .setOngoing(true)
            .build()
    }

    private fun stopMonitoring() {
        isMonitoring = false
        serviceScope.cancel()
    }

    override fun onDestroy() {
        stopMonitoring()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    companion object {
        const val INSTAGRAM_PACKAGE = "com.instagram.android"
        const val NOTIFICATION_ID = 1001
        const val NOTIFICATION_ALERT_ID = 1002

        const val ACTION_START = "com.awarescroll.START_USAGE_MONITOR"
        const val ACTION_STOP = "com.awarescroll.STOP_USAGE_MONITOR"
        const val EXTRA_INTENTION_ID = "extra_intention_id"
        const val EXTRA_LIMIT_MINUTES = "extra_limit_minutes"
        const val EXTRA_SHOW_REFLECTION = "extra_show_reflection"
        const val EXTRA_ELAPSED_MINUTES = "extra_elapsed_minutes"
    }
}
