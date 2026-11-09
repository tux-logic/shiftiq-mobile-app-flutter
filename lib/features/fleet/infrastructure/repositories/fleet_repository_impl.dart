import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/fleet_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/repositories/fleet_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/infrastructure/remote/appointment_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/infrastructure/remote/customer_registration_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/infrastructure/remote/dtos/fleet_dto.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/infrastructure/remote/employee_registration_api.dart';

/// Repository coordinating remote Fleet APIs and domain mappings.
class FleetRepositoryImpl implements FleetRepository {
  final AppointmentApi appointmentApi;
  final CustomerRegistrationApi customerRegistrationApi;
  final EmployeeRegistrationApi employeeRegistrationApi;

  FleetRepositoryImpl({
    required this.appointmentApi,
    required this.customerRegistrationApi,
    required this.employeeRegistrationApi,
  });

  // --- Appointments ---

  @override
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
  }) async {
    final json = await appointmentApi.createAppointment(
      branchId: branchId,
      customerId: customerId,
      vehicleId: vehicleId,
      scheduledStart: scheduledStart,
      scheduledEnd: scheduledEnd,
      notes: notes,
    );
    return AppointmentDto.fromJson(json).toDomain();
  }

  @override
  Future<List<Appointment>> getAppointments({
    String? branchId,
    AppointmentStatus? status,
    String? customerId,
    String? vehicleId,
    DateTime? date,
  }) async {
    final list = await appointmentApi.getAppointments(
      branchId: branchId,
      status: status?.value,
      customerId: customerId,
      vehicleId: vehicleId,
    );

    final appointments =
        list.map((json) => AppointmentDto.fromJson(json).toDomain()).toList();

    if (date != null) {
      return appointments.where((apt) {
        return apt.scheduledStart.year == date.year &&
            apt.scheduledStart.month == date.month &&
            apt.scheduledStart.day == date.day;
      }).toList();
    }

    return appointments;
  }

  @override
  Future<Appointment> getAppointmentById(String id) async {
    final json = await appointmentApi.getAppointmentById(id);
    return AppointmentDto.fromJson(json).toDomain();
  }

  @override
  Future<Appointment> updateAppointment({
    required String id,
    required String branchId,
    required String customerId,
    required String vehicleId,
    required DateTime scheduledStart,
    required AppointmentStatus status,
    String? notes,
  }) async {
    final json = await appointmentApi.updateAppointment(
      id: id,
      branchId: branchId,
      customerId: customerId,
      vehicleId: vehicleId,
      scheduledStart: scheduledStart,
      status: status.value,
      notes: notes,
    );
    return AppointmentDto.fromJson(json).toDomain();
  }

  @override
  Future<void> cancelAppointment(String id) async {
    await appointmentApi.cancelAppointment(id);
  }

  @override
  Future<Appointment> updateAppointmentStatus({
    required String id,
    required AppointmentStatus status,
  }) async {
    final json = await appointmentApi.updateAppointmentStatus(
      id: id,
      status: status.value,
    );
    return AppointmentDto.fromJson(json).toDomain();
  }

  // --- Customer Registrations ---

  @override
  Future<CustomerRegistration> registerCustomerToBranch({
    required String branchId,
    required String customerId,
  }) async {
    final json = await customerRegistrationApi.registerCustomerToBranch(
      branchId: branchId,
      customerId: customerId,
    );
    return CustomerRegistrationDto.fromJson(json).toDomain();
  }

  @override
  Future<List<CustomerRegistration>> getCustomerRegistrations({
    String? branchId,
    String? status,
    String? customerId,
  }) async {
    final list = await customerRegistrationApi.getCustomerRegistrations(
      branchId: branchId,
      status: status,
      customerId: customerId,
    );
    return list
        .map((json) => CustomerRegistrationDto.fromJson(json).toDomain())
        .toList();
  }

  @override
  Future<CustomerRegistration> getCustomerRegistrationById(
    String registrationId,
  ) async {
    final json = await customerRegistrationApi.getCustomerRegistrationById(
      registrationId,
    );
    return CustomerRegistrationDto.fromJson(json).toDomain();
  }

  @override
  Future<CustomerRegistration> updateCustomerRegistrationStatus({
    required String registrationId,
    required String status,
    String? reason,
  }) async {
    final json = await customerRegistrationApi.updateCustomerRegistrationStatus(
      id: registrationId,
      status: status,
    );
    return CustomerRegistrationDto.fromJson(json).toDomain();
  }

  @override
  Future<void> deleteCustomerRegistration(String registrationId) async {
    await customerRegistrationApi.deleteCustomerRegistration(registrationId);
  }

  @override
  Future<List<CustomerRegistration>> getCustomerDirectory(
    String branchId,
  ) async {
    return getCustomerRegistrations(branchId: branchId);
  }

  // --- Employee Registrations (Hierarchical Onboarding) ---

  @override
  Future<EmployeeRegistration> onboardEmployee({
    required String employeeId,
    required String branchId,
    required String speciality,
    required String specialityName,
    required double salary,
    String role = 'ROLE_EMPLOYEE',
  }) async {
    final json = await employeeRegistrationApi.onboardEmployee(
      employeeId: employeeId,
      branchId: branchId,
      speciality: speciality,
      specialityName: specialityName,
      salary: salary,
      role: role,
    );
    return EmployeeRegistrationDto.fromJson(json).toDomain();
  }

  @override
  Future<EmployeeRegistration> requestJoinBranch({
    required String employeeId,
    required String branchId,
    String? speciality,
    String? specialityName,
    double? salary,
  }) async {
    final json = await employeeRegistrationApi.requestJoinBranch(
      employeeId: employeeId,
      branchId: branchId,
      speciality: speciality,
      specialityName: specialityName,
      salary: salary,
    );
    return EmployeeRegistrationDto.fromJson(json).toDomain();
  }

  @override
  Future<EmployeeRegistration> approveEmployeeRegistration(
    String registrationId,
  ) async {
    final json = await employeeRegistrationApi.approveRegistration(
      registrationId,
    );
    return EmployeeRegistrationDto.fromJson(json).toDomain();
  }

  @override
  Future<void> rejectEmployeeRegistration(
    String registrationId, [
    String? reason,
  ]) async {
    await employeeRegistrationApi.rejectRegistration(
      registrationId,
      reason: reason,
    );
  }

  @override
  Future<List<EmployeeRegistration>> getEmployeeRegistrations({
    String? branchId,
    String? status,
    String? employeeId,
  }) async {
    final list = await employeeRegistrationApi.getEmployeeRegistrations(
      branchId: branchId,
      status: status,
      employeeId: employeeId,
    );
    return list
        .map((json) => EmployeeRegistrationDto.fromJson(json).toDomain())
        .toList();
  }

  @override
  Future<EmployeeRegistration> getEmployeeRegistrationById(
    String registrationId,
  ) async {
    final json = await employeeRegistrationApi.getEmployeeRegistrationById(
      registrationId,
    );
    return EmployeeRegistrationDto.fromJson(json).toDomain();
  }

  @override
  Future<EmployeeRegistration> updateEmployeeRegistration({
    required String registrationId,
    required String speciality,
    required String specialityName,
    required double salary,
  }) async {
    final json = await employeeRegistrationApi.updateEmployeeRegistration(
      id: registrationId,
      speciality: speciality,
      specialityName: specialityName,
      salary: salary,
    );
    return EmployeeRegistrationDto.fromJson(json).toDomain();
  }

  @override
  Future<void> deleteEmployeeRegistration(String registrationId) async {
    await employeeRegistrationApi.deleteEmployeeRegistration(registrationId);
  }

  @override
  Future<List<Map<String, dynamic>>> getEmployeeCareerHistory({
    required String branchId,
    required String employeeId,
  }) {
    return employeeRegistrationApi.getEmployeeCareerHistory(
      branchId: branchId,
      employeeId: employeeId,
    );
  }
}

/// Backward compatibility alias.
typedef AppointmentRepositoryImpl = FleetRepositoryImpl;
