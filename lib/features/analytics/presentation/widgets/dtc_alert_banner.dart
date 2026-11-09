import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';

class DtcAlertBanner extends StatelessWidget {
  final int alertCount;
  final VoidCallback? onDetailsPressed;

  const DtcAlertBanner({
    super.key,
    required this.alertCount,
    this.onDetailsPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (alertCount <= 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2), // Light Crimson background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ShiftIQColors.severityCrimson.withAlpha(80),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: ShiftIQColors.severityCrimson,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'ALERTA TELEMETRÍA DTC ($alertCount VEHÍCULOS)',
                  style: TextStyle(
                    color: ShiftIQColors.severityCrimson,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Se detectaron códigos de diagnóstico críticos transmitidos por dongles OBD-II. Requiere inspección inmediata.',
            style: TextStyle(
              color: Color(0xFF7F1D1D),
              fontSize: 12,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onDetailsPressed,
              style: TextButton.styleFrom(
                foregroundColor: ShiftIQColors.severityCrimson,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: BorderSide(color: ShiftIQColors.severityCrimson.withAlpha(80)),
                ),
              ),
              icon: const Icon(Icons.arrow_forward, size: 14),
              label: const Text(
                'Ver Vehículos Afectados',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
