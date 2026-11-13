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

  group('ShiftIQ B2B - Auth Integration Tests', () {
    testWidgets('Verify login page UI elements, validations and quick-fill chips',
        (tester) async {
      await tester.pumpWidget(const ShiftIqApp());
      await tester.pumpAndSettle();

      // 1. Verify branding and header
      expect(
        find.byWidgetPredicate((widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('ShiftIQ Workshop')),
        findsOneWidget,
      );
      expect(
        find.text('Gestión Inteligente de Talleres Automotrices'),
        findsOneWidget,
      );

      // 2. Verify form inputs exist
      final emailInput = find.byKey(const Key('login_email_input'));
      final passwordInput = find.byKey(const Key('login_password_input'));
      final submitButton = find.byKey(const Key('login_submit_button'));

      expect(emailInput, findsOneWidget);
      expect(passwordInput, findsOneWidget);
      expect(submitButton, findsOneWidget);

      // 3. Test empty validation
      await tester.tap(submitButton);
      await tester.pumpAndSettle();
      expect(find.text('Ingrese su correo electrónico'), findsOneWidget);

      // 4. Test quick autofill chip: Mecánico (Alan Mamani)
      final mechanicChip = find.byKey(const Key('chip_mechanic'));
      expect(mechanicChip, findsOneWidget);
      await tester.tap(mechanicChip);
      await tester.pumpAndSettle();

      expect(find.text('aldospeedcuber@gmail.com'), findsOneWidget);
      expect(find.text('ShiftIQ2026!'), findsOneWidget);

      // 5. Test quick autofill chip: Dueño (Allan Wagner)
      final ownerChip = find.byKey(const Key('chip_owner'));
      expect(ownerChip, findsOneWidget);
      await tester.tap(ownerChip);
      await tester.pumpAndSettle();

      expect(find.text('allan.wagner.107@gmail.com'), findsOneWidget);
      expect(find.text('12345678A'), findsOneWidget);
    });
  });
}
