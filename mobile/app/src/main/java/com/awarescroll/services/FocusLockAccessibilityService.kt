package com.awarescroll.services

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import com.awarescroll.ui.MainActivity

class FocusLockAccessibilityService : AccessibilityService() {

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null || !isFocusSessionActive) return

        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val packageName = event.packageName?.toString() ?: return

            // If an app switch to Instagram or blacklisted app happens during an active FocusLock block:
            if (DISTRACTING_PACKAGES.contains(packageName)) {
                // Intercept and redirect back to FocusLock restriction screen
                val redirectIntent = Intent(this, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
                    putExtra("FOCUS_BLOCK_INTERCEPTED", true)
                }
                startActivity(redirectIntent)
            }
        }
    }

    fun closeCurrentApp(): Boolean {
        return performGlobalAction(GLOBAL_ACTION_HOME)
    }

    override fun onInterrupt() {
        // Accessibility service interrupted by system
    }

    override fun onDestroy() {
        instance = null
        super.onDestroy()
    }

    companion object {
        @Volatile
        var instance: FocusLockAccessibilityService? = null

        @Volatile
        var isFocusSessionActive: Boolean = false

        val DISTRACTING_PACKAGES = setOf(
            "com.instagram.android",
            "com.facebook.katana",
            "com.snapchat.android",
            "com.google.android.youtube",
            "com.reddit.frontpage",
            "com.zhiliaoapp.musically", // TikTok
            "com.twitter.android",
            "com.x.android"
        )
    }
}
