package com.awarescroll.ui.navigation

sealed class Screen(val route: String, val title: String) {
    object Goals : Screen("goals", "Goals")
    object Intention : Screen("intention", "Intentions")
    object FocusLock : Screen("focuslock", "FocusLock")
    object Reflection : Screen("reflection", "AwareScroll")
    object Insights : Screen("insights", "Dashboard")
    object Permission : Screen("permission", "Permissions")
}
