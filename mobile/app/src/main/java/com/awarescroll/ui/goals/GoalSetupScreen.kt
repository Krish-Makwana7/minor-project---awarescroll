package com.awarescroll.ui.goals

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.awarescroll.AwareScrollApp
import com.awarescroll.data.local.GoalEntity
import com.awarescroll.ui.theme.*
import kotlinx.coroutines.launch

@Composable
fun GoalSetupScreen(
    onNavigateToIntention: () -> Unit,
    modifier: Modifier = Modifier
) {
    val repository = AwareScrollApp.instance.repository
    val scope = rememberCoroutineScope()

    var instagramDailyLimit by remember { mutableStateOf(30) }
    var avoidHoursLimit by remember { mutableStateOf(15) }
    var focusTargetMinutes by remember { mutableStateOf(90) }
    var enableAvoidHours by remember { mutableStateOf(true) }
    var savedSuccessMessage by remember { mutableStateOf<String?>(null) }

    Column(
        modifier = modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(20.dp)
    ) {
        Text(text = "Personal Boundaries", style = H1, color = MaterialTheme.colorScheme.onBackground)
        Spacer(modifier = Modifier.height(6.dp))
        Text(
            text = "Define your targets so AwareScroll AI and FocusLock know when behavior diverges from intention.",
            style = Body,
            color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.7f)
        )

        Spacer(modifier = Modifier.height(24.dp))

        // 1. Daily Instagram Limit
        Text(text = "Daily Instagram Limit", style = H3)
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = "Reflection prompt triggers when your total daily scrolling crosses this mark.",
            style = BodySmall,
            color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.6f)
        )
        Spacer(modifier = Modifier.height(8.dp))
        StepperInput(
            value = instagramDailyLimit,
            onValueChange = { instagramDailyLimit = it },
            minValue = 5,
            maxValue = 120,
            step = 5,
            unit = "min / day"
        )

        Spacer(modifier = Modifier.height(24.dp))

        // 2. Study / Avoid Hours Guard
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(text = "Study Hours Restriction", style = H3)
                Text(
                    text = "Apply tighter limits during peak study/work hours (2:00 PM – 6:00 PM)",
                    style = BodySmall,
                    color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.6f)
                )
            }
            Switch(
                checked = enableAvoidHours,
                onCheckedChange = { enableAvoidHours = it },
                colors = SwitchDefaults.colors(checkedThumbColor = Primary, checkedTrackColor = Primary.copy(alpha = 0.3f))
            )
        }
        if (enableAvoidHours) {
            Spacer(modifier = Modifier.height(8.dp))
            StepperInput(
                value = avoidHoursLimit,
                onValueChange = { avoidHoursLimit = it },
                minValue = 5,
                maxValue = 30,
                step = 5,
                unit = "min max"
            )
        }

        Spacer(modifier = Modifier.height(24.dp))

        // 3. Daily Focus Target
        Text(text = "Daily Deep Work Target", style = H3)
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = "Target minutes protected under FocusLock blocks each day.",
            style = BodySmall,
            color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.6f)
        )
        Spacer(modifier = Modifier.height(8.dp))
        StepperInput(
            value = focusTargetMinutes,
            onValueChange = { focusTargetMinutes = it },
            minValue = 25,
            maxValue = 300,
            step = 15,
            unit = "min"
        )

        Spacer(modifier = Modifier.height(32.dp))

        savedSuccessMessage?.let { msg ->
            Surface(
                color = Success.copy(alpha = 0.15f),
                shape = MaterialTheme.shapes.small,
                modifier = Modifier.fillMaxWidth()
            ) {
                Text(
                    text = msg,
                    style = BodySmall,
                    color = Success,
                    modifier = Modifier.padding(12.dp)
                )
            }
            Spacer(modifier = Modifier.height(16.dp))
        }

        PrimaryButton(
            text = "Save Goals & Continue",
            onClick = {
                scope.launch {
                    repository.saveGoal(
                        GoalEntity(
                            goalType = "instagram_time_limit",
                            targetValue = instagramDailyLimit.toDouble(),
                            unit = "minutes"
                        )
                    )
                    repository.saveGoal(
                        GoalEntity(
                            goalType = "focus_session_target",
                            targetValue = focusTargetMinutes.toDouble(),
                            unit = "minutes"
                        )
                    )
                    savedSuccessMessage = "Personal goals saved successfully."
                    onNavigateToIntention()
                }
            }
        )
    }
}
