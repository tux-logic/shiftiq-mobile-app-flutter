import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/analytics_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/infrastructure/remote/analytics_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/presentation/controllers/employee_dashboard_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/presentation/views/employee_dashboard_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/presentation/widgets/dtc_alert_banner.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/presentation/widgets/employee_workload_charts.dart';

class _FakeAnalyticsApi extends AnalyticsApi {
  _FakeAnalyticsApi()
      : super(apiClient: ApiClient(sessionStorage: SessionStorage()));

  @override
  Future<Map<String, dynamic>> getEmployeeSummary() async => {};
}

class _FakeEmployeeDashboardViewModel extends EmployeeDashboardViewModel {
  _FakeEmployeeDashboardViewModel(this._fakeSummary)
      : super(
          analyticsApi: _FakeAnalyticsApi(),
          sessionStorage: SessionStorage(),
        );

  final EmployeeAnalyticsSummary _fakeSummary;

  @override
  EmployeeAnalyticsSummary? get summary => _fakeSummary;

  @override
  Future<void> init() async {}

  @override
  Future<void> refresh() async {}
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
  testWidgets(
    'EmployeeDashboardPage reuses KpiMetricCard and DtcAlertBanner for employee summary',
    (tester) async {
      const summary = EmployeeAnalyticsSummary(
        employeeId: 'emp-1',
        assignedWorkOrdersCount: 2,
        pendingTasksCount: 3,
        completedTasksCount: 5,
        activeDtcAlertsCount: 1,
        assignedWorkOrders: [
          EmployeeAssignedWorkOrderSummary(
            workOrderId: 'wo-1',
            branchId: 'branch-1',
            vehicleId: 'veh-1',
            internalNumber: 42,
            status: 'IN_PROGRESS',
            assignedTasksCount: 2,
            pendingTasksCount: 1,
          ),
        ],
      );

      await tester.pumpWidget(
        _wrapWithApp(
          EmployeeDashboardPage(
            viewModel: _FakeEmployeeDashboardViewModel(summary),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(DtcAlertBanner), findsOneWidget);
      expect(find.byType(EmployeeRadarOverviewChart), findsOneWidget);
      expect(find.text('OTs Activas'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byType(EmployeeTaskRingChart),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byType(EmployeeTaskRingChart), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byType(EmployeeQueueWorkloadChart),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byType(EmployeeQueueWorkloadChart), findsOneWidget);
      expect(find.text('OT #000042'), findsWidgets);
    },
  );
}
