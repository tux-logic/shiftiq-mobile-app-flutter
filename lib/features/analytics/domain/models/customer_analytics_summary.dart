/// Summary of an upcoming scheduled appointment for a customer.
class CustomerUpcomingAppointment {
  final String appointmentId;
  final String branchId;
  final String vehicleId;
  final DateTime? scheduledStart;
  final String status;

  const CustomerUpcomingAppointment({
    required this.appointmentId,
    required this.branchId,
    required this.vehicleId,
    this.scheduledStart,
    required this.status,
  });
}

/// Summary of an active work order for a customer.
class CustomerActiveWorkOrder {
  final String workOrderId;
  final String branchId;
  final String vehicleId;
  final int internalNumber;
  final String status;

  const CustomerActiveWorkOrder({
    required this.workOrderId,
    required this.branchId,
    required this.vehicleId,
    required this.internalNumber,
    required this.status,
  });
}

/// Summary of a pending quote for a customer.
class CustomerPendingQuote {
  final String quoteId;
  final String workOrderId;
  final String branchId;
  final double totalAmount;
  final String status;

  const CustomerPendingQuote({
    required this.quoteId,
    required this.workOrderId,
    required this.branchId,
    required this.totalAmount,
    required this.status,
  });
}

/// Domain entity for `GET /api/v1/analytics/me/customer-summary`.
class CustomerAnalyticsSummary {
  final String customerId;
  final int activeVehiclesCount;
  final int activeDtcAlertsCount;
  final int upcomingAppointmentsCount;
  final int activeWorkOrdersCount;
  final int pendingQuotesCount;
  final List<CustomerUpcomingAppointment> upcomingAppointments;
  final List<CustomerActiveWorkOrder> activeWorkOrders;
  final List<CustomerPendingQuote> pendingQuotes;

  const CustomerAnalyticsSummary({
    required this.customerId,
    required this.activeVehiclesCount,
    required this.activeDtcAlertsCount,
    required this.upcomingAppointmentsCount,
    required this.activeWorkOrdersCount,
    required this.pendingQuotesCount,
    this.upcomingAppointments = const [],
    this.activeWorkOrders = const [],
    this.pendingQuotes = const [],
  });
}
