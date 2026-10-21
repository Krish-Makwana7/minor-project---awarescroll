package com.awarescroll.ui.intention

import android.content.Intent
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.awarescroll.AwareScrollApp
import com.awarescroll.data.local.IntentionEntity
import com.awarescroll.services.UsageMonitorService
import com.awarescroll.ui.theme.*
import kotlinx.coroutines.launch
import java.util.UUID

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun IntentionCaptureScreen(
    onStartFocusSession: (task: String, category: String, duration: Int) -> Unit,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    val repository = AwareScrollApp.instance.repository
    val scope = rememberCoroutineScope()

    var selectedSessionType by remember { mutableStateOf("instagram") } // "instagram" or "focus"

    // Instagram Intention state
    var instagramDuration by remember { mutableStateOf(15) }
    var selectedInstagramPurpose by remember { mutableStateOf("Reply to DMs") }
    var instagramPurposeCustom by remember { mutableStateOf("") }
    var predictedOverrunRisk by remember { mutableStateOf<Float?>(null) }
    var suggestedLimit by remember { mutableStateOf<Int?>(null) }

    // Focus Intention state
    var focusTaskDescription by remember { mutableStateOf("") }
    var selectedCategory by remember { mutableStateOf("Study") }
    var focusDuration by remember { mutableStateOf(25) }

    val purposeChips = listOf("Reply to DMs", "Quick check", "Catch up on feed", "Watch Reels", "Research/Ideas")
    val categoryChips = listOf("Study", "Coding", "Writing", "Work", "Reading")

    // Fetch predictive overrun score when Instagram duration changes
    LaunchedEffect(instagramDuration, selectedInstagramPurpose) {
        val purpose = if (instagramPurposeCustom.isNotBlank()) instagramPurposeCustom else selectedInstagramPurpose
        val res = repository.predictOverrun(instagramDuration, purpose)
        res.onSuccess {
            predictedOverrunRisk = it.riskScore
            suggestedLimit = it.suggestedLimit
        }
    }

    Column(
        modifier = modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(20.dp)
    ) {
        Text(text = "State Your Intention", style = H1, color = MaterialTheme.colorScheme.onBackground)
        Spacer(modifier = Modifier.height(6.dp))
        Text(
            text = "Every session begins by naming your goal and duration. This intention anchors your behavior.",
            style = Body,
            color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.7f)
        )

        Spacer(modifier = Modifier.height(20.dp))

        // Session Type Selector Tabs
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            FilterChip(
                selected = selectedSessionType == "instagram",
                onClick = { selectedSessionType = "instagram" },
                label = { Text("AwareScroll (Instagram)") },
                modifier = Modifier.weight(1f),
                colors = FilterChipDefaults.filterChipColors(
                    selectedContainerColor = Primary,
                    selectedLabelColor = MaterialTheme.colorScheme.surface
                )
            )
            FilterChip(
                selected = selectedSessionType == "focus",
                onClick = { selectedSessionType = "focus" },
                label = { Text("FocusLock (Deep Work)") },
                modifier = Modifier.weight(1f),
                colors = FilterChipDefaults.filterChipColors(
                    selectedContainerColor = Primary,
                    selectedLabelColor = MaterialTheme.colorScheme.surface
                )
            )
        }

        Spacer(modifier = Modifier.height(24.dp))

        if (selectedSessionType == "instagram") {
            // AwareScroll flow
            Text(text = "Intended Instagram Duration", style = H3)
            Spacer(modifier = Modifier.height(8.dp))
            StepperInput(
                value = instagramDuration,
                onValueChange = { instagramDuration = it },
                minValue = 5,
                maxValue = 60,
                step = 5,
                unit = "minutes"
            )

            Spacer(modifier = Modifier.height(20.dp))
            Text(text = "What is your purpose?", style = H3)
            Spacer(modifier = Modifier.height(8.dp))

            FlowRow(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                purposeChips.forEach { chip ->
                    FilterChip(
                        selected = selectedInstagramPurpose == chip,
                        onClick = {
                            selectedInstagramPurpose = chip
                            instagramPurposeCustom = ""
                        },
                        label = { Text(chip) }
                    )
                }
            }

            Spacer(modifier = Modifier.height(12.dp))
            OutlinedTextField(
                value = instagramPurposeCustom,
                onValueChange = { instagramPurposeCustom = it },
                label = { Text("Or specific purpose (e.g. reply to Sarah)") },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp)
            )

            // Predictive Risk Warning (if elevated)
            predictedOverrunRisk?.let { risk ->
                if (risk >= 0.55f) {
                    Spacer(modifier = Modifier.height(16.dp))
                    Card(
                        colors = CardDefaults.cardColors(containerColor = AccentReflect.copy(alpha = 0.12f)),
                        border = BorderStroke(1.dp, AccentReflect.copy(alpha = 0.4f)),
                        shape = RoundedCornerShape(12.dp)
                    ) {
                        Column(modifier = Modifier.padding(14.dp)) {
                            Text(
                                text = "Overrun Risk: ${(risk * 100).toInt()}%",
                                style = H3.copy(fontSize = 16.sp, lineHeight = 20.sp),
                                color = AccentReflect
                            )
                            Spacer(modifier = Modifier.height(4.dp))
                            Text(
                                text = "Based on time of day and purpose, scrolling past $instagramDuration min is likely. Suggested cap: ${suggestedLimit ?: 10} min.",
                                style = BodySmall,
                                color = MaterialTheme.colorScheme.onSurface
                            )
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(32.dp))
            PrimaryButton(
                text = "Begin AwareScroll Session",
                onClick = {
                    scope.launch {
                        val intentionId = UUID.randomUUID().toString()
                        val finalPurpose = if (instagramPurposeCustom.isNotBlank()) instagramPurposeCustom else selectedInstagramPurpose

                        repository.saveIntention(
                            IntentionEntity(
                                id = intentionId,
                                sessionType = "instagram",
                                intendedDurationMinutes = instagramDuration,
                                intendedPurpose = finalPurpose
                            )
                        )

                        // Start UsageMonitorService foreground service
                        val serviceIntent = Intent(context, UsageMonitorService::class.java).apply {
                            action = UsageMonitorService.ACTION_START
                            putExtra(UsageMonitorService.EXTRA_INTENTION_ID, intentionId)
                            putExtra(UsageMonitorService.EXTRA_LIMIT_MINUTES, instagramDuration)
                        }
                        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                            context.startForegroundService(serviceIntent)
                        } else {
                            context.startService(serviceIntent)
                        }

                        // Launch Instagram if installed
                        val launchIntent = context.packageManager.getLaunchIntentForPackage(UsageMonitorService.INSTAGRAM_PACKAGE)
                        if (launchIntent != null) {
                            context.startActivity(launchIntent)
                        }
                    }
                }
            )

        } else {
            // FocusLock flow
            Text(text = "Task Category", style = H3)
            Spacer(modifier = Modifier.height(8.dp))

            FlowRow(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                categoryChips.forEach { cat ->
                    FilterChip(
                        selected = selectedCategory == cat,
                        onClick = { selectedCategory = cat },
                        label = { Text(cat) }
                    )
                }
            }

            Spacer(modifier = Modifier.height(16.dp))
            Text(text = "What will you accomplish?", style = H3)
            Spacer(modifier = Modifier.height(8.dp))
            OutlinedTextField(
                value = focusTaskDescription,
                onValueChange = { focusTaskDescription = it },
                label = { Text("Task (e.g. Finish Chapter 3 review questions)") },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp)
            )

            Spacer(modifier = Modifier.height(20.dp))
            Text(text = "Planned Duration", style = H3)
            Spacer(modifier = Modifier.height(8.dp))
            StepperInput(
                value = focusDuration,
                onValueChange = { focusDuration = it },
                minValue = 15,
                maxValue = 120,
                step = 5,
                unit = "minutes"
            )

            Spacer(modifier = Modifier.height(32.dp))
            PrimaryButton(
                text = "Enter FocusLock Block",
                enabled = focusTaskDescription.isNotBlank(),
                onClick = {
                    scope.launch {
                        val intentionId = UUID.randomUUID().toString()
                        repository.saveIntention(
                            IntentionEntity(
                                id = intentionId,
                                sessionType = "focus",
                                intendedDurationMinutes = focusDuration,
                                intendedPurpose = "$selectedCategory: $focusTaskDescription"
                            )
                        )
                        onStartFocusSession(focusTaskDescription, selectedCategory, focusDuration)
                    }
                }
            )
        }
    }
}
