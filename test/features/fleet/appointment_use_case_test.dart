import 'package:flutter_test/flutter_test.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/application/usecases/create_appointment.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/application/usecases/get_appointments.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/application/usecases/get_customer_registrations.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/application/usecases/update_appointment.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/fleet_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/repositories/fleet_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/presentation/controllers/appointments_view_model.dart';

class MockAppointmentRepository implements AppointmentRepository {
  final List<Appointment> _appointments = [
    Appointment(
      id: 'apt-01',
      branchId: 'b-01-smp',
      customerId: 'cust-01',
      customerName: 'Martín Vizcarra',
      customerPhone: '+51 999 111 222',
      vehicleId: 'veh-01',
      vehiclePlate: 'B8C-456',
      vehicleModel: 'Nissan Sentra 2020',
      scheduledStart: DateTime(2026, 11, 8, 9, 0),
      serviceType: 'Mantenimiento Preventivo 30,000 km',
      status: AppointmentStatus.confirmed,
      bayNumber: 1,
    ),
    Appointment(
      id: 'apt-02',
      branchId: 'b-01-smp',
      customerId: 'cust-02',
      customerName: 'Andrea Benavente',
      customerPhone: '+51 988 333 444',
      vehicleId: 'veh-02',
      vehiclePlate: 'F1G-789',
      vehicleModel: 'Kia Sportage 2022',
      scheduledStart: DateTime(2026, 11, 8, 11, 30),
      serviceType: 'Diagnóstico OBD-II',
      status: AppointmentStatus.pending,
      bayNumber: 3,
    ),
    Appointment(
      id: 'apt-03',
      branchId: 'b-02-surco',
      customerId: 'cust-03',
      customerName: 'Roberto Gómez',
      customerPhone: '+51 977 555 666',
      vehicleId: 'veh-03',
      vehiclePlate: 'C4D-123',
      vehicleModel: 'Toyota Yaris 2018',
      scheduledStart: DateTime(2026, 11, 9, 15, 0),
      serviceType: 'Cambio de Pastillas de Freno',
      status: AppointmentStatus.confirmed,
      bayNumber: 2,
    ),
  ];

  final List<CustomerRegistration> _customers = [
    const CustomerRegistration(
      id: 'reg-01',
      branchId: 'b-01-smp',
      customerId: 'cust-01',
      customerName: 'Martín Vizcarra',
      phone: '+51 999 111 222',
      email: 'martin@gmail.com',
      vehiclePlate: 'B8C-456',
      vehicleModel: 'Nissan Sentra 2020',
    ),
    const CustomerRegistration(
      id: 'reg-02',
      branchId: 'b-01-smp',
      customerId: 'cust-02',
      customerName: 'Andrea Benavente',
      phone: '+51 988 333 444',
      email: 'andrea@gmail.com',
      vehiclePlate: 'F1G-789',
      vehicleModel: 'Kia Sportage 2022',
    ),
  ];

  @override
  Future<List<Appointment>> getAppointments({
    String? branchId,
    AppointmentStatus? status,
    String? customerId,
    String? vehicleId,
    DateTime? date,
  }) async {
    return _appointments.where((a) {
      if (branchId != null && a.branchId != branchId) return false;
      if (customerId != null && a.customerId != customerId) return false;
      if (vehicleId != null && a.vehicleId != vehicleId) return false;
      if (date != null) {
        final sameDay = a.scheduledStart.year == date.year &&
            a.scheduledStart.month == date.month &&
            a.scheduledStart.day == date.day;
        if (!sameDay) return false;
      }
      if (status != null && a.status != status) return false;
      return true;
    }).toList();
  }

  @override
  Future<Appointment> getAppointmentById(String id) async {
    return _appointments.firstWhere(
      (a) => a.id == id,
      orElse: () => throw Exception('Appointment not found'),
    );
  }

  @override
  Future<Appointment> createAppointment({
    required String branchId,
    required String customerId,
    required String vehicleId,
    required DateTime scheduledStart,
    DateTime? scheduledEnd,
    String serviceType = 'Mantenimiento General',
    String notes = '',
    String customerName = 'Cliente del Taller',
    String customerPhone = '',
    String vehiclePlate = 'S/P',
    String vehicleModel = 'Vehículo General',
    int bayNumber = 1,
  }) async {
    final appointment = Appointment(
      id: 'apt-${_appointments.length + 1}',
      branchId: branchId,
      customerId: customerId,
      vehicleId: vehicleId,
      customerName: customerName,
      customerPhone: customerPhone,
      vehiclePlate: vehiclePlate,
      vehicleModel: vehicleModel,
      scheduledStart: scheduledStart,
      scheduledEnd: scheduledEnd,
      serviceType: serviceType,
      notes: notes,
      status: AppointmentStatus.confirmed,
      bayNumber: bayNumber,
    );
    _appointments.add(appointment);
    return appointment;
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
    final index = _appointments.indexWhere((a) => a.id == id);
    if (index == -1) throw Exception('Appointment not found');
    final updated = _appointments[index].copyWith(
      branchId: branchId,
      customerId: customerId,
      vehicleId: vehicleId,
      scheduledStart: scheduledStart,
      status: status,
      notes: notes ?? _appointments[index].notes,
    );
    _appointments[index] = updated;
    return updated;
  }

  @override
  Future<void> cancelAppointment(String id) async {
    final index = _appointments.indexWhere((a) => a.id == id);
    if (index != -1) {
      _appointments[index] = _appointments[index].copyWith(status: AppointmentStatus.canceled);
    }
  }

  @override
  Future<Appointment> updateAppointmentStatus({
    required String id,
    required AppointmentStatus status,
  }) async {
    final index = _appointments.indexWhere((a) => a.id == id);
    if (index == -1) throw Exception('Appointment not found');
    final updated = _appointments[index].copyWith(status: status);
    _appointments[index] = updated;
    return updated;
  }

  @override
  Future<List<CustomerRegistration>> getCustomerDirectory(String branchId) async {
    return _customers.where((c) => c.branchId == branchId).toList();
  }

  @override
  Future<CustomerRegistration> registerCustomerToBranch({
    required String branchId,
    required String customerId,
  }) async {
    final reg = CustomerRegistration(
      id: 'reg-${_customers.length + 1}',
      branchId: branchId,
      customerId: customerId,
      customerName: 'Nuevo Cliente',
      phone: '+51 900 000 000',
      vehiclePlate: 'ABC-123',
      vehicleModel: 'Toyota Corolla',
    );
    _customers.add(reg);
    return reg;
  }

  @override
  Future<List<CustomerRegistration>> getCustomerRegistrations({
    String? branchId,
    String? status,
    String? customerId,
  }) async {
    return _customers.where((c) {
      if (branchId != null && c.branchId != branchId) return false;
      if (customerId != null && c.customerId != customerId) return false;
      return true;
    }).toList();
  }

  @override
  Future<CustomerRegistration> getCustomerRegistrationById(String registrationId) async {
    return _customers.firstWhere((c) => c.id == registrationId);
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
    return EmployeeRegistration(
      id: 'emp-reg-1',
      employeeId: employeeId,
      branchId: branchId,
      speciality: speciality,
      specialityName: specialityName,
      salary: salary,
      role: role,
      status: 'ACTIVE',
    );
  }

  @override
  Future<EmployeeRegistration> requestJoinBranch({
    required String employeeId,
    required String branchId,
    String? speciality,
    String? specialityName,
    double? salary,
  }) async {
    return EmployeeRegistration(
      id: 'emp-reg-2',
      employeeId: employeeId,
      branchId: branchId,
      speciality: speciality ?? 'General',
      specialityName: specialityName ?? 'General Mechanic',
      salary: salary ?? 0.0,
      role: 'ROLE_EMPLOYEE',
      status: 'PENDING_APPROVAL',
    );
  }

  @override
  Future<EmployeeRegistration> approveEmployeeRegistration(String registrationId) async {
    return EmployeeRegistration(
      id: registrationId,
      employeeId: 'emp-1',
      branchId: 'b-01',
      speciality: 'General',
      specialityName: 'General Mechanic',
      salary: 1000.0,
      role: 'ROLE_EMPLOYEE',
      status: 'ACTIVE',
    );
  }

  @override
  Future<void> rejectEmployeeRegistration(String registrationId, [String? reason]) async {}

  @override
  Future<List<EmployeeRegistration>> getEmployeeRegistrations({
    String? branchId,
    String? status,
    String? employeeId,
  }) async {
    return [];
  }

  @override
  Future<CustomerRegistration> updateCustomerRegistrationStatus({
    required String registrationId,
    required String status,
    String? reason,
  }) async {
    final index = _customers.indexWhere((c) => c.id == registrationId);
    if (index == -1) throw Exception('Customer registration not found');
    final updated = _customers[index].copyWith(status: status);
    _customers[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteCustomerRegistration(String registrationId) async {
    _customers.removeWhere((c) => c.id == registrationId);
  }

  @override
  Future<EmployeeRegistration> getEmployeeRegistrationById(
    String registrationId,
  ) async {
    return EmployeeRegistration(
      id: registrationId,
      employeeId: 'emp-1',
      branchId: 'b-01',
      speciality: 'General',
      specialityName: 'General Mechanic',
      salary: 1000.0,
      role: 'ROLE_EMPLOYEE',
      status: 'ACTIVE',
    );
  }

  @override
  Future<EmployeeRegistration> updateEmployeeRegistration({
    required String registrationId,
    required String speciality,
    required String specialityName,
    required double salary,
  }) async {
    return EmployeeRegistration(
      id: registrationId,
      employeeId: 'emp-1',
      branchId: 'b-01',
      speciality: speciality,
      specialityName: specialityName,
      salary: salary,
      role: 'ROLE_EMPLOYEE',
      status: 'ACTIVE',
    );
  }

  @override
  Future<void> deleteEmployeeRegistration(String registrationId) async {}

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
  late MockAppointmentRepository repository;
  late GetAppointmentsByBranchQueryService getAppointmentsQuery;
  late GetCustomerDirectoryQueryService getCustomerDirectoryQuery;
  late CreateAppointmentCommandService createAppointmentCommand;
  late UpdateAppointmentStatusCommandService updateStatusCommand;

  setUp(() {
    repository = MockAppointmentRepository();
    getAppointmentsQuery = GetAppointmentsByBranchQueryService(appointmentRepository: repository);
    getCustomerDirectoryQuery = GetCustomerDirectoryQueryService(appointmentRepository: repository);
    createAppointmentCommand = CreateAppointmentCommandService(appointmentRepository: repository);
    updateStatusCommand = UpdateAppointmentStatusCommandService(appointmentRepository: repository);
  });

  group('Hito 4: Fleet & CRM B2B - Appointments & Customer Directory', () {
    test('1. GetAppointmentsByBranchQueryService returns appointments for target branch', () async {
      final results = await getAppointmentsQuery.execute(branchId: 'b-01-smp');
      expect(results.length, equals(2));
      expect(results.every((a) => a.branchId == 'b-01-smp'), isTrue);
    });

    test('2. Query filters appointments by specific date and status', () async {
      final results = await getAppointmentsQuery.execute(
        branchId: 'b-01-smp',
        date: DateTime(2026, 11, 8),
        status: AppointmentStatus.pending,
      );

      expect(results.length, equals(1));
      expect(results.first.customerName, equals('Andrea Benavente'));
      expect(results.first.status, equals(AppointmentStatus.pending));
    });

    test('3. CreateAppointmentCommandService creates appointment with formatted plate', () async {
      final command = CreateAppointmentCommand(
        branchId: 'b-01-smp',
        customerId: 'cust-99',
        customerName: 'Renzo Costa',
        customerPhone: '+51 911 222 333',
        vehicleId: 'veh-99',
        vehiclePlate: 'abc-456',
        vehicleModel: 'Honda Civic 2021',
        scheduledStart: DateTime(2026, 11, 8, 14, 0),
        serviceType: 'Cambio de Pastillas de Freno',
        bayNumber: 2,
      );

      final created = await createAppointmentCommand.execute(command);
      expect(created.id, startsWith('apt-'));
      expect(created.vehiclePlate, equals('ABC-456'));
      expect(created.status, equals(AppointmentStatus.confirmed));

      final all = await getAppointmentsQuery.execute(branchId: 'b-01-smp');
      expect(all.length, equals(3));
    });

    test('4. CreateAppointmentCommandService throws ArgumentError on missing fields', () async {
      expect(
        () => createAppointmentCommand.execute(
          CreateAppointmentCommand(
            branchId: '',
            customerId: 'c1',
            customerName: 'Test',
            customerPhone: '123',
            vehicleId: 'v1',
            vehiclePlate: 'ABC-123',
            vehicleModel: 'Car',
            scheduledStart: DateTime.now(),
            serviceType: 'Oil change',
          ),
        ),
        throwsArgumentError,
      );
    });

    test('5. UpdateAppointmentStatusCommandService updates status of aggregate', () async {
      final updated = await updateStatusCommand.execute(
        appointmentId: 'apt-02',
        newStatus: AppointmentStatus.confirmed,
      );

      expect(updated.status, equals(AppointmentStatus.confirmed));
      expect(updated.isConfirmed, isTrue);
    });

    test('6. GetCustomerDirectoryQueryService filters customers by query', () async {
      final results = await getCustomerDirectoryQuery.execute(
        branchId: 'b-01-smp',
        searchQuery: 'vizcarra',
      );

      expect(results.length, equals(1));
      expect(results.first.customerName, equals('Martín Vizcarra'));
      expect(results.first.vehiclePlate, equals('B8C-456'));
    });

    test('7. AppointmentsViewModel correctly loads and handles state transitions', () async {
      final viewModel = AppointmentsViewModel(
        getAppointmentsQuery: getAppointmentsQuery,
        getCustomerDirectoryQuery: getCustomerDirectoryQuery,
        createAppointmentCommand: createAppointmentCommand,
        updateStatusCommand: updateStatusCommand,
      );

      await viewModel.selectDate(DateTime(2026, 11, 8), 'b-01-smp');
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);

      // Confirm appointment apt-02
      await viewModel.confirmAppointment('apt-02', 'b-01-smp');
      final target = viewModel.appointments.firstWhere((a) => a.id == 'apt-02');
      expect(target.status, equals(AppointmentStatus.confirmed));

      // Cancel appointment apt-01
      await viewModel.cancelAppointment('apt-01', 'b-01-smp');
      final canceled = viewModel.appointments.firstWhere((a) => a.id == 'apt-01');
      expect(canceled.status, equals(AppointmentStatus.canceled));
    });
  });
}
