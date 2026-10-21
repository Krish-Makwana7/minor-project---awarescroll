package com.awarescroll.ui.navigation

import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.BarChart
import androidx.compose.material.icons.filled.Flag
import androidx.compose.material.icons.filled.PlayCircleOutline
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.NavHostController
import androidx.navigation.compose.*
import com.awarescroll.ui.awarescroll.ReflectionModal
import com.awarescroll.ui.focuslock.FocusLockScreen
import com.awarescroll.ui.goals.GoalSetupScreen
import com.awarescroll.ui.insights.InsightsDashboardScreen
import com.awarescroll.ui.intention.IntentionCaptureScreen
import com.awarescroll.ui.permission.PermissionExplanationScreen
import com.awarescroll.ui.theme.Primary

@Composable
fun NavGraph(
    navController: NavHostController,
    startDestination: String = Screen.Goals.route,
    modifier: Modifier = Modifier
) {
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = navBackStackEntry?.destination?.route

    // Show bottom bar on primary top-level tabs only
    val showBottomBar = currentRoute in listOf(
        Screen.Goals.route,
        Screen.Intention.route,
        Screen.Insights.route
    )

    Scaffold(
        bottomBar = {
            if (showBottomBar) {
                NavigationBar {
                    NavigationBarItem(
                        icon = { Icon(Icons.Default.Flag, contentDescription = "Goals") },
                        label = { Text("Goals") },
                        selected = currentRoute == Screen.Goals.route,
                        onClick = {
                            navController.navigate(Screen.Goals.route) {
                                popUpTo(navController.graph.findStartDestination().id) { saveState = true }
                                launchSingleTop = true
                                restoreState = true
                            }
                        },
                        colors = NavigationBarItemDefaults.colors(selectedIconColor = Primary, selectedTextColor = Primary)
                    )
                    NavigationBarItem(
                        icon = { Icon(Icons.Default.PlayCircleOutline, contentDescription = "Intention") },
                        label = { Text("Intention") },
                        selected = currentRoute == Screen.Intention.route,
                        onClick = {
                            navController.navigate(Screen.Intention.route) {
                                popUpTo(navController.graph.findStartDestination().id) { saveState = true }
                                launchSingleTop = true
                                restoreState = true
                            }
                        },
                        colors = NavigationBarItemDefaults.colors(selectedIconColor = Primary, selectedTextColor = Primary)
                    )
                    NavigationBarItem(
                        icon = { Icon(Icons.Default.BarChart, contentDescription = "Insights") },
                        label = { Text("Insights") },
                        selected = currentRoute == Screen.Insights.route,
                        onClick = {
                            navController.navigate(Screen.Insights.route) {
                                popUpTo(navController.graph.findStartDestination().id) { saveState = true }
                                launchSingleTop = true
                                restoreState = true
                            }
                        },
                        colors = NavigationBarItemDefaults.colors(selectedIconColor = Primary, selectedTextColor = Primary)
                    )
                }
            }
        }
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = startDestination,
            modifier = modifier.padding(innerPadding)
        ) {
            composable(Screen.Goals.route) {
                GoalSetupScreen(
                    onNavigateToIntention = {
                        navController.navigate(Screen.Intention.route)
                    }
                )
            }

            composable(Screen.Intention.route) {
                IntentionCaptureScreen(
                    onStartFocusSession = { task, category, duration ->
                        navController.navigate("${Screen.FocusLock.route}/$task/$category/$duration")
                    }
                )
            }

            composable(
                route = "${Screen.FocusLock.route}/{task}/{category}/{duration}"
            ) { backStackEntry ->
                val task = backStackEntry.arguments?.getString("task") ?: "Deep Work"
                val category = backStackEntry.arguments?.getString("category") ?: "Study"
                val duration = backStackEntry.arguments?.getString("duration")?.toIntOrNull() ?: 25

                FocusLockScreen(
                    taskDescription = task,
                    taskCategory = category,
                    plannedDurationMinutes = duration,
                    onSessionFinished = {
                        navController.navigate(Screen.Insights.route) {
                            popUpTo(Screen.Intention.route) { inclusive = false }
                        }
                    }
                )
            }

            composable(Screen.Reflection.route) {
                ReflectionModal(
                    elapsedMinutes = 25,
                    intendedMinutes = 15,
                    originalPurpose = "Quick check on DMs",
                    usageSessionId = null,
                    onCloseInstagram = {
                        navController.navigate(Screen.Insights.route)
                    },
                    onContinueAnyway = {
                        navController.navigate(Screen.Insights.route)
                    }
                )
            }

            composable(Screen.Insights.route) {
                InsightsDashboardScreen(
                    onNavigateToIntention = {
                        navController.navigate(Screen.Intention.route)
                    }
                )
            }

            composable(Screen.Permission.route) {
                PermissionExplanationScreen(
                    onContinue = { manualMode ->
                        navController.navigate(Screen.Goals.route) {
                            popUpTo(Screen.Permission.route) { inclusive = true }
                        }
                    }
                )
            }
        }
    }
}
