package com.awarescroll.awarescroll_app

import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.core.app.NotificationCompat

object AwareScrollMonitor {
    @Volatile var isRunning = false
    @Volatile var targetAppName = "Instagram"
    @Volatile var targetPackageName = "com.instagram.android"
    @Volatile var limitMinutes = 5
    @Volatile var targetTotalSeconds = 300
    @Volatile var elapsedSeconds = 0
    @Volatile var extensionSeconds = 0
    @Volatile var isTargetInForeground = false
    @Volatile var isBlockerShowing = false

    private val handler = Handler(Looper.getMainLooper())
    private var tickerRunnable: Runnable? = null
    var appContext: Context? = null

    fun start(context: Context, appName: String, packageName: String, minutes: Int, seconds: Int = minutes * 60) {
        appContext = context.applicationContext
        targetAppName = appName
        targetPackageName = packageName
        limitMinutes = minutes
        targetTotalSeconds = seconds
        elapsedSeconds = 0
        extensionSeconds = 0
        isRunning = true
        isBlockerShowing = false
        isTargetInForeground = false

        Log.d("AwareScroll", "Monitor started: $appName, package: $packageName, limit: $minutes m ($seconds s)")
        startTicker()
    }

    fun stop() {
        Log.d("AwareScroll", "Monitor stopped")
        isRunning = false
        isTargetInForeground = false
        isBlockerShowing = false
        stopTicker()
    }

    fun updateForegroundStatus(inFg: Boolean) {
        if (!isRunning) return
        isTargetInForeground = inFg
    }

    fun onAccessibilityWindowStateChanged(packageName: String) {
        if (!isRunning) return

        if (isMatchingPackage(packageName, targetPackageName)) {
            isTargetInForeground = true
        } else if (packageName != "com.awarescroll.awarescroll_app" && packageName != "com.android.systemui") {
            isTargetInForeground = false
        }
    }

    fun isMatchingPackage(fgPackage: String, targetPackage: String): Boolean {
        if (fgPackage.equals(targetPackage, ignoreCase = true)) return true
        if (fgPackage.startsWith(targetPackage) || targetPackage.startsWith(fgPackage)) return true

        // Known ecosystem aliases
        if (targetPackage.contains("youtube", ignoreCase = true) && fgPackage.contains("youtube", ignoreCase = true)) return true
        if (targetPackage.contains("instagram", ignoreCase = true) && fgPackage.contains("instagram", ignoreCase = true)) return true
        if (targetPackage.contains("facebook", ignoreCase = true) && (fgPackage.contains("facebook", ignoreCase = true) || fgPackage.contains("katana", ignoreCase = true))) return true
        if (targetPackage.contains("snapchat", ignoreCase = true) && fgPackage.contains("snapchat", ignoreCase = true)) return true
        if (targetPackage.contains("reddit", ignoreCase = true) && fgPackage.contains("reddit", ignoreCase = true)) return true
        if ((targetPackage.contains("twitter", ignoreCase = true) || targetPackage.contains("x", ignoreCase = true)) && (fgPackage.contains("twitter", ignoreCase = true) || fgPackage.contains("x", ignoreCase = true))) return true
        if (targetPackage.contains("musically", ignoreCase = true) && (fgPackage.contains("musically", ignoreCase = true) || fgPackage.contains("tiktok", ignoreCase = true))) return true

        return false
    }

    fun grantExtension(minutes: Int) {
        extensionSeconds += (minutes * 60)
        isBlockerShowing = false
        Log.d("AwareScroll", "Extension granted: $minutes min. Total allowed: ${(limitMinutes * 60) + extensionSeconds}s")
    }

    private fun startTicker() {
        stopTicker()
        tickerRunnable = object : Runnable {
            override fun run() {
                if (isRunning) {
                    if (isTargetInForeground && !isBlockerShowing) {
                        elapsedSeconds++
                        Log.d("AwareScroll", "Target in FG ($targetAppName): $elapsedSeconds s / ${(limitMinutes * 60) + extensionSeconds} s")

                        val totalAllowed = targetTotalSeconds + extensionSeconds
                        if (elapsedSeconds >= totalAllowed) {
                            triggerBlocker()
                        }
                    }
                    handler.postDelayed(this, 1000)
                }
            }
        }
        handler.post(tickerRunnable!!)
    }

    private fun stopTicker() {
        tickerRunnable?.let { handler.removeCallbacks(it) }
        tickerRunnable = null
    }

    fun triggerBlocker() {
        if (isBlockerShowing) return
        isBlockerShowing = true
        Log.d("AwareScroll", "TRIGGERING BLOCKER for $targetAppName after $elapsedSeconds s!")

        val ctx = appContext ?: return

        // 1. Kick target app to home screen if Accessibility Service is active
        try {
            AwareScrollAccessibilityService.instance?.closeAppToHome()
        } catch (e: Exception) {
            Log.e("AwareScroll", "Failed to close via accessibility", e)
        }

        // 2. Prepare Blocker Intent
        val blockerIntent = Intent(ctx, AwareScrollBlockerActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP or
                    Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
            putExtra("APP_NAME", targetAppName)
            putExtra("PACKAGE_NAME", targetPackageName)
            putExtra("LIMIT_MINUTES", limitMinutes)
            putExtra("ELAPSED_MINUTES", elapsedSeconds / 60)
        }

        // 3. Launch via High-Priority FullScreenIntent Notification (works across Android 10-16)
        try {
            val fullScreenPendingIntent = PendingIntent.getActivity(
                ctx,
                2001,
                blockerIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val notificationManager = ctx.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
            val alertNotification = NotificationCompat.Builder(ctx, AwareScrollUsageService.ALERT_CHANNEL_ID)
                .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
                .setContentTitle("Your time is up on $targetAppName!")
                .setContentText("Tap to review boundary or close app.")
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setCategory(NotificationCompat.CATEGORY_ALARM)
                .setFullScreenIntent(fullScreenPendingIntent, true)
                .setAutoCancel(true)
                .build()

            notificationManager?.notify(AwareScrollUsageService.ALERT_NOTIFICATION_ID, alertNotification)
        } catch (e: Exception) {
            Log.e("AwareScroll", "Failed to send fullScreenIntent notification", e)
        }

        // 4. Also launch Activity directly
        try {
            ctx.startActivity(blockerIntent)
        } catch (e: Exception) {
            Log.e("AwareScroll", "Failed direct startActivity", e)
        }
    }
}
