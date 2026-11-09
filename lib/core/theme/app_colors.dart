import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';

/// Semantic color tokens mapping directly to ShiftIQ brand design tokens
class AppColors {
  AppColors._();

  static const Color primary = ShiftIQColors.primaryBlue;
  static const Color primaryLight = ShiftIQColors.accentSkyBlue;
  static const Color secondary = ShiftIQColors.secondaryTeal;
  static const Color neutralBg = ShiftIQColors.warmNeutral;
  static const Color neutralDark = ShiftIQColors.graphiteText;
  static const Color neutralLight = Color(0xFF64748B);
  static const Color neutralBorder = ShiftIQColors.borderSlate;
  static const Color stateSuccess = ShiftIQColors.preventiveGreen;
  static const Color stateWarning = ShiftIQColors.severityAmber;
  static const Color stateError = ShiftIQColors.severityCrimson;
  static const Color stateInfo = Color(0xFF2563EB);

  // Convenient semantic aliases
  static const Color success = ShiftIQColors.preventiveGreen;
  static const Color warning = ShiftIQColors.severityAmber;
  static const Color error = ShiftIQColors.severityCrimson;
  static const Color info = Color(0xFF2563EB);
  static const Color border = ShiftIQColors.borderSlate;
  static const Color textSecondary = Color(0xFF64748B);
  static const Color surface = Colors.white;
}
