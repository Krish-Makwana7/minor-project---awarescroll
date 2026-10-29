// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSessionRecord {
  final String id;
  final String studentEmail;
  final String studentName;
  final DateTime timestamp;
  final String appName;
  final int intendedMinutes;
  final int actualSeconds;
  final String purpose;
  final String priorActivity;
  final String necessity;
  final bool limitRespected;
  final String? wasImportant;
  final String? triggerReason;
  final String? mood;
  final String sessionOutcome;

  UserSessionRecord({
    required this.id,
    required this.studentEmail,
    required this.studentName,
    required this.timestamp,
    this.appName = 'Instagram',
    required this.intendedMinutes,
    required this.actualSeconds,
    required this.purpose,
    this.priorActivity = 'Studying',
    this.necessity = 'Casual leisure',
    required this.limitRespected,
    this.wasImportant,
    this.triggerReason,
    this.mood,
    required this.sessionOutcome,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentEmail': studentEmail,
      'studentName': studentName,
      'studentId': '$studentName ($studentEmail)',
      'timestamp': timestamp.toIso8601String(),
      'appName': appName,
      'packageName': 'com.instagram.android',
      'intendedMinutes': intendedMinutes,
      'limitMinutes': intendedMinutes,
      'actualSeconds': actualSeconds,
      'elapsedSeconds': actualSeconds,
      'actualMinutes': (actualSeconds / 60.0).toStringAsFixed(1),
      'purpose': purpose,
      'priorActivity': priorActivity,
      'supposedActivity': priorActivity,
      'necessity': necessity,
      'limitRespected': limitRespected,
      'wasImportant': wasImportant ?? '',
      'triggerReason': triggerReason ?? '',
      'trigger': triggerReason ?? '',
      'mood': mood ?? 'Neutral',
      'feeling': mood ?? 'Neutral',
      'sessionOutcome': sessionOutcome,
      'dayOfWeek': _getDayName(timestamp.weekday),
      'hourOfDay': timestamp.hour,
    };
  }

  factory UserSessionRecord.fromMap(Map<String, dynamic> map) {
    return UserSessionRecord(
      id: map['id'] ?? 'session_${DateTime.now().millisecondsSinceEpoch}',
      studentEmail: map['studentEmail'] ?? '',
      studentName: map['studentName'] ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      appName: map['appName'] ?? 'Instagram',
      intendedMinutes: (map['intendedMinutes'] as num?)?.toInt() ?? 5,
      actualSeconds: (map['actualSeconds'] as num?)?.toInt() ?? 0,
      purpose: map['purpose'] ?? 'General scroll',
      priorActivity: map['priorActivity'] ?? map['supposedActivity'] ?? 'Working',
      necessity: map['necessity'] ?? '',
      limitRespected: map['limitRespected'] == true,
      wasImportant: map['wasImportant'],
      triggerReason: map['triggerReason'] ?? map['trigger'],
      mood: map['mood'] ?? map['feeling'],
      sessionOutcome: map['sessionOutcome'] ?? 'completed',
    );
  }

  static String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[(weekday - 1) % 7];
  }
}

class UserSessionService {
  static const String googleSheetWebhookUrl =
      'https://script.google.com/macros/s/AKfycbz0UGg5UuExe1joA5LYNWkAbyKp3vl5l-2Pk1MXVoN3U-AOSzePm78Q1BKWsRVsdQ8l/exec';

  static const MethodChannel _platform = MethodChannel('com.awarescroll/restriction');

  static final ValueNotifier<int> sessionUpdateNotifier = ValueNotifier<int>(0);

  static Future<String> getCurrentUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('student_email') ?? 'student@awarescroll.app';
  }

  static Future<String> getCurrentUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('student_name') ?? 'Student';
  }

  static String _getStorageKey(String email) {
    final clean = email.toLowerCase().trim().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    return 'user_real_sessions_$clean';
  }

  static Future<List<UserSessionRecord>> getSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final email = await getCurrentUserEmail();
    final key = _getStorageKey(email);
    final rawList = prefs.getStringList(key);

    if (rawList == null || rawList.isEmpty) {
      return [];
    }

    final List<UserSessionRecord> records = [];
    for (final item in rawList) {
      try {
        final map = jsonDecode(item) as Map<String, dynamic>;
        records.add(UserSessionRecord.fromMap(map));
      } catch (_) {}
    }

    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return records;
  }

  static Future<void> recordSession(UserSessionRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final email = await getCurrentUserEmail();
    final key = _getStorageKey(email);

    final rawList = prefs.getStringList(key) ?? [];
    rawList.insert(0, jsonEncode(record.toMap()));
    await prefs.setStringList(key, rawList);

    // Also notify UI listeners
    sessionUpdateNotifier.value++;

    // Sync to Google Sheet Webhook
    _syncToGoogleSheetAsync(record);

    // Sync to Android Kotlin Telemetry storage
    try {
      await _platform.invokeMethod('recordTelemetryFeedback', record.toMap());
    } catch (_) {}
  }

  static void _syncToGoogleSheetAsync(UserSessionRecord record) {
    Future.microtask(() async {
      try {
        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 12);
        final request = await client.postUrl(Uri.parse(googleSheetWebhookUrl));
        request.headers.set('Content-Type', 'application/json; charset=UTF-8');
        request.headers.set('Accept', 'application/json');

        final payload = jsonEncode(record.toMap());
        request.write(payload);

        final response = await request.close();
        if (kDebugMode) {
          print('Google Sheet Webhook response code: ${response.statusCode}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error syncing session to Google Sheet: $e');
        }
      }
    });
  }

  static Future<Map<String, dynamic>> getTodayStats() async {
    final all = await getSessions();
    final now = DateTime.now();

    final todaySessions = all.where((s) {
      return s.timestamp.year == now.year &&
          s.timestamp.month == now.month &&
          s.timestamp.day == now.day;
    }).toList();

    int totalSecondsToday = 0;
    int adheredCount = 0;
    int meaningfulCount = 0;
    int surveyCount = 0;

    for (final s in todaySessions) {
      totalSecondsToday += s.actualSeconds;
      if (s.limitRespected) adheredCount++;

      if (s.wasImportant != null && s.wasImportant!.isNotEmpty) {
        surveyCount++;
        if (s.wasImportant!.toLowerCase().contains('yes') ||
            s.wasImportant!.toLowerCase().contains('meaningful')) {
          meaningfulCount++;
        } else {
        }
      }
    }

    final adherencePct = todaySessions.isEmpty
        ? 100
        : ((adheredCount / todaySessions.length) * 100).round();

    final meaningfulPct = surveyCount == 0
        ? 35
        : ((meaningfulCount / surveyCount) * 100).round();

    final mindlessPct = surveyCount == 0 ? 65 : (100 - meaningfulPct);

    return {
      'totalSecondsToday': totalSecondsToday,
      'todaySessionCount': todaySessions.length,
      'adherencePct': adherencePct,
      'adheredCount': adheredCount,
      'meaningfulPct': meaningfulPct,
      'mindlessPct': mindlessPct,
      'surveyCount': surveyCount,
      'todaySessions': todaySessions,
    };
  }

  static Future<Map<String, double>> getWeeklyDailyMinutes() async {
    final all = await getSessions();
    final now = DateTime.now();
    final Map<String, double> result = {};

    for (int i = 6; i >= 0; i--) {
      final targetDate = now.subtract(Duration(days: i));
      final dayName = _getDayShort(targetDate.weekday);
      result[dayName] = 0.0;
    }

    for (final s in all) {
      final diff = now.difference(s.timestamp).inDays;
      if (diff >= 0 && diff < 7) {
        final dayName = _getDayShort(s.timestamp.weekday);
        final mins = s.actualSeconds / 60.0;
        result[dayName] = (result[dayName] ?? 0.0) + mins;
      }
    }

    return result;
  }

  static String _getDayShort(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[(weekday - 1) % 7];
  }

  static Future<void> clearUserSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final email = await getCurrentUserEmail();
    final key = _getStorageKey(email);
    await prefs.remove(key);
    sessionUpdateNotifier.value++;
  }
}
