package com.awarescroll.data.remote

import com.awarescroll.data.remote.dto.*
import okhttp3.ResponseBody
import retrofit2.Response
import retrofit2.http.*

interface ApiService {

    // Auth
    @POST("auth/register")
    suspend fun register(@Body req: AuthRequest): Response<AuthResponse>

    @POST("auth/login")
    suspend fun login(@Body req: AuthRequest): Response<AuthResponse>

    // Goals
    @POST("goals")
    suspend fun createGoal(@Body req: GoalRequest): Response<GoalResponseDto>

    @GET("goals")
    suspend fun getGoals(): Response<List<GoalResponseDto>>

    // Intentions
    @POST("intentions")
    suspend fun createIntention(@Body req: IntentionRequest): Response<IntentionResponseDto>

    @GET("intentions/latest")
    suspend fun getLatestIntention(@Query("session_type") sessionType: String): Response<IntentionResponseDto>

    // Usage Sessions
    @POST("usage-sessions")
    suspend fun recordUsageSession(@Body req: UsageSessionRequest): Response<UsageSessionResponseDto>

    // Focus Sessions
    @POST("focus-sessions")
    suspend fun recordFocusSession(@Body req: FocusSessionRequest): Response<FocusSessionResponseDto>

    @POST("focus-sessions/{id}/interruptions")
    suspend fun logInterruption(
        @Path("id") sessionId: String,
        @Body req: InterruptionRequest
    ): Response<ResponseBody>

    // Feedback
    @POST("feedback")
    suspend fun submitFeedback(@Body req: FeedbackRequest): Response<ResponseBody>

    // Analytics & Dashboard
    @GET("analytics/summary")
    suspend fun getAnalyticsSummary(
        @Query("uid") uid: String? = null,
        @Query("range") rangeDays: Int = 30
    ): Response<AnalyticsSummaryDto>

    @GET("analytics/patterns")
    suspend fun getPatterns(@Query("uid") uid: String? = null): Response<PatternResponseDto>

    // Predictions
    @POST("predict/overrun")
    suspend fun predictOverrun(@Body req: PredictOverrunRequestDto): Response<PredictOverrunResponseDto>

    @POST("predict/interruption")
    suspend fun predictInterruption(@Body req: PredictInterruptionRequestDto): Response<PredictInterruptionResponseDto>

    // CSV Export
    @GET("export")
    @Streaming
    suspend fun exportCsv(
        @Query("uid") uid: String? = null,
        @Query("format") format: String = "csv"
    ): Response<ResponseBody>
}
