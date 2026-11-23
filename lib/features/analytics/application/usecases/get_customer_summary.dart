import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/analytics_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/repositories/analytics_repository.dart';

/// Retrieves the self-service analytics summary for the authenticated customer.
class GetCustomerSummaryUseCase {
  final AnalyticsRepository repository;

  const GetCustomerSummaryUseCase({required this.repository});

  Future<CustomerAnalyticsSummary> execute() {
    return repository.getCustomerSummary();
  }
}
