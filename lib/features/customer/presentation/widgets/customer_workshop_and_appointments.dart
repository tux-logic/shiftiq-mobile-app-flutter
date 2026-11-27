import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_tactile_card.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_toast.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/analytics_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/core_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/customer/presentation/customer_home_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/iot_domain.dart';

/// Displays an associated workshop branch from `GET /api/v1/branches/catalog`
/// with branding, rating, free bay availability, and a quick booking CTA.
class CustomerWorkshopCard extends StatelessWidget {
  final CustomerBranchCatalogItem branch;
  final VoidCallback? onScheduleTap;

  const CustomerWorkshopCard({
    super.key,
    required this.branch,
    this.onScheduleTap,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final hasCover =
        branch.coverImageUrl != null && branch.coverImageUrl!.isNotEmpty;

    return ShiftIQTactileCard(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ShiftIQColors.borderSlate),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasCover)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: Image.network(
                branch.coverImageUrl!,
                height: 112,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: ShiftIQColors.primaryBlue.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.store_mall_directory_rounded,
                        color: ShiftIQColors.primaryBlue,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            branch.displayTitle,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: ShiftIQColors.graphiteText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            branch.branchCode.isNotEmpty
                                ? '${branch.branchName} · ${branch.branchCode}'
                                : branch.branchName,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (branch.averageRating > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Color(0xFFD97706),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              branch.averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (branch.address.isNotEmpty)
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    text: branch.address,
                  ),
                if (branch.phone.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    text: branch.phone,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: (branch.freeBaysToday > 0
                                  ? ShiftIQColors.preventiveGreen
                                  : const Color(0xFF64748B))
                              .withAlpha(22),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${branch.freeBaysToday}/${branch.activeBaysCount} ${loc.translate('customer_free_bays_today')}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: branch.freeBaysToday > 0
                                ? ShiftIQColors.preventiveGreen
                                : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (onScheduleTap != null)
                      FilledButton.icon(
                        key: Key('btn_schedule_branch_${branch.branchId}'),
                        onPressed: onScheduleTap,
                        icon: const Icon(Icons.calendar_today_rounded, size: 14),
                        label: Text(loc.translate('customer_schedule_appointment')),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
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
        ],
      ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: const Color(0xFF64748B)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF475569),
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

/// Displays an upcoming appointment summary item enriched with branch and vehicle labels.
class CustomerUpcomingAppointmentCard extends StatelessWidget {
  final CustomerUpcomingAppointment appointment;
  final CustomerBranchCatalogItem? branch;
  final Vehicle? vehicle;

  const CustomerUpcomingAppointmentCard({
    super.key,
    required this.appointment,
    this.branch,
    this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    final start = appointment.scheduledStart?.toLocal();
    final formattedDate = start != null
        ? '${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}/${start.year} · ${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}'
        : '-';
    final branchLabel = branch != null
        ? '${branch!.displayTitle} · ${branch!.branchName}'
        : 'Sede asignada';
    final vehicleLabel = vehicle != null
        ? '${vehicle!.displayName} (${vehicle!.plateNumber})'
        : 'Vehículo registrado';

    return ShiftIQTactileCard(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ShiftIQColors.borderSlate),
        ),
        child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: ShiftIQColors.primaryBlue.withAlpha(18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: ShiftIQColors.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: ShiftIQColors.graphiteText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  branchLabel,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  vehicleLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              appointment.status,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: ShiftIQColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

/// Opens a modal bottom sheet allowing the customer to book an appointment
/// via `POST /api/v1/appointments`.
Future<void> showCustomerScheduleAppointmentSheet(
  BuildContext context,
  CustomerHomeViewModel vm, {
  String? initialBranchId,
}) async {
  final loc = AppLocalizations.of(context);
  if (vm.branches.isEmpty) {
    ShiftIQToast.show(
      context,
      message: loc.translate('customer_no_workshop_subtitle'),
      type: ShiftIQToastType.info,
    );
    return;
  }
  if (vm.vehicles.isEmpty) {
    ShiftIQToast.show(
      context,
      message: loc.translate('customer_add_vehicle_first'),
      type: ShiftIQToastType.info,
    );
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _ScheduleAppointmentSheetContent(
      vm: vm,
      parentContext: context,
      initialBranchId: initialBranchId ?? vm.branches.first.branchId,
    ),
  );
}

class _ScheduleAppointmentSheetContent extends StatefulWidget {
  final CustomerHomeViewModel vm;
  final BuildContext parentContext;
  final String initialBranchId;

  const _ScheduleAppointmentSheetContent({
    required this.vm,
    required this.parentContext,
    required this.initialBranchId,
  });

  @override
  State<_ScheduleAppointmentSheetContent> createState() =>
      _ScheduleAppointmentSheetContentState();
}

class _ScheduleAppointmentSheetContentState
    extends State<_ScheduleAppointmentSheetContent> {
  late String _selectedBranchId;
  late String _selectedVehicleId;
  late DateTime _selectedDateTime;
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedBranchId = widget.initialBranchId;
    _selectedVehicleId = widget.vm.vehicles.first.id;
    final now = DateTime.now();
    _selectedDateTime = DateTime(now.year, now.month, now.day + 1, 9, 0);
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final vm = widget.vm;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final dateLabel =
        '${_selectedDateTime.day.toString().padLeft(2, '0')}/${_selectedDateTime.month.toString().padLeft(2, '0')}/${_selectedDateTime.year} · ${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 24 + bottomInset),
      child: SingleChildScrollView(
        child: ListenableBuilder(
          listenable: vm,
          builder: (context, _) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: ShiftIQColors.borderSlate,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                loc.translate('customer_schedule_appointment'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: ShiftIQColors.graphiteText,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                key: const Key('dropdown_appointment_branch'),
                initialValue: _selectedBranchId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: loc.translate('customer_select_branch'),
                  prefixIcon: const Icon(Icons.storefront_outlined),
                ),
                items: vm.branches
                    .map(
                      (b) => DropdownMenuItem<String>(
                        value: b.branchId,
                        child: Text(
                          '${b.displayTitle} · ${b.branchName}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedBranchId = val);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: const Key('dropdown_appointment_vehicle'),
                initialValue: _selectedVehicleId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: loc.translate('customer_select_vehicle'),
                  prefixIcon: const Icon(Icons.directions_car_outlined),
                ),
                items: vm.vehicles
                    .map(
                      (v) => DropdownMenuItem<String>(
                        value: v.id,
                        child: Text(
                          '${v.displayName} (${v.plateNumber})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedVehicleId = val);
                  }
                },
              ),
              const SizedBox(height: 12),
              InkWell(
                key: const Key('btn_pick_appointment_datetime'),
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDateTime,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (pickedDate == null || !context.mounted) return;
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
                  );
                  if (pickedTime == null || !context.mounted) return;
                  setState(() {
                    _selectedDateTime = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                  });
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: loc.translate('customer_appointment_date_time'),
                    prefixIcon: const Icon(Icons.schedule_rounded),
                  ),
                  child: Text(
                    dateLabel,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: ShiftIQColors.graphiteText,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('field_appointment_notes'),
                controller: _notesCtrl,
                maxLength: 500,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: loc.translate('customer_appointment_notes_hint'),
                  prefixIcon: const Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('btn_submit_customer_appointment'),
                  onPressed: vm.isSchedulingAppointment
                      ? null
                      : () async {
                          if (!_selectedDateTime.isAfter(DateTime.now())) {
                            ShiftIQToast.show(
                              context,
                              message: loc.translate(
                                'customer_appointment_future_required',
                              ),
                              type: ShiftIQToastType.error,
                            );
                            return;
                          }
                          final created = await vm.scheduleAppointment(
                            branchId: _selectedBranchId,
                            vehicleId: _selectedVehicleId,
                            scheduledStart: _selectedDateTime,
                            notes: _notesCtrl.text,
                          );
                          if (!context.mounted) return;
                          if (created != null) {
                            Navigator.of(context).pop();
                            if (widget.parentContext.mounted) {
                              ShiftIQToast.show(
                                widget.parentContext,
                                message: loc.translate(
                                  'customer_appointment_created_success',
                                ),
                                type: ShiftIQToastType.success,
                              );
                            }
                          } else if (vm.error != null) {
                            ShiftIQToast.show(
                              context,
                              message: vm.error!,
                              type: ShiftIQToastType.error,
                            );
                          }
                        },
                  icon: vm.isSchedulingAppointment
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    loc.translate('customer_schedule_appointment'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: ShiftIQColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
