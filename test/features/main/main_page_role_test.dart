import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftiq_mobile_app_flutter/core/auth/mobile_role_scope.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/features/customer/presentation/customer_home_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/main/presentation/main_page.dart';

Widget _wrapWithApp(Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
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
  setUpAll(() {
    if (!getIt.isRegistered<SessionStorage>()) {
      getIt.registerLazySingleton<SessionStorage>(() => SessionStorage());
    }
  });

  group('MainPage role-scoped navigation', () {
    testWidgets('shows 5 destinations for ownerAdmin scope', (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          const MainPage(
            roleScope: MobileRoleScope.ownerAdmin,
            overridePages: [
              SizedBox(key: Key('page_0')),
              SizedBox(key: Key('page_1')),
              SizedBox(key: Key('page_2')),
              SizedBox(key: Key('page_3')),
              SizedBox(key: Key('page_4')),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('main_navigation_bar')), findsOneWidget);
      expect(find.byKey(const Key('nav_dashboard')), findsOneWidget);
      expect(find.byKey(const Key('nav_orders')), findsOneWidget);
      expect(find.byKey(const Key('nav_appointments')), findsOneWidget);
      expect(find.byKey(const Key('nav_inventory')), findsOneWidget);
      expect(find.byKey(const Key('nav_telemetry')), findsOneWidget);
    });

    testWidgets('shows 3 operational destinations for employee scope',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          const MainPage(
            roleScope: MobileRoleScope.employee,
            overridePages: [
              SizedBox(key: Key('page_0')),
              SizedBox(key: Key('page_1')),
              SizedBox(key: Key('page_2')),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('main_navigation_bar')), findsOneWidget);
      expect(find.byKey(const Key('nav_dashboard')), findsNothing);
      expect(find.byKey(const Key('nav_inventory')), findsNothing);
      expect(find.byKey(const Key('nav_orders')), findsOneWidget);
      expect(find.byKey(const Key('nav_appointments')), findsOneWidget);
      expect(find.byKey(const Key('nav_telemetry')), findsOneWidget);
    });

    testWidgets('renders CustomerHomePage when customer scope enters MainPage',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithApp(
          const MainPage(roleScope: MobileRoleScope.customer),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomerHomePage), findsOneWidget);
      expect(find.byKey(const Key('main_navigation_bar')), findsNothing);
    });
  });
}
