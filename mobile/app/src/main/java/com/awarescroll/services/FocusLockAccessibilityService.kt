package com.awarescroll.services

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import com.awarescroll.ui.MainActivity

class FocusLockAccessibilityService : AccessibilityService() {

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

    override fun onInterrupt() {
        // Accessibility service interrupted by system
    }

    companion object {
        @Volatile
        var isFocusSessionActive: Boolean = false

        private val DISTRACTING_PACKAGES = setOf(
            "com.instagram.android",
            "com.zhiliaoapp.musically", // TikTok
            "com.twitter.android",
            "com.facebook.katana"
        )
    }
}
