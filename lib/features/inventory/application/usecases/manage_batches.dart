import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/inventory_domain.dart';

/// Application use case managing stock intake batches, manual stock adjustments, and FIFO stock depletion.
class ManageBatches {
  final InventoryRepository repository;

  const ManageBatches({required this.repository});

  /// Registers an inventory batch for a product.
  /// When [quantity] is positive, [acquisitionCost] (or [costPrice]) must be greater than zero.
  Future<ProductBatch> registerBatch({
    required String productId,
    required int quantity,
    double acquisitionCost = 0.0,
    String? branchId,
    String? batchNumber,
    String? supplierName,
    double? costPrice,
    DateTime? expirationDate,
  }) async {
    if (productId.trim().isEmpty) {
      throw ArgumentError('productId cannot be empty');
    }
    if (quantity == 0) {
      throw ArgumentError('quantity cannot be zero');
    }
    final effectiveCost = acquisitionCost > 0 ? acquisitionCost : (costPrice ?? 0.0);
    if (quantity > 0 && effectiveCost <= 0) {
      throw ArgumentError('acquisitionCost must be greater than zero for stock intake');
    }

    return repository.registerBatch(
      productId: productId.trim(),
      quantity: quantity,
      acquisitionCost: effectiveCost,
      branchId: branchId?.trim(),
      batchNumber: batchNumber?.trim(),
      supplierName: supplierName?.trim(),
      costPrice: effectiveCost,
      expirationDate: expirationDate,
    );
  }

  /// Performs a stock adjustment (positive for intake, negative for adjustment/shrinkage).
  /// Returns the updated total stock for the product.
  Future<int> adjustStock({
    required String productId,
    required int quantity,
    double acquisitionCost = 0.0,
  }) async {
    if (productId.trim().isEmpty) {
      throw ArgumentError('productId cannot be empty');
    }
    if (quantity == 0) {
      throw ArgumentError('quantity cannot be zero');
    }
    if (quantity > 0 && acquisitionCost <= 0) {
      throw ArgumentError('acquisitionCost must be greater than zero for positive adjustments');
    }

    return repository.adjustStock(
      productId: productId.trim(),
      quantity: quantity,
      acquisitionCost: acquisitionCost,
    );
  }

  /// Retrieves the list of batches for a specific product.
  Future<List<ProductBatch>> getProductBatches(String productId) async {
    if (productId.trim().isEmpty) {
      throw ArgumentError('productId cannot be empty');
    }
    final product = await repository.getProductById(productId.trim());
    return product.batches;
  }
}
