/// Aggregate root representing consolidated multi-branch network analytics for platform owners and admins.
class NetworkAnalyticsSummary {
  final int totalActiveBranchesCount;
  final double totalNetworkRevenue;
  final int totalNetworkCompletedWorkOrders;
  final int totalNetworkAppointments;
  final int totalNetworkDtcAlerts;

  const NetworkAnalyticsSummary({
    required this.totalActiveBranchesCount,
    required this.totalNetworkRevenue,
    required this.totalNetworkCompletedWorkOrders,
    required this.totalNetworkAppointments,
    required this.totalNetworkDtcAlerts,
  });

  String get formattedNetworkRevenue =>
      'S/ ${totalNetworkRevenue.toStringAsFixed(2)}';

  NetworkAnalyticsSummary copyWith({
    int? totalActiveBranchesCount,
    double? totalNetworkRevenue,
    int? totalNetworkCompletedWorkOrders,
    int? totalNetworkAppointments,
    int? totalNetworkDtcAlerts,
  }) {
    return NetworkAnalyticsSummary(
      totalActiveBranchesCount:
          totalActiveBranchesCount ?? this.totalActiveBranchesCount,
      totalNetworkRevenue: totalNetworkRevenue ?? this.totalNetworkRevenue,
      totalNetworkCompletedWorkOrders: totalNetworkCompletedWorkOrders ??
          this.totalNetworkCompletedWorkOrders,
      totalNetworkAppointments:
          totalNetworkAppointments ?? this.totalNetworkAppointments,
      totalNetworkDtcAlerts:
          totalNetworkDtcAlerts ?? this.totalNetworkDtcAlerts,
    );
  }
}
