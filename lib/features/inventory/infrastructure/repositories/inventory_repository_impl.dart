import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/model/aggregates/product.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/model/entities/product_batch.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/model/valueobjects/stock_status.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/infrastructure/remote/inventory_api.dart';

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
        description: 'Lubricante 100% sintético para motores gasolina y diésel ligero con tecnología Fluid TITANIUM',
        category: 'LUBRICANTES',
        unitOfMeasure: 'GALON',
        unitPrice: 165.00,
        costPrice: 110.00,
        currentStock: 28,
        minimumStock: 8,
        createdAt: now.subtract(const Duration(days: 30)),
        batches: [
          ProductBatch(
            id: 'batch-01-1',
            batchNumber: 'LOT-CASTROL-2026-08',
            productId: 'prod-01',
            supplierName: 'Castrol Perú S.A.C.',
            quantityReceived: 30,
            quantityRemaining: 18,
            costPrice: 110.00,
            receptionDate: now.subtract(const Duration(days: 20)),
          ),
          ProductBatch(
            id: 'batch-01-2',
            batchNumber: 'LOT-CASTROL-2026-11',
            productId: 'prod-01',
            supplierName: 'Castrol Perú S.A.C.',
            quantityReceived: 10,
            quantityRemaining: 10,
            costPrice: 110.00,
            receptionDate: now.subtract(const Duration(days: 5)),
          ),
        ],
      ),
      Product(
        id: 'prod-02',
        branchId: 'b-01-smp',
        sku: 'FLT-OIL-P3300',
        name: 'Filtro de Aceite Bosch P3300',
        description: 'Filtro blindado de alta eficiencia para línea Toyota Yaris, Hilux y Nissan Sentra',
        category: 'FILTROS',
        unitOfMeasure: 'UND',
        unitPrice: 38.00,
        costPrice: 20.00,
        currentStock: 4, // LOW STOCK
        minimumStock: 10,
        createdAt: now.subtract(const Duration(days: 25)),
        batches: [
          ProductBatch(
            id: 'batch-02-1',
            batchNumber: 'LOT-BOSCH-8842',
            productId: 'prod-02',
            supplierName: 'Bosch Autopartes Lima S.A.',
            quantityReceived: 25,
            quantityRemaining: 4,
            costPrice: 20.00,
            receptionDate: now.subtract(const Duration(days: 18)),
          ),
        ],
      ),
      Product(
        id: 'prod-03',
        branchId: 'b-01-smp',
        sku: 'BRK-PAD-FRD90',
        name: 'Pastillas de Freno Delanteras Ferodo Racing',
        description: 'Juego de pastillas cerámicas delanteras con láminas anti-ruido para Toyota Hilux y SW4',
        category: 'FRENOS',
        unitOfMeasure: 'JUEGO',
        unitPrice: 175.00,
        costPrice: 105.00,
        currentStock: 12,
        minimumStock: 4,
        createdAt: now.subtract(const Duration(days: 40)),
        batches: [
          ProductBatch(
            id: 'batch-03-1',
            batchNumber: 'LOT-FERODO-401',
            productId: 'prod-03',
            supplierName: 'Frenos y Repuestos Lima S.A.C.',
            quantityReceived: 15,
            quantityRemaining: 12,
            costPrice: 105.00,
            receptionDate: now.subtract(const Duration(days: 12)),
          ),
        ],
      ),
      Product(
        id: 'prod-04',
        branchId: 'b-01-smp',
        sku: 'BRK-DOT4-500',
        name: 'Líquido de Frenos DOT 4 Bosch 500ml',
        description: 'Fluido sintético de frenos para sistemas con ABS y ESP. Punto de ebullición húmedo 165°C',
        category: 'FRENOS',
        unitOfMeasure: 'BOTELLA',
        unitPrice: 34.00,
        costPrice: 18.00,
        currentStock: 2, // LOW STOCK
        minimumStock: 6,
        createdAt: now.subtract(const Duration(days: 15)),
        batches: [
          ProductBatch(
            id: 'batch-04-1',
            batchNumber: 'LOT-BOSCH-DOT4-99',
            productId: 'prod-04',
            supplierName: 'Bosch Autopartes Lima S.A.',
            quantityReceived: 20,
            quantityRemaining: 2,
            costPrice: 18.00,
            receptionDate: now.subtract(const Duration(days: 14)),
          ),
        ],
      ),
      Product(
        id: 'prod-05',
        branchId: 'b-01-smp',
        sku: 'SUS-AMR-MNR77',
        name: 'Amortiguador Delantero Monroe Gas-Magnum',
        description: 'Amortiguador bitubo de gas presurizado para eje delantero camionetas 4x4',
        category: 'SUSPENSION',
        unitOfMeasure: 'PAR',
        unitPrice: 380.00,
        costPrice: 240.00,
        currentStock: 0, // OUT OF STOCK
        minimumStock: 2,
        createdAt: now.subtract(const Duration(days: 60)),
        batches: [],
      ),
      Product(
        id: 'prod-06',
        branchId: 'b-01-smp',
        sku: 'SPK-NGK-IRID',
        name: 'Bujía de Iridio NGK Laser LFR6AIX-11',
        description: 'Bujía de alta conductividad térmica con electrodo central de iridio fino de 0.6 mm',
        category: 'MOTOR',
        unitOfMeasure: 'UND',
        unitPrice: 48.00,
        costPrice: 26.00,
        currentStock: 24,
        minimumStock: 8,
        createdAt: now.subtract(const Duration(days: 20)),
        batches: [
          ProductBatch(
            id: 'batch-06-1',
            batchNumber: 'LOT-NGK-2026-X',
            productId: 'prod-06',
            supplierName: 'Importadora Automotriz San Jacinto',
            quantityReceived: 30,
            quantityRemaining: 24,
            costPrice: 26.00,
            receptionDate: now.subtract(const Duration(days: 10)),
          ),
        ],
      ),
    ]);
  }

  @override
  Future<List<Product>> getProducts({
    required String branchId,
    String? category,
    String? query,
    StockStatus? status,
  }) async {
    try {
      final remoteDtos = await inventoryApi.getProducts(
        branchId: branchId,
        category: category,
        query: query,
      );
      if (remoteDtos.isNotEmpty) {
        var list = remoteDtos.map((dto) => dto.toDomain()).toList();
        if (status != null) {
          list = list.where((p) => p.status == status).toList();
        }
        return list;
      }
    } catch (_) {
      // Local fallback
    }

    var list = _localProducts
        .where((p) => p.branchId == branchId || branchId.isEmpty)
        .toList();

    if (category != null && category.isNotEmpty && category != 'TODOS') {
      list = list.where((p) => p.category.toUpperCase() == category.toUpperCase()).toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.sku.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q);
      }).toList();
    }

    if (status != null) {
      list = list.where((p) => p.status == status).toList();
    }

    return list;
  }

  @override
  Future<Product> getProductById(String id) async {
    try {
      final dto = await inventoryApi.getProductById(id);
      return dto.toDomain();
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
    required double unitPrice,
    required double costPrice,
    required int initialStock,
    int minimumStock = 5,
    String unitOfMeasure = 'UND',
    String description = '',
  }) async {
    try {
      final dto = await inventoryApi.createProduct(
        branchId: branchId,
        sku: sku,
        name: name,
        category: category,
        unitPrice: unitPrice,
        costPrice: costPrice,
        initialStock: initialStock,
        minimumStock: minimumStock,
        unitOfMeasure: unitOfMeasure,
        description: description,
      );
      final product = dto.toDomain();
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
      unitPrice: unitPrice,
      costPrice: costPrice,
      currentStock: initialStock,
      minimumStock: minimumStock,
      unitOfMeasure: unitOfMeasure.toUpperCase().trim(),
      description: description.trim(),
      createdAt: DateTime.now(),
      batches: initialStock > 0
          ? [
              ProductBatch(
                id: 'batch-${DateTime.now().millisecondsSinceEpoch}',
                batchNumber: 'LOT-INI-${DateTime.now().month}${DateTime.now().day}',
                productId: 'prod-${DateTime.now().millisecondsSinceEpoch}',
                supplierName: 'Inventario Inicial',
                quantityReceived: initialStock,
                quantityRemaining: initialStock,
                costPrice: costPrice,
                receptionDate: DateTime.now(),
              ),
            ]
          : [],
    );

    _localProducts.add(newProduct);
    return newProduct;
  }

  @override
  Future<ProductBatch> registerBatch({
    required String branchId,
    required String productId,
    required String batchNumber,
    required String supplierName,
    required int quantity,
    required double costPrice,
    DateTime? expirationDate,
  }) async {
    try {
      final dto = await inventoryApi.registerBatch(
        branchId: branchId,
        productId: productId,
        batchNumber: batchNumber,
        supplierName: supplierName,
        quantity: quantity,
        costPrice: costPrice,
        expirationDate: expirationDate,
      );
      final batch = dto.toDomain();
      _updateLocalStockWithBatch(productId, batch);
      return batch;
    } catch (_) {
      // Local fallback
    }

    final newBatch = ProductBatch(
      id: 'batch-${DateTime.now().millisecondsSinceEpoch}',
      batchNumber: batchNumber.toUpperCase().trim(),
      productId: productId,
      supplierName: supplierName.trim(),
      quantityReceived: quantity,
      quantityRemaining: quantity,
      costPrice: costPrice,
      receptionDate: DateTime.now(),
      expirationDate: expirationDate,
    );

    _updateLocalStockWithBatch(productId, newBatch);
    return newBatch;
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
    final products = await getProducts(branchId: branchId);
    return products.where((p) => p.isLowStock || p.isOutOfStock).toList();
  }
}
