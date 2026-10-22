package com.awarescroll.ui

import android.app.AppOpsManager
import android.content.Context
import android.os.Build
import android.os.Bundle
import android.os.Process
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import androidx.navigation.compose.rememberNavController
import com.awarescroll.services.UsageMonitorService
import com.awarescroll.ui.navigation.NavGraph
import com.awarescroll.ui.navigation.Screen
import com.awarescroll.ui.theme.AwareScrollTheme

class MainActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val hasUsage = hasUsagePermission(this)
        if (hasUsage) {
            // Automatically ensure background monitor is active for social media apps
            UsageMonitorService.startMonitoring(this, limitMinutes = 5)
        }

        val showReflection = intent.getBooleanExtra(UsageMonitorService.EXTRA_SHOW_REFLECTION, false)
        val startDestination = when {
            showReflection -> Screen.Reflection.route
            !hasUsage -> Screen.Permission.route
            else -> Screen.Insights.route // Default directly to User Dashboard
        }

        setContent {
            AwareScrollTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = androidx.compose.material3.MaterialTheme.colorScheme.background
                ) {
                    val navController = rememberNavController()
                    NavGraph(
                        navController = navController,
                        startDestination = startDestination
                    )
                }
            }
        }
    }

    override fun onResume() {
        super.onResume()
        if (hasUsagePermission(this)) {
            UsageMonitorService.startMonitoring(this, limitMinutes = 5)
        }
    }

    private fun hasUsagePermission(context: Context): Boolean {
        val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as? AppOpsManager ?: return false
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                context.packageName
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                context.packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }
}
