import 'package:shiftiq_mobile_app_flutter/features/iot/domain/iot_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/repositories/iot_repository.dart';

/// Application use case to retrieve all vehicles associated with a customer.
class GetCustomerVehicles {
  final IotRepository repository;

  const GetCustomerVehicles({required this.repository});

  /// Executes vehicle query for a specified customer ID.
  Future<List<Vehicle>> execute(String customerId) async {
    final trimmedCustomerId = customerId.trim();
    if (trimmedCustomerId.isEmpty) {
      throw ArgumentError('Customer ID cannot be empty.');
    }

    return repository.getCustomerVehicles(trimmedCustomerId);
  }
}
