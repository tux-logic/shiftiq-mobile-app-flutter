/// Global API configuration and endpoint paths for ShiftIQ Platform
class ApiConstants {
  ApiConstants._();

  /// Production Base URL deployed on Render
  static const String baseUrl = 'https://shiftiq-platform.onrender.com';

  /// Timeout duration for HTTP requests (15 seconds)
  static const Duration requestTimeout = Duration(seconds: 15);

  // IAM Context
  static const String authSessions = '/api/v1/authentication/sessions';
  static const String authRefresh = '/api/v1/authentication/sessions/refresh';
  static const String passwordRecoveries = '/api/v1/authentication/password-recoveries';
  static const String users = '/api/v1/users';

  // Core Context
  static const String owners = '/api/v1/owners';
  static const String workshops = '/api/v1/workshops';
  static String workshopBranches(String workshopId) => '/api/v1/workshops/$workshopId/branches';
  static String branchEmployees(String branchId) => '/api/v1/branches/$branchId/employees';

  // Analytics Context
  static String branchAnalyticsSummary(String branchId) =>
      '/api/v1/analytics/branches/$branchId/summary';
  static String branchAnalyticsFinancial(String branchId) =>
      '/api/v1/analytics/branches/$branchId/financial';

  // Operations Context
  static const String workOrders = '/api/v1/work-orders';
  static String workOrderDetails(String id) => '/api/v1/work-orders/$id';
  static String workOrderTasks(String id) => '/api/v1/work-orders/$id/tasks';
  static String workOrderTaskStatus(String taskId) => '/api/v1/work-order-tasks/$taskId/status';
  static String workOrderTaskProducts(String taskId) =>
      '/api/v1/work-order-tasks/$taskId/products';
  static String completeWorkOrder(String id) => '/api/v1/work-orders/$id/complete';

  // Fleet Context
  static String branchAppointments(String branchId) => '/api/v1/branches/$branchId/appointments';
  static const String appointments = '/api/v1/appointments';
  static String appointmentStatus(String id) => '/api/v1/appointments/$id/status';
  static String branchCustomerRegistrations(String branchId) =>
      '/api/v1/branches/$branchId/customer-registrations';

  // Inventory Context
  static String branchProducts(String branchId) => '/api/v1/branches/$branchId/products';
  static String productBatches(String productId) => '/api/v1/products/$productId/batches';

  // IoT Context
  static const String vehicles = '/api/v1/vehicles';
  static String vehicleDtcAlerts(String vehicleId) => '/api/v1/vehicles/$vehicleId/dtc-alerts';
  static String vehicleTelemetrySnapshots(String vehicleId) =>
      '/api/v1/vehicles/$vehicleId/telemetry-snapshots';
  static const String obd2DeviceRegistrations = '/api/v1/obd2-device-registrations';

  // Billing Context
  static const String quotes = '/api/v1/quotes';
  static const String vouchers = '/api/v1/vouchers';
  static const String checkouts = '/api/v1/checkouts';

  // Shared
  static const String health = '/api/v1/health';
}
