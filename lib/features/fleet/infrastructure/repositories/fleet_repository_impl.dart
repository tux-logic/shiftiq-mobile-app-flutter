import 'package:shiftiq_mobile_app_flutter/features/core/infrastructure/remote/profile_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/fleet_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/repositories/fleet_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/infrastructure/remote/appointment_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/infrastructure/remote/customer_registration_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/infrastructure/remote/dtos/fleet_dto.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/infrastructure/remote/employee_registration_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/infrastructure/remote/work_order_api.dart';

/// Repository coordinating remote Fleet APIs and domain mappings.
class FleetRepositoryImpl implements FleetRepository {
  final AppointmentApi appointmentApi;
  final CustomerRegistrationApi customerRegistrationApi;
  final EmployeeRegistrationApi employeeRegistrationApi;
  final ProfileApi? profileApi;
  final WorkOrderApi? workOrderApi;

  FleetRepositoryImpl({
    required this.appointmentApi,
    required this.customerRegistrationApi,
    required this.employeeRegistrationApi,
    this.profileApi,
    this.workOrderApi,
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
    final registrations = list
        .map((json) => CustomerRegistrationDto.fromJson(json).toDomain())
        .toList();

    if (registrations.isEmpty) {
      return registrations;
    }

    return _enrichCustomerRegistrations(registrations, branchId: branchId);
  }

  /// Enriches branch customer registrations with Core profile details and
  /// vehicle metadata from branch work orders, degrading gracefully on errors.
  Future<List<CustomerRegistration>> _enrichCustomerRegistrations(
    List<CustomerRegistration> registrations, {
    String? branchId,
  }) async {
    final uniqueCustomerIds = registrations
        .map((r) => r.customerId)
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    final profileFuture = profileApi == null
        ? Future.value(<String, Map<String, dynamic>>{})
        : Future.wait(
            uniqueCustomerIds.map((id) async {
              try {
                final data = await profileApi!.getCustomerById(id);
                return MapEntry(id, data);
              } catch (_) {
                return null;
              }
            }),
          ).then(
            (entries) => Map<String, Map<String, dynamic>>.fromEntries(
              entries.whereType<MapEntry<String, Map<String, dynamic>>>(),
            ),
          );

    final workOrdersFuture = (workOrderApi == null ||
            branchId == null ||
            branchId.trim().isEmpty)
        ? Future.value(const <dynamic>[])
        : workOrderApi!
            .getWorkOrders(branchId: branchId)
            .catchError((_) => const <dynamic>[]);

    final results = await Future.wait([profileFuture, workOrdersFuture]);
    final profilesById = results[0] as Map<String, Map<String, dynamic>>;
    final rawWorkOrders = results[1] as List<dynamic>;

    final vehicleByCustomerId = <String, ({String plate, String model, String? name})>{};
    for (final raw in rawWorkOrders) {
      if (raw is! Map<String, dynamic>) continue;
      final cid = raw['customerId']?.toString() ?? '';
      if (cid.isEmpty) continue;
      final plate = raw['vehiclePlateNumber']?.toString().trim() ?? '';
      final brand = raw['vehicleBrand']?.toString().trim() ?? '';
      final model = raw['vehicleModel']?.toString().trim() ?? '';
      final year = raw['vehicleYear']?.toString().trim() ?? '';
      final fullModel = [
        if (brand.isNotEmpty) brand,
        if (model.isNotEmpty) model,
        if (year.isNotEmpty) '($year)',
      ].join(' ');
      final woCustomerName = raw['customerName']?.toString().trim();

      if (plate.isNotEmpty || fullModel.isNotEmpty) {
        vehicleByCustomerId[cid] = (
          plate: plate,
          model: fullModel,
          name: (woCustomerName != null && woCustomerName.isNotEmpty)
              ? woCustomerName
              : null,
        );
      }
    }

    return registrations.map((reg) {
      final profile = profilesById[reg.customerId];
      final vehicle = vehicleByCustomerId[reg.customerId];

      var resolvedName = reg.customerName;
      var resolvedPhone = reg.phone;

      if (profile != null) {
        final businessName = profile['businessName']?.toString().trim() ?? '';
        final firstName = profile['firstName']?.toString().trim() ?? '';
        final lastName = profile['lastName']?.toString().trim() ?? '';
        final fullName = '$firstName $lastName'.trim();
        if (businessName.isNotEmpty) {
          resolvedName = businessName;
        } else if (fullName.isNotEmpty) {
          resolvedName = fullName;
        }
        final phone = profile['phone']?.toString().trim() ?? '';
        if (phone.isNotEmpty) {
          resolvedPhone = phone;
        }
      } else if (vehicle?.name != null) {
        resolvedName = vehicle!.name!;
      }

      final resolvedPlate =
          (vehicle != null && vehicle.plate.isNotEmpty)
              ? vehicle.plate
              : reg.vehiclePlate;
      final resolvedModel =
          (vehicle != null && vehicle.model.isNotEmpty)
              ? vehicle.model
              : reg.vehicleModel;

      return reg.copyWith(
        customerName: resolvedName,
        phone: resolvedPhone,
        vehiclePlate: resolvedPlate,
        vehicleModel: resolvedModel,
      );
    }).toList();
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
