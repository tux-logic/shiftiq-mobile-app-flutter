import 'package:flutter_test/flutter_test.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/application/inventory_application.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/inventory_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/presentation/controllers/inventory_view_model.dart';

class FakeInventoryRepository implements InventoryRepository {
  final List<Product> products = [];

  FakeInventoryRepository() {
    _seedInitialProducts();
  }

  void _seedInitialProducts() {
    products.addAll([
      Product(
        id: 'prod-01',
        branchId: 'b-01',
        category: 'LUBRICANTES',
        name: 'Aceite Sintético Castrol Edge 5W-30',
        sku: 'OIL-SYN-5W30',
        description: 'Lubricante sintético premium',
        salePrice: 165.00,
        minimumStock: 8,
        currentStock: 28,
        createdAt: DateTime(2026, 10, 1),
        batches: [
          ProductBatch(
            batchId: 'LOT-CASTROL-2026-08',
            productId: 'prod-01',
            initialQuantity: 30,
            availableQuantity: 18,
            acquisitionCost: 110.00,
            createdAt: DateTime(2026, 10, 5),
          ),
          ProductBatch(
            batchId: 'LOT-CASTROL-2026-11',
            productId: 'prod-01',
            initialQuantity: 10,
            availableQuantity: 10,
            acquisitionCost: 110.00,
            createdAt: DateTime(2026, 10, 20),
          ),
        ],
      ),
      Product(
        id: 'prod-02',
        branchId: 'b-01',
        category: 'FILTROS',
        name: 'Filtro de Aceite Bosch P3300',
        sku: 'FLT-OIL-P3300',
        description: 'Filtro blindado',
        salePrice: 38.00,
        minimumStock: 10,
        currentStock: 4, // Low stock: 4 <= 10
        createdAt: DateTime(2026, 9, 15),
        batches: [
          ProductBatch(
            batchId: 'LOT-BOSCH-2026-05',
            productId: 'prod-02',
            initialQuantity: 20,
            availableQuantity: 4,
            acquisitionCost: 20.00,
            createdAt: DateTime(2026, 9, 20),
          ),
        ],
      ),
      Product(
        id: 'prod-03',
        branchId: 'b-01',
        category: 'SUSPENSION',
        name: 'Amortiguador Delantero Monroe Gas-Magnum',
        sku: 'SUS-AMR-MNR77',
        description: 'Amortiguador presurizado',
        salePrice: 380.00,
        minimumStock: 2,
        currentStock: 0, // Out of stock
        createdAt: DateTime(2026, 8, 1),
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
    return products.where((p) {
      if (p.branchId != branchId && branchId.isNotEmpty) return false;
      if (category != null && category.isNotEmpty && category != 'TODOS') {
        if (p.category.toUpperCase() != category.toUpperCase()) return false;
      }
      final search = (name ?? query)?.trim().toLowerCase();
      if (search != null && search.isNotEmpty) {
        final matches = p.name.toLowerCase().contains(search) ||
            p.sku.toLowerCase().contains(search) ||
            p.category.toLowerCase().contains(search);
        if (!matches) return false;
      }
      if (status != null && p.status != status) return false;
      if (lowStockOnly == true && !p.isLowStock && !p.isOutOfStock) return false;
      return true;
    }).toList();
  }

  @override
  Future<List<Product>> getBranchCatalog(String branchId) =>
      getProducts(branchId: branchId);

  @override
  Future<Product> getProductById(String id) async {
    return products.firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception('Product not found: $id'),
    );
  }

  @override
  Future<Product> createProduct({
    required String branchId,
    required String category,
    required String name,
    required String sku,
    String description = '',
    double? salePrice,
    double? unitPrice,
    int minimumStock = 5,
    double costPrice = 0.0,
    int initialStock = 0,
    String unitOfMeasure = 'UND',
  }) async {
    final effectivePrice = (salePrice != null && salePrice > 0) ? salePrice : (unitPrice ?? 0.0);
    final newProd = Product(
      id: 'prod-${DateTime.now().millisecondsSinceEpoch}',
      branchId: branchId,
      category: category,
      name: name,
      sku: sku,
      description: description,
      salePrice: effectivePrice,
      minimumStock: minimumStock,
      currentStock: initialStock,
      createdAt: DateTime.now(),
      batches: initialStock > 0
          ? [
              ProductBatch(
                batchId: 'LOT-INI-${DateTime.now().millisecondsSinceEpoch}',
                initialQuantity: initialStock,
                availableQuantity: initialStock,
                acquisitionCost: costPrice,
                createdAt: DateTime.now(),
              ),
            ]
          : const [],
    );
    products.add(newProd);
    return newProd;
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
    final index = products.indexWhere((p) => p.id == productId);
    if (index == -1) throw Exception('Product not found: $productId');
    final updated = products[index].copyWith(
      name: name,
      category: category,
      sku: sku,
      description: description,
      salePrice: salePrice,
      minimumStock: minimumStock,
    );
    products[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteProduct(String productId) async {
    products.removeWhere((p) => p.id == productId);
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
    final index = products.indexWhere((p) => p.id == productId);
    if (index == -1) throw Exception('Product not found: $productId');

    final effectiveCost = acquisitionCost ?? costPrice ?? 0.0;
    final effectiveBatchNum = batchNumber ?? 'LOT-${DateTime.now().millisecondsSinceEpoch}';

    final batch = ProductBatch(
      batchId: effectiveBatchNum,
      productId: productId,
      supplierName: supplierName ?? 'Distribuidora Mayorista',
      initialQuantity: quantity,
      availableQuantity: quantity,
      acquisitionCost: effectiveCost,
      createdAt: DateTime.now(),
      expirationDate: expirationDate,
    );

    final current = products[index];
    final updatedBatches = List<ProductBatch>.from(current.batches)..add(batch);
    products[index] = current.copyWith(
      currentStock: current.currentStock + quantity,
      batches: updatedBatches,
    );

    return batch;
  }

  @override
  Future<int> adjustStock({
    required String productId,
    required int quantity,
    double acquisitionCost = 0.0,
  }) async {
    final index = products.indexWhere((p) => p.id == productId);
    if (index == -1) throw Exception('Product not found: $productId');

    final current = products[index];
    if (quantity > 0) {
      await registerBatch(
        productId: productId,
        quantity: quantity,
        acquisitionCost: acquisitionCost,
      );
      return products[index].currentStock;
    } else {
      // FIFO negative adjustment
      final deductionNeeded = -quantity;
      if (current.currentStock < deductionNeeded) {
        throw Exception('INSUFFICIENT_STOCK: cannot deduct $deductionNeeded from ${current.currentStock}');
      }

      var remainingToDeduct = deductionNeeded;
      final updatedBatches = <ProductBatch>[];

      for (final b in current.batches) {
        if (remainingToDeduct == 0) {
          updatedBatches.add(b);
        } else if (b.availableQuantity <= remainingToDeduct) {
          remainingToDeduct -= b.availableQuantity;
          updatedBatches.add(b.copyWith(availableQuantity: 0));
        } else {
          updatedBatches.add(b.copyWith(
            availableQuantity: b.availableQuantity - remainingToDeduct,
          ));
          remainingToDeduct = 0;
        }
      }

      final newTotalStock = current.currentStock - deductionNeeded;
      products[index] = current.copyWith(
        currentStock: newTotalStock,
        batches: updatedBatches,
      );
      return newTotalStock;
    }
  }

  @override
  Future<List<Product>> getLowStockAlerts(String branchId) async {
    return getProducts(branchId: branchId, lowStockOnly: true);
  }
}

void main() {
  late FakeInventoryRepository repository;
  late ManageProducts manageProducts;
  late ManageBatches manageBatches;

  setUp(() {
    repository = FakeInventoryRepository();
    manageProducts = ManageProducts(repository: repository);
    manageBatches = ManageBatches(repository: repository);
  });

  group('ManageProducts Use Case', () {
    test('enforces validation rules on product creation', () async {
      expect(
        () => manageProducts.createProduct(
          branchId: '',
          category: 'FILTROS',
          name: 'Filtro Aire',
          sku: 'FLT-AIR-01',
          salePrice: 45.0,
          minimumStock: 5,
        ),
        throwsArgumentError,
      );

      expect(
        () => manageProducts.createProduct(
          branchId: 'b-01',
          category: '',
          name: 'Filtro Aire',
          sku: 'FLT-AIR-01',
          salePrice: 45.0,
          minimumStock: 5,
        ),
        throwsArgumentError,
      );

      expect(
        () => manageProducts.createProduct(
          branchId: 'b-01',
          category: 'FILTROS',
          name: 'A',
          sku: 'FLT-AIR-01',
          salePrice: 45.0,
          minimumStock: 5,
        ),
        throwsArgumentError,
      );

      expect(
        () => manageProducts.createProduct(
          branchId: 'b-01',
          category: 'FILTROS',
          name: 'Filtro Aire',
          sku: 'FLT-AIR-01',
          salePrice: -5.0,
          minimumStock: 5,
        ),
        throwsArgumentError,
      );

      expect(
        () => manageProducts.createProduct(
          branchId: 'b-01',
          category: 'FILTROS',
          name: 'Filtro Aire',
          sku: 'FLT-AIR-01',
          salePrice: 45.0,
          minimumStock: -1,
        ),
        throwsArgumentError,
      );
    });

    test('creates new product with SKU formatting and initial zero stock', () async {
      final product = await manageProducts.createProduct(
        branchId: 'b-01',
        category: 'Frenos',
        name: 'Pastillas de Freno Cerámicas',
        sku: 'frn-cer-001',
        description: 'Pastillas de alto rendimiento',
        salePrice: 120.00,
        minimumStock: 4,
      );

      expect(product.id.isNotEmpty, isTrue);
      expect(product.sku, 'FRN-CER-001');
      expect(product.category, 'Frenos');
      expect(product.name, 'Pastillas de Freno Cerámicas');
      expect(product.salePrice, 120.00);
      expect(product.currentStock, 0);
      expect(product.minimumStock, 4);
      expect(product.isOutOfStock, isTrue);
      expect(product.status, StockStatus.outOfStock);
    });

    test('queries products by category and low stock filters', () async {
      final all = await manageProducts.getProducts(branchId: 'b-01');
      expect(all.length, 3);

      final filtersOnly = await manageProducts.getProducts(
        branchId: 'b-01',
        category: 'FILTROS',
      );
      expect(filtersOnly.length, 1);
      expect(filtersOnly.first.sku, 'FLT-OIL-P3300');

      final searchResults = await manageProducts.getProducts(
        branchId: 'b-01',
        name: 'Castrol',
      );
      expect(searchResults.length, 1);
      expect(searchResults.first.id, 'prod-01');

      final lowStockItems = await manageProducts.getProducts(
        branchId: 'b-01',
        lowStockOnly: true,
      );
      // prod-02 (lowStock: 4 <= 10) and prod-03 (outOfStock: 0 <= 2)
      expect(lowStockItems.length, 2);
      expect(lowStockItems.any((p) => p.id == 'prod-02'), isTrue);
      expect(lowStockItems.any((p) => p.id == 'prod-03'), isTrue);
    });

    test('updates product metadata and handles product deletion', () async {
      final updated = await manageProducts.updateProduct(
        productId: 'prod-02',
        name: 'Filtro de Aceite Bosch Blindado Pro',
        category: 'FILTROS',
        sku: 'FLT-OIL-P3300-PRO',
        description: 'Nueva descripción',
        salePrice: 42.50,
        minimumStock: 8,
      );

      expect(updated.name, 'Filtro de Aceite Bosch Blindado Pro');
      expect(updated.sku, 'FLT-OIL-P3300-PRO');
      expect(updated.salePrice, 42.50);
      expect(updated.minimumStock, 8);

      await manageProducts.deleteProduct('prod-03');
      final remaining = await manageProducts.getProducts(branchId: 'b-01');
      expect(remaining.length, 2);
      expect(remaining.any((p) => p.id == 'prod-03'), isFalse);
    });
  });

  group('ManageBatches Use Case', () {
    test('enforces validation on stock intake and adjustments', () async {
      expect(
        () => manageBatches.registerBatch(
          productId: '',
          quantity: 10,
          acquisitionCost: 25.0,
        ),
        throwsArgumentError,
      );

      expect(
        () => manageBatches.registerBatch(
          productId: 'prod-01',
          quantity: 0,
          acquisitionCost: 25.0,
        ),
        throwsArgumentError,
      );

      expect(
        () => manageBatches.registerBatch(
          productId: 'prod-01',
          quantity: 10,
          acquisitionCost: 0.0,
        ),
        throwsArgumentError,
      );

      expect(
        () => manageBatches.adjustStock(
          productId: 'prod-01',
          quantity: 0,
        ),
        throwsArgumentError,
      );
    });

    test('registers batch intake with acquisition cost and increments stock', () async {
      final batch = await manageBatches.registerBatch(
        productId: 'prod-02',
        quantity: 15,
        acquisitionCost: 22.50,
        batchNumber: 'LOT-BOSCH-2026-10',
        supplierName: 'Bosch Autopartes Lima',
      );

      expect(batch.batchId, 'LOT-BOSCH-2026-10');
      expect(batch.initialQuantity, 15);
      expect(batch.availableQuantity, 15);
      expect(batch.acquisitionCost, 22.50);

      final product = await manageProducts.getProductById('prod-02');
      // Previous stock was 4, added 15 -> 19
      expect(product.currentStock, 19);
      expect(product.isOptimalStock, isTrue); // 19 > minimumStock 10
      expect(product.status, StockStatus.normal);
    });

    test('performs negative FIFO stock adjustment and rejects overdrawn stock', () async {
      // prod-01 has 28 units: Batch 1 has 18 available, Batch 2 has 10 available
      final newStock = await manageBatches.adjustStock(
        productId: 'prod-01',
        quantity: -20, // Should deplete 18 from Batch 1 and 2 from Batch 2
      );

      expect(newStock, 8);
      final product = await manageProducts.getProductById('prod-01');
      expect(product.currentStock, 8);
      expect(product.batches[0].availableQuantity, 0);
      expect(product.batches[1].availableQuantity, 8);

      // Attempting to deduct more than remaining 8 units must throw
      expect(
        () => manageBatches.adjustStock(
          productId: 'prod-01',
          quantity: -10,
        ),
        throwsException,
      );
    });

    test('recalculates low stock alert across inventory operations', () async {
      // prod-01 has 8 units, minimumStock is 8. Since currentStock <= minimumStock, it is low stock
      final product = await manageProducts.getProductById('prod-01');
      expect(product.currentStock, 28);

      // Deduct 20 units -> currentStock becomes 8 (minimumStock is 8)
      await manageBatches.adjustStock(productId: 'prod-01', quantity: -20);
      final lowStockProduct = await manageProducts.getProductById('prod-01');
      expect(lowStockProduct.currentStock, 8);
      expect(lowStockProduct.isLowStock, isTrue);
      expect(lowStockProduct.status, StockStatus.lowStock);

      // Add intake of 5 units -> currentStock becomes 13 (13 > 8)
      await manageBatches.adjustStock(
        productId: 'prod-01',
        quantity: 5,
        acquisitionCost: 110.0,
      );
      final optimalProduct = await manageProducts.getProductById('prod-01');
      expect(optimalProduct.currentStock, 13);
      expect(optimalProduct.isOptimalStock, isTrue);
      expect(optimalProduct.status, StockStatus.normal);
    });
  });

  group('InventoryViewModel Presentation Flow', () {
    test('loads products, filters by category and search, and computes summaries', () async {
      final viewModel = InventoryViewModel(
        manageProducts: manageProducts,
        manageBatches: manageBatches,
      );

      await viewModel.loadProducts('b-01');
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.totalProductsCount, 3);
      expect(viewModel.lowStockCount, 1);
      expect(viewModel.outOfStockCount, 1);
      expect(viewModel.totalValuation, greaterThan(0));

      await viewModel.selectCategory('FILTROS', 'b-01');
      expect(viewModel.products.length, 1);
      expect(viewModel.selectedCategory, 'FILTROS');

      await viewModel.selectCategory('TODOS', 'b-01');
      await viewModel.search('Castrol', 'b-01');
      expect(viewModel.products.length, 1);
      expect(viewModel.products.first.name, contains('Castrol'));
    });

    test('handles product detail loading, batch registration, and deletion', () async {
      final viewModel = InventoryViewModel(
        manageProducts: manageProducts,
        manageBatches: manageBatches,
      );

      await viewModel.loadProductDetail('prod-01');
      expect(viewModel.selectedProduct?.name, contains('Castrol'));
      expect(viewModel.selectedProduct?.batches.length, 2);

      final created = await viewModel.createProduct(
        branchId: 'b-01',
        sku: 'IGN-BUJ-NGK',
        name: 'Bujía Láser Iridium NGK',
        category: 'MOTOR',
        salePrice: 65.00,
        minimumStock: 4,
      );
      expect(created, isTrue);
      expect(viewModel.totalProductsCount, 4);

      final batchAdded = await viewModel.registerBatch(
        branchId: 'b-01',
        productId: 'prod-02',
        quantity: 10,
        acquisitionCost: 20.00,
        batchNumber: 'LOT-TEST-ADD',
      );
      expect(batchAdded, isTrue);
      expect(
        viewModel.products.firstWhere((p) => p.id == 'prod-02').currentStock,
        14,
      );

      final deleted = await viewModel.deleteProduct(
        productId: 'prod-03',
        branchId: 'b-01',
      );
      expect(deleted, isTrue);
      expect(viewModel.products.any((p) => p.id == 'prod-03'), isFalse);
    });
  });
}
