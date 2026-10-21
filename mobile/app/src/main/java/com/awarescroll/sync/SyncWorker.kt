package com.awarescroll.sync

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.awarescroll.AwareScrollApp
import com.awarescroll.data.remote.dto.*
import java.text.SimpleDateFormat
import java.util.*

class SyncWorker(
    appContext: Context,
    workerParams: WorkerParameters
) : CoroutineWorker(appContext, workerParams) {

    private val isoFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.US).apply {
        timeZone = TimeZone.getTimeZone("UTC")
    }

    override suspend fun doWork(): Result {
        val app = AwareScrollApp.instance
        val db = app.database
        val api = app.repository

        return try {
            // 1. Sync usage sessions
            val unsyncedUsage = db.usageSessionDao().getUnsyncedSessions()
            for (sess in unsyncedUsage) {
                val res = com.awarescroll.data.remote.ApiClient.apiService.recordUsageSession(
                    UsageSessionRequest(
                        intentionId = sess.intentionId,
                        startTime = isoFormat.format(Date(sess.startTime)),
                        endTime = sess.endTime?.let { isoFormat.format(Date(it)) },
                        actualDurationMinutes = sess.actualDurationMinutes,
                        exceededLimit = sess.exceededLimit,
                        reminderCount = sess.reminderCount,
                        timeOfDayBucket = sess.timeOfDayBucket
                    )
                )
                if (res.isSuccessful) {
                    db.usageSessionDao().markSynced(sess.id)
                }
            }

            // 2. Sync focus sessions
            val unsyncedFocus = db.focusSessionDao().getUnsyncedFocusSessions()
            for (focus in unsyncedFocus) {
                val res = com.awarescroll.data.remote.ApiClient.apiService.recordFocusSession(
                    FocusSessionRequest(
                        intentionId = focus.intentionId,
                        taskCategory = focus.taskCategory,
                        taskDescription = focus.taskDescription,
                        plannedDurationMinutes = focus.plannedDurationMinutes,
                        startTime = isoFormat.format(Date(focus.startTime)),
                        endTime = focus.endTime?.let { isoFormat.format(Date(it)) },
                        completed = focus.completed,
                        interrupted = focus.interrupted
                    )
                )
                if (res.isSuccessful) {
                    db.focusSessionDao().markSynced(focus.id)
                }
            }

            // 3. Sync feedback
            val unsyncedFeedback = db.feedbackDao().getUnsyncedFeedback()
            for (fb in unsyncedFeedback) {
                val res = com.awarescroll.data.remote.ApiClient.apiService.submitFeedback(
                    FeedbackRequest(
                        usageSessionId = fb.usageSessionId,
                        originalIntention = fb.originalIntention,
                        continuationMotivation = fb.continuationMotivation,
                        contentType = fb.contentType,
                        delayedPlannedWork = fb.delayedPlannedWork,
                        moodAfter = fb.moodAfter
                    )
                )
                if (res.isSuccessful) {
                    db.feedbackDao().markSynced(fb.id)
                }
            }

            Result.success()
        } catch (e: Exception) {
            Result.retry()
        }
    }
}
