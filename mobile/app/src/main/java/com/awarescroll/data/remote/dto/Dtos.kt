package com.awarescroll.data.remote.dto

import com.google.gson.annotations.SerializedName

// Auth
data class AuthRequest(
    val email: String,
    val password: String,
    val timezone: String = "UTC"
)

data class AuthResponse(
    @SerializedName("access_token") val accessToken: String,
    @SerializedName("refresh_token") val refreshToken: String,
    @SerializedName("token_type") val tokenType: String
)

// Goals
data class GoalRequest(
    @SerializedName("goal_type") val goalType: String,
    @SerializedName("target_value") val targetValue: Double,
    val unit: String = "minutes",
    val active: Boolean = true
)

data class GoalResponseDto(
    val id: String,
    @SerializedName("user_id") val userId: String,
    @SerializedName("goal_type") val goalType: String,
    @SerializedName("target_value") val targetValue: Double,
    val unit: String,
    val active: Boolean
)

// Intentions
data class IntentionRequest(
    @SerializedName("session_type") val sessionType: String,
    @SerializedName("intended_duration_minutes") val intendedDurationMinutes: Int,
    @SerializedName("intended_purpose") val intendedPurpose: String?
)

data class IntentionResponseDto(
    val id: String,
    @SerializedName("user_id") val userId: String,
    @SerializedName("session_type") val sessionType: String,
    @SerializedName("intended_duration_minutes") val intendedDurationMinutes: Int,
    @SerializedName("intended_purpose") val intendedPurpose: String?
)

// Usage Sessions
data class UsageSessionRequest(
    @SerializedName("intention_id") val intentionId: String?,
    @SerializedName("start_time") val startTime: String,
    @SerializedName("end_time") val endTime: String?,
    @SerializedName("actual_duration_minutes") val actualDurationMinutes: Double,
    @SerializedName("exceeded_limit") val exceededLimit: Boolean,
    @SerializedName("reminder_count") val reminderCount: Int,
    @SerializedName("time_of_day_bucket") val timeOfDayBucket: String?
)

data class UsageSessionResponseDto(
    val id: String,
    @SerializedName("actual_duration_minutes") val actualDurationMinutes: Double,
    @SerializedName("exceeded_limit") val exceededLimit: Boolean
)

// Focus Sessions
data class FocusSessionRequest(
    @SerializedName("intention_id") val intentionId: String?,
    @SerializedName("task_category") val taskCategory: String,
    @SerializedName("task_description") val taskDescription: String,
    @SerializedName("planned_duration_minutes") val plannedDurationMinutes: Int,
    @SerializedName("start_time") val startTime: String,
    @SerializedName("end_time") val endTime: String?,
    val completed: Boolean,
    val interrupted: Boolean
)

data class FocusSessionResponseDto(
    val id: String,
    val completed: Boolean,
    val interrupted: Boolean
)

// Interruption
data class InterruptionRequest(
    @SerializedName("interruption_time") val interruptionTime: String,
    @SerializedName("reason_text") val reasonText: String,
    @SerializedName("reason_category") val reasonCategory: String
)

// Feedback
data class FeedbackRequest(
    @SerializedName("usage_session_id") val usageSessionId: String,
    @SerializedName("original_intention") val originalIntention: String?,
    @SerializedName("continuation_motivation") val continuationMotivation: String,
    @SerializedName("content_type") val contentType: String,
    @SerializedName("delayed_planned_work") val delayedPlannedWork: Boolean,
    @SerializedName("mood_after") val moodAfter: String
)

// Analytics Summary
data class AnalyticsSummaryDto(
    @SerializedName("uid") val uid: String,
    @SerializedName("range_days") val rangeDays: Int,
    @SerializedName("average_usage_duration_minutes") val averageUsageDurationMinutes: Double,
    @SerializedName("usage_overrun_rate") val usageOverrunRate: Double,
    @SerializedName("usage_continuation_rate") val usageContinuationRate: Double,
    @SerializedName("focus_completion_rate") val focusCompletionRate: Double,
    @SerializedName("focus_interruption_rate") val focusInterruptionRate: Double,
    @SerializedName("total_usage_sessions") val totalUsageSessions: Int,
    @SerializedName("total_focus_sessions") val totalFocusSessions: Int,
    @SerializedName("adherence_score") val adherenceScore: Double
)

data class PatternItemDto(
    val pattern: String,
    val confidence: Float,
    @SerializedName("evidence_count") val evidenceCount: Int,
    val category: String
)

data class PatternResponseDto(
    val uid: String,
    val patterns: List<PatternItemDto>
)

data class PredictOverrunRequestDto(
    @SerializedName("intended_duration_minutes") val intendedDurationMinutes: Int,
    @SerializedName("intended_purpose") val intendedPurpose: String?,
    @SerializedName("time_of_day") val timeOfDay: String?
)

data class PredictOverrunResponseDto(
    @SerializedName("risk_score") val riskScore: Float,
    @SerializedName("suggested_limit") val suggestedLimit: Int,
    val explanation: String
)

data class PredictInterruptionRequestDto(
    @SerializedName("task_category") val taskCategory: String,
    @SerializedName("planned_duration_minutes") val plannedDurationMinutes: Int,
    @SerializedName("time_of_day") val timeOfDay: String?
)

data class PredictInterruptionResponseDto(
    @SerializedName("risk_score") val riskScore: Float,
    @SerializedName("suggested_duration") val suggestedDuration: Int,
    val explanation: String
)
