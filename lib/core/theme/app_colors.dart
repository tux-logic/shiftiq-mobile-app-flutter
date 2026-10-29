import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF1E3A8A); // Deep ShiftIQ Blue
  static const Color primaryLight = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF0F172A);

  // Automotive Visualizer Tech Palette
  static const Color techCardBackground = Color(0xFF081224); // Deep Navy
  static const Color techCardBorder = Color(0xFF162947);
  static const Color techElevatorLine = Color(0xFF38BDF8); // Cyan Accent
  static const Color techDtcBox = Color(0xFF0D1E3A);

  // Status & Telemetry Neons
  static const Color neonGreen = Color(0xFF00E676); // CAN-BUS Online
  static const Color neonGreenSubtle = Color(0x2200E676);
  static const Color neonBlue = Color(0xFF00C2FF); // OBD2 Synced
  static const Color neonOrange = Color(0xFFFF9100); // DTC Warning
  static const Color neonRed = Color(0xFFFF1744); // Critical DTC

  // Neutral Colors (Light mode surfaces & contrast)
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Neutral Colors (Dark mode)
  static const Color backgroundDark = Color(0xFF0B0F19);
  static const Color surfaceDark = Color(0xFF131A29);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color borderDark = Color(0xFF1E293B);

  // Button & Input styling
  static const Color darkButtonBackground = Color(0xFF111827);
  static const Color outlinedButtonBorder = Color(0xFFE2E8F0);
}
