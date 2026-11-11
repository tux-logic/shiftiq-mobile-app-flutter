import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/infrastructure/remote/profile_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/profile_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/infrastructure/remote/employee_registration_api.dart';

void main() {
  late SessionStorage sessionStorage;

  setUp(() {
    sessionStorage = SessionStorage();
  });

  group('ProfileViewModel Tests', () {
    test('init() should load employee profile and registration from Render', () async {
      await sessionStorage.saveSession(
        accessToken: 'mock-token',
        refreshToken: 'mock-refresh',
        userId: 'bc782c92-e6b4-463f-98f5-8e14b020a5dc',
        username: 'aldospeedcuber@gmail.com',
        roles: ['EMPLOYEE'],
      );
      await sessionStorage.setActiveBranch(
        branchId: 'acf71fc5-4be0-4aed-b82d-55b7faf901f8',
        branchName: 'Sede Principal Surquillo',
      );

      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/v1/profiles/me') {
          return http.Response(
            jsonEncode({
              'userId': 'bc782c92-e6b4-463f-98f5-8e14b020a5dc',
              'roles': ['EMPLOYEE'],
              'employee': {
                'id': 'd064205b-0594-4ca5-b2ff-24f4b1fac460',
                'firstName': 'ALAN JAIVI',
                'lastName': 'MAMANI VILCA',
                'documentType': 'DNI',
                'documentNumber': '75981176',
                'phone': '+51987654322',
              },
            }),
            200,
          );
        }
        if (request.url.path == '/api/v1/employee-registrations') {
          return http.Response(
            jsonEncode([
              {
                'id': 'b95aeab8-66ef-4b43-be12-178d2aede1c4',
                'speciality': 'GENERAL_MECHANIC',
                'specialityName': 'Mecánica General',
                'salary': 2800.0,
              }
            ]),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(sessionStorage: sessionStorage, client: mockClient);
      final profileApi = ProfileApi(apiClient: apiClient);
      final employeeRegistrationApi = EmployeeRegistrationApi(apiClient: apiClient);

      final viewModel = ProfileViewModel(
        profileApi: profileApi,
        employeeRegistrationApi: employeeRegistrationApi,
        sessionStorage: sessionStorage,
      );

      await viewModel.init();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.displayName, equals('ALAN JAIVI MAMANI VILCA'));
      expect(viewModel.roleDisplay, equals('Mecánico Especialista (B2B Staff)'));
      expect(viewModel.documentDisplay, equals('DNI: 75981176'));
      expect(viewModel.phoneDisplay, equals('+51987654322'));
      expect(viewModel.specialtyName, equals('Mecánica General'));
      expect(viewModel.salary, equals(2800.0));
      expect(viewModel.activeBranchName, equals('Sede Principal Surquillo'));
    });

    test('updateProfile() should call PUT /api/v1/employees/{id} on Render', () async {
      await sessionStorage.saveSession(
        accessToken: 'mock-token',
        refreshToken: 'mock-refresh',
        userId: 'user-1',
        username: 'aldospeedcuber@gmail.com',
        roles: ['EMPLOYEE'],
      );

      var putCalled = false;
      final mockClient = MockClient((request) async {
        if (request.method == 'GET' && request.url.path == '/api/v1/profiles/me') {
          return http.Response(
            jsonEncode({
              'userId': 'user-1',
              'roles': ['EMPLOYEE'],
              'employee': {
                'id': 'd064205b-0594-4ca5-b2ff-24f4b1fac460',
                'firstName': 'Alan',
                'lastName': 'Mamani',
                'documentType': 'DNI',
                'documentNumber': '75981176',
                'phone': '+51987654322',
              },
            }),
            200,
          );
        }
        if (request.method == 'GET' && request.url.path == '/api/v1/employee-registrations') {
          return http.Response('[]', 200);
        }
        if (request.method == 'PUT' &&
            request.url.path == '/api/v1/employees/d064205b-0594-4ca5-b2ff-24f4b1fac460') {
          putCalled = true;
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['firstName'], equals('Alan Jaivi'));
          expect(body['lastName'], equals('Mamani Vilca'));
          expect(body['phone'], equals('+51999999999'));
          return http.Response(
            jsonEncode({
              'id': 'd064205b-0594-4ca5-b2ff-24f4b1fac460',
              'userId': 'user-1',
              'firstName': 'Alan Jaivi',
              'lastName': 'Mamani Vilca',
              'documentType': 'DNI',
              'documentNumber': '75981176',
              'phone': '+51999999999',
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(sessionStorage: sessionStorage, client: mockClient);
      final profileApi = ProfileApi(apiClient: apiClient);
      final employeeRegistrationApi = EmployeeRegistrationApi(apiClient: apiClient);

      final viewModel = ProfileViewModel(
        profileApi: profileApi,
        employeeRegistrationApi: employeeRegistrationApi,
        sessionStorage: sessionStorage,
      );

      await viewModel.init();

      final success = await viewModel.updateProfile(
        firstName: 'Alan Jaivi',
        lastName: 'Mamani Vilca',
        phone: '+51999999999',
      );

      expect(success, isTrue);
      expect(putCalled, isTrue);
      expect(viewModel.successMessage, contains('exitosamente'));
    });

    test('logout() should clear session storage', () async {
      await sessionStorage.saveSession(
        accessToken: 'token-xyz',
        refreshToken: 'refresh-xyz',
        userId: 'user-xyz',
        username: 'user@test.com',
        roles: ['EMPLOYEE'],
      );
      expect(sessionStorage.isAuthenticated, isTrue);

      final mockClient = MockClient((request) async => http.Response('', 200));
      final apiClient = ApiClient(sessionStorage: sessionStorage, client: mockClient);
      final viewModel = ProfileViewModel(
        profileApi: ProfileApi(apiClient: apiClient),
        employeeRegistrationApi: EmployeeRegistrationApi(apiClient: apiClient),
        sessionStorage: sessionStorage,
      );

      await viewModel.logout();

      expect(sessionStorage.isAuthenticated, isFalse);
      expect(sessionStorage.userId, isNull);
      expect(sessionStorage.username, isNull);
    });
  });
}
