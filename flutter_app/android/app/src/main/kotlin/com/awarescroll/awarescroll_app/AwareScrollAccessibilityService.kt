package com.awarescroll.awarescroll_app

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent

class AwareScrollAccessibilityService : AccessibilityService() {

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val pkg = event.packageName?.toString() ?: return

            // If time limit is reached / restricted:
            if (AwareScrollMonitor.isRestricted) {
                if (AwareScrollMonitor.isMatchingPackage(pkg, AwareScrollMonitor.targetPackageName)) {
                    // Instagram is in foreground -> Block immediately with overlay!
                    AwareScrollMonitor.triggerBlocker()
                    return
                } else if (pkg != "com.awarescroll.awarescroll_app" && pkg != "com.android.systemui") {
                    // User went to home screen or another app -> temporarily hide overlay
                    AwareScrollOverlayManager.hide()
                }
            }

            AwareScrollMonitor.onAccessibilityWindowStateChanged(pkg)
        }
    }

    override fun onInterrupt() {}

    fun closeAppToHome(): Boolean {
        val success = performGlobalAction(GLOBAL_ACTION_HOME)
        if (!success) {
            val homeIntent = Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_HOME)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            startActivity(homeIntent)
        }
        return true
    }

    override fun onDestroy() {
        if (instance == this) {
            instance = null
        }
        super.onDestroy()
    }

    companion object {
        var instance: AwareScrollAccessibilityService? = null
    }
}
