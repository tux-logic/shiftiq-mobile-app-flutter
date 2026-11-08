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
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: ShiftIQColors.severityCrimson,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'OBD-II LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 0, height: 10),
          Text(
            'Se detectaron códigos de falla activa en vehículos asignados a esta sede:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 6),
          _buildDtcRow('Toyota Hilux (BCX-892)', 'P0300 - Fallo de encendido múltiple'),
          _buildDtcRow('Hyundai Tucson (AJ-4421)', 'P0171 - Mezcla de combustible pobre'),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onDetailsPressed,
              style: TextButton.styleFrom(
                foregroundColor: ShiftIQColors.severityCrimson,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              icon: const Text(
                'VER DETALLES DE TELEMETRÍA',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              label: const Icon(Icons.arrow_forward, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDtcRow(String vehicle, String dtcCode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 6, color: ShiftIQColors.severityCrimson),
          const SizedBox(width: 8),
          Text(
            vehicle,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
          const Text(' : ', style: TextStyle(fontSize: 12)),
          Expanded(
            child: Text(
              dtcCode,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[700],
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

