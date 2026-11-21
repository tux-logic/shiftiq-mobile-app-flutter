import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_constants.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_empty_state.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_page_header.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_primary_pill_button.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/widgets/shiftiq_liquid_button.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/model/aggregates/appointment.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/model/valueobjects/appointment_status.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/presentation/controllers/appointments_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/presentation/views/customer_directory_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/presentation/widgets/appointment_card.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/presentation/widgets/create_appointment_modal.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/presentation/widgets/date_strip_selector.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/create_work_order_page.dart';

class AppointmentsPage extends StatefulWidget {
  final String? branchId;
  final AppointmentsViewModel? viewModel;

  const AppointmentsPage({
    super.key,
    this.branchId,
    this.viewModel,
  });

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  late final AppointmentsViewModel _viewModel;
  late final String _effectiveBranchId;
  String _branchName = 'Sede Principal';

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? getIt<AppointmentsViewModel>();
    final session = getIt.isRegistered<SessionStorage>() ? getIt<SessionStorage>() : null;
    _effectiveBranchId = widget.branchId ?? session?.activeBranchId ?? ApiConstants.defaultBranchId;
    _branchName = session?.activeBranchName ?? ApiConstants.defaultBranchName;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadAppointments(_effectiveBranchId);
      _viewModel.loadCustomers(_effectiveBranchId);
    });
  }

  void _openCreateAppointment() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CreateAppointmentModal(
        branchId: _effectiveBranchId,
        viewModel: _viewModel,
      ),
    );
  }

  void _openDirectory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CustomerDirectoryPage(
          branchId: _effectiveBranchId,
          viewModel: _viewModel,
        ),
      ),
    );
  }

  void _openWorkOrderFromAppointment(Appointment appointment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateWorkOrderPage(
          branchId: _effectiveBranchId,
          initialPlate: appointment.vehiclePlate,
          initialCustomerName: appointment.customerName,
          initialPhone: appointment.customerPhone,
          initialModel: appointment.vehicleModel,
          initialDiagnostic:
              '${appointment.serviceType}${appointment.notes.isNotEmpty ? ' - ${appointment.notes}' : ''}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: ShiftIQColors.warmNeutral,
      body: Column(
        children: [
          ShiftIQPageHeader(
            title: loc.translate('appointments_title'),
            subtitle: 'Gestión de Bahías · $_branchName',
            actions: [
              ShiftIQLiquidIconButton(
                tooltip: loc.translate('tooltip_customer_directory'),
                icon: Icons.people_alt_outlined,
                onDarkBackground: true,
                onPressed: _openDirectory,
              ),
            ],
          ),
          Expanded(
            child: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final appointments = _viewModel.appointments;
          final isLoading = _viewModel.isLoading;
          final error = _viewModel.errorMessage;

          return Column(
            children: [
              // Horizontal calendar strip
              DateStripSelector(
                selectedDate: _viewModel.selectedDate,
                onDateSelected: (date) =>
                    _viewModel.selectDate(date, _effectiveBranchId),
              ),

              // Minimalist Filter Pills
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterPill(
                        loc.translate('all_appointments'),
                        null,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterPill(
                        loc.translate('pending_appointments'),
                        AppointmentStatus.pending,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterPill(
                        loc.translate('confirmed_appointments'),
                        AppointmentStatus.confirmed,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterPill(
                        loc.translate('completed_appointments'),
                        AppointmentStatus.completed,
                      ),
                    ],
                  ),
                ),
              ),

              if (error != null)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: ShiftIQColors.severityCrimson.withAlpha(18),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: ShiftIQColors.severityCrimson.withAlpha(50),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: ShiftIQColors.severityCrimson,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          error,
                          style: const TextStyle(
                            color: ShiftIQColors.severityCrimson,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Appointment List
              Expanded(
                child: RefreshIndicator(
                  color: ShiftIQColors.primaryBlue,
                  onRefresh: () => _viewModel.loadAppointments(_effectiveBranchId),
                  child: isLoading && appointments.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : appointments.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(32, 64, 32, 120),
                              children: [
                                const Center(
                                  child: ShiftIQEmptyStateIcon(),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No hay citas agendadas para esta fecha',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                    color: ShiftIQColors.graphiteText,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Selecciona otro día o agenda una nueva cita para comenzar',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Center(
                                  child: ShiftIQPrimaryPillButton(
                                    label: loc.translate(
                                      'schedule_appointment_bay',
                                    ),
                                    icon: Icons.add_rounded,
                                    onPressed: _openCreateAppointment,
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                              itemCount: appointments.length,
                              itemBuilder: (context, index) {
                                final appointment = appointments[index];
                                return AppointmentCard(
                                  appointment: appointment,
                                  onOpenWorkOrder: () =>
                                      _openWorkOrderFromAppointment(appointment),
                                  onConfirm: () => _viewModel.confirmAppointment(
                                    appointment.id,
                                    _effectiveBranchId,
                                  ),
                                  onCancel: () => _viewModel.cancelAppointment(
                                    appointment.id,
                                    _effectiveBranchId,
                                  ),
                                  onComplete: () =>
                                      _viewModel.completeAppointment(
                                    appointment.id,
                                    _effectiveBranchId,
                                  ),
                                );
                              },
                            ),
                ),
              ),
            ],
          );
        },
      ),
          ),
        ],
      ),
      floatingActionButton: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.appointments.isEmpty) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 84),
            child: ShiftIQPrimaryPillButton(
              label: loc.translate('new_appointment'),
              icon: Icons.add_rounded,
              onPressed: _openCreateAppointment,
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterPill(String label, AppointmentStatus? status) {
    final isSelected = _viewModel.selectedStatusFilter == status;

    return GestureDetector(
      onTap: () => _viewModel.filterByStatus(status, _effectiveBranchId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0F172A)
                : ShiftIQColors.borderSlate,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withAlpha(28),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}
