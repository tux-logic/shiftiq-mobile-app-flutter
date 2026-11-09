import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';

/// Represents inventory stock status states for workshop spare parts.
enum StockStatus {
  normal('NORMAL', 'Stock Óptimo', ShiftIQColors.preventiveGreen),
  lowStock('LOW_STOCK', 'Stock Crítico', ShiftIQColors.severityAmber),
  outOfStock('OUT_OF_STOCK', 'Agotado', ShiftIQColors.severityCrimson);

  final String value;
  final String label;
  final Color color;

  const StockStatus(this.value, this.label, this.color);

  static StockStatus fromString(String? val) {
    if (val == null) return StockStatus.normal;
    return StockStatus.values.firstWhere(
      (s) => s.value.toUpperCase() == val.toUpperCase(),
      orElse: () => StockStatus.normal,
    );
  }
}
