import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/model/aggregates/appointment.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/model/valueobjects/appointment_status.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onOpenWorkOrder;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final VoidCallback? onComplete;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onOpenWorkOrder,
    this.onConfirm,
    this.onCancel,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final statusColor = _getStatusColor(appointment.status);
    final statusBg = _getStatusBg(appointment.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ShiftIQColors.borderSlate),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withAlpha(9),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Bay badge, Time, and Status Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: ShiftIQColors.primaryBlue.withAlpha(18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: ShiftIQColors.primaryBlue.withAlpha(55),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.garage_outlined,
                        size: 13.5,
                        color: ShiftIQColors.primaryBlue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Bahía ${appointment.bayNumber}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: ShiftIQColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTime(appointment.scheduledStart),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ShiftIQColors.graphiteText,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    appointment.status.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: ShiftIQColors.borderSlate),
            ),

            // Customer and Vehicle Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: ShiftIQColors.primaryBlue.withAlpha(20),
                  child: Text(
                    _getInitials(appointment.customerName),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: ShiftIQColors.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.customerName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: ShiftIQColors.graphiteText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            size: 13,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            appointment.customerPhone,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    appointment.vehiclePlate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Vehicle Model and Service info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ShiftIQColors.warmNeutral,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: ShiftIQColors.borderSlate.withAlpha(140),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.directions_car_outlined,
                        size: 14,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          appointment.vehicleModel,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: ShiftIQColors.graphiteText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.build_outlined,
                        size: 14,
                        color: ShiftIQColors.primaryBlue,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          appointment.serviceType,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: ShiftIQColors.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (appointment.notes.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      appointment.notes,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Actions row
            Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                if (appointment.isPending) ...[
                  OutlinedButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.close_rounded, size: 14),
                    label: Text(loc.translate('cancel')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ShiftIQColors.severityCrimson,
                      side: const BorderSide(color: ShiftIQColors.severityCrimson),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: onConfirm,
                    icon: const Icon(Icons.check_rounded, size: 14),
                    label: Text(loc.translate('confirm')),
                    style: FilledButton.styleFrom(
                      backgroundColor: ShiftIQColors.preventiveGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                if (appointment.isConfirmed) ...[
                  OutlinedButton.icon(
                    onPressed: onComplete,
                    icon: const Icon(Icons.done_all_rounded, size: 14),
                    label: Text(loc.translate('complete')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ShiftIQColors.primaryBlue,
                      side: const BorderSide(color: ShiftIQColors.primaryBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                FilledButton.icon(
                  onPressed: onOpenWorkOrder,
                  icon: const Icon(Icons.post_add_rounded, size: 15),
                  label: Text(loc.translate('open_ot')),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return ShiftIQColors.severityOrange;
      case AppointmentStatus.confirmed:
        return ShiftIQColors.preventiveGreen;
      case AppointmentStatus.completed:
        return ShiftIQColors.primaryBlue;
      case AppointmentStatus.canceled:
        return ShiftIQColors.severityCrimson;
    }
  }

  Color _getStatusBg(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return ShiftIQColors.severityOrange.withAlpha(26);
      case AppointmentStatus.confirmed:
        return ShiftIQColors.preventiveGreen.withAlpha(26);
      case AppointmentStatus.completed:
        return ShiftIQColors.primaryBlue.withAlpha(26);
      case AppointmentStatus.canceled:
        return ShiftIQColors.severityCrimson.withAlpha(26);
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final standardHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$standardHour:$minute $period';
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty && parts[0].isNotEmpty
        ? parts[0][0].toUpperCase()
        : 'C';
  }
}
