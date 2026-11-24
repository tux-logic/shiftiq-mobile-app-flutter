import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/operations_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/work_order_detail_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/work_order_detail_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/work_orders_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/work_orders_view_model.dart';

class _FakeSessionStorage extends SessionStorage {
  final List<String> _fakeRoles;

  _FakeSessionStorage(this._fakeRoles);

  @override
  List<String> get roles => _fakeRoles;
}

class _FakeWorkOrdersViewModel extends ChangeNotifier
    implements WorkOrdersViewModel {
  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  List<WorkOrder> get orders => const [];

  @override
  List<WorkOrder> ordersForStatus(WorkOrderStatus? status) => const [];

  @override
  Future<void> setFilter(WorkOrderStatus? filter) async {}

  @override
  WorkOrderStatus? get statusFilter => null;

  @override
  String get activeBranchId => 'branch-1';

  @override
  String get activeBranchName => 'Sede Principal';

  @override
  Future<void> init() async {}

  @override
  Future<void> loadOrders() async {}

  @override
  Future<void> refresh() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeWorkOrderDetailViewModel extends ChangeNotifier
    implements WorkOrderDetailViewModel {
  final WorkOrder _workOrder;

  _FakeWorkOrderDetailViewModel(this._workOrder);

  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  WorkOrder? get order => _workOrder;

  @override
  Future<void> loadOrder(String id) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _wrapWithApp(Widget child) {
  return MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

WorkOrder _completedOrder() => WorkOrder(
      id: 'wo-1',
      appointmentId: 'app-1',
      branchId: 'branch-1',
      vehicleId: 'veh-1',
      vehiclePlate: 'ABC-123',
      vehicleModel: 'Toyota Corolla',
      customerId: 'cust-1',
      customerName: 'Juan Pérez',
      internalNumber: 42,
      formattedNumber: 'OT-0042',
      status: WorkOrderStatus.completed,
      diagnosticSummary: 'Cambio de aceite y filtros',
      mileageIn: 52000,
      totalAmount: 180.0,
      createdAt: DateTime(2026, 11, 13),
    );

void main() {
  tearDown(() async {
    if (getIt.isRegistered<SessionStorage>()) {
      await getIt.unregister<SessionStorage>();
    }
  });

  group('Operations role scoping & redesigned header', () {
    testWidgets(
      'WorkOrdersPage renders profile button in header for employee logout access',
      (tester) async {
        getIt.registerSingleton<SessionStorage>(
          _FakeSessionStorage(const ['ROLE_EMPLOYEE']),
        );

        await tester.pumpWidget(
          _wrapWithApp(
            WorkOrdersPage(viewModel: _FakeWorkOrdersViewModel()),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('work_orders_profile_button')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'WorkOrderDetailPage hides billing voucher button for employee scope',
      (tester) async {
        getIt.registerSingleton<SessionStorage>(
          _FakeSessionStorage(const ['ROLE_EMPLOYEE']),
        );

        await tester.pumpWidget(
          _wrapWithApp(
            WorkOrderDetailPage(
              workOrderId: 'wo-1',
              viewModel: _FakeWorkOrderDetailViewModel(_completedOrder()),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.receipt_long), findsNothing);
      },
    );

    testWidgets(
      'WorkOrderDetailPage shows billing voucher button for ownerAdmin scope',
      (tester) async {
        getIt.registerSingleton<SessionStorage>(
          _FakeSessionStorage(const ['ROLE_OWNER']),
        );

        await tester.pumpWidget(
          _wrapWithApp(
            WorkOrderDetailPage(
              workOrderId: 'wo-1',
              viewModel: _FakeWorkOrderDetailViewModel(_completedOrder()),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.receipt_long), findsOneWidget);
      },
    );

    testWidgets(
      'WorkOrderDetailPage hides completed banner when IN_PROGRESS order is viewed in readOnly mode',
      (tester) async {
        getIt.registerSingleton<SessionStorage>(
          _FakeSessionStorage(const ['ROLE_CUSTOMER']),
        );

        final inProgressOrder = WorkOrder(
          id: 'wo-2',
          appointmentId: 'appt-2',
          branchId: 'b-1',
          vehicleId: 'v-1',
          customerId: 'c-1',
          internalNumber: 2,
          formattedNumber: 'MOL-01-000002',
          status: WorkOrderStatus.inProgress,
          diagnosticSummary: 'Cambio de frenos',
          mileageIn: 12000,
          totalAmount: 180.0,
          createdAt: DateTime(2026, 11, 23),
        );

        await tester.pumpWidget(
          _wrapWithApp(
            WorkOrderDetailPage(
              workOrderId: 'wo-2',
              readOnly: true,
              viewModel: _FakeWorkOrderDetailViewModel(inProgressOrder),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('ORDEN COMPLETADA'), findsNothing);
        expect(find.textContaining('ORDEN PAGADA'), findsNothing);
        expect(find.textContaining('FINALIZAR Y LIQUIDAR'), findsNothing);
      },
    );
  });
}
