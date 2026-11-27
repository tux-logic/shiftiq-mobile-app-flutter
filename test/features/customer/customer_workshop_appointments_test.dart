import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shiftiq_mobile_app_flutter/core/infrastructure/event/stream_domain_event_bus.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_time_picker_sheet.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/application/usecases/get_customer_summary.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/infrastructure/remote/analytics_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/infrastructure/repositories/analytics_repository_impl.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/application/usecases/get_customer_branch_catalog.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/infrastructure/remote/branch_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/infrastructure/remote/profile_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/infrastructure/remote/workshop_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/infrastructure/repositories/core_repository_impl.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/profile_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/profile_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/customer/presentation/customer_home_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/customer/presentation/customer_home_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/application/usecases/create_appointment.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/infrastructure/remote/appointment_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/infrastructure/remote/customer_registration_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/infrastructure/remote/employee_registration_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/infrastructure/repositories/fleet_repository_impl.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/application/usecases/get_customer_vehicles.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/infrastructure/remote/obd2_device_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/infrastructure/remote/obd2_registration_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/infrastructure/remote/telemetry_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/infrastructure/remote/telemetry_batch_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/infrastructure/remote/vehicle_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/infrastructure/repositories/iot_repository_impl.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/application/usecases/manage_work_orders.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/infrastructure/remote/service_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/infrastructure/remote/work_order_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/infrastructure/remote/work_order_task_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/infrastructure/repositories/operations_repository_impl.dart';

Future<CustomerHomeViewModel> _buildTestViewModel(
  MockClient mockClient,
) async {
  final session = SessionStorage();
  await session.saveSession(
    accessToken: 'cust-token',
    refreshToken: 'cust-refresh',
    userId: 'user-1',
    username: 'maria@test.com',
    roles: ['ROLE_CUSTOMER'],
  );

  final apiClient = ApiClient(sessionStorage: session, client: mockClient);
  final profileApi = ProfileApi(apiClient: apiClient);
  final workOrderApi = WorkOrderApi(apiClient: apiClient);

  final coreRepo = CoreRepositoryImpl(
    workshopApi: WorkshopApi(apiClient: apiClient),
    branchApi: BranchApi(apiClient: apiClient),
    profileApi: profileApi,
    sessionStorage: session,
    eventBus: StreamDomainEventBus(),
  );
  final fleetRepo = FleetRepositoryImpl(
    appointmentApi: AppointmentApi(apiClient: apiClient),
    customerRegistrationApi: CustomerRegistrationApi(apiClient: apiClient),
    employeeRegistrationApi: EmployeeRegistrationApi(apiClient: apiClient),
    profileApi: profileApi,
    workOrderApi: workOrderApi,
  );
  final opsRepo = OperationsRepositoryImpl(
    serviceApi: ServiceApi(apiClient: apiClient),
    workOrderApi: workOrderApi,
    workOrderTaskApi: WorkOrderTaskApi(apiClient: apiClient),
  );
  final iotRepo = IotRepositoryImpl(
    vehicleApi: VehicleApi(apiClient: apiClient),
    obd2DeviceApi: Obd2DeviceApi(apiClient: apiClient),
    obd2RegistrationApi: Obd2RegistrationApi(apiClient: apiClient),
    telemetryBatchApi: TelemetryBatchApi(apiClient: apiClient),
    telemetryApi: TelemetryApi(apiClient: apiClient),
  );
  final analyticsRepo = AnalyticsRepositoryImpl(
    analyticsApi: AnalyticsApi(apiClient: apiClient),
  );

  return CustomerHomeViewModel(
    manageWorkOrders: ManageWorkOrders(repository: opsRepo),
    getCustomerSummary: GetCustomerSummaryUseCase(repository: analyticsRepo),
    getCustomerVehicles: GetCustomerVehicles(repository: iotRepo),
    getBranchCatalog: GetCustomerBranchCatalogUseCase(repository: coreRepo),
    createAppointment: CreateAppointmentUseCase(repository: fleetRepo),
  );
}

void main() {
  test(
    'CustomerHomeViewModel loads GET /api/v1/branches/catalog and schedules POST /api/v1/appointments',
    () async {
      Map<String, dynamic>? capturedAppointmentBody;
      var summaryFetches = 0;

      final mockClient = MockClient((request) async {
        if (request.method == 'GET' && request.url.path == '/api/v1/work-orders/me') {
          return http.Response('[]', 200);
        }
        if (request.method == 'GET' &&
            request.url.path == '/api/v1/analytics/me/customer-summary') {
          summaryFetches++;
          return http.Response(
            jsonEncode({
              'customerId': 'cust-1',
              'activeVehiclesCount': 1,
              'activeDtcAlertsCount': 0,
              'upcomingAppointmentsCount': summaryFetches > 1 ? 1 : 0,
              'activeWorkOrdersCount': 0,
              'pendingQuotesCount': 0,
              'upcomingAppointments': summaryFetches > 1
                  ? [
                      {
                        'appointmentId': 'apt-101',
                        'branchId': 'br-1',
                        'vehicleId': 'veh-1',
                        'scheduledStart': '2026-12-01T10:00:00',
                        'status': 'PENDING',
                      },
                    ]
                  : [],
              'activeWorkOrders': [],
              'pendingQuotes': [],
            }),
            200,
          );
        }
        if (request.method == 'GET' &&
            request.url.path == '/api/v1/branches/catalog') {
          return http.Response(
            jsonEncode([
              {
                'branchId': 'br-1',
                'workshopId': 'ws-1',
                'workshopBrandName': 'AT Motors Miraflores',
                'workshopBusinessName': 'AT MOTORS EIRL',
                'branchCode': 'MIR-01',
                'branchName': 'Sede Miraflores - Santa Cruz',
                'address': 'Jr. Toribio Pacheco 550, Miraflores',
                'phone': '+5114451234',
                'averageRating': 4.8,
                'reviewCount': 12,
                'activeBaysCount': 4,
                'freeBaysToday': 3,
              },
            ]),
            200,
          );
        }
        if (request.method == 'GET' &&
            request.url.path == '/api/v1/customers/cust-1/vehicles') {
          return http.Response(
            jsonEncode([
              {
                'id': 'veh-1',
                'plateNumber': 'ABC-123',
                'brand': 'Toyota',
                'model': 'Corolla Cross',
                'year': 2023,
                'vin': '9BRBL3HE2P0123456',
              },
            ]),
            200,
          );
        }
        if (request.method == 'POST' && request.url.path == '/api/v1/appointments') {
          capturedAppointmentBody =
              jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({
              'id': 'apt-101',
              'branchId': 'br-1',
              'customerId': 'cust-1',
              'vehicleId': 'veh-1',
              'scheduledStart': '2026-12-01T10:00:00',
              'scheduledEnd': '2026-12-01T11:00:00',
              'status': 'PENDING',
              'notes': 'Cambio de aceite',
            }),
            201,
          );
        }
        return http.Response('[]', 200);
      });

      final vm = await _buildTestViewModel(mockClient);
      await vm.load();

      expect(vm.branches.length, 1);
      expect(vm.branches.first.workshopBrandName, 'AT Motors Miraflores');
      expect(vm.branches.first.freeBaysToday, 3);
      expect(vm.vehicles.length, 1);

      final created = await vm.scheduleAppointment(
        branchId: 'br-1',
        vehicleId: 'veh-1',
        scheduledStart: DateTime(2026, 12, 1, 10, 0),
        notes: 'Cambio de aceite',
      );

      expect(created, isNotNull);
      expect(created!.id, 'apt-101');
      expect(capturedAppointmentBody, isNotNull);
      expect(capturedAppointmentBody!['branchId'], 'br-1');
      expect(capturedAppointmentBody!['customerId'], 'cust-1');
      expect(capturedAppointmentBody!['vehicleId'], 'veh-1');
      expect(capturedAppointmentBody!['notes'], 'Cambio de aceite');
      expect(vm.summary?.upcomingAppointments.length, 1);
    },
  );

  testWidgets(
    'CustomerHomePage renders associated workshop and books an appointment via modal',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      var postedAppointment = false;
      final mockClient = MockClient((request) async {
        if (request.method == 'GET' && request.url.path == '/api/v1/work-orders/me') {
          return http.Response('[]', 200);
        }
        if (request.method == 'GET' &&
            request.url.path == '/api/v1/analytics/me/customer-summary') {
          return http.Response(
            jsonEncode({
              'customerId': 'cust-1',
              'activeVehiclesCount': 1,
              'activeDtcAlertsCount': 0,
              'upcomingAppointmentsCount': postedAppointment ? 1 : 0,
              'activeWorkOrdersCount': 0,
              'pendingQuotesCount': 0,
              'upcomingAppointments': postedAppointment
                  ? [
                      {
                        'appointmentId': 'apt-202',
                        'branchId': 'br-1',
                        'vehicleId': 'veh-1',
                        'scheduledStart': '2026-12-05T09:00:00',
                        'status': 'PENDING',
                      },
                    ]
                  : [],
              'activeWorkOrders': [],
              'pendingQuotes': [],
            }),
            200,
          );
        }
        if (request.method == 'GET' &&
            request.url.path == '/api/v1/branches/catalog') {
          return http.Response(
            jsonEncode([
              {
                'branchId': 'br-1',
                'workshopId': 'ws-1',
                'workshopBrandName': 'AT Motors Miraflores',
                'workshopBusinessName': 'AT MOTORS EIRL',
                'branchCode': 'MIR-01',
                'branchName': 'Sede Miraflores - Santa Cruz',
                'address': 'Jr. Toribio Pacheco 550, Miraflores',
                'phone': '+5114451234',
                'averageRating': 4.8,
                'reviewCount': 12,
                'activeBaysCount': 4,
                'freeBaysToday': 3,
              },
            ]),
            200,
          );
        }
        if (request.method == 'GET' &&
            request.url.path == '/api/v1/customers/cust-1/vehicles') {
          return http.Response(
            jsonEncode([
              {
                'id': 'veh-1',
                'plateNumber': 'ABC-123',
                'brand': 'Toyota',
                'model': 'Corolla Cross',
                'year': 2023,
                'vin': '9BRBL3HE2P0123456',
              },
            ]),
            200,
          );
        }
        if (request.method == 'POST' && request.url.path == '/api/v1/appointments') {
          postedAppointment = true;
          return http.Response(
            jsonEncode({
              'id': 'apt-202',
              'branchId': 'br-1',
              'customerId': 'cust-1',
              'vehicleId': 'veh-1',
              'scheduledStart': '2026-12-05T09:00:00',
              'status': 'PENDING',
              'notes': 'Revisión general',
            }),
            201,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('[]', 200);
      });

      final vm = await _buildTestViewModel(mockClient);

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('es'), Locale('en')],
          home: CustomerHomePage(viewModel: vm),
        ),
      );
      await tester.pumpAndSettle();

      // Summary tab stays clean without the workshop card or appointment FAB
      expect(find.text('MI TALLER ASOCIADO'), findsNothing);
      expect(
        find.byKey(const Key('btn_customer_schedule_appointment')),
        findsNothing,
      );

      // Navigate to the dedicated Citas tab (index 2)
      await tester.tap(find.byKey(const Key('customer_nav_appointments')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('btn_customer_schedule_appointment')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('field_appointment_notes')),
        'Revisión general',
      );
      await tester.tap(find.byKey(const Key('btn_submit_customer_appointment')));
      await tester.pumpAndSettle();

      expect(postedAppointment, isTrue);
      expect(vm.error, isNull);
      expect(vm.summary?.upcomingAppointments.length, 1);
      expect(find.text('PRÓXIMAS CITAS'), findsOneWidget);
      expect(find.text('PENDING'), findsOneWidget);
    },
  );

  testWidgets(
    'ProfilePage displays associated workshop card for customer accounts',
    (tester) async {
      final session = SessionStorage();
      await session.saveSession(
        accessToken: 'cust-token',
        refreshToken: 'cust-refresh',
        userId: 'user-1',
        username: 'maria@test.com',
        roles: ['ROLE_CUSTOMER'],
      );
      final mockClient = MockClient((request) async {
        if (request.method == 'GET' && request.url.path == '/api/v1/profiles/me') {
          return http.Response(
            jsonEncode({
              'userId': 'user-1',
              'roles': ['ROLE_CUSTOMER'],
              'customer': {
                'customerId': 'cust-1',
                'firstName': 'María',
                'lastName': 'Fernández',
                'documentType': 'DNI',
                'documentNumber': '48765432',
                'phone': '+51922334455',
              },
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        if (request.method == 'GET' &&
            request.url.path == '/api/v1/branches/catalog') {
          return http.Response(
            jsonEncode([
              {
                'branchId': 'br-1',
                'workshopId': 'ws-1',
                'workshopBrandName': 'AT Motors Miraflores',
                'workshopBusinessName': 'AT MOTORS EIRL',
                'branchCode': 'MIR-01',
                'branchName': 'Sede Miraflores - Santa Cruz',
                'address': 'Jr. Toribio Pacheco 550, Miraflores',
                'phone': '+5114451234',
                'averageRating': 4.8,
                'reviewCount': 12,
                'activeBaysCount': 4,
                'freeBaysToday': 3,
              },
            ]),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        return http.Response('[]', 200);
      });

      final apiClient = ApiClient(sessionStorage: session, client: mockClient);
      final profileApi = ProfileApi(apiClient: apiClient);
      final coreRepo = CoreRepositoryImpl(
        workshopApi: WorkshopApi(apiClient: apiClient),
        branchApi: BranchApi(apiClient: apiClient),
        profileApi: profileApi,
        sessionStorage: session,
        eventBus: StreamDomainEventBus(),
      );
      final profileVm = ProfileViewModel(
        profileApi: profileApi,
        employeeRegistrationApi: EmployeeRegistrationApi(apiClient: apiClient),
        sessionStorage: session,
        getCustomerBranchCatalog:
            GetCustomerBranchCatalogUseCase(repository: coreRepo),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('es'), Locale('en')],
          home: ProfilePage(viewModel: profileVm),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('MI TALLER ASOCIADO'), findsOneWidget);
      expect(find.text('AT Motors Miraflores'), findsOneWidget);
      expect(find.text('3/4 bahías libres hoy'), findsOneWidget);
    },
  );

  testWidgets(
    'showTimePicker in manual keyboard input mode renders without BoxConstraints error under ShiftIQTheme',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: const MaterialTheme(TextTheme()).light(),
          locale: const Locale('es'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('es'), Locale('en')],
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  key: const Key('btn_open_time_picker'),
                  onPressed: () => showTimePicker(
                    context: context,
                    initialTime: const TimeOfDay(hour: 9, minute: 0),
                    initialEntryMode: TimePickerEntryMode.input,
                  ),
                  child: const Text('Pick time'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('btn_open_time_picker')));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'showShiftIQTimePickerSheet selects time cleanly without keyboard BoxConstraints crash',
    (tester) async {
      TimeOfDay? picked;
      await tester.pumpWidget(
        MaterialApp(
          theme: const MaterialTheme(TextTheme()).light(),
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  key: const Key('btn_open_wheel_time_picker'),
                  onPressed: () async {
                    picked = await showShiftIQTimePickerSheet(
                      context,
                      initialTime: const TimeOfDay(hour: 10, minute: 30),
                    );
                  },
                  child: const Text('Pick wheel time'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('btn_open_wheel_time_picker')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('btn_confirm_time_picker')));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(picked, const TimeOfDay(hour: 10, minute: 30));
    },
  );
}
