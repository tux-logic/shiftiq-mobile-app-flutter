/// Global API configuration and endpoint paths for ShiftIQ Platform
class ApiConstants {
  ApiConstants._();

  /// Production Base URL deployed on Render
  static const String baseUrl = 'https://shiftiq-platform.onrender.com';

  /// Timeout duration for HTTP requests (15 seconds)
  static const Duration requestTimeout = Duration(seconds: 15);

  // IAM Context
  static const String authSessions = '/api/v1/authentication/sessions';
  static const String authLogin = '/api/v1/authentication/login';
  static const String authGoogle = '/api/v1/authentication/sessions/google';
  static const String authRefresh = '/api/v1/authentication/sessions/refresh';
  static const String passwordRecoveries =
      '/api/v1/authentication/password-recoveries';
  static const String passwordResets =
      '/api/v1/authentication/password-resets';
  static const String otpSend = '/api/v1/authentication/otp/send';
  static const String otpVerify = '/api/v1/authentication/otp/verify';
  static const String users = '/api/v1/users';
  static String userById(String userId) => '/api/v1/users/$userId';
  static String userEmail(String userId) => '/api/v1/users/$userId/email';
  static String userPassword(String userId) =>
      '/api/v1/users/$userId/password';
  static const String profilesMe = '/api/v1/profiles/me';

  // Core Context
  static const String owners = '/api/v1/owners';
  static String ownerById(String id) => '/api/v1/owners/$id';
  static String ownerByUserId(String userId) => '/api/v1/owners?userId=$userId';
  static const String employees = '/api/v1/employees';
  static String employeeById(String id) => '/api/v1/employees/$id';
  static String employeeByUserId(String userId) =>
      '/api/v1/employees?userId=$userId';
  static const String customers = '/api/v1/customers';
  static String customerById(String id) => '/api/v1/customers/$id';
  static String customerByUserId(String userId) =>
      '/api/v1/customers?userId=$userId';
  static const String profiles = '/api/v1/profiles';
  static const String profilesMe = '/api/v1/profiles/me';
  static String profileRoles(String userId) =>
      '/api/v1/profiles/roles?userId=$userId';
  static String profileByDocument(String documentNumber) =>
      '/api/v1/profiles?documentNumber=$documentNumber';
  static const String workshops = '/api/v1/workshops';
  static String workshopById(String id) => '/api/v1/workshops/$id';
  static String ownerWorkshops(String ownerId) =>
      '/api/v1/workshops?ownerId=$ownerId';
  static String workshopSpecialties(String workshopId) =>
      '/api/v1/workshops/$workshopId/specialties';
  static String workshopSpecialtyById(String workshopId, String specialtyId) =>
      '/api/v1/workshops/$workshopId/specialties/$specialtyId';
  static String workshopSpecialtyHistory(
    String workshopId,
    String specialtyId,
  ) =>
      '/api/v1/workshops/$workshopId/specialties/$specialtyId/history';
  static const String branches = '/api/v1/branches';
  static String branchById(String id) => '/api/v1/branches/$id';
  static String workshopBranches(String workshopId) =>
      '/api/v1/branches?workshopId=$workshopId';
  static String branchesByWorkshop(String workshopId) =>
      '/api/v1/branches?workshopId=$workshopId';
  static String branchSubscriptions(String branchId) =>
      '/api/v1/branches/$branchId/subscriptions';
  static String branchSubscription(String branchId) =>
      '/api/v1/branches/$branchId/subscription';
  static String branchEmployees(String branchId) =>
      '/api/v1/branches/$branchId/employees';

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
  static const String appointments = '/api/v1/appointments';
  static String appointmentById(String id) => '/api/v1/appointments/$id';
  static String appointmentStatus(String id) =>
      '/api/v1/appointments/$id/status';
  static String branchAppointments(String branchId) =>
      '/api/v1/branches/$branchId/appointments';
  static const String customerRegistrations =
      '/api/v1/customer-registrations';
  static String customerRegistrationById(String id) =>
      '/api/v1/customer-registrations/$id';
  static String branchCustomerRegistrations(String branchId) =>
      '/api/v1/branches/$branchId/customer-registrations';
  static const String employeeRegistrations =
      '/api/v1/employee-registrations';
  static const String employeeRegistrationRequestJoin =
      '/api/v1/employee-registrations/request-join';
  static String employeeRegistrationApprove(String id) =>
      '/api/v1/employee-registrations/$id/approve';
  static String employeeRegistrationReject(String id) =>
      '/api/v1/employee-registrations/$id/reject';

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

