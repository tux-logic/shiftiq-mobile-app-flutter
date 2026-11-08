import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';

enum WorkOrderStatus {
  pending('PENDING', 'Pendiente', ShiftIQColors.severityAmber),
  inProgress('IN_PROGRESS', 'En Progreso', ShiftIQColors.secondaryTeal),
  completed('COMPLETED', 'Completada', ShiftIQColors.preventiveGreen),
  paid('PAID', 'Pagada', ShiftIQColors.primaryBlue),
  cancelled('CANCELLED', 'Cancelada', ShiftIQColors.severityCrimson);

  final String value;
  final String label;
  final Color color;

  const WorkOrderStatus(this.value, this.label, this.color);

  static WorkOrderStatus fromString(String? value) {
    if (value == null) return WorkOrderStatus.pending;
    return WorkOrderStatus.values.firstWhere(
      (s) => s.value.toUpperCase() == value.toUpperCase(),
      orElse: () => WorkOrderStatus.pending,
    );
  }
}
