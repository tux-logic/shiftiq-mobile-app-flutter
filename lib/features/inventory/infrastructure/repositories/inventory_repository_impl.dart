import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/inventory_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/infrastructure/remote/dtos/inventory_dto.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/infrastructure/remote/inventory_api.dart';

/// Implementation of [InventoryRepository] coordinating remote HTTP calls via [InventoryApi]
/// and mapping to pure immutable domain aggregates.
class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryApi inventoryApi;

  final List<Product> _localProducts = [];

  InventoryRepositoryImpl({required this.inventoryApi}) {
    _initDemoProducts();
  }

  void _initDemoProducts() {
    if (_localProducts.isNotEmpty) return;

    final now = DateTime.now();

    _localProducts.addAll([
      Product(
        id: 'prod-01',
        branchId: 'b-01-smp',
        sku: 'OIL-SYN-5W30',
        name: 'Aceite Sintético Castrol Edge 5W-30',
        description:
            'Lubricante 100% sintético para motores gasolina y diésel ligero con tecnología Fluid TITANIUM',
        category: 'LUBRICANTES',
        unitOfMeasure: 'GALON',
        salePrice: 165.00,
        costPrice: 110.00,
        currentStock: 28,
        minimumStock: 8,
        createdAt: now.subtract(const Duration(days: 30)),
        batches: [
          ProductBatch(
            batchId: 'LOT-CASTROL-2026-08',
            productId: 'prod-01',
            supplierName: 'Castrol Perú S.A.C.',
            initialQuantity: 30,
            availableQuantity: 18,
            acquisitionCost: 110.00,
            createdAt: now.subtract(const Duration(days: 20)),
          ),
          ProductBatch(
            batchId: 'LOT-CASTROL-2026-11',
            productId: 'prod-01',
            supplierName: 'Castrol Perú S.A.C.',
            initialQuantity: 10,
            availableQuantity: 10,
            acquisitionCost: 110.00,
            createdAt: now.subtract(const Duration(days: 5)),
          ),
        ],
      ),
      Product(
        id: 'prod-02',
        branchId: 'b-01-smp',
        sku: 'FLT-OIL-P3300',
        name: 'Filtro de Aceite Bosch P3300',
        description: 'Filtro de aceite blindado de alta eficiencia para vehículos asiáticos',
        category: 'FILTROS',
        unitOfMeasure: 'UND',
        salePrice: 38.00,
        costPrice: 20.00,
        currentStock: 4,
        minimumStock: 10,
        createdAt: now.subtract(const Duration(days: 45)),
        batches: [
          ProductBatch(
            batchId: 'LOT-BOSCH-2026-05',
            productId: 'prod-02',
            supplierName: 'Bosch Autopartes Lima',
            initialQuantity: 20,
            availableQuantity: 4,
            acquisitionCost: 20.00,
            createdAt: now.subtract(const Duration(days: 40)),
          ),
        ],
      ),
      Product(
        id: 'prod-03',
        branchId: 'b-01-smp',
        sku: 'SUS-AMR-MNR77',
        name: 'Amortiguador Delantero Monroe Gas-Magnum',
        description: 'Amortiguador presurizado con gas nitrógeno para trabajo pesado',
        category: 'SUSPENSION',
        unitOfMeasure: 'PAR',
        salePrice: 380.00,
        costPrice: 240.00,
        currentStock: 0,
        minimumStock: 2,
        createdAt: now.subtract(const Duration(days: 60)),
        batches: const [],
      ),
    ]);
  }

  @override
  Future<List<Product>> getProducts({
    required String branchId,
    String? category,
    String? query,
    StockStatus? status,
    String? name,
    bool? lowStockOnly,
  }) async {
    try {
      final effectiveName = name ?? query;
      final rawList = await inventoryApi.getProductsRaw(
        branchId: branchId,
        category: category,
        name: effectiveName,
        lowStockOnly: lowStockOnly,
      );

      if (rawList.isNotEmpty) {
        var list = rawList
            .whereType<Map<String, dynamic>>()
            .map((item) => ProductDto.fromJson(item).toDomain())
            .toList();

        if (status != null) {
          list = list.where((p) => p.status == status).toList();
        }
        return list;
      }
    } catch (_) {
      // Local demo fallback
    }

    var list = _localProducts
        .where((p) => p.branchId == branchId || branchId.isEmpty)
        .toList();

    if (category != null && category.isNotEmpty && category != 'TODOS') {
      list = list.where((p) => p.category.toUpperCase() == category.toUpperCase()).toList();
    }

    final effectiveSearch = (query ?? name)?.trim().toLowerCase();
    if (effectiveSearch != null && effectiveSearch.isNotEmpty) {
      list = list.where((p) {
        return p.name.toLowerCase().contains(effectiveSearch) ||
            p.sku.toLowerCase().contains(effectiveSearch) ||
            p.category.toLowerCase().contains(effectiveSearch);
      }).toList();
    }

    if (status != null) {
      list = list.where((p) => p.status == status).toList();
    }

    if (lowStockOnly == true) {
      list = list.where((p) => p.isLowStock || p.isOutOfStock).toList();
    }

    return list;
  }

  @override
  Future<List<Product>> getBranchCatalog(String branchId) async {
    try {
      final rawList = await inventoryApi.getBranchCatalogRaw(branchId);
      if (rawList.isNotEmpty) {
        return rawList
            .whereType<Map<String, dynamic>>()
            .map((item) => ProductDto.fromJson(item).toDomain())
            .toList();
      }
    } catch (_) {
      // Local fallback
    }
    return getProducts(branchId: branchId);
  }

  @override
  Future<Product> getProductById(String id) async {
    try {
      final raw = await inventoryApi.getProductByIdRaw(id);
      return ProductDto.fromJson(raw).toDomain();
    } catch (_) {
      // Local fallback
    }

    return _localProducts.firstWhere(
      (p) => p.id == id,
      orElse: () => _localProducts.first,
    );
  }

  @override
  Future<Product> createProduct({
    required String branchId,
    required String sku,
    required String name,
    required String category,
    double? salePrice,
    double? unitPrice,
    double costPrice = 0.0,
    int initialStock = 0,
    int minimumStock = 5,
    String unitOfMeasure = 'UND',
    String description = '',
  }) async {
    final effectivePrice = salePrice ?? unitPrice ?? 0.0;
    try {
      final raw = await inventoryApi.createProductRaw(
        branchId: branchId,
        category: category,
        name: name,
        sku: sku,
        description: description,
        salePrice: effectivePrice,
        minimumStock: minimumStock,
      );
      final product = ProductDto.fromJson(raw).toDomain();
      _localProducts.add(product);
      return product;
    } catch (_) {
      // Local fallback
    }

    final newProduct = Product(
      id: 'prod-${DateTime.now().millisecondsSinceEpoch}',
      branchId: branchId,
      sku: sku.toUpperCase().trim(),
      name: name.trim(),
      category: category.toUpperCase().trim(),
      salePrice: effectivePrice,
      costPrice: costPrice,
      currentStock: initialStock,
      minimumStock: minimumStock,
      unitOfMeasure: unitOfMeasure.toUpperCase().trim(),
      description: description.trim(),
      createdAt: DateTime.now(),
      batches: initialStock > 0
          ? [
              ProductBatch(
                batchId: 'LOT-INI-${DateTime.now().month}${DateTime.now().day}',
                productId: 'prod-${DateTime.now().millisecondsSinceEpoch}',
                supplierName: 'Inventario Inicial',
                initialQuantity: initialStock,
                availableQuantity: initialStock,
                acquisitionCost: costPrice,
                createdAt: DateTime.now(),
              ),
            ]
          : const [],
    );

    _localProducts.add(newProduct);
    return newProduct;
  }

  @override
  Future<Product> updateProduct({
    required String productId,
    required String name,
    required String category,
    required String sku,
    String description = '',
    required double salePrice,
    required int minimumStock,
  }) async {
    try {
      final raw = await inventoryApi.updateProductRaw(
        productId: productId,
        name: name,
        category: category,
        sku: sku,
        description: description,
        salePrice: salePrice,
        minimumStock: minimumStock,
      );
      final product = ProductDto.fromJson(raw).toDomain();
      final index = _localProducts.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _localProducts[index] = product;
      }
      return product;
    } catch (_) {
      // Local fallback
    }

    final index = _localProducts.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final updated = _localProducts[index].copyWith(
        name: name,
        category: category,
        sku: sku,
        description: description,
        salePrice: salePrice,
        minimumStock: minimumStock,
      );
      _localProducts[index] = updated;
      return updated;
    }
    throw Exception('Product not found: $productId');
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      await inventoryApi.deleteProduct(productId);
    } catch (_) {
      // Continue to local cleanup
    }
    _localProducts.removeWhere((p) => p.id == productId);
  }

  @override
  Future<ProductBatch> registerBatch({
    required String productId,
    required int quantity,
    String? branchId,
    String? batchNumber,
    String? supplierName,
    double? costPrice,
    double? acquisitionCost,
    DateTime? expirationDate,
  }) async {
    final effectiveCost = acquisitionCost ?? costPrice ?? 0.0;
    final effectiveBatchNum = batchNumber ?? 'LOT-${DateTime.now().millisecondsSinceEpoch}';
    final effectiveSupplier = supplierName ?? 'Distribuidor General';

    try {
      final raw = await inventoryApi.registerBatchRaw(
        productId: productId,
        quantity: quantity,
        acquisitionCost: effectiveCost,
      );
      final batch = ProductBatchDto.fromJson(raw).toDomain();
      _updateLocalStockWithBatch(productId, batch);
      return batch;
    } catch (_) {
      // Local fallback
    }

    final newBatch = ProductBatch(
      batchId: effectiveBatchNum.toUpperCase().trim(),
      productId: productId,
      supplierName: effectiveSupplier.trim(),
      initialQuantity: quantity,
      availableQuantity: quantity,
      acquisitionCost: effectiveCost,
      createdAt: DateTime.now(),
      expirationDate: expirationDate,
    );

    _updateLocalStockWithBatch(productId, newBatch);
    return newBatch;
  }

  @override
  Future<int> adjustStock({
    required String productId,
    required int quantity,
    double acquisitionCost = 0.0,
  }) async {
    try {
      final raw = await inventoryApi.registerBatchRaw(
        productId: productId,
        quantity: quantity,
        acquisitionCost: acquisitionCost,
      );
      final res = StockAdjustmentResponseDto.fromJson(raw);
      return res.currentStock;
    } catch (_) {
      // Local fallback
    }

    await registerBatch(
      productId: productId,
      quantity: quantity,
      acquisitionCost: acquisitionCost,
    );
    final p = await getProductById(productId);
    return p.currentStock;
  }

  void _updateLocalStockWithBatch(String productId, ProductBatch batch) {
    final index = _localProducts.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final product = _localProducts[index];
      final updatedBatches = List<ProductBatch>.from(product.batches)..add(batch);
      final newStock = product.currentStock + batch.quantityReceived;

      _localProducts[index] = product.copyWith(
        currentStock: newStock,
        costPrice: batch.costPrice,
        batches: updatedBatches,
      );
    }
  }

  @override
  Future<List<Product>> getLowStockAlerts(String branchId) async {
    return getProducts(branchId: branchId, lowStockOnly: true);
  }
}
