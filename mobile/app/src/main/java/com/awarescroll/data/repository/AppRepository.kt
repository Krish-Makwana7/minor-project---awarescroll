package com.awarescroll.data.repository

import com.awarescroll.data.local.*
import com.awarescroll.data.remote.ApiService
import com.awarescroll.data.remote.dto.*
import kotlinx.coroutines.flow.Flow
import java.text.SimpleDateFormat
import java.util.*

class AppRepository(
    private val goalDao: GoalDao,
    private val intentionDao: IntentionDao,
    private val usageSessionDao: UsageSessionDao,
    private val focusSessionDao: FocusSessionDao,
    private val feedbackDao: FeedbackDao,
    private val syncQueueDao: SyncQueueDao,
    private val apiService: ApiService
) {
    private val isoFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.US).apply {
        timeZone = TimeZone.getTimeZone("UTC")
    }

    // Goals
    fun getGoals(): Flow<List<GoalEntity>> = goalDao.getAllGoals()

    suspend fun saveGoal(goal: GoalEntity) {
        goalDao.insertGoal(goal)
        try {
            apiService.createGoal(
                GoalRequest(
                    goalType = goal.goalType,
                    targetValue = goal.targetValue,
                    unit = goal.unit,
                    active = goal.active
                )
            )
        } catch (e: Exception) {
            // Handled offline: Room stores it locally
        }
    }

    // Intentions
    fun getIntentions(): Flow<List<IntentionEntity>> = intentionDao.getAllIntentions()

    suspend fun getLatestIntention(sessionType: String): IntentionEntity? =
        intentionDao.getLatestIntention(sessionType)

    suspend fun saveIntention(intention: IntentionEntity) {
        intentionDao.insertIntention(intention)
        try {
            apiService.createIntention(
                IntentionRequest(
                    sessionType = intention.sessionType,
                    intendedDurationMinutes = intention.intendedDurationMinutes,
                    intendedPurpose = intention.intendedPurpose
                )
            )
        } catch (e: Exception) {
            // Handled offline
        }
    }

    // Usage Sessions
    fun getUsageSessions(): Flow<List<UsageSessionEntity>> = usageSessionDao.getAllSessions()

    suspend fun recordUsageSession(session: UsageSessionEntity) {
        usageSessionDao.insertSession(session)
        try {
            val res = apiService.recordUsageSession(
                UsageSessionRequest(
                    intentionId = session.intentionId,
                    startTime = isoFormat.format(Date(session.startTime)),
                    endTime = session.endTime?.let { isoFormat.format(Date(it)) },
                    actualDurationMinutes = session.actualDurationMinutes,
                    exceededLimit = session.exceededLimit,
                    reminderCount = session.reminderCount,
                    timeOfDayBucket = session.timeOfDayBucket
                )
            )
            if (res.isSuccessful) {
                usageSessionDao.markSynced(session.id)
            }
        } catch (e: Exception) {
            // Will be synced by SyncWorker when connectivity resumes
        }
    }

    // Focus Sessions
    fun getFocusSessions(): Flow<List<FocusSessionEntity>> = focusSessionDao.getAllFocusSessions()

    suspend fun recordFocusSession(session: FocusSessionEntity) {
        focusSessionDao.insertFocusSession(session)
        try {
            val res = apiService.recordFocusSession(
                FocusSessionRequest(
                    intentionId = session.intentionId,
                    taskCategory = session.taskCategory,
                    taskDescription = session.taskDescription,
                    plannedDurationMinutes = session.plannedDurationMinutes,
                    startTime = isoFormat.format(Date(session.startTime)),
                    endTime = session.endTime?.let { isoFormat.format(Date(it)) },
                    completed = session.completed,
                    interrupted = session.interrupted
                )
            )
            if (res.isSuccessful) {
                focusSessionDao.markSynced(session.id)
            }
        } catch (e: Exception) {
            // SyncWorker flushes later
        }
    }

    suspend fun logInterruption(interruption: InterruptionEntity) {
        focusSessionDao.insertInterruption(interruption)
        try {
            apiService.logInterruption(
                sessionId = interruption.focusSessionId,
                req = InterruptionRequest(
                    interruptionTime = isoFormat.format(Date(interruption.interruptionTime)),
                    reasonText = interruption.reasonText,
                    reasonCategory = interruption.reasonCategory
                )
            )
        } catch (e: Exception) {
            // SyncWorker flushes later
        }
    }

    // Feedback
    suspend fun submitFeedback(feedback: FeedbackEntity) {
        feedbackDao.insertFeedback(feedback)
        try {
            val res = apiService.submitFeedback(
                FeedbackRequest(
                    usageSessionId = feedback.usageSessionId,
                    originalIntention = feedback.originalIntention,
                    continuationMotivation = feedback.continuationMotivation,
                    contentType = feedback.contentType,
                    delayedPlannedWork = feedback.delayedPlannedWork,
                    moodAfter = feedback.moodAfter
                )
            )
            if (res.isSuccessful) {
                feedbackDao.markSynced(feedback.id)
            }
        } catch (e: Exception) {
            // SyncWorker flushes later
        }
    }

    // Analytics & Remote Insights
    suspend fun fetchAnalyticsSummary(): Result<AnalyticsSummaryDto> {
        return try {
            val res = apiService.getAnalyticsSummary()
            if (res.isSuccessful && res.body() != null) {
                Result.success(res.body()!!)
            } else {
                Result.failure(Exception("Failed to fetch summary: ${res.code()}"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun fetchPatterns(): Result<List<PatternItemDto>> {
        return try {
            val res = apiService.getPatterns()
            if (res.isSuccessful && res.body() != null) {
                Result.success(res.body()!!.patterns)
            } else {
                Result.failure(Exception("Failed to fetch patterns: ${res.code()}"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun predictOverrun(duration: Int, purpose: String?): Result<PredictOverrunResponseDto> {
        return try {
            val res = apiService.predictOverrun(
                PredictOverrunRequestDto(
                    intendedDurationMinutes = duration,
                    intendedPurpose = purpose,
                    time_of_day = null
                )
            )
            if (res.isSuccessful && res.body() != null) {
                Result.success(res.body()!!)
            } else {
                Result.failure(Exception("Prediction unavailable"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
