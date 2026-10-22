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
import androidx.core.app.NotificationCompat

class AwareScrollUsageService : Service() {

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val appName = intent?.getStringExtra("APP_NAME") ?: "Instagram"
        val packageName = intent?.getStringExtra("PACKAGE_NAME") ?: "com.instagram.android"
        val minutes = intent?.getIntExtra("LIMIT_MINUTES", 5) ?: 5

        createNotificationChannel()

        val notification = buildNotification(appName, minutes)
        startForeground(NOTIFICATION_ID, notification)

        AwareScrollMonitor.start(this, appName, packageName, minutes)

        return START_STICKY
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "AwareScroll Active Boundary",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Monitors foreground time for configured apps"
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(appName: String, minutes: Int): Notification {
        val launchIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("AwareScroll Active")
            .setContentText("Guarding $appName • Limit: $minutes minutes")
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .build()
    }

    override fun onDestroy() {
        AwareScrollMonitor.stop()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    companion object {
        const val CHANNEL_ID = "awarescroll_service_channel"
        const val NOTIFICATION_ID = 1001
    }
}
