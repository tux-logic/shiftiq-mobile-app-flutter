import 'package:flutter/foundation.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/application/usecases/create_appointment.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/application/usecases/get_appointments.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/application/usecases/get_customer_registrations.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/application/usecases/update_appointment.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/fleet_domain.dart';

class AppointmentsViewModel extends ChangeNotifier {
  final GetAppointmentsByBranchQueryService getAppointmentsQuery;
  final GetCustomerDirectoryQueryService getCustomerDirectoryQuery;
  final CreateAppointmentCommandService createAppointmentCommand;
  final UpdateAppointmentStatusCommandService updateStatusCommand;

  AppointmentsViewModel({
    required this.getAppointmentsQuery,
    required this.getCustomerDirectoryQuery,
    required this.createAppointmentCommand,
    required this.updateStatusCommand,
  }) {
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  bool _isLoading = false;
  String? _errorMessage;
  late DateTime _selectedDate;
  AppointmentStatus? _selectedStatusFilter;
  List<Appointment> _appointments = [];
  List<CustomerRegistration> _customers = [];
  String _customerSearchQuery = '';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime get selectedDate => _selectedDate;
  AppointmentStatus? get selectedStatusFilter => _selectedStatusFilter;
  List<Appointment> get appointments => _appointments;
  List<CustomerRegistration> get customers => _customers;
  String get customerSearchQuery => _customerSearchQuery;

  int get pendingCount => _appointments.where((a) => a.isPending).length;
  int get confirmedCount => _appointments.where((a) => a.isConfirmed).length;
  int get completedCount => _appointments.where((a) => a.isCompleted).length;

  Future<void> loadAppointments(String branchId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _appointments = await getAppointmentsQuery.execute(
        branchId: branchId,
        date: _selectedDate,
        status: _selectedStatusFilter,
      );
    } catch (e) {
      _errorMessage = 'Error al cargar citas de la sede: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectDate(DateTime date, String branchId) async {
    _selectedDate = DateTime(date.year, date.month, date.day);
    await loadAppointments(branchId);
  }

  Future<void> filterByStatus(AppointmentStatus? status, String branchId) async {
    _selectedStatusFilter = status;
    await loadAppointments(branchId);
  }

  Future<void> confirmAppointment(String appointmentId, String branchId) async {
    try {
      await updateStatusCommand.execute(
        appointmentId: appointmentId,
        newStatus: AppointmentStatus.confirmed,
      );
      await loadAppointments(branchId);
    } catch (e) {
      _errorMessage = 'Error al confirmar cita: $e';
      notifyListeners();
    }
  }

  Future<void> cancelAppointment(String appointmentId, String branchId) async {
    try {
      await updateStatusCommand.execute(
        appointmentId: appointmentId,
        newStatus: AppointmentStatus.canceled,
      );
      await loadAppointments(branchId);
    } catch (e) {
      _errorMessage = 'Error al cancelar cita: $e';
      notifyListeners();
    }
  }

  Future<void> completeAppointment(String appointmentId, String branchId) async {
    try {
      await updateStatusCommand.execute(
        appointmentId: appointmentId,
        newStatus: AppointmentStatus.completed,
      );
      await loadAppointments(branchId);
    } catch (e) {
      _errorMessage = 'Error al completar cita: $e';
      notifyListeners();
    }
  }

  Future<bool> createAppointment(
    CreateAppointmentCommand command,
    String branchId,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await createAppointmentCommand.execute(command);
      await loadAppointments(branchId);
      return true;
    } catch (e) {
      _errorMessage = 'Error al crear la cita: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadCustomers(String branchId, {String? query}) async {
    _customerSearchQuery = query ?? '';
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _customers = await getCustomerDirectoryQuery.execute(
        branchId: branchId,
        searchQuery: _customerSearchQuery,
      );
    } catch (e) {
      _errorMessage = 'Error al cargar directorio de clientes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

