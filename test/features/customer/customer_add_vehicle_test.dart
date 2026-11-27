import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_navy_banner_fallback.dart';
import 'package:shiftiq_mobile_app_flutter/features/customer/presentation/customer_home_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/customer/presentation/customer_home_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/application/usecases/register_vehicle.dart';
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
  final opsRepo = OperationsRepositoryImpl(
    serviceApi: ServiceApi(apiClient: apiClient),
    workOrderApi: WorkOrderApi(apiClient: apiClient),
    workOrderTaskApi: WorkOrderTaskApi(apiClient: apiClient),
  );
  final iotRepo = IotRepositoryImpl(
    vehicleApi: VehicleApi(apiClient: apiClient),
    obd2DeviceApi: Obd2DeviceApi(apiClient: apiClient),
    obd2RegistrationApi: Obd2RegistrationApi(apiClient: apiClient),
    telemetryBatchApi: TelemetryBatchApi(apiClient: apiClient),
    telemetryApi: TelemetryApi(apiClient: apiClient),
  );

  return CustomerHomeViewModel(
    manageWorkOrders: ManageWorkOrders(repository: opsRepo),
    registerVehicle: RegisterVehicle(repository: iotRepo),
  );
}

void main() {
  test('CustomerHomeViewModel.addVehicle posts to /api/v1/vehicles and appends vehicle', () async {
    Map<String, dynamic>? capturedBody;
    final mockClient = MockClient((request) async {
      if (request.method == 'POST' && request.url.path == '/api/v1/vehicles') {
        capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'id': 'veh-99',
            'plateNumber': 'ABC-123',
            'brand': 'Toyota',
            'model': 'Corolla Cross',
            'year': 2023,
            'vin': '9BRBL3HE2P0123456',
          }),
          201,
        );
      }
      return http.Response('[]', 200);
    });

    final vm = await _buildTestViewModel(mockClient);
    final created = await vm.addVehicle(
      plateNumber: 'abc-123',
      brand: 'Toyota',
      model: 'Corolla Cross',
      year: 2023,
      vin: '9brbl3he2p0123456',
      photoUrl: 'https://res.cloudinary.com/demo/vehicle.jpg',
    );

    expect(created, isNotNull);
    expect(created!.plateNumber, 'ABC-123');
    expect(vm.vehicles.length, 1);
    expect(capturedBody?['plateNumber'], 'ABC-123');
    expect(capturedBody?['vin'], '9BRBL3HE2P0123456');
    expect(
      capturedBody?['photoUrl'],
      'https://res.cloudinary.com/demo/vehicle.jpg',
    );
  });

  testWidgets('CustomerHomePage allows customer to add a vehicle from My Vehicles tab', (tester) async {
    var postedVehicle = false;
    final mockClient = MockClient((request) async {
      if (request.method == 'POST' && request.url.path == '/api/v1/vehicles') {
        postedVehicle = true;
        return http.Response(
          jsonEncode({
            'id': 'veh-100',
            'plateNumber': 'XYZ-789',
            'brand': 'Mazda',
            'model': 'CX-5',
            'year': 2024,
            'vin': 'JM3KFBCM5R0123456',
          }),
          201,
        );
      }
      return http.Response('[]', 200);
    });

    final vm = await _buildTestViewModel(mockClient);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: CustomerHomePage(viewModel: vm),
      ),
    );
    await tester.pumpAndSettle();

    // Switch to My Vehicles tab
    await tester.tap(find.byKey(const Key('customer_nav_vehicles')));
    await tester.pumpAndSettle();

    // Open Add Vehicle sheet
    await tester.tap(find.byKey(const Key('btn_customer_add_vehicle')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('field_vehicle_plate')), 'XYZ-789');
    await tester.enterText(find.byKey(const Key('field_vehicle_brand')), 'Mazda');
    await tester.enterText(find.byKey(const Key('field_vehicle_model')), 'CX-5');
    await tester.enterText(find.byKey(const Key('field_vehicle_year')), '2024');
    await tester.enterText(
      find.byKey(const Key('field_vehicle_vin')),
      'JM3KFBCM5R0123456',
    );

    await tester.tap(find.byKey(const Key('btn_submit_add_vehicle')));
    await tester.pumpAndSettle();

    expect(postedVehicle, isTrue);
    expect(find.textContaining('XYZ-789'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Mazda CX-5'), findsOneWidget);
    expect(find.byType(ShiftIQNavyBannerFallback), findsAtLeastNWidgets(1));
  });
}
