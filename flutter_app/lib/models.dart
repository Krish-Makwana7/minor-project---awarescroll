// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary & Accents
  static const Color primary = Color(0xFF3A5BFF);
  static const Color primaryDark = Color(0xFF22348F);
  static const Color secondary = Color(0xFF00B894);
  static const Color accentReflect = Color(0xFFFF9F43);
  static const Color error = Color(0xFFE5484D);

  // Surfaces & Backgrounds
  static const Color bgLight = Color(0xFFF8F9FE);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF14152B);
  static const Color textSecondary = Color(0xFF6B6F8C);
  static const Color borderLight = Color(0xFFE2E4F0);
}

class SessionRecord {
  final String id;
  final String appName;
  final int intendedMinutes;
  final double actualMinutes;
  final bool closedOnFirstReminder;
  final String timeOfDay;
  final DateTime timestamp;
  final Map<String, String>? feedback;

  SessionRecord({
    required this.id,
    required this.appName,
    required this.intendedMinutes,
    required this.actualMinutes,
    required this.closedOnFirstReminder,
    required this.timeOfDay,
    required this.timestamp,
    this.feedback,
  });
}

RoundedRectangleBorder RoundedCornerShape(double radius) =>
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
