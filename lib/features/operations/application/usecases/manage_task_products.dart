import 'package:shiftiq_mobile_app_flutter/features/operations/domain/operations_domain.dart';

/// Application use case to attach, update, and remove spare parts from repair tasks with immediate FIFO stock reservations.
class ManageTaskProducts {
  final OperationsRepository repository;

  const ManageTaskProducts({required this.repository});

  /// Attaches a product to a repair task, creating an immediate stock reservation in branch inventory.
  Future<WorkOrder> addProductToTask({
    required String taskId,
    required String productId,
    required int quantity,
  }) async {
    final trimmedTaskId = taskId.trim();
    final trimmedProductId = productId.trim();

    if (trimmedTaskId.isEmpty) {
      throw ArgumentError('Task ID cannot be empty.');
    }
    if (trimmedProductId.isEmpty) {
      throw ArgumentError('Product ID cannot be empty.');
    }
    if (quantity <= 0) {
      throw ArgumentError('Product quantity must be greater than zero.');
    }

    return repository.addProductToTask(
      taskId: trimmedTaskId,
      productId: trimmedProductId,
      quantity: quantity,
    );
  }

  /// Updates quantity of an attached replacement part, adjusting branch stock reservations.
  Future<WorkOrder> updateProductQuantity({
    required String taskId,
    required String productId,
    required int quantity,
  }) async {
    final trimmedTaskId = taskId.trim();
    final trimmedProductId = productId.trim();

    if (trimmedTaskId.isEmpty) {
      throw ArgumentError('Task ID cannot be empty.');
    }
    if (trimmedProductId.isEmpty) {
      throw ArgumentError('Product ID cannot be empty.');
    }
    if (quantity <= 0) {
      throw ArgumentError('Product quantity must be greater than zero.');
    }

    return repository.updateTaskProductQuantity(
      taskId: trimmedTaskId,
      productId: trimmedProductId,
      quantity: quantity,
    );
  }

  /// Removes product from repair task and releases reserved stock back to inventory batches.
  Future<void> removeProductFromTask({
    required String taskId,
    required String productId,
  }) async {
    final trimmedTaskId = taskId.trim();
    final trimmedProductId = productId.trim();

    if (trimmedTaskId.isEmpty) {
      throw ArgumentError('Task ID cannot be empty.');
    }
    if (trimmedProductId.isEmpty) {
      throw ArgumentError('Product ID cannot be empty.');
    }

    return repository.removeProductFromTask(
      taskId: trimmedTaskId,
      productId: trimmedProductId,
    );
  }
}
