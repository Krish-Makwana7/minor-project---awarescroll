package com.awarescroll.ui.permission

import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Process
import android.provider.Settings
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Accessibility
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.QueryStats
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import com.awarescroll.ui.theme.*

@Composable
fun PermissionExplanationScreen(
    onContinue: (manualMode: Boolean) -> Unit,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current

    fun hasUsagePermission(): Boolean {
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

    var usageGranted by remember { mutableStateOf(hasUsagePermission()) }

    Column(
        modifier = modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(24.dp)
    ) {
        Text(text = "Transparency & Permissions", style = H1, color = MaterialTheme.colorScheme.onBackground)
        Spacer(modifier = Modifier.height(6.dp))
        Text(
            text = "AwareScroll AI + FocusLock never sells your data or reads private chats. We only measure session start/end timestamps and protect focus blocks.",
            style = Body,
            color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.7f)
        )

        Spacer(modifier = Modifier.height(24.dp))

        // 1. Usage Access Permission Explanation Card
        Card(
            shape = RoundedCornerShape(16.dp),
            colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
            border = androidx.compose.foundation.BorderStroke(1.dp, MaterialTheme.colorScheme.outline),
            modifier = Modifier.fillMaxWidth()
        ) {
            Column(modifier = Modifier.padding(18.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = Icons.Default.QueryStats,
                        contentDescription = "Usage Stats",
                        tint = Primary,
                        modifier = Modifier.size(24.dp)
                    )
                    Spacer(modifier = Modifier.width(10.dp))
                    Text(text = "Usage Access", style = H3)
                }
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = "Allows AwareScroll AI to detect when Instagram opens, compare time spent to your stated limit, and alert you at the moment drift occurs.",
                    style = BodySmall,
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f)
                )
                Spacer(modifier = Modifier.height(14.dp))

                if (usageGranted) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(imageVector = Icons.Default.CheckCircle, contentDescription = "Granted", tint = Success)
                        Spacer(modifier = Modifier.width(6.dp))
                        Text(text = "Permission Granted", style = BodySmall, color = Success)
                    }
                } else {
                    OutlinedButton(
                        onClick = {
                            val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
                            context.startActivity(intent)
                        },
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text("GRANT USAGE ACCESS")
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // 2. Accessibility Service Explanation Card
        Card(
            shape = RoundedCornerShape(16.dp),
            colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
            border = androidx.compose.foundation.BorderStroke(1.dp, MaterialTheme.colorScheme.outline),
            modifier = Modifier.fillMaxWidth()
        ) {
            Column(modifier = Modifier.padding(18.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = Icons.Default.Accessibility,
                        contentDescription = "Accessibility",
                        tint = Primary,
                        modifier = Modifier.size(24.dp)
                    )
                    Spacer(modifier = Modifier.width(10.dp))
                    Text(text = "FocusLock Guardian", style = H3)
                }
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = "Uses Android Accessibility APIs to detect distracting app switches while a focus session is actively running, gently bringing your focus countdown back to the front.",
                    style = BodySmall,
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f)
                )
                Spacer(modifier = Modifier.height(14.dp))

                OutlinedButton(
                    onClick = {
                        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                        context.startActivity(intent)
                    },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text("ENABLE FOCUSLOCK SERVICE")
                }
            }
        }

        Spacer(modifier = Modifier.height(24.dp))

        // Defensive Graceful Degradation Notice
        Surface(
            color = MaterialTheme.colorScheme.surface,
            shape = RoundedCornerShape(12.dp),
            border = androidx.compose.foundation.BorderStroke(1.dp, MaterialTheme.colorScheme.outline)
        ) {
            Row(
                modifier = Modifier.padding(14.dp),
                verticalAlignment = Alignment.Top
            ) {
                Icon(
                    imageVector = Icons.Default.Info,
                    contentDescription = "Notice",
                    tint = Primary,
                    modifier = Modifier.size(20.dp)
                )
                Spacer(modifier = Modifier.width(10.dp))
                Text(
                    text = "If you prefer not to grant system permissions, you can continue in Manual Check-in mode. You'll log session start and end times directly inside the app.",
                    style = Caption,
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f)
                )
            }
        }

        Spacer(modifier = Modifier.height(32.dp))

        PrimaryButton(
            text = "PROCEED WITH ACTIVE MONITORING",
            onClick = { onContinue(false) }
        )

        Spacer(modifier = Modifier.height(12.dp))

        SecondaryButton(
            text = "CONTINUE IN MANUAL CHECK-IN MODE",
            onClick = { onContinue(true) }
        )
    }
}
