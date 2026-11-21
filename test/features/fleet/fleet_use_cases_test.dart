import 'package:flutter_test/flutter_test.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/application/usecases/cancel_appointment.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/application/usecases/create_appointment.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/application/usecases/get_appointments.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/application/usecases/get_customer_registrations.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/application/usecases/manage_employee_applications.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/application/usecases/onboard_employee.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/application/usecases/register_customer_to_branch.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/application/usecases/update_appointment.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/fleet_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/repositories/fleet_repository.dart';

class InMemoryFleetRepository implements FleetRepository {
  final List<Appointment> appointments = [];
  final List<CustomerRegistration> customerRegistrations = [];
  final List<EmployeeRegistration> employeeRegistrations = [];

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
    final appointment = Appointment(
      id: 'apt-${appointments.length + 1}',
      branchId: branchId,
      customerId: customerId,
      vehicleId: vehicleId,
      customerName: customerName,
      customerPhone: customerPhone,
      vehiclePlate: vehiclePlate,
      vehicleModel: vehicleModel,
      scheduledStart: scheduledStart,
      scheduledEnd: scheduledEnd ?? scheduledStart.add(const Duration(hours: 1)),
      serviceType: serviceType,
      notes: notes,
      status: AppointmentStatus.pending,
      bayNumber: bayNumber,
    );
    appointments.add(appointment);
    return appointment;
  }

  @override
  Future<List<Appointment>> getAppointments({
    String? branchId,
    AppointmentStatus? status,
    String? customerId,
    String? vehicleId,
    DateTime? date,
  }) async {
    return appointments.where((a) {
      if (branchId != null && a.branchId != branchId) return false;
      if (status != null && a.status != status) return false;
      if (customerId != null && a.customerId != customerId) return false;
      if (vehicleId != null && a.vehicleId != vehicleId) return false;
      if (date != null) {
        final sameDate = a.scheduledStart.year == date.year &&
            a.scheduledStart.month == date.month &&
            a.scheduledStart.day == date.day;
        if (!sameDate) return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<Appointment> getAppointmentById(String id) async {
    return appointments.firstWhere(
      (a) => a.id == id,
      orElse: () => throw StateError('Appointment not found'),
    );
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
    final index = appointments.indexWhere((a) => a.id == id);
    if (index == -1) throw StateError('Appointment not found');
    final current = appointments[index];
    final updated = current.copyWith(
      branchId: branchId,
      customerId: customerId,
      vehicleId: vehicleId,
      scheduledStart: scheduledStart,
      status: status,
      notes: notes ?? current.notes,
    );
    appointments[index] = updated;
    return updated;
  }

  @override
  Future<void> cancelAppointment(String id) async {
    final index = appointments.indexWhere((a) => a.id == id);
    if (index != -1) {
      appointments[index] = appointments[index].copyWith(
        status: AppointmentStatus.canceled,
      );
    }
  }

  @override
  Future<Appointment> updateAppointmentStatus({
    required String id,
    required AppointmentStatus status,
  }) async {
    final index = appointments.indexWhere((a) => a.id == id);
    if (index == -1) throw StateError('Appointment not found');
    final updated = appointments[index].copyWith(status: status);
    appointments[index] = updated;
    return updated;
  }

  @override
  Future<CustomerRegistration> registerCustomerToBranch({
    required String branchId,
    required String customerId,
  }) async {
    final reg = CustomerRegistration(
      id: 'reg-${customerRegistrations.length + 1}',
      branchId: branchId,
      customerId: customerId,
      customerName: 'Verified Customer',
      phone: '+51 987 654 321',
      vehiclePlate: 'XYZ-789',
      vehicleModel: 'Toyota Corolla 2022',
      status: 'ACTIVE',
      registeredAt: DateTime.now(),
    );
    customerRegistrations.add(reg);
    return reg;
  }

  @override
  Future<List<CustomerRegistration>> getCustomerRegistrations({
    String? branchId,
    String? status,
    String? customerId,
  }) async {
    return customerRegistrations.where((c) {
      if (branchId != null && c.branchId != branchId) return false;
      if (status != null && c.status.toUpperCase() != status.toUpperCase()) return false;
      if (customerId != null && c.customerId != customerId) return false;
      return true;
    }).toList();
  }

  @override
  Future<CustomerRegistration> getCustomerRegistrationById(String registrationId) async {
    return customerRegistrations.firstWhere(
      (c) => c.id == registrationId,
      orElse: () => throw StateError('Customer registration not found'),
    );
  }

  @override
  Future<List<CustomerRegistration>> getCustomerDirectory(String branchId) async {
    return customerRegistrations.where((c) => c.branchId == branchId).toList();
  }

  @override
  Future<EmployeeRegistration> onboardEmployee({
    required String employeeId,
    required String branchId,
    required String speciality,
    required String specialityName,
    required double salary,
    String role = 'ROLE_EMPLOYEE',
  }) async {
    final registration = EmployeeRegistration(
      id: 'emp-reg-${employeeRegistrations.length + 1}',
      employeeId: employeeId,
      branchId: branchId,
      speciality: speciality,
      specialityName: specialityName,
      salary: salary,
      role: role,
      status: 'ACTIVE',
      createdAt: DateTime.now(),
    );
    employeeRegistrations.add(registration);
    return registration;
  }

  @override
  Future<EmployeeRegistration> requestJoinBranch({
    required String employeeId,
    required String branchId,
    String? speciality,
    String? specialityName,
    double? salary,
  }) async {
    final registration = EmployeeRegistration(
      id: 'emp-reg-${employeeRegistrations.length + 1}',
      employeeId: employeeId,
      branchId: branchId,
      speciality: speciality ?? 'General',
      specialityName: specialityName ?? 'General Mechanic',
      salary: salary ?? 0.0,
      role: 'ROLE_EMPLOYEE',
      status: 'PENDING_APPROVAL',
      createdAt: DateTime.now(),
    );
    employeeRegistrations.add(registration);
    return registration;
  }

  @override
  Future<EmployeeRegistration> approveEmployeeRegistration(String registrationId) async {
    final index = employeeRegistrations.indexWhere((e) => e.id == registrationId);
    if (index == -1) throw StateError('Registration not found');
    final approved = employeeRegistrations[index].copyWith(
      status: 'ACTIVE',
      role: 'ROLE_EMPLOYEE',
    );
    employeeRegistrations[index] = approved;
    return approved;
  }

  @override
  Future<void> rejectEmployeeRegistration(String registrationId, [String? reason]) async {
    final index = employeeRegistrations.indexWhere((e) => e.id == registrationId);
    if (index != -1) {
      employeeRegistrations[index] = employeeRegistrations[index].copyWith(
        status: 'REJECTED',
      );
    }
  }

  @override
  Future<List<EmployeeRegistration>> getEmployeeRegistrations({
    String? branchId,
    String? status,
    String? employeeId,
  }) async {
    return employeeRegistrations.where((e) {
      if (branchId != null && e.branchId != branchId) return false;
      if (status != null && e.status.toUpperCase() != status.toUpperCase()) return false;
      if (employeeId != null && e.employeeId != employeeId) return false;
      return true;
    }).toList();
  }

  @override
  Future<CustomerRegistration> updateCustomerRegistrationStatus({
    required String registrationId,
    required String status,
    String? reason,
  }) async {
    final index = customerRegistrations.indexWhere((c) => c.id == registrationId);
    if (index == -1) throw StateError('Customer registration not found');
    final updated = customerRegistrations[index].copyWith(status: status);
    customerRegistrations[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteCustomerRegistration(String registrationId) async {
    customerRegistrations.removeWhere((c) => c.id == registrationId);
  }

  @override
  Future<EmployeeRegistration> getEmployeeRegistrationById(
    String registrationId,
  ) async {
    return employeeRegistrations.firstWhere(
      (e) => e.id == registrationId,
      orElse: () => throw StateError('Employee registration not found'),
    );
  }

  @override
  Future<EmployeeRegistration> updateEmployeeRegistration({
    required String registrationId,
    required String speciality,
    required String specialityName,
    required double salary,
  }) async {
    final index = employeeRegistrations.indexWhere((e) => e.id == registrationId);
    if (index == -1) throw StateError('Employee registration not found');
    final existing = employeeRegistrations[index];
    final updated = existing.copyWith(
      speciality: speciality,
      specialityName: specialityName,
      salary: salary,
    );
    employeeRegistrations[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteEmployeeRegistration(String registrationId) async {
    employeeRegistrations.removeWhere((e) => e.id == registrationId);
  }

  @override
  Future<List<Map<String, dynamic>>> getEmployeeCareerHistory({
    required String branchId,
    required String employeeId,
  }) async {
    return [
      {'branchId': branchId, 'employeeId': employeeId, 'role': 'ROLE_EMPLOYEE'},
    ];
  }
}

void main() {
  late InMemoryFleetRepository repository;
  late CreateAppointmentUseCase createAppointmentUseCase;
  late GetAppointmentsUseCase getAppointmentsUseCase;
  late UpdateAppointmentUseCase updateAppointmentUseCase;
  late CancelAppointmentUseCase cancelAppointmentUseCase;
  late RegisterCustomerToBranchUseCase registerCustomerUseCase;
  late GetCustomerRegistrationsUseCase getCustomerRegistrationsUseCase;
  late OnboardEmployeeUseCase onboardEmployeeUseCase;
  late ManageEmployeeApplicationsUseCase manageEmployeeApplicationsUseCase;

  setUp(() {
    repository = InMemoryFleetRepository();
    createAppointmentUseCase = CreateAppointmentUseCase(repository: repository);
    getAppointmentsUseCase = GetAppointmentsUseCase(repository: repository);
    updateAppointmentUseCase = UpdateAppointmentUseCase(repository: repository);
    cancelAppointmentUseCase = CancelAppointmentUseCase(repository: repository);
    registerCustomerUseCase = RegisterCustomerToBranchUseCase(repository: repository);
    getCustomerRegistrationsUseCase = GetCustomerRegistrationsUseCase(repository: repository);
    onboardEmployeeUseCase = OnboardEmployeeUseCase(repository: repository);
    manageEmployeeApplicationsUseCase = ManageEmployeeApplicationsUseCase(repository: repository);
  });

  group('Fleet Appointments Use Cases', () {
    test('CreateAppointmentUseCase schedules appointment with default scheduledEnd and pending status', () async {
      final start = DateTime(2026, 11, 10, 10, 0);
      final appointment = await createAppointmentUseCase.execute(
        branchId: 'branch-01',
        customerId: 'cust-10',
        vehicleId: 'veh-20',
        scheduledStart: start,
        notes: 'Oil change and brake inspection',
      );

      expect(appointment.id, equals('apt-1'));
      expect(appointment.branchId, equals('branch-01'));
      expect(appointment.customerId, equals('cust-10'));
      expect(appointment.vehicleId, equals('veh-20'));
      expect(appointment.scheduledStart, equals(start));
      expect(appointment.scheduledEnd, equals(start.add(const Duration(hours: 1))));
      expect(appointment.isPending, isTrue);
    });

    test('GetAppointmentsUseCase retrieves and filters appointments', () async {
      final now = DateTime(2026, 11, 10, 9, 0);
      await createAppointmentUseCase.execute(
        branchId: 'branch-01',
        customerId: 'c1',
        vehicleId: 'v1',
        scheduledStart: now,
      );
      await createAppointmentUseCase.execute(
        branchId: 'branch-02',
        customerId: 'c2',
        vehicleId: 'v2',
        scheduledStart: now,
      );

      final branch1Appointments = await getAppointmentsUseCase.execute(branchId: 'branch-01');
      expect(branch1Appointments.length, equals(1));
      expect(branch1Appointments.first.branchId, equals('branch-01'));

      final byId = await getAppointmentsUseCase.getById('apt-1');
      expect(byId.id, equals('apt-1'));
    });

    test('UpdateAppointmentUseCase updates details and status transition', () async {
      final start = DateTime(2026, 11, 10, 8, 30);
      final created = await createAppointmentUseCase.execute(
        branchId: 'b-1',
        customerId: 'c-1',
        vehicleId: 'v-1',
        scheduledStart: start,
      );

      final updated = await updateAppointmentUseCase.execute(
        id: created.id,
        branchId: 'b-1',
        customerId: 'c-1',
        vehicleId: 'v-1',
        scheduledStart: start.add(const Duration(hours: 2)),
        status: AppointmentStatus.confirmed,
        notes: 'Rescheduled upon customer request',
      );

      expect(updated.isConfirmed, isTrue);
      expect(updated.notes, equals('Rescheduled upon customer request'));
      expect(updated.scheduledStart, equals(start.add(const Duration(hours: 2))));
    });

    test('CancelAppointmentUseCase marks appointment as canceled', () async {
      final created = await createAppointmentUseCase.execute(
        branchId: 'b-1',
        customerId: 'c-1',
        vehicleId: 'v-1',
        scheduledStart: DateTime.now(),
      );

      await cancelAppointmentUseCase.execute(created.id);
      final canceled = await getAppointmentsUseCase.getById(created.id);
      expect(canceled.isCanceled, isTrue);
    });
  });

  group('Fleet Customer Registrations Use Cases', () {
    test('RegisterCustomerToBranchUseCase registers active affiliation', () async {
      final reg = await registerCustomerUseCase.execute(
        branchId: 'b-san-miguel',
        customerId: 'cust-55',
      );

      expect(reg.id, startsWith('reg-'));
      expect(reg.branchId, equals('b-san-miguel'));
      expect(reg.customerId, equals('cust-55'));
      expect(reg.isActive, isTrue);
    });

    test('GetCustomerRegistrationsUseCase filters by branch and search query', () async {
      await registerCustomerUseCase.execute(branchId: 'b-1', customerId: 'c-1');
      await registerCustomerUseCase.execute(branchId: 'b-2', customerId: 'c-2');

      final list = await getCustomerRegistrationsUseCase.execute(
        branchId: 'b-1',
        searchQuery: 'Verified',
      );
      expect(list.length, equals(1));
      expect(list.first.branchId, equals('b-1'));
    });
  });

  group('Fleet Employee Onboarding & Applications Use Cases', () {
    test('OnboardEmployeeUseCase directly provisions active staff with specified role', () async {
      final emp = await onboardEmployeeUseCase.execute(
        employeeId: 'emp-101',
        branchId: 'b-main',
        speciality: 'MEC_ELEC',
        specialityName: 'Mecánico Electricista Automotriz',
        salary: 2800.0,
        role: 'ROLE_EMPLOYEE',
      );

      expect(emp.id, startsWith('emp-reg-'));
      expect(emp.isActive, isTrue);
      expect(emp.role, equals('ROLE_EMPLOYEE'));
      expect(emp.speciality, equals('MEC_ELEC'));
      expect(emp.salary, equals(2800.0));
    });

    test('ManageEmployeeApplicationsUseCase handles request-join, approval, and rejection workflow', () async {
      // 1. Employee requests to join branch
      final application = await manageEmployeeApplicationsUseCase.requestJoin(
        employeeId: 'emp-202',
        branchId: 'b-sur',
        speciality: 'FRENOS',
        specialityName: 'Especialista en Frenos y Suspensión',
        salary: 2200.0,
      );

      expect(application.isPendingApproval, isTrue);
      expect(application.status, equals('PENDING_APPROVAL'));

      // 2. Query applications for branch
      final pendingList = await manageEmployeeApplicationsUseCase.getApplications(
        branchId: 'b-sur',
        status: 'PENDING_APPROVAL',
      );
      expect(pendingList.length, equals(1));
      expect(pendingList.first.id, equals(application.id));

      // 3. Workshop manager approves application
      final approved = await manageEmployeeApplicationsUseCase.approve(application.id);
      expect(approved.isActive, isTrue);
      expect(approved.status, equals('ACTIVE'));

      // 4. Test rejection flow for a second applicant
      final secondApp = await manageEmployeeApplicationsUseCase.requestJoin(
        employeeId: 'emp-303',
        branchId: 'b-sur',
      );
      await manageEmployeeApplicationsUseCase.reject(secondApp.id);
      final apps = await manageEmployeeApplicationsUseCase.getApplications(
        branchId: 'b-sur',
        status: 'REJECTED',
      );
      expect(apps.length, equals(1));
      expect(apps.first.isRejected, isTrue);
    });
  });
}
