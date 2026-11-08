import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/model/aggregates/product.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/repositories/inventory_repository.dart';

class GetProductDetailQueryService {
  final InventoryRepository inventoryRepository;

  const GetProductDetailQueryService({
    required this.inventoryRepository,
  });

  Future<Product> execute(String productId) async {
    if (productId.trim().isEmpty) {
      throw ArgumentError('El ID del producto no puede estar vacío.');
    }
    return inventoryRepository.getProductById(productId);
  }
}
