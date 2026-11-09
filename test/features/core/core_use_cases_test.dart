import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shiftiq_mobile_app_flutter/core/domain/event/domain_event.dart';
import 'package:shiftiq_mobile_app_flutter/core/infrastructure/event/stream_domain_event_bus.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/application/usecases/create_workshop.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/application/usecases/get_user_profile_context.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/application/usecases/lookup_profile_by_document.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/application/usecases/manage_branch_subscription.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/application/usecases/manage_specialties.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/application/usecases/select_active_branch.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/core_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/infrastructure/remote/branch_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/infrastructure/remote/profile_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/infrastructure/remote/workshop_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/infrastructure/repositories/core_repository_impl.dart';

void main() {
  late StreamDomainEventBus eventBus;
  late SessionStorage sessionStorage;
  late WorkshopApi workshopApi;
  late BranchApi branchApi;
  late ProfileApi profileApi;
  late CoreRepositoryImpl repository;

  setUp(() {
    eventBus = StreamDomainEventBus();
    sessionStorage = SessionStorage();
  });

  tearDown(() {
    eventBus.dispose();
  });

  group('Core Domain - Workshop & Specialty Use Cases', () {
    test('CreateWorkshopUseCase successfully posts and parses Workshop aggregate', () async {
      final mockClient = MockClient((request) async {
        if (request.method == 'POST' && request.url.path == '/api/v1/workshops') {
          return http.Response(
            jsonEncode({
              'id': 'w-100',
              'ownerId': 'owner-200',
              'businessName': 'Castro Motors S.A.C.',
              'brandName': 'Castro Motors',
              'taxId': '20549876123',
              'mileageIntervalConfig': 5000,
            }),
            201,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(client: mockClient, sessionStorage: sessionStorage);
      workshopApi = WorkshopApi(apiClient: apiClient);
      branchApi = BranchApi(apiClient: apiClient);
      profileApi = ProfileApi(apiClient: apiClient);
      repository = CoreRepositoryImpl(
        workshopApi: workshopApi,
        branchApi: branchApi,
        profileApi: profileApi,
        sessionStorage: sessionStorage,
        eventBus: eventBus,
      );

      final useCase = CreateWorkshopUseCase(repository: repository);
      final workshop = await useCase.execute(
        ownerId: 'owner-200',
        businessName: 'Castro Motors S.A.C.',
        brandName: 'Castro Motors',
        taxId: '20549876123',
      );

      expect(workshop.id, 'w-100');
      expect(workshop.businessName, 'Castro Motors S.A.C.');
      expect(workshop.brandName, 'Castro Motors');
      expect(workshop.taxId, '20549876123');
      expect(workshop.mileageIntervalConfig, 5000);
    });

    test('ManageSpecialtiesUseCase lists specialties with active filter', () async {
      final mockClient = MockClient((request) async {
        if (request.method == 'GET' &&
            request.url.path == '/api/v1/workshops/w-100/specialties' &&
            request.url.queryParameters['activeOnly'] == 'true') {
          return http.Response(
            jsonEncode([
              {
                'id': 'spec-1',
                'workshopId': 'w-100',
                'name': 'Mecánica General',
                'code': 'GENERAL_MECHANIC',
                'description': 'Mantenimiento preventivo',
                'active': true,
              },
            ]),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(client: mockClient, sessionStorage: sessionStorage);
      workshopApi = WorkshopApi(apiClient: apiClient);
      branchApi = BranchApi(apiClient: apiClient);
      profileApi = ProfileApi(apiClient: apiClient);
      repository = CoreRepositoryImpl(
        workshopApi: workshopApi,
        branchApi: branchApi,
        profileApi: profileApi,
        sessionStorage: sessionStorage,
        eventBus: eventBus,
      );

      final useCase = ManageSpecialtiesUseCase(repository: repository);
      final specialties = await useCase.list(workshopId: 'w-100');

      expect(specialties.length, 1);
      expect(specialties.first.code, 'GENERAL_MECHANIC');
      expect(specialties.first.active, isTrue);
    });
  });

  group('Core Domain - Branch & Active Selection Use Cases', () {
    test('SelectActiveBranchUseCase persists branch in session and emits ActiveBranchChangedEvent', () async {
      final mockClient = MockClient((request) async => http.Response('OK', 200));
      final apiClient = ApiClient(client: mockClient, sessionStorage: sessionStorage);
      workshopApi = WorkshopApi(apiClient: apiClient);
      branchApi = BranchApi(apiClient: apiClient);
      profileApi = ProfileApi(apiClient: apiClient);
      repository = CoreRepositoryImpl(
        workshopApi: workshopApi,
        branchApi: branchApi,
        profileApi: profileApi,
        sessionStorage: sessionStorage,
        eventBus: eventBus,
      );

      final eventsReceived = <ActiveBranchChangedEvent>[];
      eventBus.on<ActiveBranchChangedEvent>().listen(eventsReceived.add);

      const branch = Branch(
        id: 'br-surco-01',
        workshopId: 'w-100',
        code: 'BR-SURCO-01',
        name: 'Sede Surco Premium',
        address: 'Av. Primavera 1234',
      );

      final selectUseCase = SelectActiveBranchUseCase(repository: repository);
      await selectUseCase.execute(branch);

      expect(await selectUseCase.getActiveBranchId(), 'br-surco-01');
      expect(await selectUseCase.getActiveBranchName(), 'Sede Surco Premium');
      expect(sessionStorage.activeWorkshopId, 'w-100');

      // Allow event stream loop to deliver
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(eventsReceived.length, 1);
      expect(eventsReceived.first.branchId, 'br-surco-01');
      expect(eventsReceived.first.branchName, 'Sede Surco Premium');
    });

    test('ManageBranchSubscriptionUseCase assigns and cancels subscription', () async {
      final mockClient = MockClient((request) async {
        if (request.method == 'POST' &&
            request.url.path == '/api/v1/branches/br-surco-01/subscriptions') {
          return http.Response(
            jsonEncode({
              'id': 'sub-99',
              'branchId': 'br-surco-01',
              'planId': 'plan-premium',
              'billingCycle': 'MONTHLY',
              'status': 'ACTIVE',
            }),
            201,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.method == 'DELETE' &&
            request.url.path == '/api/v1/branches/br-surco-01/subscription') {
          return http.Response('', 204);
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(client: mockClient, sessionStorage: sessionStorage);
      workshopApi = WorkshopApi(apiClient: apiClient);
      branchApi = BranchApi(apiClient: apiClient);
      profileApi = ProfileApi(apiClient: apiClient);
      repository = CoreRepositoryImpl(
        workshopApi: workshopApi,
        branchApi: branchApi,
        profileApi: profileApi,
        sessionStorage: sessionStorage,
        eventBus: eventBus,
      );

      final useCase = ManageBranchSubscriptionUseCase(repository: repository);
      final sub = await useCase.assign(
        branchId: 'br-surco-01',
        planId: 'plan-premium',
        billingCycle: 'MONTHLY',
        cardNumber: '4532015698451234',
        cardHolderName: 'Carlos Mendoza',
        expirationDate: '12/28',
        cvv: '123',
      );

      expect(sub.id, 'sub-99');
      expect(sub.isActive, isTrue);

      await expectLater(useCase.cancel('br-surco-01'), completes);
    });
  });

  group('Core Domain - Profile Context Use Cases', () {
    test('GetUserProfileContextUseCase parses unified profile with employee profile', () async {
      final mockClient = MockClient((request) async {
        if (request.method == 'GET' && request.url.path == '/api/v1/profiles/me') {
          return http.Response(
            jsonEncode({
              'userId': 'usr-777',
              'roles': ['ROLE_EMPLOYEE'],
              'owner': null,
              'employee': {
                'employeeId': 'emp-888',
                'workshopId': 'w-100',
                'firstName': 'Luis',
                'lastName': 'Mendoza',
                'documentType': 'DNI',
                'documentNumber': '71234567',
                'phone': '+51912345678',
              },
              'customer': null,
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(client: mockClient, sessionStorage: sessionStorage);
      workshopApi = WorkshopApi(apiClient: apiClient);
      branchApi = BranchApi(apiClient: apiClient);
      profileApi = ProfileApi(apiClient: apiClient);
      repository = CoreRepositoryImpl(
        workshopApi: workshopApi,
        branchApi: branchApi,
        profileApi: profileApi,
        sessionStorage: sessionStorage,
        eventBus: eventBus,
      );

      final useCase = GetUserProfileContextUseCase(repository: repository);
      final context = await useCase.execute();

      expect(context.userId, 'usr-777');
      expect(context.isEmployee, isTrue);
      expect(context.isOwner, isFalse);
      expect(context.employee?.fullName, 'Luis Mendoza');
      expect(context.employee?.documentNumber, '71234567');
    });

    test('LookupProfileByDocumentUseCase finds profile by DNI', () async {
      final mockClient = MockClient((request) async {
        if (request.method == 'GET' &&
            request.url.path == '/api/v1/profiles' &&
            request.url.queryParameters['documentNumber'] == '71234567') {
          return http.Response(
            jsonEncode({
              'userId': 'usr-777',
              'roles': ['ROLE_EMPLOYEE'],
              'owner': null,
              'employee': {
                'employeeId': 'emp-888',
                'workshopId': 'w-100',
                'firstName': 'Luis',
                'lastName': 'Mendoza',
                'documentType': 'DNI',
                'documentNumber': '71234567',
                'phone': '+51912345678',
              },
              'customer': null,
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(client: mockClient, sessionStorage: sessionStorage);
      workshopApi = WorkshopApi(apiClient: apiClient);
      branchApi = BranchApi(apiClient: apiClient);
      profileApi = ProfileApi(apiClient: apiClient);
      repository = CoreRepositoryImpl(
        workshopApi: workshopApi,
        branchApi: branchApi,
        profileApi: profileApi,
        sessionStorage: sessionStorage,
        eventBus: eventBus,
      );

      final useCase = LookupProfileByDocumentUseCase(repository: repository);
      final profile = await useCase.execute('71234567');

      expect(profile, isNotNull);
      expect(profile?.userId, 'usr-777');
      expect(profile?.employee?.fullName, 'Luis Mendoza');
    });
  });
}
