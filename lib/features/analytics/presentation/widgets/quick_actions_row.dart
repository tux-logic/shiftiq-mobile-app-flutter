import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ACCIONES RÁPIDAS DEL TALLER',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildActionButton(
                label: 'Nueva OT',
                icon: Icons.add_circle_outline,
                color: ShiftIQColors.primaryBlue,
                onTap: onNewOrder,
              ),
              const SizedBox(width: 10),
              _buildActionButton(
                label: 'Agendar Cita',
                icon: Icons.calendar_today_outlined,
                color: ShiftIQColors.secondaryTeal,
                onTap: onNewAppointment,
              ),
              const SizedBox(width: 10),
              _buildActionButton(
                label: 'Ingreso Lote',
                icon: Icons.inventory_2_outlined,
                color: ShiftIQColors.severityAmber,
                onTap: onNewBatch,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ShiftIQColors.borderSlate),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ShiftIQColors.graphiteText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
