import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/fleet_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/repositories/fleet_repository.dart';

/// Use case querying customer branch registrations and customer directories.
class GetCustomerRegistrationsUseCase {
  final FleetRepository repository;

  GetCustomerRegistrationsUseCase({
    FleetRepository? repository,
    FleetRepository? appointmentRepository,
  }) : repository = (repository ?? appointmentRepository)!;

  Future<List<CustomerRegistration>> execute({
    String? branchId,
    String? status,
    String? customerId,
    String? searchQuery,
  }) async {
    final results = await repository.getCustomerRegistrations(
      branchId: branchId,
      status: status,
      customerId: customerId,
    );

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      return results.where((c) {
        return c.customerName.toLowerCase().contains(q) ||
            c.vehiclePlate.toLowerCase().contains(q) ||
            c.phone.contains(q);
      }).toList();
    }

    return results;
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
