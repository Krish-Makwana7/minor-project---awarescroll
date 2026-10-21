package com.awarescroll.ui.focuslock

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.PhotoCamera
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.awarescroll.AwareScrollApp
import com.awarescroll.data.local.FocusSessionEntity
import com.awarescroll.data.local.InterruptionEntity
import com.awarescroll.services.FocusLockAccessibilityService
import com.awarescroll.ui.theme.*
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.util.UUID

@Composable
fun FocusLockScreen(
    taskDescription: String,
    taskCategory: String,
    plannedDurationMinutes: Int,
    onSessionFinished: () -> Unit,
    modifier: Modifier = Modifier
) {
    val repository = AwareScrollApp.instance.repository
    val scope = rememberCoroutineScope()

    val totalSeconds = plannedDurationMinutes * 60
    var secondsRemaining by remember { mutableStateOf(totalSeconds) }
    var isRunning by remember { mutableStateOf(true) }
    var isCompleted by remember { mutableStateOf(false) }
    var showInterruptionDialog by remember { mutableStateOf(false) }
    var workEvidenceUploaded by remember { mutableStateOf(false) }

    val sessionId = remember { UUID.randomUUID().toString() }
    val startTime = remember { System.currentTimeMillis() }

    // Activate accessibility restriction service
    DisposableEffect(Unit) {
        FocusLockAccessibilityService.isFocusSessionActive = true
        onDispose {
            FocusLockAccessibilityService.isFocusSessionActive = false
        }
    }

    // Countdown Timer Loop
    LaunchedEffect(isRunning, secondsRemaining) {
        if (isRunning && secondsRemaining > 0) {
            delay(1000)
            secondsRemaining--
            if (secondsRemaining <= 0) {
                isRunning = false
                isCompleted = true
                FocusLockAccessibilityService.isFocusSessionActive = false

                // Record completed session
                repository.recordFocusSession(
                    FocusSessionEntity(
                        id = sessionId,
                        intentionId = null,
                        taskCategory = taskCategory,
                        taskDescription = taskDescription,
                        plannedDurationMinutes = plannedDurationMinutes,
                        startTime = startTime,
                        endTime = System.currentTimeMillis(),
                        completed = true,
                        interrupted = false
                    )
                )
            }
        }
    }

    // Format mm:ss
    val minutes = secondsRemaining / 60
    val seconds = secondsRemaining % 60
    val timeFormatted = String.format("%02d:%02d", minutes, seconds)
    val progress = (secondsRemaining.toFloat() / totalSeconds.toFloat()).coerceIn(0f, 1f)

    // Forced Dark Background regardless of system theme
    Box(
        modifier = modifier
            .fillMaxSize()
            .background(BackgroundDark)
            .padding(24.dp)
    ) {
        Column(
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.SpaceBetween
        ) {
            // Header: Focus Status & Category
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Spacer(modifier = Modifier.height(24.dp))
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = Icons.Default.Lock,
                        contentDescription = "Locked",
                        tint = Primary,
                        modifier = Modifier.size(18.dp)
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    Text(
                        text = "FOCUSLOCK ACTIVE",
                        style = StatLabel,
                        color = Primary
                    )
                }

                Spacer(modifier = Modifier.height(16.dp))

                Surface(
                    color = SurfaceDark,
                    shape = RoundedCornerShape(16.dp),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text(
                            text = taskCategory.uppercase(),
                            style = Caption,
                            color = Primary
                        )
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            text = taskDescription,
                            style = H2,
                            color = Color.White
                        )
                    }
                }
            }

            // Big Timer Display with Circular Progress Indicator
            Box(
                contentAlignment = Alignment.Center,
                modifier = Modifier.size(260.dp)
            ) {
                CircularProgressIndicator(
                    progress = { progress },
                    modifier = Modifier.fillMaxSize(),
                    strokeWidth = 10.dp,
                    color = if (isCompleted) Success else Primary,
                    trackColor = BorderColorDark
                )

                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    if (isCompleted) {
                        Icon(
                            imageVector = Icons.Default.CheckCircle,
                            contentDescription = "Completed",
                            tint = Success,
                            modifier = Modifier.size(48.dp)
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = "COMPLETED",
                            style = H2,
                            color = Success
                        )
                    } else {
                        Text(
                            text = timeFormatted,
                            style = StatTimer.copy(fontSize = 54.sp, lineHeight = 60.sp),
                            color = Color.White
                        )
                        Spacer(modifier = Modifier.height(6.dp))
                        Text(
                            text = "STAY PRESENT",
                            style = StatLabel,
                            color = TextSecondaryDark
                        )
                    }
                }
            }

            // Evidence Upload & Exit Controls
            Column(
                modifier = Modifier.fillMaxWidth(),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                // Optional work-evidence upload
                OutlinedButton(
                    onClick = { workEvidenceUploaded = !workEvidenceUploaded },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(44.dp),
                    shape = RoundedCornerShape(12.dp),
                    colors = ButtonDefaults.outlinedButtonColors(
                        contentColor = if (workEvidenceUploaded) Success else TextSecondaryDark
                    ),
                    border = BorderStroke(1.dp, if (workEvidenceUploaded) Success else BorderColorDark)
                ) {
                    Icon(
                        imageVector = Icons.Default.PhotoCamera,
                        contentDescription = "Evidence",
                        modifier = Modifier.size(16.dp)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = if (workEvidenceUploaded) "Evidence Attached (Supporting)" else "Attach Work Evidence (Optional)",
                        style = BodySmall
                    )
                }

                Spacer(modifier = Modifier.height(16.dp))

                if (isCompleted) {
                    PrimaryButton(
                        text = "RETURN TO DASHBOARD",
                        onClick = onSessionFinished
                    )
                } else {
                    // Deliberate "End Session" action - opens confirmation dialog with interruption logging
                    DestructiveButton(
                        text = "END SESSION EARLY",
                        onClick = {
                            showInterruptionDialog = true
                        }
                    )
                }
                Spacer(modifier = Modifier.height(16.dp))
            }
        }
    }

    if (showInterruptionDialog) {
        InterruptionDialog(
            onConfirmExit = { category, reason ->
                showInterruptionDialog = false
                isRunning = false
                FocusLockAccessibilityService.isFocusSessionActive = false

                scope.launch {
                    // Record interrupted focus session
                    repository.recordFocusSession(
                        FocusSessionEntity(
                            id = sessionId,
                            intentionId = null,
                            taskCategory = taskCategory,
                            taskDescription = taskDescription,
                            plannedDurationMinutes = plannedDurationMinutes,
                            startTime = startTime,
                            endTime = System.currentTimeMillis(),
                            completed = false,
                            interrupted = true
                        )
                    )
                    // Log interruption record
                    repository.logInterruption(
                        InterruptionEntity(
                            focusSessionId = sessionId,
                            reasonText = reason,
                            reasonCategory = category
                        )
                    )
                    onSessionFinished()
                }
            },
            onDismiss = { showInterruptionDialog = false }
        )
    }
}
