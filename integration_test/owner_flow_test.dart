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

  group('ShiftIQ B2B - Owner Flow Integration Tests', () {
    testWidgets(
        'Owner workflow: Login -> Verify "+ Nueva Sede" Modal -> Enter Branch -> Financial BI -> Logout',
        (tester) async {
      await tester.pumpWidget(const ShiftIqApp());
      await tester.pumpAndSettle();

      // 1. Select Owner Quick Fill chip (allan.wagner.107@gmail.com)
      final ownerChip = find.byKey(const Key('chip_owner'));
      expect(ownerChip, findsOneWidget);
      await tester.tap(ownerChip);
      await tester.pumpAndSettle();

      // 2. Submit Login
      final submitBtn = find.byKey(const Key('login_submit_button'));
      await tester.tap(submitBtn);

      FocusManager.instance.primaryFocus?.unfocus();

      // Poll until Branch Selection page loads
      for (int i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('Seleccionar Sede').evaluate().isNotEmpty) break;
      }
      await tester.pumpAndSettle();

      // 3. Verify Branch Selection Page is reached
      expect(find.text('Seleccionar Sede'), findsOneWidget);

      // 4. Verify "+ Nueva Sede" Action is visible for Owner role
      final addBranchFab = find.byKey(const Key('btn_add_branch'));
      expect(addBranchFab, findsOneWidget);

      // 5. Tap "+ Nueva Sede" to trigger Bottom Sheet modal
      await tester.tap(addBranchFab);
      await tester.pumpAndSettle();

      // 6. Verify modal inputs
      expect(find.text('Registrar Nueva Sede'), findsOneWidget);
      expect(find.text('Nombre de la Sede'), findsOneWidget);
      expect(find.text('Código de Sede'), findsOneWidget);
      expect(find.text('Dirección física'), findsOneWidget);

      // Close modal
      final closeBtn = find.byIcon(Icons.close);
      if (closeBtn.evaluate().isNotEmpty) {
        await tester.tap(closeBtn);
        await tester.pumpAndSettle();
      }

      // 7. Wait for branches to finish loading and enter branch
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('INGRESAR A ESTA SEDE').evaluate().isNotEmpty) break;
      }
      await tester.pumpAndSettle();

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

      // 8. Verify Executive Dashboard & Financial KPIs
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.textContaining('Panel Ejecutivo'), findsOneWidget);

      // 9. Verify SUNAT Billing shortcut in AppBar
      final billingBtn = find.byTooltip('Facturación y Cotizaciones SUNAT');
      expect(billingBtn, findsOneWidget);
      await tester.tap(billingBtn);
      await tester.pumpAndSettle();

      expect(find.textContaining('Facturación SUNAT'), findsOneWidget);

      // Return to Dashboard
      final backBtn = find.byType(BackButton);
      if (backBtn.evaluate().isNotEmpty) {
        await tester.tap(backBtn);
        await tester.pumpAndSettle();
      }

      // 10. Open Profile and Logout
      final profileBtn = find.byTooltip('Mi Perfil de Taller / Cerrar Sesión');
      if (profileBtn.evaluate().isNotEmpty) {
        await tester.tap(profileBtn);
        await tester.pumpAndSettle();

        expect(find.text('Mi Perfil de Taller'), findsOneWidget);

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
