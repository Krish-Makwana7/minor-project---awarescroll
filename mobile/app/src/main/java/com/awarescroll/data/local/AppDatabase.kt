package com.awarescroll.data.local

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase

@Database(
    entities = [
        GoalEntity::class,
        IntentionEntity::class,
        UsageSessionEntity::class,
        FocusSessionEntity::class,
        InterruptionEntity::class,
        FeedbackEntity::class,
        SyncQueueEntity::class
    ],
    version = 1,
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun goalDao(): GoalDao
    abstract fun intentionDao(): IntentionDao
    abstract fun usageSessionDao(): UsageSessionDao
    abstract fun focusSessionDao(): FocusSessionDao
    abstract fun feedbackDao(): FeedbackDao
    abstract fun syncQueueDao(): SyncQueueDao

    companion object {
        @Volatile
        private var INSTANCE: AppDatabase? = null

        fun getInstance(context: Context): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "awarescroll_focuslock.db"
                ).fallbackToDestructiveMigration()
                    .build()
                INSTANCE = instance
                instance
            }
        }
    }
}
