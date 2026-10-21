package com.awarescroll.ui

import android.os.Bundle
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

        val showReflection = intent.getBooleanExtra(UsageMonitorService.EXTRA_SHOW_REFLECTION, false)
        val startDestination = if (showReflection) Screen.Reflection.route else Screen.Goals.route

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
}
