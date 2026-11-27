import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_navy_banner_fallback.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_tactile_card.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_time_picker_sheet.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_toast.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/analytics_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/core_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/customer/presentation/customer_home_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/iot_domain.dart';

/// Displays an associated workshop branch from `GET /api/v1/branches/catalog`
/// with branding, rating, free bay availability, and a quick booking CTA.
class CustomerWorkshopCard extends StatelessWidget {
  final CustomerBranchCatalogItem branch;
  final BranchOperatingSchedule? schedule;
  final VoidCallback? onScheduleTap;

  const CustomerWorkshopCard({
    super.key,
    required this.branch,
    this.schedule,
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
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(17)),
            child: SizedBox(
              height: 112,
              width: double.infinity,
              child: hasCover
                  ? Image.network(
                      branch.coverImageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const ShiftIQNavyBannerFallback();
                      },
                      errorBuilder: (_, _, _) =>
                          const ShiftIQNavyBannerFallback(),
                    )
                  : const ShiftIQNavyBannerFallback(),
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
                if (schedule != null) ...[
                  const SizedBox(height: 6),
                  Builder(
                    builder: (context) {
                      final today = schedule!.resolveForDate(DateTime.now());
                      return _InfoRow(
                        icon: Icons.schedule_outlined,
                        text: today.open
                            ? 'Hoy: ${today.formattedRange}'
                            : 'Hoy: Cerrado${today.reason != null ? ' (${today.reason})' : ''}',
                      );
                    },
                  ),
                ],
                if (branch.activeBaysCount > 0 || onScheduleTap != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (branch.activeBaysCount > 0)
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
                        )
                      else
                        const SizedBox.shrink(),
                      if (branch.activeBaysCount > 0 && onScheduleTap != null)
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
    _syncScheduleForBranch(_selectedBranchId);
  }

  Future<void> _syncScheduleForBranch(String branchId) async {
    final schedule = await widget.vm.loadBranchSchedule(branchId);
    if (!mounted) return;
    final effective = schedule.resolveForDate(_selectedDateTime);
    setState(() {
      _selectedDateTime = effective.clampDateTime(_selectedDateTime);
    });
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
              _SheetSectionLabel(text: loc.translate('customer_select_branch')),
              const SizedBox(height: 8),
              if (vm.branches.length == 1)
                _SelectableBranchTile(
                  branch: vm.branches.first,
                  selected: true,
                  onTap: () {},
                )
              else
                SizedBox(
                  height: 88,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: vm.branches.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final branch = vm.branches[index];
                      return SizedBox(
                        width: 248,
                        child: _SelectableBranchTile(
                          branch: branch,
                          selected: branch.branchId == _selectedBranchId,
                          onTap: () {
                            setState(() => _selectedBranchId = branch.branchId);
                            _syncScheduleForBranch(branch.branchId);
                          },
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              _SheetSectionLabel(text: loc.translate('customer_select_vehicle')),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: vm.vehicles.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final vehicle = vm.vehicles[index];
                    return SizedBox(
                      width: vm.vehicles.length == 1 ? 290 : 228,
                      child: _SelectableVehicleTile(
                        vehicle: vehicle,
                        selected: vehicle.id == _selectedVehicleId,
                        onTap: () =>
                            setState(() => _selectedVehicleId = vehicle.id),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              _SheetSectionLabel(
                text: loc.translate('customer_appointment_date_time'),
              ),
              const SizedBox(height: 8),
              Builder(
                builder: (context) {
                  final effective = vm
                      .scheduleForBranch(_selectedBranchId)
                      .resolveForDate(_selectedDateTime);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _DateTimeSelectorTile(
                              key: const Key('btn_pick_appointment_datetime'),
                              icon: Icons.calendar_today_rounded,
                              label: 'Fecha',
                              value:
                                  '${_selectedDateTime.day.toString().padLeft(2, '0')}/${_selectedDateTime.month.toString().padLeft(2, '0')}/${_selectedDateTime.year}',
                              onTap: () async {
                                final pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDateTime,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 90)),
                                );
                                if (pickedDate == null || !context.mounted) {
                                  return;
                                }
                                final nextDt = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  _selectedDateTime.hour,
                                  _selectedDateTime.minute,
                                );
                                final dayHours = vm
                                    .scheduleForBranch(_selectedBranchId)
                                    .resolveForDate(nextDt);
                                setState(() {
                                  _selectedDateTime =
                                      dayHours.clampDateTime(nextDt);
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _DateTimeSelectorTile(
                              key: const Key('btn_pick_appointment_time'),
                              icon: Icons.schedule_rounded,
                              label: 'Hora',
                              value:
                                  '${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                              onTap: () async {
                                if (!effective.open) {
                                  ShiftIQToast.show(
                                    context,
                                    message:
                                        'La sede está cerrada en la fecha elegida.',
                                    type: ShiftIQToastType.info,
                                  );
                                  return;
                                }
                                final pickedTime =
                                    await showShiftIQTimePickerSheet(
                                  context,
                                  initialTime:
                                      TimeOfDay.fromDateTime(_selectedDateTime),
                                  minimumTime: effective.openTime,
                                  maximumTime: effective.latestStartTime,
                                );
                                if (pickedTime == null || !context.mounted) {
                                  return;
                                }
                                final nextDt = DateTime(
                                  _selectedDateTime.year,
                                  _selectedDateTime.month,
                                  _selectedDateTime.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                                setState(() {
                                  _selectedDateTime =
                                      effective.clampDateTime(nextDt);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: (effective.open
                                  ? ShiftIQColors.primaryBlue
                                  : ShiftIQColors.severityCrimson)
                              .withAlpha(16),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              effective.open
                                  ? Icons.access_time_rounded
                                  : Icons.event_busy_rounded,
                              size: 15,
                              color: effective.open
                                  ? ShiftIQColors.primaryBlue
                                  : ShiftIQColors.severityCrimson,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                effective.open
                                    ? 'Horario de atención: ${effective.formattedRange}${effective.reason != null ? ' (${effective.reason})' : ''}'
                                    : 'Cerrado este día${effective.reason != null ? ' · ${effective.reason}' : ''}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: effective.open
                                      ? ShiftIQColors.primaryBlue
                                      : ShiftIQColors.severityCrimson,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 14),
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
                          final effective = vm
                              .scheduleForBranch(_selectedBranchId)
                              .resolveForDate(_selectedDateTime);
                          if (!effective.open) {
                            ShiftIQToast.show(
                              context,
                              message:
                                  'La sede no atiende en la fecha seleccionada.',
                              type: ShiftIQToastType.error,
                            );
                            return;
                          }
                          if (!effective.isWithinHours(_selectedDateTime)) {
                            ShiftIQToast.show(
                              context,
                              message:
                                  'Elige una hora dentro del horario (${effective.formattedRange}).',
                              type: ShiftIQToastType.error,
                            );
                            return;
                          }
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


class _SheetSectionLabel extends StatelessWidget {
  final String text;

  const _SheetSectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w800,
        color: Color(0xFF475569),
      ),
    );
  }
}

class _SelectableBranchTile extends StatelessWidget {
  final CustomerBranchCatalogItem branch;
  final bool selected;
  final VoidCallback onTap;

  const _SelectableBranchTile({
    required this.branch,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: Key('branch_option_${branch.branchId}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? ShiftIQColors.primaryBlue.withAlpha(14)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? ShiftIQColors.primaryBlue
                : ShiftIQColors.borderSlate,
            width: selected ? 1.6 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: selected
                    ? ShiftIQColors.primaryBlue.withAlpha(24)
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.store_mall_directory_rounded,
                size: 20,
                color: selected
                    ? ShiftIQColors.primaryBlue
                    : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    branch.displayTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: ShiftIQColors.graphiteText,
                    ),
                  ),
                  Text(
                    branch.branchName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF475569),
                    ),
                  ),
                  if (branch.address.isNotEmpty)
                    Text(
                      branch.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                size: 20,
                color: ShiftIQColors.primaryBlue,
              ),
          ],
        ),
      ),
    );
  }
}

class _SelectableVehicleTile extends StatelessWidget {
  final Vehicle vehicle;
  final bool selected;
  final VoidCallback onTap;

  const _SelectableVehicleTile({
    required this.vehicle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto =
        vehicle.photoUrl != null && vehicle.photoUrl!.isNotEmpty;

    return InkWell(
      key: Key('vehicle_option_${vehicle.id}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected
              ? ShiftIQColors.primaryBlue.withAlpha(14)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? ShiftIQColors.primaryBlue
                : ShiftIQColors.borderSlate,
            width: selected ? 1.6 : 1.0,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 48,
                height: 48,
                child: hasPhoto
                    ? Image.network(
                        vehicle.photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const ShiftIQNavyBannerFallback(
                          watermarkIcon: Icons.directions_car_filled_rounded,
                        ),
                      )
                    : const ShiftIQNavyBannerFallback(
                        watermarkIcon: Icons.directions_car_filled_rounded,
                      ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: ShiftIQColors.graphiteText,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withAlpha(16),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      vehicle.plateNumber,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: ShiftIQColors.graphiteText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: ShiftIQColors.primaryBlue,
              ),
          ],
        ),
      ),
    );
  }
}

class _DateTimeSelectorTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateTimeSelectorTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ShiftIQColors.borderSlate),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: ShiftIQColors.primaryBlue.withAlpha(18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 17, color: ShiftIQColors.primaryBlue),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: ShiftIQColors.graphiteText,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }
}
