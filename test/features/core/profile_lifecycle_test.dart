import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shiftiq_mobile_app_flutter/core/infrastructure/event/stream_domain_event_bus.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/application/usecases/manage_profile_lifecycle.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/infrastructure/remote/branch_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/infrastructure/remote/profile_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/infrastructure/remote/workshop_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/infrastructure/repositories/core_repository_impl.dart';

void main() {
  late StreamDomainEventBus eventBus;
  late SessionStorage sessionStorage;
  late CoreRepositoryImpl repository;
  late ManageProfileLifecycle useCase;

  setUp(() {
    eventBus = StreamDomainEventBus();
    sessionStorage = SessionStorage();
  });

  tearDown(() {
    eventBus.dispose();
  });

  void setUpWithMockClient(Future<http.Response> Function(http.Request request) handler) {
    final mockClient = MockClient(handler);
    final apiClient = ApiClient(client: mockClient, sessionStorage: sessionStorage);
    repository = CoreRepositoryImpl(
      workshopApi: WorkshopApi(apiClient: apiClient),
      branchApi: BranchApi(apiClient: apiClient),
      profileApi: ProfileApi(apiClient: apiClient),
      sessionStorage: sessionStorage,
      eventBus: eventBus,
    );
    useCase = ManageProfileLifecycle(repository: repository);
  }

  group('ManageProfileLifecycle - Owner Profile Lifecycle', () {
    test('getOwnerById retrieves owner profile successfully', () async {
      setUpWithMockClient((request) async {
        if (request.method == 'GET' && request.url.path == '/api/v1/owners/owner-100') {
          return http.Response(
            jsonEncode({
              'id': 'owner-100',
              'userId': 'usr-1',
              'firstName': 'Carlos',
              'lastName': 'Castro',
              'phone': '+51 987654321',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final result = await useCase.getOwnerById('owner-100');

      expect(result['id'], 'owner-100');
      expect(result['firstName'], 'Carlos');
      expect(result['lastName'], 'Castro');
      expect(result['phone'], '+51 987654321');
    });

    test('updateOwnerProfile updates owner details with PUT request', () async {
      setUpWithMockClient((request) async {
        if (request.method == 'PUT' && request.url.path == '/api/v1/owners/owner-100') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['firstName'], 'Carlos Alberto');
          expect(body['lastName'], 'Castro');
          expect(body['documentType'], 'DNI');
          expect(body['documentNumber'], '12345678');
          expect(body['phone'], '+51 999888777');
          return http.Response(
            jsonEncode({
              'id': 'owner-100',
              'firstName': 'Carlos Alberto',
              'lastName': 'Castro',
              'documentType': 'DNI',
              'documentNumber': '12345678',
              'phone': '+51 999888777',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final result = await useCase.updateOwnerProfile(
        ownerId: 'owner-100',
        firstName: 'Carlos Alberto',
        lastName: 'Castro',
        documentType: 'DNI',
        documentNumber: '12345678',
        phone: '+51 999888777',
      );

      expect(result['firstName'], 'Carlos Alberto');
      expect(result['phone'], '+51 999888777');
    });

    test('deleteOwnerProfile sends DELETE request to correct endpoint', () async {
      var deleted = false;
      setUpWithMockClient((request) async {
        if (request.method == 'DELETE' && request.url.path == '/api/v1/owners/owner-100') {
          deleted = true;
          return http.Response('', 204);
        }
        return http.Response('Not Found', 404);
      });

      await useCase.deleteOwnerProfile('owner-100');
      expect(deleted, isTrue);
    });

    test('validates ownerId is not empty', () {
      setUpWithMockClient((request) async => http.Response('OK', 200));

      expect(() => useCase.getOwnerById('  '), throwsArgumentError);
      expect(
        () => useCase.updateOwnerProfile(
          ownerId: '',
          firstName: 'Carlos',
          lastName: 'Castro',
          documentType: 'DNI',
          documentNumber: '12345678',
          phone: '+51 999',
        ),
        throwsArgumentError,
      );
      expect(() => useCase.deleteOwnerProfile('   '), throwsArgumentError);
    });
  });

  group('ManageProfileLifecycle - Employee Profile Lifecycle', () {
    test('getEmployeeById retrieves employee profile correctly', () async {
      setUpWithMockClient((request) async {
        if (request.method == 'GET' && request.url.path == '/api/v1/employees/emp-200') {
          return http.Response(
            jsonEncode({
              'id': 'emp-200',
              'firstName': 'Miguel',
              'lastName': 'Grau',
              'dni': '45678912',
              'phone': '+51 912345678',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final result = await useCase.getEmployeeById('emp-200');

      expect(result['id'], 'emp-200');
      expect(result['firstName'], 'Miguel');
      expect(result['dni'], '45678912');
    });

    test('getEmployeesByDocumentNumber queries employees by document', () async {
      setUpWithMockClient((request) async {
        if (request.method == 'GET' &&
            request.url.path == '/api/v1/employees' &&
            request.url.queryParameters['documentNumber'] == '45678912') {
          return http.Response(
            jsonEncode([
              {
                'id': 'emp-200',
                'firstName': 'Miguel',
                'lastName': 'Grau',
                'dni': '45678912',
              },
            ]),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final results = await useCase.getEmployeesByDocumentNumber('45678912');

      expect(results.length, 1);
      expect(results.first['id'], 'emp-200');
      expect(results.first['dni'], '45678912');
    });

    test('updateEmployeeProfile sends PUT and receives updated employee', () async {
      setUpWithMockClient((request) async {
        if (request.method == 'PUT' && request.url.path == '/api/v1/employees/emp-200') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['firstName'], 'Miguel');
          expect(body['lastName'], 'Grau');
          expect(body['documentType'], 'DNI');
          expect(body['documentNumber'], '45678912');
          expect(body['phone'], '+51 922333444');
          return http.Response(
            jsonEncode({
              'id': 'emp-200',
              'firstName': 'Miguel',
              'lastName': 'Grau',
              'documentType': 'DNI',
              'documentNumber': '45678912',
              'phone': '+51 922333444',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final result = await useCase.updateEmployeeProfile(
        employeeId: 'emp-200',
        firstName: 'Miguel',
        lastName: 'Grau',
        documentType: 'DNI',
        documentNumber: '45678912',
        phone: '+51 922333444',
      );

      expect(result['phone'], '+51 922333444');
    });

    test('deleteEmployeeProfile sends DELETE request', () async {
      var deleted = false;
      setUpWithMockClient((request) async {
        if (request.method == 'DELETE' && request.url.path == '/api/v1/employees/emp-200') {
          deleted = true;
          return http.Response('', 204);
        }
        return http.Response('Not Found', 404);
      });

      await useCase.deleteEmployeeProfile('emp-200');
      expect(deleted, isTrue);
    });

    test('validates employeeId and documentNumber are not empty', () {
      setUpWithMockClient((request) async => http.Response('OK', 200));

      expect(() => useCase.getEmployeeById(' '), throwsArgumentError);
      expect(() => useCase.getEmployeesByDocumentNumber(''), throwsArgumentError);
      expect(
        () => useCase.updateEmployeeProfile(
          employeeId: '',
          firstName: 'Miguel',
          lastName: 'Grau',
          documentType: 'DNI',
          documentNumber: '12345678',
          phone: '+51 999',
        ),
        throwsArgumentError,
      );
      expect(() => useCase.deleteEmployeeProfile(''), throwsArgumentError);
    });
  });

  group('ManageProfileLifecycle - Customer Profile Lifecycle', () {
    test('getCustomerById retrieves customer profile correctly', () async {
      setUpWithMockClient((request) async {
        if (request.method == 'GET' && request.url.path == '/api/v1/customers/cust-300') {
          return http.Response(
            jsonEncode({
              'id': 'cust-300',
              'firstName': 'Elena',
              'lastName': 'Rojas',
              'businessName': 'Transportes Rojas',
              'phone': '+51 944555666',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final result = await useCase.getCustomerById('cust-300');

      expect(result['id'], 'cust-300');
      expect(result['firstName'], 'Elena');
      expect(result['businessName'], 'Transportes Rojas');
    });

    test('updateCustomerProfile sends PUT and receives updated profile', () async {
      setUpWithMockClient((request) async {
        if (request.method == 'PUT' && request.url.path == '/api/v1/customers/cust-300') {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['documentType'], 'RUC');
          expect(body['documentNumber'], '20556677889');
          expect(body['phone'], '+51 944555666');
          expect(body['businessName'], 'Logística y Transportes Rojas S.A.C.');
          return http.Response(
            jsonEncode({
              'id': 'cust-300',
              'firstName': 'Elena',
              'lastName': 'Rojas',
              'businessName': 'Logística y Transportes Rojas S.A.C.',
              'documentType': 'RUC',
              'documentNumber': '20556677889',
              'phone': '+51 944555666',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final result = await useCase.updateCustomerProfile(
        customerId: 'cust-300',
        documentType: 'RUC',
        documentNumber: '20556677889',
        phone: '+51 944555666',
        businessName: 'Logística y Transportes Rojas S.A.C.',
      );

      expect(result['businessName'], 'Logística y Transportes Rojas S.A.C.');
    });

    test('deleteCustomerProfile sends DELETE request', () async {
      var deleted = false;
      setUpWithMockClient((request) async {
        if (request.method == 'DELETE' && request.url.path == '/api/v1/customers/cust-300') {
          deleted = true;
          return http.Response('', 204);
        }
        return http.Response('Not Found', 404);
      });

      await useCase.deleteCustomerProfile('cust-300');
      expect(deleted, isTrue);
    });

    test('validates customerId is not empty', () {
      setUpWithMockClient((request) async => http.Response('OK', 200));

      expect(() => useCase.getCustomerById(''), throwsArgumentError);
      expect(
        () => useCase.updateCustomerProfile(
          customerId: '  ',
          documentType: 'RUC',
          documentNumber: '20556677889',
          phone: '+51 944555666',
        ),
        throwsArgumentError,
      );
      expect(() => useCase.deleteCustomerProfile(' '), throwsArgumentError);
    });
  });
}
