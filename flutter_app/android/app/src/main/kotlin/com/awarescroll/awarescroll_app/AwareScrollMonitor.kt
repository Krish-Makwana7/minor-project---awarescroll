package com.awarescroll.awarescroll_app

import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper

object AwareScrollMonitor {
    var isRunning = false
    var targetAppName = "Instagram"
    var targetPackageName = "com.instagram.android"
    var limitMinutes = 5
    var elapsedSeconds = 0
    var extensionSeconds = 0
    var isTargetInForeground = false
    var isBlockerShowing = false

    private val handler = Handler(Looper.getMainLooper())
    private var tickerRunnable: Runnable? = null
    var appContext: Context? = null

    fun start(context: Context, appName: String, packageName: String, minutes: Int) {
        appContext = context.applicationContext
        targetAppName = appName
        targetPackageName = packageName
        limitMinutes = minutes
        elapsedSeconds = 0
        extensionSeconds = 0
        isRunning = true
        isBlockerShowing = false

        startTicker()
    }

    fun stop() {
        isRunning = false
        isTargetInForeground = false
        isBlockerShowing = false
        stopTicker()
    }

    fun onPackageForegrounded(packageName: String) {
        if (!isRunning) return

        if (packageName == targetPackageName) {
            isTargetInForeground = true
        } else if (packageName != "com.awarescroll.awarescroll_app") {
            isTargetInForeground = false
        }
    }

    fun onPackageBackgrounded(packageName: String) {
        if (!isRunning) return
        if (packageName == targetPackageName) {
            isTargetInForeground = false
        }
    }

    fun grantExtension(minutes: Int) {
        extensionSeconds += (minutes * 60)
        isBlockerShowing = false
    }

    private fun startTicker() {
        stopTicker()
        tickerRunnable = object : Runnable {
            override fun run() {
                if (isRunning) {
                    if (isTargetInForeground && !isBlockerShowing) {
                        elapsedSeconds++
                        val totalAllowed = (limitMinutes * 60) + extensionSeconds
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
        isBlockerShowing = true
        val ctx = appContext ?: return
        val intent = Intent(ctx, AwareScrollBlockerActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP or
                    Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
            putExtra("APP_NAME", targetAppName)
            putExtra("PACKAGE_NAME", targetPackageName)
            putExtra("LIMIT_MINUTES", limitMinutes)
            putExtra("ELAPSED_MINUTES", elapsedSeconds / 60)
        }
        ctx.startActivity(intent)
    }
}
