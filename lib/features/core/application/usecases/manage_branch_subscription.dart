import 'package:shiftiq_mobile_app_flutter/features/core/domain/core_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/repositories/core_repository.dart';

/// Use case managing subscription plan assignments for physical branches.
class ManageBranchSubscriptionUseCase {
  final CoreRepository repository;

  ManageBranchSubscriptionUseCase({required this.repository});

  Future<BranchSubscription> assign({
    required String branchId,
    required String planId,
    required String billingCycle,
    required String cardNumber,
    required String cardHolderName,
    required String expirationDate,
    required String cvv,
  }) {
    return repository.assignBranchSubscription(
      branchId: branchId,
      planId: planId,
      billingCycle: billingCycle,
      cardNumber: cardNumber,
      cardHolderName: cardHolderName,
      expirationDate: expirationDate,
      cvv: cvv,
    );
  }

  Future<void> cancel(String branchId) {
    return repository.cancelBranchSubscription(branchId);
  }
}
