package com.awarescroll.data.local

import androidx.room.*
import kotlinx.coroutines.flow.Flow

@Dao
interface GoalDao {
    @Query("SELECT * FROM goals ORDER BY createdAt DESC")
    fun getAllGoals(): Flow<List<GoalEntity>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertGoal(goal: GoalEntity)

    @Update
    suspend fun updateGoal(goal: GoalEntity)

    @Query("DELETE FROM goals WHERE id = :id")
    suspend fun deleteGoalById(id: String)
}

@Dao
interface IntentionDao {
    @Query("SELECT * FROM intentions ORDER BY createdAt DESC")
    fun getAllIntentions(): Flow<List<IntentionEntity>>

    @Query("SELECT * FROM intentions WHERE sessionType = :type ORDER BY createdAt DESC LIMIT 1")
    suspend fun getLatestIntention(type: String): IntentionEntity?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertIntention(intention: IntentionEntity)
}

@Dao
interface UsageSessionDao {
    @Query("SELECT * FROM usage_sessions ORDER BY startTime DESC")
    fun getAllSessions(): Flow<List<UsageSessionEntity>>

    @Query("SELECT * FROM usage_sessions WHERE isSynced = 0")
    suspend fun getUnsyncedSessions(): List<UsageSessionEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertSession(session: UsageSessionEntity)

    @Update
    suspend fun updateSession(session: UsageSessionEntity)

    @Query("UPDATE usage_sessions SET isSynced = 1 WHERE id = :id")
    suspend fun markSynced(id: String)
}

@Dao
interface FocusSessionDao {
    @Query("SELECT * FROM focus_sessions ORDER BY startTime DESC")
    fun getAllFocusSessions(): Flow<List<FocusSessionEntity>>

    @Query("SELECT * FROM focus_sessions WHERE isSynced = 0")
    suspend fun getUnsyncedFocusSessions(): List<FocusSessionEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertFocusSession(session: FocusSessionEntity)

    @Update
    suspend fun updateFocusSession(session: FocusSessionEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertInterruption(interruption: InterruptionEntity)

    @Query("UPDATE focus_sessions SET isSynced = 1 WHERE id = :id")
    suspend fun markSynced(id: String)
}

@Dao
interface FeedbackDao {
    @Query("SELECT * FROM feedback WHERE usageSessionId = :sessionId LIMIT 1")
    suspend fun getFeedbackForSession(sessionId: String): FeedbackEntity?

    @Query("SELECT * FROM feedback WHERE isSynced = 0")
    suspend fun getUnsyncedFeedback(): List<FeedbackEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertFeedback(feedback: FeedbackEntity)

    @Query("UPDATE feedback SET isSynced = 1 WHERE id = :id")
    suspend fun markSynced(id: String)
}

@Dao
interface SyncQueueDao {
    @Query("SELECT * FROM sync_queue ORDER BY queueId ASC")
    suspend fun getAllQueueItems(): List<SyncQueueEntity>

    @Insert
    suspend fun enqueue(item: SyncQueueEntity)

    @Query("DELETE FROM sync_queue WHERE queueId = :id")
    suspend fun dequeue(id: Long)
}
