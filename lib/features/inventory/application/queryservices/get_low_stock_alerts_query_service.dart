import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/model/aggregates/product.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/repositories/inventory_repository.dart';

class GetLowStockAlertsQueryService {
  final InventoryRepository inventoryRepository;

  const GetLowStockAlertsQueryService({
    required this.inventoryRepository,
  });

  Future<List<Product>> execute(String branchId) async {
    return inventoryRepository.getLowStockAlerts(branchId);
  }
}
