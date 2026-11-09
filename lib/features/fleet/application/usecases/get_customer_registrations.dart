import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/fleet_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/repositories/fleet_repository.dart';

/// Use case querying customer branch registrations and customer directories.
class GetCustomerRegistrationsUseCase {
  final FleetRepository repository;

  GetCustomerRegistrationsUseCase({required this.repository});

  Future<List<CustomerRegistration>> execute({
    String? branchId,
    String? status,
    String? customerId,
  }) {
    return repository.getCustomerRegistrations(
      branchId: branchId,
      status: status,
      customerId: customerId,
    );
  }

  Future<CustomerRegistration> getById(String registrationId) {
    return repository.getCustomerRegistrationById(registrationId);
  }

  /// Convenience directory lookup by branch ID.
  Future<List<CustomerRegistration>> getDirectory(String branchId) {
    return repository.getCustomerDirectory(branchId);
  }
}

/// Backward compatibility alias.
typedef GetCustomerDirectoryQueryService = GetCustomerRegistrationsUseCase;
