import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';

/// Lifecycle status for a workshop work order.
enum WorkOrderStatus {
  pending('PENDING', 'Pendiente', ShiftIQColors.severityAmber),
  inProgress('IN_PROGRESS', 'En Progreso', ShiftIQColors.secondaryTeal),
  completed('COMPLETED', 'Completada', ShiftIQColors.preventiveGreen),
  paid('PAID', 'Pagada / Facturada', ShiftIQColors.primaryBlue),
  deleted('DELETED', 'Cancelada', ShiftIQColors.severityCrimson),
  cancelled('CANCELLED', 'Cancelada', ShiftIQColors.severityCrimson);

  final String value;
  final String label;
  final Color color;

  const WorkOrderStatus(this.value, this.label, this.color);

  static WorkOrderStatus fromString(String? val) {
    if (val == null) return WorkOrderStatus.pending;
    return WorkOrderStatus.values.firstWhere(
      (e) => e.value.toUpperCase() == val.toUpperCase(),
      orElse: () => WorkOrderStatus.pending,
    );
  }
}
