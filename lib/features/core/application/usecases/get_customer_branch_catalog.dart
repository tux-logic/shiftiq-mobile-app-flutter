import 'package:shiftiq_mobile_app_flutter/features/core/domain/core_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/repositories/core_repository.dart';

/// Use case retrieving active workshop branches scoped to the authenticated
/// customer via `GET /api/v1/branches/catalog`.
class GetCustomerBranchCatalogUseCase {
  final CoreRepository repository;

  const GetCustomerBranchCatalogUseCase({required this.repository});

  Future<List<CustomerBranchCatalogItem>> execute() {
    return repository.getBranchCatalog();
  }
}
