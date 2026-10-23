package com.awarescroll.awarescroll_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import kotlinx.coroutines.*

class AwareScrollUsageService : Service() {

    private val serviceScope = CoroutineScope(Dispatchers.Default + SupervisorJob())
    private var monitoringJob: Job? = null
    private var notificationManager: NotificationManager? = null

    override fun onCreate() {
        super.onCreate()
        notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
        createNotificationChannels()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val appName = intent?.getStringExtra("APP_NAME") ?: "Instagram"
        val packageName = intent?.getStringExtra("PACKAGE_NAME") ?: "com.instagram.android"
        val minutes = intent?.getIntExtra("LIMIT_MINUTES", 5) ?: 5
        val seconds = intent?.getIntExtra("LIMIT_SECONDS", minutes * 60) ?: (minutes * 60)

        Log.d("AwareScroll", "Starting monitor for $appName ($packageName) limit: $minutes min ($seconds s)")

        createNotificationChannels()

        val notification = buildForegroundNotification(appName, 0, minutes)
        startForeground(NOTIFICATION_ID, notification)

        AwareScrollMonitor.start(this, appName, packageName, minutes, seconds)

        startPollingLoop()

        return START_STICKY
    }

    private fun startPollingLoop() {
        monitoringJob?.cancel()
        monitoringJob = serviceScope.launch {
            val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager

            while (isActive && AwareScrollMonitor.isRunning) {
                try {
                    // Check foreground app via UsageStatsManager
                    val fgPackage = getForegroundPackage(usageStatsManager)

                    if (fgPackage != null) {
                        val isTarget = isMatchingPackage(fgPackage, AwareScrollMonitor.targetPackageName)
                        AwareScrollMonitor.updateForegroundStatus(isTarget)

                        if (isTarget && AwareScrollMonitor.isRestricted && !AwareScrollMonitor.isBlockerShowing) {
                            AwareScrollMonitor.triggerBlocker()
                        } else if (!isTarget && AwareScrollMonitor.isRestricted && AwareScrollOverlayManager.isShowing && fgPackage != "com.awarescroll.awarescroll_app" && fgPackage != "com.android.systemui") {
                            AwareScrollOverlayManager.hide()
                        }
                    }

                    // Update persistent notification with live timer
                    if (AwareScrollMonitor.elapsedSeconds % 2 == 0) {
                        updateNotification()
                    }
                } catch (e: Exception) {
                    Log.e("AwareScroll", "Error in polling loop", e)
                }

                delay(1000)
            }
        }
    }

    private fun getForegroundPackage(usageStatsManager: UsageStatsManager?): String? {
        if (usageStatsManager == null) return null
        val now = System.currentTimeMillis()

        // Method 1: Check UsageEvents in past 10 seconds
        try {
            val events = usageStatsManager.queryEvents(now - 10000, now)
            val event = UsageEvents.Event()
            var lastPkg: String? = null
            var lastTime = 0L

            while (events.hasNextEvent()) {
                events.getNextEvent(event)
                val type = event.eventType
                // 1 = ACTIVITY_RESUMED, 7 = USER_INTERACTION
                if (type == UsageEvents.Event.ACTIVITY_RESUMED || type == 1 || type == 7) {
                    if (event.timeStamp >= lastTime) {
                        lastTime = event.timeStamp
                        lastPkg = event.packageName
                    }
                }
            }
            if (!lastPkg.isNullOrEmpty()) {
                return lastPkg
            }
        } catch (e: Exception) {
            Log.e("AwareScroll", "queryEvents failed", e)
        }

        // Method 2: Query recent UsageStats
        try {
            val stats = usageStatsManager.queryUsageStats(
                UsageStatsManager.INTERVAL_DAILY,
                now - 30000,
                now
            )
            if (!stats.isNullOrEmpty()) {
                val mostRecent = stats.maxByOrNull { it.lastTimeUsed }
                if (mostRecent != null && (now - mostRecent.lastTimeUsed) < 8000) {
                    return mostRecent.packageName
                }
            }
        } catch (e: Exception) {
            Log.e("AwareScroll", "queryUsageStats failed", e)
        }

        return null
    }

    private fun isMatchingPackage(fgPackage: String, targetPackage: String): Boolean {
        return AwareScrollMonitor.isMatchingPackage(fgPackage, targetPackage)
    }

    private fun updateNotification() {
        val appName = AwareScrollMonitor.targetAppName
        val elapsed = AwareScrollMonitor.elapsedSeconds
        val limit = AwareScrollMonitor.limitMinutes
        val notification = buildForegroundNotification(appName, elapsed, limit)
        notificationManager?.notify(NOTIFICATION_ID, notification)
    }

    private fun buildForegroundNotification(appName: String, elapsedSec: Int, limitMin: Int): Notification {
        val launchIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val mins = elapsedSec / 60
        val secs = elapsedSec % 60
        val timeStr = String.format("%02d:%02d", mins, secs)
        val limitStr = String.format("%02d:00", limitMin)

        val statusText = if (AwareScrollMonitor.isTargetInForeground) {
            "Active: $appName is open ($timeStr / $limitStr)"
        } else {
            "Guarding $appName • Usage: $timeStr / $limitStr"
        }

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("AwareScroll: $appName Boundary")
            .setContentText(statusText)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .build()
    }

    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "AwareScroll Boundary Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Monitors foreground time for configured apps"
            }

            val alertChannel = NotificationChannel(
                ALERT_CHANNEL_ID,
                "AwareScroll Time Limit Alert",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Full-screen interruption when time limit is reached"
                enableVibration(true)
                setBypassDnd(true)
            }

            notificationManager?.createNotificationChannel(serviceChannel)
            notificationManager?.createNotificationChannel(alertChannel)
        }
    }

    override fun onDestroy() {
        monitoringJob?.cancel()
        AwareScrollMonitor.stop()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    companion object {
        const val CHANNEL_ID = "awarescroll_service_channel"
        const val ALERT_CHANNEL_ID = "awarescroll_alert_channel"
        const val NOTIFICATION_ID = 1001
        const val ALERT_NOTIFICATION_ID = 2002
    }
}
