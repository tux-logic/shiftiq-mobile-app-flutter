import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/application/usecases/manage_checkouts.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/application/usecases/manage_quotes.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/infrastructure/remote/billing_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/infrastructure/repositories/billing_repository_impl.dart';
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

      await tester.tap(find.byKey(const Key('customer_nav_orders')));
      await tester.pumpAndSettle();

      expect(calledMeEndpoint, isTrue);
      expect(vm.workOrders.first.tasks.first.assignedMechanicName, equals('Luis Mendoza'));
      expect(find.text('ABC-123'), findsOneWidget);
      expect(find.text('Toyota Corolla Cross 2023'), findsOneWidget);
      expect(find.text('MOL-01-000001'), findsOneWidget);
      expect(find.text('1/1 tareas'), findsOneWidget);
    },
  );

  testWidgets(
    'CustomerHomePage loads GET /api/v1/quotes/me and creates Mercado Pago preference',
    (tester) async {
      final session = SessionStorage();
      await session.saveSession(
        accessToken: 'cust-token',
        refreshToken: 'cust-refresh',
        userId: 'user-1',
        username: 'maria@test.com',
        roles: ['ROLE_CUSTOMER'],
      );

      var calledQuotesMe = false;
      var calledMpPref = false;
      final mockClient = MockClient((request) async {
        if (request.method == 'GET' && request.url.path == '/api/v1/work-orders/me') {
          return http.Response(
            jsonEncode([
              {
                'id': 'wo-1',
                'appointmentId': 'appt-1',
                'branchId': 'branch-1',
                'vehicleId': 'veh-1',
                'vehiclePlateNumber': 'XYZ-789',
                'vehicleBrand': 'Mazda',
                'vehicleModel': 'CX-5',
                'vehicleYear': 2022,
                'customerId': 'cust-1',
                'customerName': 'Maria Fernandez',
                'internalNumber': 2,
                'formattedNumber': 'MOL-01-000002',
                'status': 'COMPLETED',
                'diagnosticSummary': 'Mantenimiento completo',
                'mileageIn': 32000,
                'totalAmount': 350.0,
                'tasks': const [],
                'entryInspectionImages': const [],
              },
            ]),
            200,
          );
        }
        if (request.method == 'GET' && request.url.path == '/api/v1/quotes/me') {
          calledQuotesMe = true;
          return http.Response(
            jsonEncode([
              {
                'id': 'quote-1',
                'branchId': 'branch-1',
                'workOrderId': 'wo-1',
                'quoteNumber': 'COT-2026-0001',
                'customerName': 'Maria Fernandez',
                'vehiclePlate': 'XYZ-789',
                'vehicleModel': 'Mazda CX-5 2022',
                'status': 'APPROVED',
                'subtotal': 350.0,
                'discountPercentage': 0.0,
                'discountAmount': 0.0,
                'igvAmount': 0.0,
                'totalAmount': 350.0,
                'validUntil': '2026-12-31T00:00:00Z',
                'createdAt': '2026-11-22T12:00:00Z',
                'items': [
                  {
                    'id': 'item-1',
                    'type': 'SERVICE',
                    'name': 'Mantenimiento completo',
                    'quantity': 1,
                    'unitPrice': 350.0,
                    'total': 350.0,
                  },
                ],
              },
            ]),
            200,
          );
        }
        if (request.method == 'POST' &&
            request.url.path == '/api/v1/payments/sessions') {
          calledMpPref = true;
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['quoteId'], equals('quote-1'));
          expect(body['provider'], equals('MERCADO_PAGO'));
          return http.Response(
            jsonEncode({
              'provider': 'MERCADO_PAGO',
              'sessionId': 'sess-123',
              'checkoutUrl':
                  'https://www.mercadopago.com.pe/checkout/v1/redirect?pref_id=sess-123',
              'sandboxCheckoutUrl':
                  'https://sandbox.mercadopago.com.pe/checkout/v1/redirect?pref_id=sess-123',
              'amount': 350.0,
              'currency': 'PEN',
              'externalReference': 'quote-1',
            }),
            201,
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(sessionStorage: session, client: mockClient);
      final opsRepo = OperationsRepositoryImpl(
        serviceApi: ServiceApi(apiClient: apiClient),
        workOrderApi: WorkOrderApi(apiClient: apiClient),
        workOrderTaskApi: WorkOrderTaskApi(apiClient: apiClient),
      );
      final billingRepo = BillingRepositoryImpl(
        billingApi: BillingApi(apiClient: apiClient),
      );
      final vm = CustomerHomeViewModel(
        manageWorkOrders: ManageWorkOrders(repository: opsRepo),
        manageQuotes: ManageQuotes(repository: billingRepo),
        manageCheckouts: ManageCheckouts(repository: billingRepo),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [AppLocalizations.delegate],
          supportedLocales: const [Locale('es'), Locale('en')],
          home: CustomerHomePage(viewModel: vm),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('customer_nav_orders')));
      await tester.pumpAndSettle();

      expect(calledQuotesMe, isTrue);
      expect(find.text('MIS COTIZACIONES'), findsOneWidget);
      expect(find.text('Pagar con Mercado Pago'), findsOneWidget);

      await tester.ensureVisible(find.byKey(const Key('pay_quote_quote-1')));
      await tester.tap(find.byKey(const Key('pay_quote_quote-1')));
      await tester.pumpAndSettle();

      expect(calledMpPref, isTrue);
      expect(find.text('Pago con Mercado Pago'), findsOneWidget);
    },
  );

  testWidgets(
    'CustomerHomePage approves DRAFT quote via POST /api/v1/quotes/{id}/approvals and enables payment',
    (tester) async {
      final session = SessionStorage();
      await session.saveSession(
        accessToken: 'cust-token',
        refreshToken: 'cust-refresh',
        userId: 'user-1',
        username: 'maria@test.com',
        roles: ['ROLE_CUSTOMER'],
      );

      var calledApprove = false;
      final mockClient = MockClient((request) async {
        if (request.method == 'GET' && request.url.path == '/api/v1/work-orders/me') {
          return http.Response(
            jsonEncode([
              {
                'id': 'wo-1',
                'appointmentId': 'appt-1',
                'branchId': 'branch-1',
                'vehicleId': 'veh-1',
                'vehiclePlateNumber': 'XYZ-789',
                'vehicleBrand': 'Mazda',
                'vehicleModel': 'CX-5',
                'vehicleYear': 2022,
                'customerId': 'cust-1',
                'customerName': 'Maria Fernandez',
                'internalNumber': 2,
                'formattedNumber': 'MOL-01-000002',
                'status': 'COMPLETED',
                'diagnosticSummary': 'Mantenimiento completo',
                'mileageIn': 32000,
                'totalAmount': 350.0,
                'tasks': const [],
                'entryInspectionImages': const [],
              },
            ]),
            200,
          );
        }
        if (request.method == 'GET' && request.url.path == '/api/v1/quotes/me') {
          return http.Response(
            jsonEncode([
              {
                'id': 'quote-draft-1',
                'branchId': 'branch-1',
                'workOrderId': 'wo-1',
                'quoteNumber': 'COT-2026-0002',
                'customerName': 'Maria Fernandez',
                'vehiclePlate': 'XYZ-789',
                'vehicleModel': 'Mazda CX-5 2022',
                'status': 'DRAFT',
                'subtotal': 350.0,
                'discountPercentage': 0.0,
                'discountAmount': 0.0,
                'igvAmount': 0.0,
                'totalAmount': 350.0,
                'validUntil': '2026-12-31T00:00:00Z',
                'createdAt': '2026-11-22T12:00:00Z',
                'items': const [],
              },
            ]),
            200,
          );
        }
        if (request.method == 'POST' &&
            request.url.path == '/api/v1/quotes/quote-draft-1/approvals') {
          calledApprove = true;
          return http.Response(
            jsonEncode({
              'id': 'quote-draft-1',
              'branchId': 'branch-1',
              'workOrderId': 'wo-1',
              'quoteNumber': 'COT-2026-0002',
              'customerName': 'Maria Fernandez',
              'vehiclePlate': 'XYZ-789',
              'vehicleModel': 'Mazda CX-5 2022',
              'status': 'APPROVED',
              'subtotal': 350.0,
              'discountPercentage': 0.0,
              'discountAmount': 0.0,
              'igvAmount': 0.0,
              'totalAmount': 350.0,
              'validUntil': '2026-12-31T00:00:00Z',
              'createdAt': '2026-11-22T12:00:00Z',
              'items': const [],
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(sessionStorage: session, client: mockClient);
      final opsRepo = OperationsRepositoryImpl(
        serviceApi: ServiceApi(apiClient: apiClient),
        workOrderApi: WorkOrderApi(apiClient: apiClient),
        workOrderTaskApi: WorkOrderTaskApi(apiClient: apiClient),
      );
      final billingRepo = BillingRepositoryImpl(
        billingApi: BillingApi(apiClient: apiClient),
      );
      final vm = CustomerHomeViewModel(
        manageWorkOrders: ManageWorkOrders(repository: opsRepo),
        manageQuotes: ManageQuotes(repository: billingRepo),
        manageCheckouts: ManageCheckouts(repository: billingRepo),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [AppLocalizations.delegate],
          supportedLocales: const [Locale('es'), Locale('en')],
          home: CustomerHomePage(viewModel: vm),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('customer_nav_orders')));
      await tester.pumpAndSettle();

      expect(find.text('Aprobar cotización'), findsOneWidget);
      expect(find.text('Pagar con Mercado Pago'), findsNothing);

      await tester.ensureVisible(find.byKey(const Key('approve_quote_quote-draft-1')));
      await tester.tap(find.byKey(const Key('approve_quote_quote-draft-1')));
      await tester.pumpAndSettle();

      expect(calledApprove, isTrue);
      expect(find.text('Pagar con Mercado Pago'), findsOneWidget);
    },
  );
}
