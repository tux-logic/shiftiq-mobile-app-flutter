import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/iot_domain.dart';

class DtcAlertCard extends StatelessWidget {
  final DtcAlert alert;
  final VoidCallback onTap;
  final VoidCallback onOpenWorkOrder;

  const DtcAlertCard({
    super.key,
    required this.alert,
    required this.onTap,
    required this.onOpenWorkOrder,
  });

  @override
  Widget build(BuildContext context) {
    Color severityColor = alert.severity.color;
    Color severityBg;

    switch (alert.severity) {
      case DtcSeverity.critical:
        severityBg = ShiftIQColors.severityCrimson.withAlpha(20);
        break;
      case DtcSeverity.moderate:
        severityBg = ShiftIQColors.severityAmber.withAlpha(25);
        break;
      case DtcSeverity.low:
        severityBg = ShiftIQColors.accentSkyBlue.withAlpha(25);
        break;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: alert.isCritical
              ? ShiftIQColors.severityCrimson.withAlpha(120)
              : ShiftIQColors.borderSlate,
          width: alert.isCritical ? 1.5 : 1.0,
        ),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Code Badge, Severity Chip, Time Ago
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: ShiftIQColors.graphiteText,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      alert.code,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: severityBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          alert.isCritical
                              ? Icons.warning_rounded
                              : Icons.info_outline,
                          size: 13,
                          color: severityColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          alert.severity.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: severityColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    alert.formattedTimeAgo,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Description
              Text(
                alert.description,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ShiftIQColors.graphiteText,
                ),
              ),
              const SizedBox(height: 6),

              // Vehicle and Customer Info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: ShiftIQColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.directions_car_outlined,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${alert.vehiclePlate} · ${alert.vehicleModel}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: ShiftIQColors.graphiteText,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      alert.customerName,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // AI Recommendation Box
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ShiftIQColors.primaryBlue.withAlpha(12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: ShiftIQColors.primaryBlue.withAlpha(40)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: ShiftIQColors.primaryBlue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        alert.aiDiagnosticRecommendation,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: ShiftIQColors.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.analytics_outlined, size: 14),
                    label: const Text('Freeze Frame'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ShiftIQColors.graphiteText,
                      side: const BorderSide(color: ShiftIQColors.borderSlate),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: onOpenWorkOrder,
                    icon: const Icon(Icons.post_add_outlined, size: 14),
                    label: const Text('Abrir OT'),
                    style: FilledButton.styleFrom(
                      backgroundColor: ShiftIQColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
