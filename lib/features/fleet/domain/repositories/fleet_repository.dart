import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/fleet_domain.dart';

/// Comprehensive contract interface for the Fleet Bounded Context:
/// Appointments, Customer Registrations, and Employee Registrations.
abstract class FleetRepository {
  // --- Appointments ---
  Future<Appointment> createAppointment({
    required String branchId,
    required String customerId,
    required String vehicleId,
    required DateTime scheduledStart,
    DateTime? scheduledEnd,
    String notes = '',
    String serviceType = 'Mantenimiento General',
    String customerName = 'Cliente del Taller',
    String customerPhone = '',
    String vehiclePlate = 'S/P',
    String vehicleModel = 'Vehículo General',
    int bayNumber = 1,
  });

  Future<List<Appointment>> getAppointments({
    String? branchId,
    AppointmentStatus? status,
    String? customerId,
    String? vehicleId,
    DateTime? date,
  });

  Future<Appointment> getAppointmentById(String id);

  Future<Appointment> updateAppointment({
    required String id,
    required String branchId,
    required String customerId,
    required String vehicleId,
    required DateTime scheduledStart,
    required AppointmentStatus status,
    String? notes,
  });

  Future<void> cancelAppointment(String id);

  Future<Appointment> updateAppointmentStatus({
    required String id,
    required AppointmentStatus status,
  });

  // --- Customer Registrations ---
  Future<CustomerRegistration> registerCustomerToBranch({
    required String branchId,
    required String customerId,
  });

  Future<List<CustomerRegistration>> getCustomerRegistrations({
    String? branchId,
    String? status,
    String? customerId,
  });

  Future<CustomerRegistration> getCustomerRegistrationById(String registrationId);

  Future<List<CustomerRegistration>> getCustomerDirectory(String branchId);

  // --- Employee Registrations (Hierarchical Onboarding) ---
  Future<EmployeeRegistration> onboardEmployee({
    required String employeeId,
    required String branchId,
    required String speciality,
    required String specialityName,
    required double salary,
    String role = 'ROLE_EMPLOYEE',
  });

  Future<EmployeeRegistration> requestJoinBranch({
    required String employeeId,
    required String branchId,
    String? speciality,
    String? specialityName,
    double? salary,
  });

  Future<EmployeeRegistration> approveEmployeeRegistration(String registrationId);

  Future<void> rejectEmployeeRegistration(String registrationId);

  Future<List<EmployeeRegistration>> getEmployeeRegistrations({
    String? branchId,
    String? status,
    String? employeeId,
  });
}

/// Backward compatibility alias.
typedef AppointmentRepository = FleetRepository;
