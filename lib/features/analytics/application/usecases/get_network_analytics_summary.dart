import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/analytics_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/repositories/analytics_repository.dart';

/// Use case retrieving the consolidated multi-branch network analytics for owners and admins.
class GetNetworkAnalyticsSummaryUseCase {
  final AnalyticsRepository repository;

  GetNetworkAnalyticsSummaryUseCase({
    AnalyticsRepository? repository,
    AnalyticsRepository? analyticsRepository,
  }) : repository = (repository ?? analyticsRepository)!;

  Future<NetworkAnalyticsSummary> execute() {
    return repository.getNetworkSummary();
  }

  Future<NetworkAnalyticsSummary> call() => execute();
}
