import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme/app_colors.dart';
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
    _effectiveBranchId = widget.branchId ?? session?.activeBranchId ?? 'b-01-smp';
    _branchName = session?.activeBranchName ?? 'Sede San Martín de Porres';

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
    return Scaffold(
      backgroundColor: AppColors.neutralBg,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Agenda de Citas B2B',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Gestión de Bahías · $_branchName',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Directorio de Clientes',
            icon: const Icon(Icons.people_alt_outlined),
            onPressed: _openDirectory,
          ),
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: () => _viewModel.loadAppointments(_effectiveBranchId),
          ),
        ],
      ),
      body: ListenableBuilder(
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

              // Filter Chips
              Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: Text('Todas (${appointments.length})'),
                        selected: _viewModel.selectedStatusFilter == null,
                        selectedColor: AppColors.primary.withAlpha(30),
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: _viewModel.selectedStatusFilter == null
                              ? AppColors.primary
                              : AppColors.neutralDark,
                          fontWeight: _viewModel.selectedStatusFilter == null
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 12,
                        ),
                        onSelected: (_) =>
                            _viewModel.filterByStatus(null, _effectiveBranchId),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: Text('Pendientes (${_viewModel.pendingCount})'),
                        selected: _viewModel.selectedStatusFilter ==
                            AppointmentStatus.pending,
                        selectedColor: AppColors.stateWarning.withAlpha(40),
                        checkmarkColor: AppColors.stateWarning,
                        labelStyle: TextStyle(
                          color: _viewModel.selectedStatusFilter ==
                                  AppointmentStatus.pending
                              ? AppColors.stateWarning
                              : AppColors.neutralDark,
                          fontWeight: _viewModel.selectedStatusFilter ==
                                  AppointmentStatus.pending
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 12,
                        ),
                        onSelected: (_) => _viewModel.filterByStatus(
                          AppointmentStatus.pending,
                          _effectiveBranchId,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: Text('Confirmadas (${_viewModel.confirmedCount})'),
                        selected: _viewModel.selectedStatusFilter ==
                            AppointmentStatus.confirmed,
                        selectedColor: AppColors.stateSuccess.withAlpha(40),
                        checkmarkColor: AppColors.stateSuccess,
                        labelStyle: TextStyle(
                          color: _viewModel.selectedStatusFilter ==
                                  AppointmentStatus.confirmed
                              ? AppColors.stateSuccess
                              : AppColors.neutralDark,
                          fontWeight: _viewModel.selectedStatusFilter ==
                                  AppointmentStatus.confirmed
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 12,
                        ),
                        onSelected: (_) => _viewModel.filterByStatus(
                          AppointmentStatus.confirmed,
                          _effectiveBranchId,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: Text('Completadas (${_viewModel.completedCount})'),
                        selected: _viewModel.selectedStatusFilter ==
                            AppointmentStatus.completed,
                        selectedColor: AppColors.stateInfo.withAlpha(40),
                        checkmarkColor: AppColors.stateInfo,
                        labelStyle: TextStyle(
                          color: _viewModel.selectedStatusFilter ==
                                  AppointmentStatus.completed
                              ? AppColors.stateInfo
                              : AppColors.neutralDark,
                          fontSize: 12,
                        ),
                        onSelected: (_) => _viewModel.filterByStatus(
                          AppointmentStatus.completed,
                          _effectiveBranchId,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (error != null)
                Container(
                  color: AppColors.stateError.withAlpha(20),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.stateError, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          error,
                          style: const TextStyle(
                              color: AppColors.stateError, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

              // Appointment List
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : appointments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.event_busy_outlined,
                                  size: 48,
                                  color: AppColors.neutralLight,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No hay citas agendadas para esta fecha',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.neutralDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Selecciona otro día o pulsa el botón para agendar una cita',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.neutralLight,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                FilledButton.icon(
                                  onPressed: _openCreateAppointment,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Agendar Cita en Bahía'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
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
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateAppointment,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Cita'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
