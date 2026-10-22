package com.awarescroll.ui.awarescroll

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.awarescroll.AwareScrollApp
import com.awarescroll.data.local.FeedbackEntity
import com.awarescroll.ui.theme.*
import kotlinx.coroutines.launch
import java.util.UUID

@OptIn(ExperimentalMaterial3Api::class, ExperimentalLayoutApi::class)
@Composable
fun ReflectionModal(
    elapsedMinutes: Int,
    intendedMinutes: Int,
    originalPurpose: String?,
    usageSessionId: String?,
    onCloseInstagram: () -> Unit,
    onContinueAnyway: () -> Unit,
    modifier: Modifier = Modifier
) {
    val repository = AwareScrollApp.instance.repository
    val scope = rememberCoroutineScope()

    var motivation by remember { mutableStateOf("Lost track of time") }
    var contentType by remember { mutableStateOf("Reels") }
    var delayedWork by remember { mutableStateOf(false) }
    var mood by remember { mutableStateOf("Neutral") }

    val motivations = listOf("Lost track of time", "Boredom", "Got hooked on Reels", "Habitual check", "Interesting conversation")
    val contentTypes = listOf("Reels", "DMs", "Explore feed", "Stories")
    val moods = listOf("Guilty", "Neutral", "Energized", "Anxious", "Satisfied")

    Card(
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(topStart = 24.dp, topEnd = 24.dp)),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        elevation = CardDefaults.cardElevation(defaultElevation = 8.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .verticalScroll(rememberScrollState())
        ) {
            // Accent-tinted header strip
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(6.dp)
                    .background(AccentReflect)
            )

            Column(modifier = Modifier.padding(24.dp)) {
                // Header
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(text = "Limit Reached", style = H2, color = AccentReflect)
                    Surface(
                        color = AccentReflect.copy(alpha = 0.15f),
                        shape = RoundedCornerShape(12.dp)
                    ) {
                        Text(
                            text = "${elapsedMinutes}m / ${intendedMinutes}m",
                            style = StatLabel,
                            color = AccentReflect,
                            modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                        )
                    }
                }

                Spacer(modifier = Modifier.height(6.dp))
                Text(
                    text = "You intended to use Instagram for $intendedMinutes min${if (!originalPurpose.isNullOrBlank()) " to $originalPurpose" else ""}. Intention drifted.",
                    style = Body,
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.8f)
                )

                Spacer(modifier = Modifier.height(20.dp))
                Divider(color = MaterialTheme.colorScheme.outline.copy(alpha = 0.4f))
                Spacer(modifier = Modifier.height(16.dp))

                // Question 1: Continuation motivation
                Text(text = "What kept you scrolling?", style = H3)
                Spacer(modifier = Modifier.height(8.dp))
                FlowRow(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    motivations.forEach { m ->
                        FilterChip(
                            selected = motivation == m,
                            onClick = { motivation = m },
                            label = { Text(m) }
                        )
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))

                // Question 2: Content Type
                Text(text = "Primary content consumed?", style = H3)
                Spacer(modifier = Modifier.height(8.dp))
                FlowRow(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    contentTypes.forEach { c ->
                        FilterChip(
                            selected = contentType == c,
                            onClick = { contentType = c },
                            label = { Text(c) }
                        )
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))

                // Question 3: Delayed Planned Work
                Text(text = "Did this delay planned work or sleep?", style = H3)
                Spacer(modifier = Modifier.height(8.dp))
                Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                    FilterChip(
                        selected = delayedWork,
                        onClick = { delayedWork = true },
                        label = { Text("Yes, pushed work/sleep") }
                    )
                    FilterChip(
                        selected = !delayedWork,
                        onClick = { delayedWork = false },
                        label = { Text("No, free time") }
                    )
                }

                Spacer(modifier = Modifier.height(16.dp))

                // Question 4: Mood After
                Text(text = "How do you feel right now?", style = H3)
                Spacer(modifier = Modifier.height(8.dp))
                FlowRow(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    moods.forEach { md ->
                        FilterChip(
                            selected = mood == md,
                            onClick = { mood = md },
                            label = { Text(md) }
                        )
                    }
                }

                Spacer(modifier = Modifier.height(28.dp))

                // Reflection Two Choices (Reflect style pill buttons)
                ReflectButton(
                    text = "I'LL CLOSE INSTAGRAM",
                    onClick = {
                        scope.launch {
                            val sessionId = usageSessionId ?: UUID.randomUUID().toString()
                            repository.submitFeedback(
                                FeedbackEntity(
                                    usageSessionId = sessionId,
                                    originalIntention = originalPurpose,
                                    continuationMotivation = "closed",
                                    contentType = contentType,
                                    delayedPlannedWork = delayedWork,
                                    moodAfter = mood
                                )
                            )
                            onCloseInstagram()
                        }
                    }
                )

                Spacer(modifier = Modifier.height(12.dp))

                OutlinedButton(
                    onClick = {
                        scope.launch {
                            val sessionId = usageSessionId ?: UUID.randomUUID().toString()
                            repository.submitFeedback(
                                FeedbackEntity(
                                    usageSessionId = sessionId,
                                    originalIntention = originalPurpose,
                                    continuationMotivation = motivation,
                                    contentType = contentType,
                                    delayedPlannedWork = delayedWork,
                                    moodAfter = mood
                                )
                            )
                            onContinueAnyway()
                        }
                    },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(48.dp),
                    shape = RoundedCornerShape(24.dp),
                    border = BorderStroke(1.5.dp, AccentReflect),
                    colors = ButtonDefaults.outlinedButtonColors(contentColor = AccentReflect)
                ) {
                    Text(text = "CONTINUE ANYWAY", style = ButtonLabel)
                }
            }
        }
    }
}
