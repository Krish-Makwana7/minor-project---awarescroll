package com.awarescroll.data.local

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.util.UUID

@Entity(tableName = "goals")
data class GoalEntity(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val goalType: String,
    val targetValue: Double,
    val unit: String = "minutes",
    val active: Boolean = true,
    val createdAt: Long = System.currentTimeMillis()
)

@Entity(tableName = "intentions")
data class IntentionEntity(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val sessionType: String, // "instagram" or "focus"
    val intendedDurationMinutes: Int,
    val intendedPurpose: String?,
    val createdAt: Long = System.currentTimeMillis()
)

@Entity(tableName = "usage_sessions")
data class UsageSessionEntity(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val intentionId: String? = null,
    val appName: String = "Instagram",
    val startTime: Long,
    val endTime: Long? = null,
    val actualDurationMinutes: Double,
    val exceededLimit: Boolean,
    val closedOnFirstReminder: Boolean = false,
    val extensionGranted: Boolean = false,
    val hardLocked: Boolean = false,
    val reminderCount: Int = 0,
    val timeOfDayBucket: String?,
    val isSynced: Boolean = false,
    val createdAt: Long = System.currentTimeMillis()
)

@Entity(tableName = "focus_sessions")
data class FocusSessionEntity(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val intentionId: String?,
    val taskCategory: String,
    val taskDescription: String,
    val plannedDurationMinutes: Int,
    val startTime: Long,
    val endTime: Long?,
    val completed: Boolean,
    val interrupted: Boolean,
    val isSynced: Boolean = false,
    val createdAt: Long = System.currentTimeMillis()
)

@Entity(tableName = "interruptions")
data class InterruptionEntity(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val focusSessionId: String,
    val interruptionTime: Long = System.currentTimeMillis(),
    val reasonText: String,
    val reasonCategory: String,
    val isSynced: Boolean = false
)

@Entity(tableName = "feedback")
data class FeedbackEntity(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val usageSessionId: String,
    val originalIntention: String? = null,
    val continuationMotivation: String, // Decision trigger
    val contentType: String, // Content category
    val delayedPlannedWork: Boolean = false,
    val workImpact: String = "No task planned",
    val moodAfter: String, // Post-scroll feeling
    val supposedToBeDoing: String = "Nothing planned",
    val helpfulStopper: String = "App closure",
    val timePerception: String = "Felt like 5 mins",
    val quoteText: String? = null,
    val quoteAuthor: String? = null,
    val isSynced: Boolean = false,
    val createdAt: Long = System.currentTimeMillis()
)

@Entity(tableName = "sync_queue")
data class SyncQueueEntity(
    @PrimaryKey(autoGenerate = true) val queueId: Long = 0,
    val entityType: String, // "usage_session", "focus_session", "feedback", "interruption"
    val payloadJson: String,
    val createdAt: Long = System.currentTimeMillis()
)
