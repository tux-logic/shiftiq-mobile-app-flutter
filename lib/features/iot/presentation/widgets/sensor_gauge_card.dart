import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/model/entities/live_sensor_reading.dart';

class SensorGaugeCard extends StatelessWidget {
  final LiveSensorReading sensor;

  const SensorGaugeCard({
    super.key,
    required this.sensor,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = sensor.statusColor;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: sensor.isWarning
              ? statusColor.withAlpha(120)
              : ShiftIQColors.borderSlate,
          width: sensor.isWarning ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(sensor.icon, size: 18, color: statusColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  sensor.sensorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            sensor.formattedValue,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: sensor.normalMax > 0
                  ? (sensor.value / sensor.normalMax).clamp(0.0, 1.0)
                  : 0.5,
              backgroundColor: ShiftIQColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mín: ${sensor.normalMin.toInt()} ${sensor.unit}',
                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
              ),
              Text(
                'Máx: ${sensor.normalMax.toInt()} ${sensor.unit}',
                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
