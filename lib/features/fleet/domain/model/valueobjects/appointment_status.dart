import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';

enum AppointmentStatus {
  pending('PENDING', 'Pendiente', ShiftIQColors.severityAmber),
  confirmed('CONFIRMED', 'Confirmada', ShiftIQColors.preventiveGreen),
  completed('COMPLETED', 'Atendida', ShiftIQColors.primaryBlue),
  canceled('CANCELED', 'Cancelada', ShiftIQColors.severityCrimson);

  final String value;
  final String label;
  final Color color;

  const AppointmentStatus(this.value, this.label, this.color);

  static AppointmentStatus fromString(String? value) {
    if (value == null) return AppointmentStatus.pending;
    final normalized = value.trim().toUpperCase();
    if (normalized == 'CANCELLED' || normalized == 'CANCELED') {
      return AppointmentStatus.canceled;
    }
    return AppointmentStatus.values.firstWhere(
      (s) => s.value == normalized,
      orElse: () => AppointmentStatus.pending,
    );
  }
}
