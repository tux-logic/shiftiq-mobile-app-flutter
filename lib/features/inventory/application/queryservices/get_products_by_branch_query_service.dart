import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/model/aggregates/product.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/model/valueobjects/stock_status.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/repositories/inventory_repository.dart';

class GetProductsByBranchQueryService {
  final InventoryRepository inventoryRepository;

  const GetProductsByBranchQueryService({
    required this.inventoryRepository,
  });

  Future<List<Product>> execute({
    required String branchId,
    String? category,
    String? searchQuery,
    StockStatus? status,
  }) async {
    return inventoryRepository.getProducts(
      branchId: branchId,
      category: category,
      query: searchQuery,
      status: status,
    );
  }
}
