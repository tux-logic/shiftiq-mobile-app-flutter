import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';

enum DtcSeverity {
  critical('CRITICAL', 'Critical / Immediate', ShiftIQColors.severityCrimson),
  moderate('MODERATE', 'Moderate / Warning', ShiftIQColors.severityAmber),
  low('LOW', 'Low / Informational', ShiftIQColors.accentSkyBlue);

  final String value;
  final String label;
  final Color color;

  const DtcSeverity(this.value, this.label, this.color);

  String localizedLabel(AppLocalizations loc) {
    switch (this) {
      case DtcSeverity.critical:
        return loc.translate('dtc_severity_critical');
      case DtcSeverity.moderate:
        return loc.translate('dtc_severity_moderate');
      case DtcSeverity.low:
        return loc.translate('dtc_severity_low');
    }
  }

  static DtcSeverity fromString(String? val) {
    if (val == null) return DtcSeverity.moderate;
    return DtcSeverity.values.firstWhere(
      (e) => e.value.toUpperCase() == val.toUpperCase(),
      orElse: () => DtcSeverity.moderate,
    );
  }
}
