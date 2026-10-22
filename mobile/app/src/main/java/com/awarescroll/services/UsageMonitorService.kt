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
import com.awarescroll.data.local.UsageSessionEntity
import com.awarescroll.ui.MainActivity
import com.awarescroll.ui.awarescroll.AwareScrollBlockActivity
import kotlinx.coroutines.*
import java.util.UUID

class UsageMonitorService : Service() {

    private val serviceScope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    private var isMonitoring = false
    private var activeSessionStartTime: Long? = null
    private var currentIntentionId: String? = null
    private var intendedLimitMinutes: Int = 5 // Default 5 minutes
    private var reminderDelivered = false
    private var activePackageName: String = "com.instagram.android"
    private var currentSessionId: String = UUID.randomUUID().toString()

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action
        if (action == ACTION_STOP) {
            stopMonitoring()
            stopSelf()
            return START_NOT_STICKY
        }

        currentIntentionId = intent?.getStringExtra(EXTRA_INTENTION_ID)
        intendedLimitMinutes = intent?.getIntExtra(EXTRA_LIMIT_MINUTES, 5) ?: 5
        currentSessionId = UUID.randomUUID().toString()
        reminderDelivered = false

        startForeground(
            NOTIFICATION_ID,
            buildForegroundNotification(
                "AwareScroll Active",
                "Monitoring social media usage (Limit: ${intendedLimitMinutes}m)"
            )
        )
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

            var lastCheckTime = System.currentTimeMillis() - 10000

            while (isMonitoring) {
                delay(2000) // Poll every 2 seconds
                val now = System.currentTimeMillis()

                val events = usageStatsManager.queryEvents(lastCheckTime, now)
                val event = UsageEvents.Event()

                while (events.hasNextEvent()) {
                    events.getNextEvent(event)
                    val pkg = event.packageName

                    if (MONITORED_PACKAGES.contains(pkg)) {
                        activePackageName = pkg
                        when (event.eventType) {
                            UsageEvents.Event.ACTIVITY_RESUMED -> {
                                if (activeSessionStartTime == null) {
                                    activeSessionStartTime = event.timeStamp
                                    reminderDelivered = false
                                    currentSessionId = UUID.randomUUID().toString()
                                }
                            }
                            UsageEvents.Event.ACTIVITY_PAUSED -> {
                                activeSessionStartTime?.let { start ->
                                    val durationMinutes = (event.timeStamp - start) / 60000.0
                                    saveCompletedSession(pkg, start, event.timeStamp, durationMinutes)
                                }
                                activeSessionStartTime = null
                            }
                        }
                    }
                }
                lastCheckTime = now

                // Check if current session has reached the intended limit (e.g. 5 minutes)
                activeSessionStartTime?.let { start ->
                    val elapsedMinutes = (now - start) / 60000.0
                    if (elapsedMinutes >= intendedLimitMinutes && !reminderDelivered) {
                        reminderDelivered = true
                        
                        // 1. Deliver high-priority heads-up notification
                        deliverReflectionNotification(elapsedMinutes.toInt())

                        // 2. BLOCK THE SCREEN: Launch AwareScrollBlockActivity directly over Instagram!
                        launchBlockScreen(activePackageName, elapsedMinutes.toInt())
                    }
                }
            }
        }
    }

    private fun launchBlockScreen(packageName: String, elapsedMinutes: Int) {
        val blockIntent = Intent(this, AwareScrollBlockActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or 
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or 
                    Intent.FLAG_ACTIVITY_SINGLE_TOP or
                    Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
            putExtra(AwareScrollBlockActivity.EXTRA_PACKAGE_NAME, packageName)
            putExtra(AwareScrollBlockActivity.EXTRA_ELAPSED_MINUTES, elapsedMinutes)
            putExtra(AwareScrollBlockActivity.EXTRA_INTENDED_MINUTES, intendedLimitMinutes)
            putExtra(AwareScrollBlockActivity.EXTRA_USAGE_SESSION_ID, currentSessionId)
        }
        startActivity(blockIntent)
    }

    private fun deliverReflectionNotification(minutes: Int) {
        val notifyIntent = Intent(this, AwareScrollBlockActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra(AwareScrollBlockActivity.EXTRA_PACKAGE_NAME, activePackageName)
            putExtra(AwareScrollBlockActivity.EXTRA_ELAPSED_MINUTES, minutes)
            putExtra(AwareScrollBlockActivity.EXTRA_INTENDED_MINUTES, intendedLimitMinutes)
            putExtra(AwareScrollBlockActivity.EXTRA_USAGE_SESSION_ID, currentSessionId)
        }
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            notifyIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
        )

        val notification = NotificationCompat.Builder(this, AwareScrollApp.CHANNEL_AWARESCROLL_LIMIT)
            .setContentTitle("5 Minutes Limit Reached")
            .setContentText("You planned $intendedLimitMinutes min. Close Instagram or continue?")
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setColor(0xFFFF9F43.toInt()) // Warm Accent #FF9F43
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setFullScreenIntent(pendingIntent, true) // Launches full screen over other apps
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .build()

        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager
        notificationManager.notify(NOTIFICATION_ALERT_ID, notification)
    }

    private fun saveCompletedSession(pkg: String, start: Long, end: Long, durationMinutes: Double) {
        val appName = when {
            pkg.contains("instagram") -> "Instagram"
            pkg.contains("facebook") -> "Facebook"
            pkg.contains("snapchat") -> "Snapchat"
            pkg.contains("youtube") -> "YouTube"
            pkg.contains("reddit") -> "Reddit"
            pkg.contains("musically") || pkg.contains("tiktok") -> "TikTok"
            else -> "Social Media"
        }

        serviceScope.launch {
            val session = UsageSessionEntity(
                id = currentSessionId,
                intentionId = currentIntentionId,
                appName = appName,
                startTime = start,
                endTime = end,
                actualDurationMinutes = durationMinutes,
                exceededLimit = durationMinutes > intendedLimitMinutes,
                closedOnFirstReminder = !reminderDelivered,
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
            hour in 17..20 -> "evening"
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

        val MONITORED_PACKAGES = setOf(
            "com.instagram.android",
            "com.facebook.katana",
            "com.snapchat.android",
            "com.google.android.youtube",
            "com.reddit.frontpage",
            "com.zhiliaoapp.musically", // TikTok
            "com.twitter.android",
            "com.x.android"
        )

        const val NOTIFICATION_ID = 1001
        const val NOTIFICATION_ALERT_ID = 1002

        const val ACTION_START = "com.awarescroll.START_USAGE_MONITOR"
        const val ACTION_STOP = "com.awarescroll.STOP_USAGE_MONITOR"
        const val EXTRA_INTENTION_ID = "extra_intention_id"
        const val EXTRA_LIMIT_MINUTES = "extra_limit_minutes"
        const val EXTRA_SHOW_REFLECTION = "extra_show_reflection"
        const val EXTRA_ELAPSED_MINUTES = "extra_elapsed_minutes"

        fun startMonitoring(context: Context, limitMinutes: Int = 5, intentionId: String? = null) {
            val intent = Intent(context, UsageMonitorService::class.java).apply {
                action = ACTION_START
                putExtra(EXTRA_LIMIT_MINUTES, limitMinutes)
                putExtra(EXTRA_INTENTION_ID, intentionId)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }
    }
}
