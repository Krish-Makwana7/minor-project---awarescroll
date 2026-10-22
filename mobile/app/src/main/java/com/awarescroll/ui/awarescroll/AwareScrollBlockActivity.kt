package com.awarescroll.ui.awarescroll

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Timer
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.awarescroll.AwareScrollApp
import com.awarescroll.data.local.FeedbackEntity
import com.awarescroll.data.local.UsageSessionEntity
import com.awarescroll.services.FocusLockAccessibilityService
import com.awarescroll.services.UsageMonitorService
import com.awarescroll.ui.theme.*
import kotlinx.coroutines.launch
import java.util.UUID

enum class InterruptionState {
    LIMIT_EXPIRED,
    SURVEY_FORM,
    QUOTE_VIEW,
    HARD_LOCKED
}

class AwareScrollBlockActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val appPackage = intent.getStringExtra(EXTRA_PACKAGE_NAME) ?: "com.instagram.android"
        val elapsedMinutes = intent.getIntExtra(EXTRA_ELAPSED_MINUTES, 5)
        val intendedMinutes = intent.getIntExtra(EXTRA_INTENDED_MINUTES, 5)
        val sessionId = intent.getStringExtra(EXTRA_USAGE_SESSION_ID) ?: UUID.randomUUID().toString()

        val appName = when {
            appPackage.contains("instagram") -> "Instagram"
            appPackage.contains("facebook") -> "Facebook"
            appPackage.contains("snapchat") -> "Snapchat"
            appPackage.contains("youtube") -> "YouTube"
            appPackage.contains("reddit") -> "Reddit"
            appPackage.contains("musically") || appPackage.contains("tiktok") -> "TikTok"
            else -> "Social Media"
        }

        setContent {
            AwareScrollTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = BackgroundLight
                ) {
                    AwareScrollBlockScreen(
                        appName = appName,
                        appPackage = appPackage,
                        elapsedMinutes = elapsedMinutes,
                        intendedMinutes = intendedMinutes,
                        sessionId = sessionId,
                        onCloseApp = {
                            closeTargetApp()
                        },
                        onFinishActivity = {
                            finish()
                        }
                    )
                }
            }
        }
    }

    private fun closeTargetApp() {
        // 1. Try closing via AccessibilityService if enabled
        val closedViaAccessibility = FocusLockAccessibilityService.instance?.closeCurrentApp() ?: false

        if (!closedViaAccessibility) {
            // 2. Return to Android Home Screen immediately
            val homeIntent = Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_HOME)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            startActivity(homeIntent)
        }
        finish()
    }

    companion object {
        const val EXTRA_PACKAGE_NAME = "extra_package_name"
        const val EXTRA_ELAPSED_MINUTES = "extra_elapsed_minutes"
        const val EXTRA_INTENDED_MINUTES = "extra_intended_minutes"
        const val EXTRA_USAGE_SESSION_ID = "extra_usage_session_id"
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun AwareScrollBlockScreen(
    appName: String,
    appPackage: String,
    elapsedMinutes: Int,
    intendedMinutes: Int,
    sessionId: String,
    onCloseApp: () -> Unit,
    onFinishActivity: () -> Unit
) {
    val repository = AwareScrollApp.instance.repository
    val scope = rememberCoroutineScope()

    var state by remember { mutableStateOf(InterruptionState.LIMIT_EXPIRED) }

    // Survey state
    var decisionTrigger by remember { mutableStateOf("Boredom") }
    var contentCategory by remember { mutableStateOf("Comedy / Memes") }
    var workImpact by remember { mutableStateOf("Delayed a task") }
    var feeling by remember { mutableStateOf("Neutral") }
    var supposedToDo by remember { mutableStateOf("Studying") }
    var helpfulStopper by remember { mutableStateOf("Time warning") }

    // Generated Quote state
    var quoteText by remember { mutableStateOf("") }
    var quoteAuthor by remember { mutableStateOf("") }

    when (state) {
        InterruptionState.LIMIT_EXPIRED -> {
            // STEP 1: LIMIT EXPIRED - CLOSE VS CONTINUE
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(24.dp),
                verticalArrangement = Arrangement.SpaceBetween,
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                // Top Tag
                Surface(
                    color = AccentReflect.copy(alpha = 0.15f),
                    shape = RoundedCornerShape(16.dp),
                    border = BorderStroke(1.dp, AccentReflect.copy(alpha = 0.3f)),
                    modifier = Modifier.padding(top = 16.dp)
                ) {
                    Row(
                        modifier = Modifier.padding(horizontal = 14.dp, vertical = 6.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            imageVector = Icons.Default.Timer,
                            contentDescription = null,
                            tint = AccentReflect,
                            modifier = Modifier.size(16.dp)
                        )
                        Spacer(modifier = Modifier.width(6.dp))
                        Text(
                            text = "TIME RESTRICTION ACTIVE",
                            style = StatLabel,
                            color = AccentReflect,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }

                // Center Card
                Card(
                    shape = RoundedCornerShape(24.dp),
                    colors = CardDefaults.cardColors(containerColor = SurfaceLight),
                    elevation = CardDefaults.cardElevation(defaultElevation = 6.dp),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(
                        modifier = Modifier.padding(24.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        // Big Timer Badge
                        Text(
                            text = "05:00",
                            style = StatTimer.copy(fontSize = 44.sp, lineHeight = 48.sp),
                            color = AccentReflect
                        )
                        Text(
                            text = "LIMIT REACHED",
                            style = StatLabel,
                            color = TextSecondaryLight
                        )

                        Spacer(modifier = Modifier.height(16.dp))

                        Text(
                            text = "Take a breath? You planned 5 minutes.",
                            style = H2,
                            color = TextPrimaryLight,
                            textAlign = TextAlign.Center
                        )

                        Spacer(modifier = Modifier.height(8.dp))

                        Text(
                            text = "You've reached your set time boundary on $appName. Would you like to close the app or continue scrolling?",
                            style = Body,
                            color = TextSecondaryLight,
                            textAlign = TextAlign.Center
                        )
                    }
                }

                // Bottom Buttons: CLOSE vs CONTINUE
                Column(
                    modifier = Modifier.fillMaxWidth(),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    // CLOSE BUTTON: Positive response logged to DB!
                    Button(
                        onClick = {
                            scope.launch {
                                val session = UsageSessionEntity(
                                    id = sessionId,
                                    appName = appName,
                                    startTime = System.currentTimeMillis() - (elapsedMinutes * 60000L),
                                    endTime = System.currentTimeMillis(),
                                    actualDurationMinutes = elapsedMinutes.toDouble(),
                                    exceededLimit = false,
                                    closedOnFirstReminder = true, // POSITIVE COMPLIANCE
                                    timeOfDayBucket = determineTimeBucket()
                                )
                                repository.recordUsageSession(session)
                                onCloseApp()
                            }
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = Primary),
                        shape = RoundedCornerShape(16.dp),
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(52.dp)
                    ) {
                        Icon(imageVector = Icons.Default.Close, contentDescription = null, tint = Color.White)
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            text = "CLOSE $appName",
                            style = H3,
                            color = Color.White,
                            fontWeight = FontWeight.Bold
                        )
                    }

                    // CONTINUE BUTTON: Opens rapid survey form
                    OutlinedButton(
                        onClick = {
                            state = InterruptionState.SURVEY_FORM
                        },
                        shape = RoundedCornerShape(16.dp),
                        border = BorderStroke(1.dp, BorderColorLight),
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(50.dp)
                    ) {
                        Text(
                            text = "Continue anyway",
                            style = H3,
                            color = TextSecondaryLight
                        )
                    }
                }
            }
        }

        InterruptionState.SURVEY_FORM -> {
            // STEP 2: RAPID 3-5 SECOND FEEDBACK FORM
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState())
                    .padding(20.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                // Header
                Text(
                    text = "Quick Reflection",
                    style = H1,
                    color = TextPrimaryLight
                )
                Text(
                    text = "Answer in 3-5 seconds to understand your usage patterns and receive your motivational quote.",
                    style = BodySmall,
                    color = TextSecondaryLight
                )

                // Q1: Decision Trigger
                SurveyQuestionCard(
                    title = "1. What most influenced your decision to continue?",
                    options = listOf(
                        "Interesting content",
                        "Boredom",
                        "Stress / mood",
                        "Notifications / messages",
                        "Habitual scrolling",
                        "Unfinished original purpose"
                    ),
                    selectedOption = decisionTrigger,
                    onSelect = { decisionTrigger = it }
                )

                // Q2: Content Category
                SurveyQuestionCard(
                    title = "2. Which content category kept you engaged?",
                    options = listOf(
                        "Comedy / Memes",
                        "Education / Technology",
                        "News / Politics",
                        "Stories / Personal content",
                        "Fitness / Lifestyle",
                        "Music / Entertainment",
                        "Other / Mixed"
                    ),
                    selectedOption = contentCategory,
                    onSelect = { contentCategory = it }
                )

                // Q3: Work Impact
                SurveyQuestionCard(
                    title = "3. How did this session affect your planned work?",
                    options = listOf(
                        "No task planned",
                        "Delayed a task",
                        "Interrupted a task",
                        "No negative impact / planned break"
                    ),
                    selectedOption = workImpact,
                    onSelect = { workImpact = it }
                )

                // Q4: Post-Scroll Feeling
                SurveyQuestionCard(
                    title = "4. How do you feel after scrolling?",
                    options = listOf(
                        "Satisfied",
                        "Relaxed",
                        "Neutral",
                        "Bored",
                        "Stressed / regretful"
                    ),
                    selectedOption = feeling,
                    onSelect = { feeling = it }
                )

                // Q5: Supposed to be doing
                SurveyQuestionCard(
                    title = "5. What were you supposed to be doing?",
                    options = listOf(
                        "Studying",
                        "Working",
                        "Sleeping",
                        "Socializing",
                        "Relaxing",
                        "Nothing planned"
                    ),
                    selectedOption = supposedToDo,
                    onSelect = { supposedToDo = it }
                )

                // Q6: Helpful Stopper
                SurveyQuestionCard(
                    title = "6. What would have helped you stop?",
                    options = listOf(
                        "Time warning",
                        "Original-purpose reminder",
                        "Mood check",
                        "Break suggestion",
                        "App closure"
                    ),
                    selectedOption = helpfulStopper,
                    onSelect = { helpfulStopper = it }
                )

                // Submit Button
                Button(
                    onClick = {
                        val generated = generateQuote(decisionTrigger, feeling, supposedToDo)
                        quoteText = generated.first
                        quoteAuthor = generated.second

                        scope.launch {
                            val session = UsageSessionEntity(
                                id = sessionId,
                                appName = appName,
                                startTime = System.currentTimeMillis() - (elapsedMinutes * 60000L),
                                endTime = System.currentTimeMillis(),
                                actualDurationMinutes = elapsedMinutes.toDouble() + 5.0,
                                exceededLimit = true,
                                closedOnFirstReminder = false,
                                extensionGranted = true,
                                timeOfDayBucket = determineTimeBucket()
                            )
                            repository.recordUsageSession(session)

                            val feedback = FeedbackEntity(
                                usageSessionId = sessionId,
                                originalIntention = "Scroll $appName",
                                continuationMotivation = decisionTrigger,
                                contentType = contentCategory,
                                delayedPlannedWork = workImpact.contains("Delayed") || workImpact.contains("Interrupted"),
                                workImpact = workImpact,
                                moodAfter = feeling,
                                supposedToBeDoing = supposedToDo,
                                helpfulStopper = helpfulStopper,
                                quoteText = quoteText,
                                quoteAuthor = quoteAuthor
                            )
                            repository.submitFeedback(feedback)
                        }

                        state = InterruptionState.QUOTE_VIEW
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = Primary),
                    shape = RoundedCornerShape(16.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(52.dp)
                ) {
                    Text(
                        text = "SUBMIT & GET QUOTE",
                        style = H3,
                        color = Color.White,
                        fontWeight = FontWeight.Bold
                    )
                }

                Spacer(modifier = Modifier.height(16.dp))
            }
        }

        InterruptionState.QUOTE_VIEW -> {
            // STEP 3: MOTIVATIONAL QUOTE & 5-MIN FREE USAGE
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(24.dp),
                verticalArrangement = Arrangement.SpaceBetween,
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Surface(
                    color = Secondary.copy(alpha = 0.15f),
                    shape = RoundedCornerShape(16.dp),
                    modifier = Modifier.padding(top = 16.dp)
                ) {
                    Text(
                        text = "5-MINUTE EXTENSION GRANTED",
                        style = StatLabel,
                        color = Secondary,
                        modifier = Modifier.padding(horizontal = 14.dp, vertical = 6.dp)
                    )
                }

                Card(
                    shape = RoundedCornerShape(24.dp),
                    colors = CardDefaults.cardColors(containerColor = SurfaceLight),
                    elevation = CardDefaults.cardElevation(defaultElevation = 6.dp),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(
                        modifier = Modifier.padding(24.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text(
                            text = "“$quoteText”",
                            style = H2,
                            color = TextPrimaryLight,
                            textAlign = TextAlign.Center,
                            lineHeight = 28.sp
                        )

                        Spacer(modifier = Modifier.height(12.dp))

                        Text(
                            text = "— $quoteAuthor",
                            style = StatLabel,
                            color = Primary,
                            fontWeight = FontWeight.Bold
                        )

                        Spacer(modifier = Modifier.height(20.dp))

                        Divider(color = BorderColorLight)

                        Spacer(modifier = Modifier.height(16.dp))

                        Text(
                            text = "Notice: After this 5-minute extension, $appName will be automatically locked to protect your time.",
                            style = BodySmall,
                            color = TextSecondaryLight,
                            textAlign = TextAlign.Center
                        )
                    }
                }

                Button(
                    onClick = {
                        // Return to Instagram with 5 min timer
                        UsageMonitorService.startMonitoring(
                            context = AwareScrollApp.instance,
                            limitMinutes = 5,
                            intentionId = sessionId
                        )
                        onFinishActivity()
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = Primary),
                    shape = RoundedCornerShape(16.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(52.dp)
                ) {
                    Text(
                        text = "CONTINUE TO $appName (5 MIN)",
                        style = H3,
                        color = Color.White,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }

        InterruptionState.HARD_LOCKED -> {
            // STEP 4: STRICT AUTO-CLOSE HARD LOCK
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(24.dp),
                verticalArrangement = Arrangement.Center,
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = "Session Complete",
                    style = H1,
                    color = ErrorColor
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = "Your 5-minute extension is over. Returning to home screen to protect your focus.",
                    style = Body,
                    color = TextSecondaryLight,
                    textAlign = TextAlign.Center
                )
                Spacer(modifier = Modifier.height(24.dp))
                Button(
                    onClick = onCloseApp,
                    colors = ButtonDefaults.buttonColors(containerColor = Primary),
                    shape = RoundedCornerShape(16.dp),
                    modifier = Modifier.fillMaxWidth().height(50.dp)
                ) {
                    Text("EXIT TO HOME", color = Color.White, style = H3)
                }
            }
        }
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun SurveyQuestionCard(
    title: String,
    options: List<String>,
    selectedOption: String,
    onSelect: (String) -> Unit
) {
    Card(
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = SurfaceLight),
        border = BorderStroke(1.dp, BorderColorLight),
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(
                text = title,
                style = H3,
                color = TextPrimaryLight
            )
            Spacer(modifier = Modifier.height(10.dp))

            FlowRow(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                options.forEach { opt ->
                    val isSelected = selectedOption == opt
                    Surface(
                        shape = RoundedCornerShape(12.dp),
                        color = if (isSelected) Primary else BackgroundLight,
                        border = BorderStroke(
                            1.dp,
                            if (isSelected) Primary else BorderColorLight
                        ),
                        onClick = { onSelect(opt) },
                        modifier = Modifier.height(36.dp)
                    ) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            modifier = Modifier.padding(horizontal = 12.dp)
                        ) {
                            if (isSelected) {
                                Icon(
                                    imageVector = Icons.Default.Check,
                                    contentDescription = null,
                                    tint = Color.White,
                                    modifier = Modifier.size(14.dp)
                                )
                                Spacer(modifier = Modifier.width(4.dp))
                            }
                            Text(
                                text = opt,
                                style = BodySmall,
                                color = if (isSelected) Color.White else TextPrimaryLight,
                                fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal
                            )
                        }
                    }
                }
            }
        }
    }
}

fun determineTimeBucket(): String {
    val cal = java.util.Calendar.getInstance()
    return when (cal.get(java.util.Calendar.HOUR_OF_DAY)) {
        in 5..11 -> "morning"
        in 12..16 -> "afternoon"
        in 17..20 -> "evening"
        else -> "night"
    }
}

fun generateQuote(decision: String, feeling: String, supposedToDo: String): Pair<String, String> {
    return when {
        supposedToDo.contains("Studying", ignoreCase = true) -> {
            "You have power over your mind - not outside events. Realize this, and you will find strength." to "Marcus Aurelius"
        }
        decision.contains("Boredom", ignoreCase = true) || decision.contains("Habitual", ignoreCase = true) -> {
            "It is not that we have a short time to live, but that we waste a lot of it." to "Seneca"
        }
        feeling.contains("Stressed", ignoreCase = true) || feeling.contains("regretful", ignoreCase = true) -> {
            "Do not spoil what you have by desiring what you have not; remember that what you now have was once among the things you only hoped for." to "Epicurus"
        }
        else -> {
            "Clarity about what matters provides clarity about what does not." to "Cal Newport"
        }
    }
}
