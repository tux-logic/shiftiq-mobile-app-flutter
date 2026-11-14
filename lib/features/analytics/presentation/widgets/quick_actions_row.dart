import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';

/// Minimalist horizontal quick-action pills matching the ShiftIQ branch palette.
class QuickActionsRow extends StatelessWidget {
  final VoidCallback? onNewOrder;
  final VoidCallback? onNewAppointment;
  final VoidCallback? onNewBatch;

  const QuickActionsRow({
    super.key,
    this.onNewOrder,
    this.onNewAppointment,
    this.onNewBatch,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _ActionPill(
            label: 'Nueva OT',
            icon: Icons.add_rounded,
            color: ShiftIQColors.primaryBlue,
            onTap: onNewOrder,
          ),
          const SizedBox(width: 10),
          _ActionPill(
            label: 'Agendar cita',
            icon: Icons.calendar_today_outlined,
            color: ShiftIQColors.secondaryTeal,
            onTap: onNewAppointment,
          ),
          const SizedBox(width: 10),
          _ActionPill(
            label: 'Ingreso lote',
            icon: Icons.inventory_2_outlined,
            color: ShiftIQColors.preventiveGreen,
            onTap: onNewBatch,
          ),
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionPill({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 15, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: ShiftIQColors.graphiteText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
