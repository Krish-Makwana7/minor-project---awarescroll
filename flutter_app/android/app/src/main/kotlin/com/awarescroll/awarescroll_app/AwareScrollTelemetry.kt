package com.awarescroll.awarescroll_app

import android.content.Context
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.net.HttpURLConnection
import java.net.URL
import java.text.SimpleDateFormat
import java.util.*

object AwareScrollTelemetry {

    private const val TAG = "AwareScrollTelemetry"
    private const val PREF_NAME = "awarescroll_telemetry"
    private const val KEY_RECORDS = "records_json"
    private const val KEY_STUDENT_ID = "student_id"
    private const val KEY_CLOUD_URL = "cloud_sync_url"
    private const val CSV_FILENAME = "awarescroll_survey_dataset.csv"
    private const val JSON_FILENAME = "awarescroll_survey_dataset.json"

    // Hardcoded Master Google Sheet Webhook URL
    private const val DEFAULT_CLOUD_URL = "https://script.google.com/macros/s/AKfycbz0UGg5UuExe1joA5LYNWkAbyKp3vl5l-2Pk1MXVoN3U-AOSzePm78Q1BKWsRVsdQ8l/exec"

    private val isoFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ", Locale.US)
    private val dayFormat = SimpleDateFormat("EEEE", Locale.US)
    private val hourFormat = SimpleDateFormat("HH", Locale.US)

    @Synchronized
    fun getStudentId(context: Context): String {
        val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        var sId = prefs.getString(KEY_STUDENT_ID, null)
        if (sId.isNullOrBlank()) {
            val randHex = Integer.toHexString(Random().nextInt(0x8fffff) + 0x100000).uppercase()
            sId = "Student_$randHex"
            prefs.edit().putString(KEY_STUDENT_ID, sId).apply()
        }
        return sId
    }

    @Synchronized
    fun setStudentId(context: Context, newId: String) {
        val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        prefs.edit().putString(KEY_STUDENT_ID, newId.trim()).apply()
    }

    @Synchronized
    fun getCloudSyncUrl(context: Context): String {
        val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        return prefs.getString(KEY_CLOUD_URL, "") ?: ""
    }

    @Synchronized
    fun setCloudSyncUrl(context: Context, url: String) {
        val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        prefs.edit().putString(KEY_CLOUD_URL, url.trim()).apply()
    }

    @Synchronized
    fun recordSurveyResponse(
        context: Context,
        appName: String = "Instagram",
        packageName: String = "com.instagram.android",
        limitMinutes: Int = 5,
        elapsedSeconds: Int = 300,
        extensionMinutes: Int = 5,
        purpose: String,
        trigger: String,
        category: String,
        workImpact: String,
        feeling: String,
        supposedActivity: String,
        helpStop: String,
        sessionOutcome: String = "extended"
    ) {
        try {
            val now = Date()
            val id = "session_${now.time}"
            val studentId = getStudentId(context)
            val timestamp = isoFormat.format(now)
            val dayOfWeek = dayFormat.format(now)
            val hourOfDay = try { hourFormat.format(now).toInt() } catch (e: Exception) { 12 }

            val record = JSONObject().apply {
                put("id", id)
                put("studentId", studentId)
                put("timestamp", timestamp)
                put("appName", appName)
                put("packageName", packageName)
                put("limitMinutes", limitMinutes)
                put("elapsedSeconds", elapsedSeconds)
                put("extensionMinutes", extensionMinutes)
                put("purpose", purpose)
                put("trigger", trigger)
                put("category", category)
                put("workImpact", workImpact)
                put("feeling", feeling)
                put("supposedActivity", supposedActivity)
                put("helpStop", helpStop)
                put("sessionOutcome", sessionOutcome)
                put("dayOfWeek", dayOfWeek)
                put("hourOfDay", hourOfDay)
            }

            val records = getRecordsArray(context)
            records.put(record)

            saveRecordsArray(context, records)
            exportFiles(context, records)
            Log.d(TAG, "Recorded survey response: $id for $studentId on $appName (Total records: ${records.length()})")

            // Automatically attempt non-blocking background sync to class cloud sheet
            syncRecordToCloudAsync(context, record)
        } catch (e: Exception) {
            Log.e(TAG, "Error recording survey response", e)
        }
    }

    private fun syncRecordToCloudAsync(context: Context, record: JSONObject) {
        val cloudUrl = getCloudSyncUrl(context)
        if (cloudUrl.isBlank()) return

        Thread {
            try {
                val url = URL(cloudUrl)
                val conn = url.openConnection() as HttpURLConnection
                conn.requestMethod = "POST"
                conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8")
                conn.setRequestProperty("Accept", "application/json")
                conn.connectTimeout = 10000
                conn.readTimeout = 10000
                conn.doOutput = true

                conn.outputStream.use { os ->
                    os.write(record.toString().toByteArray(Charsets.UTF_8))
                }

                val code = conn.responseCode
                Log.d(TAG, "Cloud sync single record finished with HTTP: $code")
                conn.disconnect()
            } catch (e: Exception) {
                Log.e(TAG, "Async cloud sync failed (will retry on batch sync)", e)
            }
        }.start()
    }

    fun syncAllToCloud(context: Context): Boolean {
        val cloudUrl = getCloudSyncUrl(context)
        if (cloudUrl.isBlank()) return false

        val records = getRecordsArray(context)
        if (records.length() == 0) return true

        return try {
            val url = URL(cloudUrl)
            val conn = url.openConnection() as HttpURLConnection
            conn.requestMethod = "POST"
            conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8")
            conn.setRequestProperty("Accept", "application/json")
            conn.connectTimeout = 12000
            conn.readTimeout = 12000
            conn.doOutput = true

            val payload = JSONObject().apply {
                put("studentId", getStudentId(context))
                put("deviceTimestamp", isoFormat.format(Date()))
                put("recordsCount", records.length())
                put("records", records)
            }

            conn.outputStream.use { os ->
                os.write(payload.toString().toByteArray(Charsets.UTF_8))
            }

            val code = conn.responseCode
            conn.disconnect()
            code in 200..399
        } catch (e: Exception) {
            Log.e(TAG, "Batch cloud sync failed", e)
            false
        }
    }

    @Synchronized
    fun getRecordsJson(context: Context): String {
        val records = getRecordsArray(context)
        if (records.length() == 0) {
            // Seed with sample data so Data Science dashboard is immediately rich & demonstrative
            loadSampleData(context)
            return getRecordsArray(context).toString()
        }
        return records.toString()
    }

    @Synchronized
    fun getRecordsCsv(context: Context): String {
        val records = getRecordsArray(context)
        if (records.length() == 0) {
            loadSampleData(context)
            return convertJsonToCsv(getRecordsArray(context))
        }
        return convertJsonToCsv(records)
    }

    @Synchronized
    fun saveRecordsJson(context: Context, jsonStr: String): Boolean {
        return try {
            val records = JSONArray(jsonStr)
            saveRecordsArray(context, records)
            exportFiles(context, records)
            true
        } catch (e: Exception) {
            Log.e(TAG, "Error saving records json", e)
            false
        }
    }

    @Synchronized
    fun clearRecords(context: Context) {
        val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        prefs.edit().remove(KEY_RECORDS).apply()
        try {
            File(context.filesDir, CSV_FILENAME).delete()
            File(context.filesDir, JSON_FILENAME).delete()
        } catch (e: Exception) {}
    }

    @Synchronized
    fun loadSampleData(context: Context) {
        val sampleList = listOf(
            SampleItem("24bt04d233@gsfcuniversity.ac.in", "Reply to a message", "Boredom", "Comedy / Memes", "Delayed a task", "Neutral", "Working", "Time warning", 5, 310, "Friday", 14),
            SampleItem("24bt04d233@gsfcuniversity.ac.in", "Check updates", "Interesting content", "Reels / Entertainment", "Delayed a task", "Bored", "Studying", "App closure", 10, 620, "Friday", 16),
            SampleItem("24sc06007@gsfcuniversity.ac.in", "Nothing to do, so watch reels", "Boredom", "Comedy / Memes", "Interrupted a task", "Bored", "Working", "Time warning", 5, 305, "Thursday", 11),
            SampleItem("24sc06007@gsfcuniversity.ac.in", "Reply to a message", "Notifications / messages", "Stories / Personal content", "No task planned", "Satisfied", "Relaxing", "Mood check", 2, 130, "Thursday", 19),
            SampleItem("24sc06028@gsfcuniversity.ac.in", "Finished all tasks, want to watch reels", "Habitual scrolling", "Reels / Entertainment", "No negative impact / planned break", "Relaxed", "Nothing planned", "Break suggestion", 5, 320, "Wednesday", 21),
            SampleItem("24sc06028@gsfcuniversity.ac.in", "Opened automatically / out of habit", "Habitual scrolling", "Comedy / Memes", "Delayed a task", "Stressed / regretful", "Studying", "Original-purpose reminder", 5, 315, "Wednesday", 15),
            SampleItem("rohit.patel@gmail.com", "Study or research", "Unfinished original purpose", "Education / Technology", "No negative impact / planned break", "Satisfied", "Working", "Time warning", 10, 600, "Tuesday", 10),
            SampleItem("rohit.patel@gmail.com", "Nothing to do, so watch reels", "Boredom", "Fitness / Lifestyle", "Delayed a task", "Neutral", "Studying", "Time warning", 5, 302, "Tuesday", 17),
            SampleItem("sneha.sharma@gmail.com", "Checking someone's reply", "Stress / mood", "Music / Entertainment", "Interrupted a task", "Bored", "Working", "Break suggestion", 5, 340, "Monday", 13),
            SampleItem("sneha.sharma@gmail.com", "Opened automatically / out of habit", "Boredom", "Reels / Entertainment", "Delayed a task", "Stressed / regretful", "Sleeping", "App closure", 15, 920, "Monday", 23),
            SampleItem("ananya.shah@gmail.com", "Check updates", "Notifications / messages", "News / Politics", "No negative impact / planned break", "Relaxed", "Socializing", "Mood check", 2, 125, "Sunday", 12),
            SampleItem("ananya.shah@gmail.com", "Nothing to do, so watch reels", "Interesting content", "Comedy / Memes", "Delayed a task", "Neutral", "Studying", "Time warning", 5, 310, "Saturday", 18),
            SampleItem("manav.desai@gmail.com", "Finished all tasks, want to watch reels", "Boredom", "Music / Entertainment", "No negative impact / planned break", "Satisfied", "Nothing planned", "Break suggestion", 10, 605, "Saturday", 20),
            SampleItem("manav.desai@gmail.com", "Reply to a message", "Habitual scrolling", "Stories / Personal content", "Delayed a task", "Bored", "Working", "Time warning", 5, 310, "Friday", 15),
            SampleItem("dev.joshi@gmail.com", "Opened automatically / out of habit", "Boredom", "Comedy / Memes", "Delayed a task", "Stressed / regretful", "Studying", "App closure", 5, 305, "Thursday", 14),
            SampleItem("dev.joshi@gmail.com", "Reply to a message", "Notifications / messages", "Reels / Entertainment", "Delayed a task", "Neutral", "Working", "Time warning", 5, 315, "Wednesday", 16),
            SampleItem("khushi.mehta@gmail.com", "Check updates", "Interesting content", "Comedy / Memes", "Interrupted a task", "Bored", "Studying", "App closure", 5, 320, "Tuesday", 19),
            SampleItem("khushi.mehta@gmail.com", "Nothing to do, so watch reels", "Boredom", "Reels / Entertainment", "Delayed a task", "Stressed / regretful", "Sleeping", "App closure", 10, 610, "Monday", 22)
        )

        val arr = JSONArray()
        val cal = Calendar.getInstance()

        for (i in sampleList.indices) {
            val s = sampleList[i]
            cal.time = Date()
            cal.add(Calendar.DAY_OF_YEAR, -(i % 7))
            cal.set(Calendar.HOUR_OF_DAY, s.hour)

            val rec = JSONObject().apply {
                put("id", "sample_${cal.timeInMillis}_$i")
                put("studentId", s.studentId)
                put("timestamp", isoFormat.format(cal.time))
                put("appName", "Instagram")
                put("packageName", "com.instagram.android")
                put("limitMinutes", 5)
                put("elapsedSeconds", s.elapsed)
                put("extensionMinutes", s.extMin)
                put("purpose", s.purpose)
                put("trigger", s.trigger)
                put("category", s.category)
                put("workImpact", s.workImpact)
                put("feeling", s.feeling)
                put("supposedActivity", s.supposedActivity)
                put("helpStop", s.helpStop)
                put("sessionOutcome", "extended")
                put("dayOfWeek", s.day)
                put("hourOfDay", s.hour)
            }
            arr.put(rec)
        }

        saveRecordsArray(context, arr)
        exportFiles(context, arr)
    }

    private data class SampleItem(
        val studentId: String,
        val purpose: String,
        val trigger: String,
        val category: String,
        val workImpact: String,
        val feeling: String,
        val supposedActivity: String,
        val helpStop: String,
        val extMin: Int,
        val elapsed: Int,
        val day: String,
        val hour: Int
    )

    private fun getRecordsArray(context: Context): JSONArray {
        val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        val jsonStr = prefs.getString(KEY_RECORDS, null) ?: return JSONArray()
        return try {
            JSONArray(jsonStr)
        } catch (e: Exception) {
            JSONArray()
        }
    }

    private fun saveRecordsArray(context: Context, arr: JSONArray) {
        val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        prefs.edit().putString(KEY_RECORDS, arr.toString()).apply()
    }

    private fun exportFiles(context: Context, arr: JSONArray) {
        try {
            // Write JSON file
            val jsonFile = File(context.filesDir, JSON_FILENAME)
            jsonFile.writeText(arr.toString(2))

            // Write CSV file
            val csvContent = convertJsonToCsv(arr)
            val csvFile = File(context.filesDir, CSV_FILENAME)
            csvFile.writeText(csvContent)

            // Also copy to external files dir (if available) for easy PC transfer
            context.getExternalFilesDir(null)?.let { extDir ->
                File(extDir, JSON_FILENAME).writeText(arr.toString(2))
                File(extDir, CSV_FILENAME).writeText(csvContent)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error exporting files", e)
        }
    }

    private fun convertJsonToCsv(arr: JSONArray): String {
        val sb = StringBuilder()
        // CSV Header with studentId for multi-student group analysis
        sb.append("id,studentId,timestamp,appName,packageName,limitMinutes,elapsedSeconds,extensionMinutes,purpose,trigger,category,workImpact,feeling,supposedActivity,helpStop,sessionOutcome,dayOfWeek,hourOfDay\n")

        for (i in 0 until arr.length()) {
            val obj = arr.getJSONObject(i)
            sb.append(escapeCsv(obj.optString("id"))).append(",")
            sb.append(escapeCsv(obj.optString("studentId", "Student_Anon"))).append(",")
            sb.append(escapeCsv(obj.optString("timestamp"))).append(",")
            sb.append(escapeCsv(obj.optString("appName"))).append(",")
            sb.append(escapeCsv(obj.optString("packageName"))).append(",")
            sb.append(obj.optInt("limitMinutes", 5)).append(",")
            sb.append(obj.optInt("elapsedSeconds", 300)).append(",")
            sb.append(obj.optInt("extensionMinutes", 5)).append(",")
            sb.append(escapeCsv(obj.optString("purpose"))).append(",")
            sb.append(escapeCsv(obj.optString("trigger"))).append(",")
            sb.append(escapeCsv(obj.optString("category"))).append(",")
            sb.append(escapeCsv(obj.optString("workImpact"))).append(",")
            sb.append(escapeCsv(obj.optString("feeling"))).append(",")
            sb.append(escapeCsv(obj.optString("supposedActivity"))).append(",")
            sb.append(escapeCsv(obj.optString("helpStop"))).append(",")
            sb.append(escapeCsv(obj.optString("sessionOutcome"))).append(",")
            sb.append(escapeCsv(obj.optString("dayOfWeek"))).append(",")
            sb.append(obj.optInt("hourOfDay", 12)).append("\n")
        }
        return sb.toString()
    }

    private fun escapeCsv(value: String): String {
        var str = value.replace("\"", "\"\"")
        if (str.contains(",") || str.contains("\n") || str.contains("\"")) {
            str = "\"$str\""
        }
        return str
    }
}
