package com.awarescroll.awarescroll_app

import android.content.Context
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.text.SimpleDateFormat
import java.util.*

object AwareScrollTelemetry {

    private const val TAG = "AwareScrollTelemetry"
    private const val PREF_NAME = "awarescroll_telemetry"
    private const val KEY_RECORDS = "records_json"
    private const val CSV_FILENAME = "awarescroll_survey_dataset.csv"
    private const val JSON_FILENAME = "awarescroll_survey_dataset.json"

    private val isoFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZ", Locale.US)
    private val dayFormat = SimpleDateFormat("EEEE", Locale.US)
    private val hourFormat = SimpleDateFormat("HH", Locale.US)

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
            val timestamp = isoFormat.format(now)
            val dayOfWeek = dayFormat.format(now)
            val hourOfDay = try { hourFormat.format(now).toInt() } catch (e: Exception) { 12 }

            val record = JSONObject().apply {
                put("id", id)
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
            Log.d(TAG, "Recorded survey response: $id for $appName (Total records: ${records.length()})")
        } catch (e: Exception) {
            Log.e(TAG, "Error recording survey response", e)
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
            SampleItem("Reply to a message", "Boredom", "Comedy / Memes", "Delayed a task", "Neutral", "Working", "Time warning", 5, 310, "Friday", 14),
            SampleItem("Check updates", "Interesting content", "Reels / Entertainment", "Delayed a task", "Bored", "Studying", "App closure", 10, 620, "Friday", 16),
            SampleItem("Nothing to do, so watch reels", "Boredom", "Comedy / Memes", "Interrupted a task", "Bored", "Working", "Time warning", 5, 305, "Thursday", 11),
            SampleItem("Reply to a message", "Notifications / messages", "Stories / Personal content", "No task planned", "Satisfied", "Relaxing", "Mood check", 2, 130, "Thursday", 19),
            SampleItem("Finished all tasks, want to watch reels", "Habitual scrolling", "Reels / Entertainment", "No negative impact / planned break", "Relaxed", "Nothing planned", "Break suggestion", 5, 320, "Wednesday", 21),
            SampleItem("Opened automatically / out of habit", "Habitual scrolling", "Comedy / Memes", "Delayed a task", "Stressed / regretful", "Studying", "Original-purpose reminder", 5, 315, "Wednesday", 15),
            SampleItem("Study or research", "Unfinished original purpose", "Education / Technology", "No negative impact / planned break", "Satisfied", "Working", "Time warning", 10, 600, "Tuesday", 10),
            SampleItem("Nothing to do, so watch reels", "Boredom", "Fitness / Lifestyle", "Delayed a task", "Neutral", "Studying", "Time warning", 5, 302, "Tuesday", 17),
            SampleItem("Checking someone's reply", "Stress / mood", "Music / Entertainment", "Interrupted a task", "Bored", "Working", "Break suggestion", 5, 340, "Monday", 13),
            SampleItem("Opened automatically / out of habit", "Boredom", "Reels / Entertainment", "Delayed a task", "Stressed / regretful", "Sleeping", "App closure", 15, 920, "Monday", 23),
            SampleItem("Check updates", "Notifications / messages", "News / Politics", "No negative impact / planned break", "Relaxed", "Socializing", "Mood check", 2, 125, "Sunday", 12),
            SampleItem("Nothing to do, so watch reels", "Interesting content", "Comedy / Memes", "Delayed a task", "Neutral", "Studying", "Time warning", 5, 310, "Saturday", 18),
            SampleItem("Finished all tasks, want to watch reels", "Boredom", "Music / Entertainment", "No negative impact / planned break", "Satisfied", "Nothing planned", "Break suggestion", 10, 605, "Saturday", 20),
            SampleItem("Reply to a message", "Habitual scrolling", "Stories / Personal content", "Delayed a task", "Bored", "Working", "Time warning", 5, 310, "Friday", 15),
            SampleItem("Opened automatically / out of habit", "Boredom", "Comedy / Memes", "Delayed a task", "Stressed / regretful", "Studying", "App closure", 5, 305, "Thursday", 14)
        )

        val arr = JSONArray()
        val cal = Calendar.getInstance()

        for (i in sampleList.indices) {
            val s = sampleList[i]
            cal.time = Date()
            cal.add(Calendar.DAY_OF_YEAR, -(i % 7))
            cal.set(Calendar.HOUR_OF_DAY, s.hour)

            val rec = JSONObject().apply {
                put("id", "sample_${cal.timeInMillis}")
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
        // CSV Header
        sb.append("id,timestamp,appName,packageName,limitMinutes,elapsedSeconds,extensionMinutes,purpose,trigger,category,workImpact,feeling,supposedActivity,helpStop,sessionOutcome,dayOfWeek,hourOfDay\n")

        for (i in 0 until arr.length()) {
            val obj = arr.getJSONObject(i)
            sb.append(escapeCsv(obj.optString("id"))).append(",")
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
