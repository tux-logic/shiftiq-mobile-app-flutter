import 'package:flutter_test/flutter_test.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/application/commandservices/create_product_command_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/application/commandservices/register_batch_command_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/application/queryservices/get_low_stock_alerts_query_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/application/queryservices/get_product_detail_query_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/application/queryservices/get_products_by_branch_query_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/model/aggregates/product.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/model/entities/product_batch.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/model/valueobjects/stock_status.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/presentation/controllers/inventory_view_model.dart';

class MockInventoryRepository implements InventoryRepository {
  final List<Product> _products = [
    Product(
      id: 'prod-01',
      branchId: 'b-01-smp',
      sku: 'OIL-SYN-5W30',
      name: 'Aceite Sintético Castrol Edge 5W-30',
      category: 'LUBRICANTES',
      unitOfMeasure: 'GALON',
      unitPrice: 165.00,
      costPrice: 110.00,
      currentStock: 28,
      minimumStock: 8,
      batches: [
        ProductBatch(
          id: 'batch-01',
          batchNumber: 'LOT-CASTROL-2026-08',
          productId: 'prod-01',
          quantityReceived: 30,
          quantityRemaining: 18,
          costPrice: 110.00,
          receptionDate: DateTime(2026, 10, 15),
        ),
      ],
    ),
    const Product(
      id: 'prod-02',
      branchId: 'b-01-smp',
      sku: 'FLT-OIL-P3300',
      name: 'Filtro de Aceite Bosch P3300',
      category: 'FILTROS',
      unitOfMeasure: 'UND',
      unitPrice: 38.00,
      costPrice: 20.00,
      currentStock: 4, // LOW STOCK (min: 10)
      minimumStock: 10,
    ),
    const Product(
      id: 'prod-03',
      branchId: 'b-01-smp',
      sku: 'SUS-AMR-MNR77',
      name: 'Amortiguador Delantero Monroe Gas-Magnum',
      category: 'SUSPENSION',
      unitOfMeasure: 'PAR',
      unitPrice: 380.00,
      costPrice: 240.00,
      currentStock: 0, // OUT OF STOCK
      minimumStock: 2,
    ),
  ];

  @override
  @override
  Future<List<Product>> getProducts({
    required String branchId,
    String? category,
    String? query,
    StockStatus? status,
    String? name,
    bool? lowStockOnly,
  }) async {
    return _products.where((p) {
      if (p.branchId != branchId) return false;
      if (category != null && category.isNotEmpty && category != 'TODOS') {
        if (p.category.toUpperCase() != category.toUpperCase()) return false;
      }
      final effectiveQuery = query ?? name;
      if (effectiveQuery != null && effectiveQuery.isNotEmpty) {
        final q = effectiveQuery.toLowerCase();
        final match = p.name.toLowerCase().contains(q) ||
            p.sku.toLowerCase().contains(q);
        if (!match) return false;
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
    return _products.firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception('Product not found'),
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
    final product = Product(
      id: 'prod-${_products.length + 1}',
      branchId: branchId,
      sku: sku,
      name: name,
      category: category,
      salePrice: effectivePrice,
      costPrice: costPrice,
      currentStock: initialStock,
      minimumStock: minimumStock,
      unitOfMeasure: unitOfMeasure,
      description: description,
    );
    _products.add(product);
    return product;
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
    final index = _products.indexWhere((p) => p.id == productId);
    if (index == -1) throw Exception('Product not found');
    final updated = _products[index].copyWith(
      name: name,
      category: category,
      sku: sku,
      description: description,
      salePrice: salePrice,
      minimumStock: minimumStock,
    );
    _products[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteProduct(String productId) async {
    _products.removeWhere((p) => p.id == productId);
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
    final index = _products.indexWhere((p) => p.id == productId);
    if (index == -1) throw Exception('Product not found');

    final effectiveCost = acquisitionCost ?? costPrice ?? 0.0;
    final effectiveBatchNum = batchNumber ?? 'LOT-${DateTime.now().millisecondsSinceEpoch}';

    final batch = ProductBatch(
      batchNumber: effectiveBatchNum,
      productId: productId,
      supplierName: supplierName ?? 'Bosch Lima',
      quantityReceived: quantity,
      quantityRemaining: quantity,
      acquisitionCost: effectiveCost,
      receptionDate: DateTime.now(),
      expirationDate: expirationDate,
    );

    final current = _products[index];
    final updatedBatches = List<ProductBatch>.from(current.batches)..add(batch);
    _products[index] = current.copyWith(
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
    await registerBatch(
      productId: productId,
      quantity: quantity,
      acquisitionCost: acquisitionCost,
    );
    final p = await getProductById(productId);
    return p.currentStock;
  }

  @override
  Future<List<Product>> getLowStockAlerts(String branchId) async {
    final products = await getProducts(branchId: branchId);
    return products.where((p) => p.isLowStock || p.isOutOfStock).toList();
  }
}

void main() {
  late MockInventoryRepository repository;
  late GetProductsByBranchQueryService getProductsQuery;
  late GetProductDetailQueryService getProductDetailQuery;
  late GetLowStockAlertsQueryService getLowStockAlertsQuery;
  late CreateProductCommandService createProductCommand;
  late RegisterBatchCommandService registerBatchCommand;

  setUp(() {
    repository = MockInventoryRepository();
    getProductsQuery = GetProductsByBranchQueryService(inventoryRepository: repository);
    getProductDetailQuery = GetProductDetailQueryService(inventoryRepository: repository);
    getLowStockAlertsQuery = GetLowStockAlertsQueryService(inventoryRepository: repository);
    createProductCommand = CreateProductCommandService(inventoryRepository: repository);
    registerBatchCommand = RegisterBatchCommandService(inventoryRepository: repository);
  });

  group('Hito 5: Inventory & Spare Parts Catalog B2B', () {
    test('1. GetProductsByBranchQueryService returns all branch spare parts', () async {
      final results = await getProductsQuery.execute(branchId: 'b-01-smp');
      expect(results.length, equals(3));
      expect(results.every((p) => p.branchId == 'b-01-smp'), isTrue);
    });

    test('2. Query filters products by category correctly', () async {
      final results = await getProductsQuery.execute(
        branchId: 'b-01-smp',
        category: 'LUBRICANTES',
      );
      expect(results.length, equals(1));
      expect(results.first.sku, equals('OIL-SYN-5W30'));
    });

    test('3. GetLowStockAlertsQueryService identifies low stock and out of stock items', () async {
      final alerts = await getLowStockAlertsQuery.execute('b-01-smp');
      expect(alerts.length, equals(2)); // prod-02 (4/10) and prod-03 (0/2)
      expect(alerts.any((p) => p.id == 'prod-02' && p.isLowStock), isTrue);
      expect(alerts.any((p) => p.id == 'prod-03' && p.isOutOfStock), isTrue);
    });

    test('4. CreateProductCommandService creates product with validated SKU and prices', () async {
      final command = const CreateProductCommand(
        branchId: 'b-01-smp',
        sku: 'brk-pad-bsh',
        name: 'Pastillas de Freno Bosch Blue',
        category: 'FRENOS',
        unitPrice: 120.00,
        costPrice: 70.00,
        initialStock: 15,
        minimumStock: 4,
        unitOfMeasure: 'JUEGO',
      );

      final created = await createProductCommand.execute(command);
      expect(created.sku, equals('BRK-PAD-BSH'));
      expect(created.profitMargin, equals(50.00));
      expect(created.currentStock, equals(15));
      expect(created.isOptimalStock, isTrue);

      final all = await getProductsQuery.execute(branchId: 'b-01-smp');
      expect(all.length, equals(4));
    });

    test('5. CreateProductCommandService throws ArgumentError on invalid inputs', () async {
      expect(
        () => createProductCommand.execute(
          const CreateProductCommand(
            branchId: 'b-01-smp',
            sku: '',
            name: 'Invalido',
            category: 'FRENOS',
            unitPrice: 50.0,
            costPrice: 30.0,
            initialStock: 5,
          ),
        ),
        throwsArgumentError,
      );

      expect(
        () => createProductCommand.execute(
          const CreateProductCommand(
            branchId: 'b-01-smp',
            sku: 'VALID',
            name: 'Invalido',
            category: 'FRENOS',
            unitPrice: -10.0,
            costPrice: 30.0,
            initialStock: 5,
          ),
        ),
        throwsArgumentError,
      );
    });

    test('6. RegisterBatchCommandService increments product stock and creates batch', () async {
      final initial = await getProductDetailQuery.execute('prod-02');
      expect(initial.currentStock, equals(4));

      final batchCommand = RegisterBatchCommand(
        branchId: 'b-01-smp',
        productId: 'prod-02',
        batchNumber: 'LOT-TEST-99',
        supplierName: 'Bosch Lima',
        quantity: 20,
        costPrice: 20.00,
      );

      final batch = await registerBatchCommand.execute(batchCommand);
      expect(batch.batchNumber, equals('LOT-TEST-99'));
      expect(batch.quantityReceived, equals(20));

      final updated = await getProductDetailQuery.execute('prod-02');
      expect(updated.currentStock, equals(24));
      expect(updated.isOptimalStock, isTrue);
    });

    test('7. InventoryViewModel handles state, search, and category changes', () async {
      final viewModel = InventoryViewModel(
        getProductsQuery: getProductsQuery,
        getProductDetailQuery: getProductDetailQuery,
        createProductCommand: createProductCommand,
        registerBatchCommand: registerBatchCommand,
      );

      await viewModel.loadProducts('b-01-smp');
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.products.length, equals(3));
      expect(viewModel.lowStockCount, equals(1));
      expect(viewModel.outOfStockCount, equals(1));

      // Category filter
      await viewModel.selectCategory('LUBRICANTES', 'b-01-smp');
      expect(viewModel.products.length, equals(1));
      expect(viewModel.selectedCategory, equals('LUBRICANTES'));

      // Search (reset category to TODOS)
      await viewModel.selectCategory('TODOS', 'b-01-smp');
      await viewModel.search('Bosch', 'b-01-smp');
      expect(viewModel.products.length, equals(1));
      expect(viewModel.products.first.name, contains('Bosch'));
    });
  });
}
