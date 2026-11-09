/// Domain Entity representing a subscription plan assigned to a branch.
class BranchSubscription {
  final String id;
  final String branchId;
  final String planId;
  final String billingCycle;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;

  const BranchSubscription({
    required this.id,
    required this.branchId,
    required this.planId,
    required this.billingCycle,
    required this.status,
    this.startDate,
    this.endDate,
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';
}
