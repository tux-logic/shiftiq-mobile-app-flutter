import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/features/customer/presentation/customer_home_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/customer/presentation/customer_home_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/application/usecases/manage_work_orders.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/infrastructure/remote/service_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/infrastructure/remote/work_order_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/infrastructure/remote/work_order_task_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/infrastructure/repositories/operations_repository_impl.dart';

void main() {
  testWidgets(
    'CustomerHomePage loads GET /api/v1/work-orders/me and renders customer work orders',
    (tester) async {
      final session = SessionStorage();
      await session.saveSession(
        accessToken: 'cust-token',
        refreshToken: 'cust-refresh',
        userId: 'user-1',
        username: 'maria@test.com',
        roles: ['ROLE_CUSTOMER'],
      );

      var calledMeEndpoint = false;
      final mockClient = MockClient((request) async {
        if (request.method == 'GET' && request.url.path == '/api/v1/work-orders/me') {
          calledMeEndpoint = true;
          return http.Response(
            jsonEncode([
              {
                'id': 'wo-1',
                'appointmentId': 'appt-1',
                'branchId': 'branch-1',
                'vehicleId': 'veh-1',
                'vehiclePlateNumber': 'ABC-123',
                'vehicleBrand': 'Toyota',
                'vehicleModel': 'Corolla Cross',
                'vehicleYear': 2023,
                'customerId': 'cust-1',
                'customerName': 'Maria Fernandez',
                'internalNumber': 1,
                'formattedNumber': 'MOL-01-000001',
                'status': 'IN_PROGRESS',
                'diagnosticSummary': 'Cambio de aceite y filtro de aire',
                'mileageIn': 25000,
                'totalAmount': 280.0,
                'tasks': [
                  {
                    'id': 'task-1',
                    'workOrderId': 'wo-1',
                    'serviceId': 'srv-1',
                    'branchId': 'branch-1',
                    'assignedMechanicId': 'mech-1',
                    'assignedMechanicName': 'Luis Mendoza',
                    'status': 'COMPLETED',
                    'description': 'Cambio de aceite',
                    'price': 150.0,
                    'products': const [],
                    'evidenceImages': const ['https://example.com/ev1.jpg'],
                  },
                ],
                'entryInspectionImages': const [],
              },
            ]),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(sessionStorage: session, client: mockClient);
      final repo = OperationsRepositoryImpl(
        serviceApi: ServiceApi(apiClient: apiClient),
        workOrderApi: WorkOrderApi(apiClient: apiClient),
        workOrderTaskApi: WorkOrderTaskApi(apiClient: apiClient),
      );
      final vm = CustomerHomeViewModel(
        manageWorkOrders: ManageWorkOrders(repository: repo),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [AppLocalizations.delegate],
          supportedLocales: const [Locale('es'), Locale('en')],
          home: CustomerHomePage(viewModel: vm),
        ),
      );
      await tester.pumpAndSettle();

      expect(calledMeEndpoint, isTrue);
      expect(find.text('ABC-123'), findsOneWidget);
      expect(find.text('Toyota Corolla Cross 2023'), findsOneWidget);
      expect(find.text('MOL-01-000001'), findsOneWidget);
      expect(find.text('1/1 tareas'), findsOneWidget);
    },
  );
}
