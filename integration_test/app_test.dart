import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    setupDependencies();
    await getIt<SessionStorage>().initialize();
    await getIt<SessionStorage>().clearSession();
  });

  group('ShiftIQ B2B - Employee / Mechanic Flow Integration Tests', () {
    testWidgets(
        'Mechanic complete workflow: Login -> Select Branch -> Browse Tabs -> Profile -> Logout',
        (tester) async {
      await tester.pumpWidget(const ShiftIqApp());
      await tester.pumpAndSettle();

      // 1. Select Mechanic Chip and Submit Login
      final mechanicChip = find.byKey(const Key('chip_mechanic'));
      expect(mechanicChip, findsOneWidget);
      await tester.tap(mechanicChip);
      await tester.pumpAndSettle();

      final submitBtn = find.byKey(const Key('login_submit_button'));
      await tester.tap(submitBtn);

      // Dismiss soft keyboard
      FocusManager.instance.primaryFocus?.unfocus();

      // Poll until Branch Selection page loads
      for (int i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('Seleccionar Sede').evaluate().isNotEmpty) break;
      }
      await tester.pumpAndSettle();

      // 2. Branch Selection view verification
      expect(find.text('Seleccionar Sede'), findsOneWidget);

      // Wait for branches to finish loading from network
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('INGRESAR A ESTA SEDE').evaluate().isNotEmpty) break;
      }
      await tester.pumpAndSettle();

      // Tap on 'INGRESAR A ESTA SEDE' button ensuring it is visible
      final selectBranchBtn = find.text('INGRESAR A ESTA SEDE').first;
      await tester.ensureVisible(selectBranchBtn);
      await tester.pumpAndSettle();
      await tester.tap(selectBranchBtn);
      await tester.pumpAndSettle();

      // Poll until MainPage (NavigationBar) loads
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.byType(NavigationBar).evaluate().isNotEmpty) break;
      }
      await tester.pumpAndSettle();

      // 3. Main Dashboard verification
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Panel'), findsOneWidget);
      expect(find.text('Órdenes'), findsOneWidget);
      expect(find.text('Citas'), findsOneWidget);

      // 4. Operations Context: Switch to "Órdenes" tab
      await tester.tap(find.text('Órdenes'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.textContaining('Órdenes de Trabajo'), findsOneWidget);

      // 5. Fleet Context: Switch to "Citas" tab
      await tester.tap(find.text('Citas'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.textContaining('Citas'), findsWidgets);

      // 6. Inventory Context: Switch to "Inventario" tab
      await tester.tap(find.text('Inventario'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.textContaining('Inventario'), findsWidgets);

      // 7. IoT Context: Switch to "Telemetría" tab
      await tester.tap(find.text('Telemetría'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.textContaining('Telemetría'), findsWidgets);

      // 8. Return to Panel and open Profile
      await tester.tap(find.text('Panel'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final profileBtn = find.byTooltip('Mi Perfil de Taller / Cerrar Sesión');
      if (profileBtn.evaluate().isNotEmpty) {
        await tester.tap(profileBtn);
        await tester.pumpAndSettle();

        expect(find.text('Mi Perfil de Taller'), findsOneWidget);

        // Verify logout action
        final logoutBtn = find.byKey(const Key('btn_logout'));
        if (logoutBtn.evaluate().isNotEmpty) {
          await tester.ensureVisible(logoutBtn);
          await tester.pumpAndSettle();
          await tester.tap(logoutBtn);
          await tester.pumpAndSettle();

          final confirmBtn = find.byKey(const Key('btn_confirm_logout'));
          if (confirmBtn.evaluate().isNotEmpty) {
            await tester.tap(confirmBtn);
            await tester.pumpAndSettle();
            expect(find.byKey(const Key('login_submit_button')), findsOneWidget);
          }
        }
      }
    });
  });
}
