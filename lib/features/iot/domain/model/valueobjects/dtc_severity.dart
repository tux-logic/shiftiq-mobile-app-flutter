import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';

enum DtcSeverity {
  critical('CRITICAL', 'Crítica / Inmediata', ShiftIQColors.severityCrimson),
  moderate('MODERATE', 'Moderada / Advertencia', ShiftIQColors.severityAmber),
  low('LOW', 'Baja / Informativa', ShiftIQColors.accentSkyBlue);

  final String value;
  final String label;
  final Color color;

  const DtcSeverity(this.value, this.label, this.color);

  static DtcSeverity fromString(String? val) {
    if (val == null) return DtcSeverity.moderate;
    return DtcSeverity.values.firstWhere(
      (e) => e.value.toUpperCase() == val.toUpperCase(),
      orElse: () => DtcSeverity.moderate,
    );
  }
}
