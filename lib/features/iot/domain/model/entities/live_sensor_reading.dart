import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';

class LiveSensorReading {
  final String sensorId;
  final String sensorName;
  final double value;
  final String unit;
  final double normalMin;
  final double normalMax;
  final IconData icon;

  const LiveSensorReading({
    required this.sensorId,
    required this.sensorName,
    required this.value,
    required this.unit,
    required this.normalMin,
    required this.normalMax,
    this.icon = Icons.sensors,
  });

  bool get isWarning => value < normalMin || value > normalMax;
  bool get isDanger =>
      value > (normalMax * 1.15) || (normalMin > 0 && value < (normalMin * 0.85));

  Color get statusColor {
    if (isDanger) return ShiftIQColors.severityCrimson;
    if (isWarning) return ShiftIQColors.severityAmber;
    return ShiftIQColors.preventiveGreen;
  }

  String get formattedValue => '${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1)} $unit';
}
