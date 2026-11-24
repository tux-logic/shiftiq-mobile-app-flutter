import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftiq_mobile_app_flutter/core/auth/mobile_role_scope.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/application/operations_application.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/operations_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/work_orders_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/work_orders_view_model.dart';

class _FakeOperationsRepository implements OperationsRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeWorkOrdersViewModel extends WorkOrdersViewModel {
  _FakeWorkOrdersViewModel()
      : super(
          manageWorkOrders: ManageWorkOrders(
            repository: _FakeOperationsRepository(),
          ),
          sessionStorage: SessionStorage(),
        );

  @override
  Future<void> init() async {}

  @override
  Future<void> loadOrders() async {}
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

void main() {
  testWidgets('hides Nueva OT button for employee scope', (tester) async {
    await tester.pumpWidget(
      _wrapWithApp(
        WorkOrdersPage(
          viewModel: _FakeWorkOrdersViewModel(),
          roleScope: MobileRoleScope.employee,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nueva OT'), findsNothing);
    expect(
      find.text('No hay órdenes de trabajo disponibles en esta sede.'),
      findsOneWidget,
    );
  });

  testWidgets('shows Nueva OT button for ownerAdmin scope', (tester) async {
    await tester.pumpWidget(
      _wrapWithApp(
        WorkOrdersPage(
          viewModel: _FakeWorkOrdersViewModel(),
          roleScope: MobileRoleScope.ownerAdmin,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nueva OT'), findsOneWidget);
  });
}
