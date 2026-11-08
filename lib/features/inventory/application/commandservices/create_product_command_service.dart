import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/model/aggregates/product.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/repositories/inventory_repository.dart';

class CreateProductCommand {
  final String branchId;
  final String sku;
  final String name;
  final String category;
  final double unitPrice;
  final double costPrice;
  final int initialStock;
  final int minimumStock;
  final String unitOfMeasure;
  final String description;

  const CreateProductCommand({
    required this.branchId,
    required this.sku,
    required this.name,
    required this.category,
    required this.unitPrice,
    required this.costPrice,
    required this.initialStock,
    this.minimumStock = 5,
    this.unitOfMeasure = 'UND',
    this.description = '',
  });
}

class CreateProductCommandService {
  final InventoryRepository inventoryRepository;

  const CreateProductCommandService({
    required this.inventoryRepository,
  });

  Future<Product> execute(CreateProductCommand command) async {
    if (command.sku.trim().isEmpty) {
      throw ArgumentError('El código SKU es obligatorio.');
    }
    if (command.name.trim().isEmpty) {
      throw ArgumentError('El nombre del repuesto es obligatorio.');
    }
    if (command.unitPrice <= 0) {
      throw ArgumentError('El precio de venta debe ser mayor a cero.');
    }
    if (command.costPrice < 0) {
      throw ArgumentError('El costo de compra no puede ser negativo.');
    }

    return inventoryRepository.createProduct(
      branchId: command.branchId,
      sku: command.sku.trim().toUpperCase(),
      name: command.name.trim(),
      category: command.category.trim().toUpperCase(),
      unitPrice: command.unitPrice,
      costPrice: command.costPrice,
      initialStock: command.initialStock,
      minimumStock: command.minimumStock,
      unitOfMeasure: command.unitOfMeasure.trim().toUpperCase(),
      description: command.description.trim(),
    );
  }
}
