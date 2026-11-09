import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/app_exception.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/application/usecases/manage_customer_registration_status.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/application/usecases/manage_staff_affiliations.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/infrastructure/remote/appointment_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/infrastructure/remote/customer_registration_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/infrastructure/remote/employee_registration_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/infrastructure/repositories/fleet_repository_impl.dart';

void main() {
  late SessionStorage sessionStorage;
  late FleetRepositoryImpl repository;
  late ManageCustomerRegistrationStatus customerStatusUseCase;
  late ManageStaffAffiliations staffAffiliationsUseCase;

  setUp(() {
    sessionStorage = SessionStorage();
  });

  void setUpWithMockClient(Future<http.Response> Function(http.Request request) handler) {
    final mockClient = MockClient(handler);
    final apiClient = ApiClient(client: mockClient, sessionStorage: sessionStorage);
    repository = FleetRepositoryImpl(
      appointmentApi: AppointmentApi(apiClient: apiClient),
      customerRegistrationApi: CustomerRegistrationApi(apiClient: apiClient),
      employeeRegistrationApi: EmployeeRegistrationApi(apiClient: apiClient),
    );
    customerStatusUseCase = ManageCustomerRegistrationStatus(repository: repository);
    staffAffiliationsUseCase = ManageStaffAffiliations(repository: repository);
  }

  group('ManageCustomerRegistrationStatus - Lifecycle Operations', () {
    test('updateStatus updates customer status to ACTIVE', () async {
      setUpWithMockClient((request) async {
        if (request.method == 'PUT' &&
            request.url.path == '/api/v1/customer-registrations/reg-001') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['status'], 'ACTIVE');
          return http.Response(
            jsonEncode({
              'id': 'reg-001',
              'branchId': 'b-smp-01',
              'customerId': 'cust-101',
              'customerName': 'Juan Pérez',
              'phone': '+51 987654321',
              'vehiclePlate': 'ABC-123',
              'vehicleModel': 'Toyota Hilux 2021',
              'status': 'ACTIVE',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final result = await customerStatusUseCase.updateStatus(
        registrationId: 'reg-001',
        status: 'ACTIVE',
      );

      expect(result.id, 'reg-001');
      expect(result.status, 'ACTIVE');
      expect(result.isActive, isTrue);
    });

    test('blacklistCustomer sends INACTIVE status to remote endpoint', () async {
      setUpWithMockClient((request) async {
        if (request.method == 'PUT' &&
            request.url.path == '/api/v1/customer-registrations/reg-001') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['status'], 'INACTIVE');
          return http.Response(
            jsonEncode({
              'id': 'reg-001',
              'branchId': 'b-smp-01',
              'customerId': 'cust-101',
              'customerName': 'Juan Pérez',
              'phone': '+51 987654321',
              'vehiclePlate': 'ABC-123',
              'vehicleModel': 'Toyota Hilux 2021',
              'status': 'INACTIVE',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final result = await customerStatusUseCase.blacklistCustomer(
        registrationId: 'reg-001',
        reason: 'Frequent payment delays and no-shows',
      );

      expect(result.status, 'INACTIVE');
      expect(result.isActive, isFalse);
    });

    test('activateCustomer convenience method sets ACTIVE status', () async {
      setUpWithMockClient((request) async {
        if (request.method == 'PUT' &&
            request.url.path == '/api/v1/customer-registrations/reg-001') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['status'], 'ACTIVE');
          return http.Response(
            jsonEncode({
              'id': 'reg-001',
              'branchId': 'b-smp-01',
              'customerId': 'cust-101',
              'customerName': 'Juan Pérez',
              'phone': '+51 987654321',
              'vehiclePlate': 'ABC-123',
              'vehicleModel': 'Toyota Hilux 2021',
              'status': 'ACTIVE',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final result = await customerStatusUseCase.activateCustomer('reg-001');

      expect(result.status, 'ACTIVE');
    });

    test('deactivateRegistration sends DELETE request', () async {
      var deleted = false;
      setUpWithMockClient((request) async {
        if (request.method == 'DELETE' &&
            request.url.path == '/api/v1/customer-registrations/reg-001') {
          deleted = true;
          return http.Response('', 204);
        }
        return http.Response('Not Found', 404);
      });

      await customerStatusUseCase.deactivateRegistration('reg-001');
      expect(deleted, isTrue);
    });

    test('validates registrationId, valid status values, and blacklisted reason', () async {
      setUpWithMockClient((request) async => http.Response('OK', 200));

      expect(
        () => customerStatusUseCase.updateStatus(
          registrationId: '',
          status: 'ACTIVE',
        ),
        throwsA(isA<ValidationException>()),
      );

      expect(
        () => customerStatusUseCase.updateStatus(
          registrationId: 'reg-001',
          status: 'INVALID_STATUS',
        ),
        throwsA(isA<ValidationException>()),
      );

      expect(
        () => customerStatusUseCase.updateStatus(
          registrationId: 'reg-001',
          status: 'BLACKLISTED',
          reason: '  ',
        ),
        throwsA(isA<ValidationException>()),
      );

      expect(
        () => customerStatusUseCase.deactivateRegistration('  '),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('ManageStaffAffiliations - Lifecycle Operations', () {
    test('getRegistrationById fetches employee registration details', () async {
      setUpWithMockClient((request) async {
        if (request.method == 'GET' &&
            request.url.path == '/api/v1/employee-registrations/emp-reg-10') {
          return http.Response(
            jsonEncode({
              'id': 'emp-reg-10',
              'employeeId': 'emp-50',
              'branchId': 'b-smp-01',
              'speciality': 'BRAKES_SPECIALIST',
              'specialityName': 'Especialista en Frenos y Suspensión',
              'salary': 2500.0,
              'role': 'ROLE_MECHANIC',
              'status': 'ACTIVE',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final result = await staffAffiliationsUseCase.getRegistrationById('emp-reg-10');

      expect(result.id, 'emp-reg-10');
      expect(result.employeeId, 'emp-50');
      expect(result.speciality, 'BRAKES_SPECIALIST');
      expect(result.salary, 2500.0);
      expect(result.role, 'ROLE_MECHANIC');
    });

    test('updateContractTerms sends PUT with updated specialty and salary', () async {
      setUpWithMockClient((request) async {
        if (request.method == 'PUT' &&
            request.url.path == '/api/v1/employee-registrations/emp-reg-10') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['speciality'], 'SENIOR_ENGINE_DIAGNOSTICS');
          expect(body['salary'], 3200.0);
          return http.Response(
            jsonEncode({
              'id': 'emp-reg-10',
              'employeeId': 'emp-50',
              'branchId': 'b-smp-01',
              'speciality': 'SENIOR_ENGINE_DIAGNOSTICS',
              'specialityName': 'Diagnóstico Avanzado de Motores',
              'salary': 3200.0,
              'role': 'ROLE_MECHANIC',
              'status': 'ACTIVE',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final result = await staffAffiliationsUseCase.updateContractTerms(
        registrationId: 'emp-reg-10',
        speciality: 'SENIOR_ENGINE_DIAGNOSTICS',
        specialityName: 'Diagnóstico Avanzado de Motores',
        salary: 3200.0,
      );

      expect(result.speciality, 'SENIOR_ENGINE_DIAGNOSTICS');
      expect(result.salary, 3200.0);
    });

    test('dismissStaffMember sends DELETE request to employee registration', () async {
      var deleted = false;
      setUpWithMockClient((request) async {
        if (request.method == 'DELETE' &&
            request.url.path == '/api/v1/employee-registrations/emp-reg-10') {
          deleted = true;
          return http.Response('', 204);
        }
        return http.Response('Not Found', 404);
      });

      await staffAffiliationsUseCase.dismissStaffMember('emp-reg-10');
      expect(deleted, isTrue);
    });

    test('getCareerHistory returns chronological career timeline events', () async {
      setUpWithMockClient((request) async {
        if (request.method == 'GET' &&
            request.url.path == '/api/v1/branches/b-smp-01/employees/emp-50/history') {
          return http.Response(
            jsonEncode([
              {
                'id': 'evt-1',
                'branchId': 'b-smp-01',
                'employeeId': 'emp-50',
                'eventType': 'HIRED',
                'description': 'Contratado como Mecánico Junior',
                'timestamp': '2024-01-15T08:00:00Z',
              },
              {
                'id': 'evt-2',
                'branchId': 'b-smp-01',
                'employeeId': 'emp-50',
                'eventType': 'PROMOTION',
                'description': 'Ascendido a Especialista Senior',
                'timestamp': '2025-06-01T08:00:00Z',
              },
            ]),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final history = await staffAffiliationsUseCase.getCareerHistory(
        branchId: 'b-smp-01',
        employeeId: 'emp-50',
      );

      expect(history.length, 2);
      expect(history.first['eventType'], 'HIRED');
      expect(history.last['eventType'], 'PROMOTION');
    });

    test('validates registrationId, salary non-negativity, and history params', () {
      setUpWithMockClient((request) async => http.Response('OK', 200));

      expect(
        () => staffAffiliationsUseCase.getRegistrationById('  '),
        throwsA(isA<ValidationException>()),
      );

      expect(
        () => staffAffiliationsUseCase.updateContractTerms(
          registrationId: '',
          speciality: 'GENERAL',
          specialityName: 'General',
          salary: 1000,
        ),
        throwsA(isA<ValidationException>()),
      );

      expect(
        () => staffAffiliationsUseCase.updateContractTerms(
          registrationId: 'emp-reg-10',
          speciality: 'GENERAL',
          specialityName: 'General',
          salary: -500.0,
        ),
        throwsA(isA<ValidationException>()),
      );

      expect(
        () => staffAffiliationsUseCase.dismissStaffMember(' '),
        throwsA(isA<ValidationException>()),
      );

      expect(
        () => staffAffiliationsUseCase.getCareerHistory(
          branchId: '',
          employeeId: 'emp-50',
        ),
        throwsA(isA<ValidationException>()),
      );

      expect(
        () => staffAffiliationsUseCase.getCareerHistory(
          branchId: 'b-smp-01',
          employeeId: '  ',
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
