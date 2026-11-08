import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/model/entities/product_batch.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/repositories/inventory_repository.dart';

class RegisterBatchCommand {
  final String branchId;
  final String productId;
  final String batchNumber;
  final String supplierName;
  final int quantity;
  final double costPrice;
  final DateTime? expirationDate;

  const RegisterBatchCommand({
    required this.branchId,
    required this.productId,
    required this.batchNumber,
    required this.supplierName,
    required this.quantity,
    required this.costPrice,
    this.expirationDate,
  });
}

class RegisterBatchCommandService {
  final InventoryRepository inventoryRepository;

  const RegisterBatchCommandService({
    required this.inventoryRepository,
  });

  Future<ProductBatch> execute(RegisterBatchCommand command) async {
    if (command.productId.trim().isEmpty) {
      throw ArgumentError('El ID del repuesto es obligatorio.');
    }
    if (command.batchNumber.trim().isEmpty) {
      throw ArgumentError('El número de lote es obligatorio.');
    }
    if (command.quantity <= 0) {
      throw ArgumentError('La cantidad del lote debe ser mayor a cero.');
    }
    if (command.costPrice < 0) {
      throw ArgumentError('El costo unitario no puede ser negativo.');
    }

    return inventoryRepository.registerBatch(
      branchId: command.branchId,
      productId: command.productId,
      batchNumber: command.batchNumber.trim().toUpperCase(),
      supplierName: command.supplierName.trim(),
      quantity: command.quantity,
      costPrice: command.costPrice,
      expirationDate: command.expirationDate,
    );
  }
}
