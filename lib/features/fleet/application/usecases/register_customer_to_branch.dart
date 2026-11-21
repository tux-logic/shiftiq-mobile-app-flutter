import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/fleet_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/repositories/fleet_repository.dart';

/// Use case linking a customer profile to a physical workshop branch.
class RegisterCustomerToBranchUseCase {
  final FleetRepository repository;

  RegisterCustomerToBranchUseCase({required this.repository});

  Future<CustomerRegistration> execute({
    required String branchId,
    required String customerId,
  }) {
    return repository.registerCustomerToBranch(
      branchId: branchId,
      customerId: customerId,
    );
  }
}
