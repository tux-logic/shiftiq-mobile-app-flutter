import 'package:flutter_test/flutter_test.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/features/dashboard/application/get_branch_summary_use_case.dart';
import 'package:shiftiq_mobile_app_flutter/features/dashboard/domain/analytics_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/dashboard/domain/branch_summary.dart';
import 'package:shiftiq_mobile_app_flutter/features/dashboard/presentation/dashboard_view_model.dart';

class MockAnalyticsRepository implements AnalyticsRepository {
  bool shouldThrow = false;
  BranchSummary? stubSummary;

  @override
  Future<BranchSummary> getBranchSummary(String branchId) async {
    if (shouldThrow) {
      throw Exception('Server error loading analytics');
    }
    return stubSummary ??
        BranchSummary(
          branchId: branchId,
          totalRevenue: 24850.00,
          completedWorkOrdersCount: 12,
          totalAppointmentsCount: 8,
          lowStockAlertsCount: 3,
          dtcAlertsCount: 2,
        );
  }
}

class MockSessionStorage extends SessionStorage {
  MockSessionStorage() : super(appDatabase: null);

  @override
  Future<String?> getActiveBranchId() async => 'b-01-smp';

  @override
  Future<String?> getActiveBranchName() async =>
      'Sede Central - San Martín de Porres';
}

void main() {
  group('GetBranchSummaryUseCase', () {
    late MockAnalyticsRepository mockRepository;
    late GetBranchSummaryUseCase useCase;

    setUp(() {
      mockRepository = MockAnalyticsRepository();
      useCase = GetBranchSummaryUseCase(repository: mockRepository);
    });

    test('should return BranchSummary when repository succeeds', () async {
      final summary = await useCase.execute('b-01-smp');

      expect(summary.branchId, equals('b-01-smp'));
      expect(summary.totalRevenue, equals(24850.00));
      expect(summary.completedWorkOrdersCount, equals(12));
      expect(summary.totalAppointmentsCount, equals(8));
      expect(summary.lowStockAlertsCount, equals(3));
      expect(summary.dtcAlertsCount, equals(2));
      expect(summary.hasCriticalAlerts, isTrue);
      expect(summary.formattedRevenue, equals('S/ 24850.00'));
    });

    test('should propagate exception when repository fails', () async {
      mockRepository.shouldThrow = true;

      expect(
        () => useCase.execute('b-01-smp'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('DashboardViewModel', () {
    late MockAnalyticsRepository mockRepository;
    late GetBranchSummaryUseCase useCase;
    late MockSessionStorage mockStorage;
    late DashboardViewModel viewModel;

    setUp(() {
      mockRepository = MockAnalyticsRepository();
      useCase = GetBranchSummaryUseCase(repository: mockRepository);
      mockStorage = MockSessionStorage();
      viewModel = DashboardViewModel(
        getBranchSummaryUseCase: useCase,
        sessionStorage: mockStorage,
      );
    });

    test('init should load active branch and fetch summary', () async {
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.summary, isNull);

      await viewModel.init();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.activeBranchId, equals('b-01-smp'));
      expect(
        viewModel.activeBranchName,
        equals('Sede Central - San Martín de Porres'),
      );
      expect(viewModel.summary, isNotNull);
      expect(viewModel.summary!.completedWorkOrdersCount, equals(12));
      expect(viewModel.error, isNull);
    });

    test('loadSummary should set error state when use case throws', () async {
      mockRepository.shouldThrow = true;

      await viewModel.loadSummary();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.summary, isNull);
      expect(viewModel.error, isNotNull);
      expect(viewModel.error, contains('No se pudo cargar el resumen de KPIs'));
    });
  });
}
