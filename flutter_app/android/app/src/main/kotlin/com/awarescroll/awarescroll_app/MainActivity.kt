package com.awarescroll.awarescroll_app

import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Process
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.awarescroll/restriction"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkPermissions" -> {
                    result.success(
                        mapOf(
                            "usage" to hasUsageAccess(),
                            "overlay" to hasOverlayPermission(),
                            "accessibility" to hasAccessibilityPermission()
                        )
                    )
                }

                "openUsageSettings" -> {
                    try {
                        startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                    } catch (e: Exception) {
                        startActivity(Intent(Settings.ACTION_SETTINGS))
                    }
                    result.success(true)
                }

                "openOverlaySettings" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        try {
                            val intent = Intent(
                                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                                Uri.parse("package:$packageName")
                            )
                            startActivity(intent)
                        } catch (e: Exception) {
                            startActivity(Intent(Settings.ACTION_SETTINGS))
                        }
                    }
                    result.success(true)
                }

                "openAccessibilitySettings" -> {
                    try {
                        startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                    } catch (e: Exception) {
                        startActivity(Intent(Settings.ACTION_SETTINGS))
                    }
                    result.success(true)
                }

                "startRestriction" -> {
                    val appName = call.argument<String>("appName") ?: "Instagram"
                    val pkgName = call.argument<String>("packageName") ?: "com.instagram.android"
                    val minutes = call.argument<Int>("minutes") ?: 5
                    val seconds = call.argument<Int>("seconds") ?: (minutes * 60)

                    val serviceIntent = Intent(this, AwareScrollUsageService::class.java).apply {
                        putExtra("APP_NAME", appName)
                        putExtra("PACKAGE_NAME", pkgName)
                        putExtra("LIMIT_MINUTES", minutes)
                        putExtra("LIMIT_SECONDS", seconds)
                    }

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        startForegroundService(serviceIntent)
                    } else {
                        startService(serviceIntent)
                    }

                    result.success(true)
                }

                "stopRestriction" -> {
                    val serviceIntent = Intent(this, AwareScrollUsageService::class.java)
                    stopService(serviceIntent)
                    AwareScrollMonitor.stop()
                    result.success(true)
                }

                "getStatus" -> {
                    result.success(
                        mapOf(
                            "isRunning" to AwareScrollMonitor.isRunning,
                            "appName" to AwareScrollMonitor.targetAppName,
                            "packageName" to AwareScrollMonitor.targetPackageName,
                            "limitMinutes" to AwareScrollMonitor.limitMinutes,
                            "elapsedSeconds" to AwareScrollMonitor.elapsedSeconds,
                            "isTargetInForeground" to AwareScrollMonitor.isTargetInForeground
                        )
                    )
                }

                "grantExtension" -> {
                    val minutes = call.argument<Int>("minutes") ?: 5
                    AwareScrollMonitor.grantExtension(minutes)
                    result.success(true)
                }

                "closeTargetApp" -> {
                    AwareScrollOverlayManager.hide()
                    val closed = AwareScrollAccessibilityService.instance?.closeAppToHome() ?: false
                    if (!closed) {
                        val homeIntent = Intent(Intent.ACTION_MAIN).apply {
                            addCategory(Intent.CATEGORY_HOME)
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                        startActivity(homeIntent)
                    }
                    result.success(true)
                }

                "testBlocker" -> {
                    AwareScrollMonitor.triggerBlocker()
                    result.success(true)
                }

                "getInstalledApps" -> {
                    try {
                        val pm = packageManager
                        val intent = Intent(Intent.ACTION_MAIN, null).apply {
                            addCategory(Intent.CATEGORY_LAUNCHER)
                        }
                        val resolveInfos = pm.queryIntentActivities(intent, 0)
                        val apps = mutableListOf<Map<String, String>>()
                        for (info in resolveInfos) {
                            val pkg = info.activityInfo.packageName
                            if (pkg != packageName) {
                                val label = info.loadLabel(pm).toString()
                                apps.add(mapOf("name" to label, "package" to pkg))
                            }
                        }
                        apps.sortBy { it["name"]?.lowercase() ?: "" }
                        result.success(apps)
                    } catch (e: Exception) {
                        result.success(emptyList<Map<String, String>>())
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun hasUsageAccess(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as? AppOpsManager ?: return false
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                packageName
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun hasOverlayPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this)
        } else {
            true
        }
    }

    private fun hasAccessibilityPermission(): Boolean {
        if (AwareScrollAccessibilityService.instance != null) return true
        return try {
            val enabledServices = Settings.Secure.getString(
                contentResolver,
                Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
            ) ?: return false
            enabledServices.contains(packageName)
        } catch (e: Exception) {
            false
        }
    }
}
