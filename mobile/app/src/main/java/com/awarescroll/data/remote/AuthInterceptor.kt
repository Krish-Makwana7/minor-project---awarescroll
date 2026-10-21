package com.awarescroll.data.remote

import okhttp3.Interceptor
import okhttp3.Response

class AuthInterceptor : Interceptor {
    @Volatile
    private var authToken: String? = null

    fun setToken(token: String?) {
        authToken = token
    }

    override fun intercept(chain: Interceptor.Chain): Response {
        val original = chain.request()
        val requestBuilder = original.newBuilder()

        authToken?.let {
            requestBuilder.header("Authorization", "Bearer $it")
        }

        return chain.proceed(requestBuilder.build())
    }
}
