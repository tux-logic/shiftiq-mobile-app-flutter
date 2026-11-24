import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/operations_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/widgets/task_detail_sheet.dart';

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
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets(
    'TaskDetailSheet renders product breakdown, mechanic, and cost totals',
    (tester) async {
      final task = WorkOrderTask(
        id: 'task-1',
        serviceId: 'svc-1',
        branchId: 'branch-1',
        assignedMechanicId: 'emp-1',
        assignedMechanicName: 'Aldo Machacca',
        status: TaskStatus.doing,
        description: 'Cambio de aceite y filtro',
        price: 240.0,
        products: const [
          WorkOrderTaskProduct(
            id: 'tp-1',
            productId: 'prod-1',
            productName: 'Filtro de Aceite Bosch',
            branchId: 'branch-1',
            quantity: 2,
            unitPrice: 45.0,
            totalAmount: 90.0,
          ),
        ],
      );

      await tester.pumpWidget(
        _wrapWithApp(TaskDetailSheet(task: task)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cambio de aceite y filtro'), findsOneWidget);
      expect(find.text('Aldo Machacca'), findsOneWidget);
      expect(find.text('Filtro de Aceite Bosch'), findsOneWidget);
      expect(find.text('2 unid · S/ 45.00 c/u'), findsOneWidget);
      expect(find.text('S/ 90.00'), findsNWidgets(2));
      expect(find.text('S/ 240.00'), findsOneWidget);
    },
  );

  testWidgets(
    'TaskDetailSheet supports updating product quantity and removing a part',
    (tester) async {
      int? updatedQty;
      String? removedProductId;

      final task = WorkOrderTask(
        id: 'task-2',
        serviceId: 'svc-1',
        branchId: 'branch-1',
        assignedMechanicId: 'emp-1',
        assignedMechanicName: 'Aldo Machacca',
        status: TaskStatus.doing,
        description: 'Cambio de bujías',
        price: 190.0,
        products: const [
          WorkOrderTaskProduct(
            id: 'tp-1',
            productId: 'prod-1',
            productName: 'Bujía NGK',
            branchId: 'branch-1',
            quantity: 1,
            unitPrice: 40.0,
            totalAmount: 40.0,
          ),
        ],
      );

      await tester.pumpWidget(
        _wrapWithApp(
          TaskDetailSheet(
            task: task,
            onUpdateProductQuantity: (productId, qty) async {
              updatedQty = qty;
              return task.copyWith(
                price: 230.0,
                products: [
                  task.products.first.copyWith(
                    quantity: qty,
                    totalAmount: 40.0 * qty,
                  ),
                ],
              );
            },
            onRemoveProduct: (productId) async {
              removedProductId = productId;
              return task.copyWith(price: 150.0, products: const []);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();
      expect(updatedQty, 2);
      expect(find.text('2 unid · S/ 40.00 c/u'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();
      expect(removedProductId, 'prod-1');
      expect(
        find.text('No hay repuestos asignados a esta tarea.'),
        findsOneWidget,
      );
    },
  );
}
