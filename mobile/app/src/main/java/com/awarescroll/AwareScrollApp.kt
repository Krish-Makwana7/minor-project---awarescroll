package com.awarescroll

import android.app.Application
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import androidx.work.Constraints
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.NetworkType
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import com.awarescroll.data.local.AppDatabase
import com.awarescroll.data.remote.ApiClient
import com.awarescroll.data.repository.AppRepository
import com.awarescroll.sync.SyncWorker
import java.util.concurrent.TimeUnit

class AwareScrollApp : Application() {

    lateinit var database: AppDatabase
        private set

    lateinit var repository: AppRepository
        private set

    override fun onCreate() {
        super.onCreate()
        instance = this

        // Initialize local Room database
        database = AppDatabase.getInstance(this)

        // Initialize repository bridging Room and Retrofit
        repository = AppRepository(
            goalDao = database.goalDao(),
            intentionDao = database.intentionDao(),
            usageSessionDao = database.usageSessionDao(),
            focusSessionDao = database.focusSessionDao(),
            feedbackDao = database.feedbackDao(),
            syncQueueDao = database.syncQueueDao(),
            apiService = ApiClient.apiService
        )

        createNotificationChannels()
        schedulePeriodicBackgroundSync()
    }

    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = getSystemService(NotificationManager::class.java)

            // AwareScroll Reflection Prompt Channel
            val reflectChannel = NotificationChannel(
                CHANNEL_AWARESCROLL_LIMIT,
                "AwareScroll Limit Alerts",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notifies when Instagram usage hits your stated limit and prompts reflection."
                enableVibration(true)
            }

            // FocusLock Active Session Channel
            val focusChannel = NotificationChannel(
                CHANNEL_FOCUSLOCK_SESSION,
                "FocusLock Active Blocks",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows ongoing focus block status."
            }

            notificationManager?.createNotificationChannel(reflectChannel)
            notificationManager?.createNotificationChannel(focusChannel)
        }
    }

    private fun schedulePeriodicBackgroundSync() {
        val syncConstraints = Constraints.Builder()
            .setRequiredNetworkType(NetworkType.CONNECTED)
            .build()

        val syncRequest = PeriodicWorkRequestBuilder<SyncWorker>(15, TimeUnit.MINUTES)
            .setConstraints(syncConstraints)
            .build()

        WorkManager.getInstance(this).enqueueUniquePeriodicWork(
            "AwareScrollBehavioralSync",
            ExistingPeriodicWorkPolicy.KEEP,
            syncRequest
        )
    }

    companion object {
        lateinit var instance: AwareScrollApp
            private set

        const val CHANNEL_AWARESCROLL_LIMIT = "channel_awarescroll_limit"
        const val CHANNEL_FOCUSLOCK_SESSION = "channel_focuslock_session"
    }
}
