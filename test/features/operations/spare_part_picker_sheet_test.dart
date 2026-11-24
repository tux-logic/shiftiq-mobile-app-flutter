import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/models/product.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/widgets/spare_part_picker_sheet.dart';

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
    'SparePartPickerSheet loads real products, blocks out-of-stock, and dispatches selected product',
    (tester) async {
      String? dispatchedProductId;
      int? dispatchedQty;

      final products = [
        Product(
          id: 'prod-real-1',
          branchId: 'branch-1',
          category: 'Filtros',
          name: 'Filtro de Aceite Bosch',
          sku: 'FLT-001',
          salePrice: 45.0,
          minimumStock: 2,
          currentStock: 5,
        ),
        Product(
          id: 'prod-zero-2',
          branchId: 'branch-1',
          category: 'Frenos',
          name: 'Pastillas Brembo',
          sku: 'BRK-002',
          salePrice: 120.0,
          minimumStock: 2,
          currentStock: 0,
        ),
      ];

      await tester.pumpWidget(
        _wrapWithApp(
          SparePartPickerSheet(
            loadProducts: () async => products,
            onDispatch: (product, qty) async {
              dispatchedProductId = product.id;
              dispatchedQty = qty;
              return null;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Filtro de Aceite Bosch'), findsOneWidget);
      expect(find.text('Pastillas Brembo'), findsOneWidget);
      expect(find.text('Sin stock'), findsOneWidget);

      // Tapping out-of-stock item should not select it
      await tester.tap(find.text('Pastillas Brembo'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.add_rounded), findsNothing);

      // Select real in-stock item and increment quantity to 2
      await tester.tap(find.text('Filtro de Aceite Bosch'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(dispatchedProductId, 'prod-real-1');
      expect(dispatchedQty, 2);
    },
  );
}
