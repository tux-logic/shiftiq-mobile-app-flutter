import 'package:get_it/get_it.dart';
import 'package:shiftiq_mobile_app_flutter/core/app_database.dart';
import 'package:shiftiq_mobile_app_flutter/core/domain/event/domain_event_bus.dart';
import 'package:shiftiq_mobile_app_flutter/core/infrastructure/event/stream_domain_event_bus.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/application/usecases/get_user_profile.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/application/usecases/login_with_google.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/application/usecases/login_with_password.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/application/usecases/logout.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/application/usecases/otp_verification.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/application/usecases/password_recovery.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/application/usecases/refresh_token.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/application/usecases/sign_up_user.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/application/usecases/update_user_credentials.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/domain/auth_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/infrastructure/auth_repository_impl.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/infrastructure/remote/auth_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/infrastructure/remote/user_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/presentation/login_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/branch/application/get_user_branches_use_case.dart';
import 'package:shiftiq_mobile_app_flutter/features/branch/application/select_active_branch_use_case.dart';
import 'package:shiftiq_mobile_app_flutter/features/branch/domain/branch_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/branch/infrastructure/branch_repository_impl.dart';
import 'package:shiftiq_mobile_app_flutter/features/branch/infrastructure/remote/branch_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/branch/presentation/branch_selection_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/dashboard/application/get_branch_summary_use_case.dart';
import 'package:shiftiq_mobile_app_flutter/features/dashboard/domain/analytics_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/dashboard/infrastructure/analytics_repository_impl.dart';
import 'package:shiftiq_mobile_app_flutter/features/dashboard/infrastructure/remote/analytics_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/dashboard/presentation/dashboard_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/application/add_task_to_work_order_use_case.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/application/create_work_order_use_case.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/application/finalize_operations_use_cases.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/application/get_work_order_detail_use_case.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/application/get_work_orders_use_case.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/application/manage_task_status_use_cases.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/work_order_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/infrastructure/remote/work_order_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/infrastructure/work_order_repository_impl.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/work_order_detail_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/work_orders_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/application/commandservices/create_appointment_command_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/application/commandservices/update_appointment_status_command_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/application/queryservices/get_appointments_by_branch_query_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/application/queryservices/get_customer_directory_query_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/repositories/appointment_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/infrastructure/remote/appointment_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/infrastructure/repositories/appointment_repository_impl.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/presentation/controllers/appointments_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/application/commandservices/create_product_command_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/application/commandservices/register_batch_command_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/application/queryservices/get_low_stock_alerts_query_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/application/queryservices/get_product_detail_query_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/application/queryservices/get_products_by_branch_query_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/infrastructure/remote/inventory_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/infrastructure/repositories/inventory_repository_impl.dart';
import 'package:shiftiq_mobile_app_flutter/features/inventory/presentation/controllers/inventory_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/application/commandservices/update_dtc_status_command_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/application/queryservices/get_dtc_alerts_query_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/application/queryservices/get_dtc_detail_query_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/application/queryservices/get_live_sensor_stream_query_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/repositories/telemetry_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/infrastructure/remote/telemetry_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/infrastructure/repositories/telemetry_repository_impl.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/presentation/controllers/telemetry_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/application/commandservices/create_quote_command_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/application/commandservices/emit_voucher_command_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/application/commandservices/process_payment_command_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/application/queryservices/get_quotes_query_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/application/queryservices/get_voucher_detail_query_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/application/queryservices/get_vouchers_by_branch_query_service.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/domain/repositories/billing_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/infrastructure/remote/billing_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/infrastructure/repositories/billing_repository_impl.dart';
import 'package:shiftiq_mobile_app_flutter/features/billing/presentation/controllers/billing_view_model.dart';

final getIt = GetIt.instance;

/// Global Dependency Injection registry following easyrecipe architecture
void setupDependencies() {
  // 1. Core Singletons
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  getIt.registerLazySingleton<SessionStorage>(
    () => SessionStorage(appDatabase: getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<DomainEventBus>(() => StreamDomainEventBus());

  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(
      sessionStorage: getIt<SessionStorage>(),
      eventBus: getIt<DomainEventBus>(),
    ),
  );

  // 2. IAM Context (Authentication & User Management)
  getIt.registerLazySingleton<AuthApi>(
    () => AuthApi(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<UserApi>(
    () => UserApi(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authApi: getIt<AuthApi>(),
      userApi: getIt<UserApi>(),
      sessionStorage: getIt<SessionStorage>(),
      eventBus: getIt<DomainEventBus>(),
    ),
  );

  getIt.registerLazySingleton<LoginWithPasswordUseCase>(
    () => LoginWithPasswordUseCase(repository: getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<LoginWithGoogleUseCase>(
    () => LoginWithGoogleUseCase(repository: getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<RefreshTokenUseCase>(
    () => RefreshTokenUseCase(repository: getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(repository: getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<RequestPasswordRecoveryUseCase>(
    () => RequestPasswordRecoveryUseCase(repository: getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<ResetPasswordUseCase>(
    () => ResetPasswordUseCase(repository: getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<SendOtpUseCase>(
    () => SendOtpUseCase(repository: getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<VerifyOtpUseCase>(
    () => VerifyOtpUseCase(repository: getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<SignUpUserUseCase>(
    () => SignUpUserUseCase(repository: getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<GetUserProfileUseCase>(
    () => GetUserProfileUseCase(repository: getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<UpdateUserEmailUseCase>(
    () => UpdateUserEmailUseCase(repository: getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<UpdateUserPasswordUseCase>(
    () => UpdateUserPasswordUseCase(repository: getIt<AuthRepository>()),
  );

  getIt.registerFactory<LoginViewModel>(
    () => LoginViewModel(loginUseCase: getIt<LoginWithPasswordUseCase>()),
  );

  // 3. Core Context (Workshops & Branches)
  getIt.registerLazySingleton<BranchApi>(
    () => BranchApi(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<BranchRepository>(
    () => BranchRepositoryImpl(
      branchApi: getIt<BranchApi>(),
      sessionStorage: getIt<SessionStorage>(),
    ),
  );

  getIt.registerLazySingleton<GetUserBranchesUseCase>(
    () => GetUserBranchesUseCase(repository: getIt<BranchRepository>()),
  );

  getIt.registerLazySingleton<SelectActiveBranchUseCase>(
    () => SelectActiveBranchUseCase(repository: getIt<BranchRepository>()),
  );

  getIt.registerFactory<BranchSelectionViewModel>(
    () => BranchSelectionViewModel(
      getUserBranchesUseCase: getIt<GetUserBranchesUseCase>(),
      selectActiveBranchUseCase: getIt<SelectActiveBranchUseCase>(),
    ),
  );

  // 4. Analytics Context (KPIs & Executive Dashboard)
  getIt.registerLazySingleton<AnalyticsApi>(
    () => AnalyticsApi(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(analyticsApi: getIt<AnalyticsApi>()),
  );

  getIt.registerLazySingleton<GetBranchSummaryUseCase>(
    () => GetBranchSummaryUseCase(repository: getIt<AnalyticsRepository>()),
  );

  getIt.registerFactory<DashboardViewModel>(
    () => DashboardViewModel(
      getBranchSummaryUseCase: getIt<GetBranchSummaryUseCase>(),
      sessionStorage: getIt<SessionStorage>(),
    ),
  );

  // 5. Operations Context (Work Orders & Tasks)
  getIt.registerLazySingleton<WorkOrderApi>(
    () => WorkOrderApi(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<WorkOrderRepository>(
    () => WorkOrderRepositoryImpl(workOrderApi: getIt<WorkOrderApi>()),
  );

  getIt.registerLazySingleton<GetWorkOrdersUseCase>(
    () => GetWorkOrdersUseCase(repository: getIt<WorkOrderRepository>()),
  );

  getIt.registerLazySingleton<GetWorkOrderDetailUseCase>(
    () => GetWorkOrderDetailUseCase(repository: getIt<WorkOrderRepository>()),
  );

  getIt.registerLazySingleton<CreateWorkOrderUseCase>(
    () => CreateWorkOrderUseCase(repository: getIt<WorkOrderRepository>()),
  );

  getIt.registerLazySingleton<AddTaskToWorkOrderUseCase>(
    () => AddTaskToWorkOrderUseCase(repository: getIt<WorkOrderRepository>()),
  );

  getIt.registerLazySingleton<StartTaskUseCase>(
    () => StartTaskUseCase(repository: getIt<WorkOrderRepository>()),
  );

  getIt.registerLazySingleton<CompleteTaskUseCase>(
    () => CompleteTaskUseCase(repository: getIt<WorkOrderRepository>()),
  );

  getIt.registerLazySingleton<AddProductToTaskUseCase>(
    () => AddProductToTaskUseCase(repository: getIt<WorkOrderRepository>()),
  );

  getIt.registerLazySingleton<CompleteWorkOrderUseCase>(
    () => CompleteWorkOrderUseCase(repository: getIt<WorkOrderRepository>()),
  );

  getIt.registerFactory<WorkOrdersViewModel>(
    () => WorkOrdersViewModel(
      getWorkOrdersUseCase: getIt<GetWorkOrdersUseCase>(),
      sessionStorage: getIt<SessionStorage>(),
    ),
  );

  getIt.registerFactory<WorkOrderDetailViewModel>(
    () => WorkOrderDetailViewModel(
      getWorkOrderDetailUseCase: getIt<GetWorkOrderDetailUseCase>(),
      startTaskUseCase: getIt<StartTaskUseCase>(),
      completeTaskUseCase: getIt<CompleteTaskUseCase>(),
      addTaskUseCase: getIt<AddTaskToWorkOrderUseCase>(),
      addProductUseCase: getIt<AddProductToTaskUseCase>(),
      completeWorkOrderUseCase: getIt<CompleteWorkOrderUseCase>(),
    ),
  );

  // 6. Fleet & CRM Context (Appointments, Bays & Customer Directory)
  getIt.registerLazySingleton<AppointmentApi>(
    () => AppointmentApi(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<AppointmentRepository>(
    () => AppointmentRepositoryImpl(appointmentApi: getIt<AppointmentApi>()),
  );

  getIt.registerLazySingleton<GetAppointmentsByBranchQueryService>(
    () => GetAppointmentsByBranchQueryService(
      appointmentRepository: getIt<AppointmentRepository>(),
    ),
  );

  getIt.registerLazySingleton<GetCustomerDirectoryQueryService>(
    () => GetCustomerDirectoryQueryService(
      appointmentRepository: getIt<AppointmentRepository>(),
    ),
  );

  getIt.registerLazySingleton<CreateAppointmentCommandService>(
    () => CreateAppointmentCommandService(
      appointmentRepository: getIt<AppointmentRepository>(),
    ),
  );

  getIt.registerLazySingleton<UpdateAppointmentStatusCommandService>(
    () => UpdateAppointmentStatusCommandService(
      appointmentRepository: getIt<AppointmentRepository>(),
    ),
  );

  getIt.registerFactory<AppointmentsViewModel>(
    () => AppointmentsViewModel(
      getAppointmentsQuery: getIt<GetAppointmentsByBranchQueryService>(),
      getCustomerDirectoryQuery: getIt<GetCustomerDirectoryQueryService>(),
      createAppointmentCommand: getIt<CreateAppointmentCommandService>(),
      updateStatusCommand: getIt<UpdateAppointmentStatusCommandService>(),
    ),
  );

  // 7. Inventory Context (Products, Spare Parts & Batch Management)
  getIt.registerLazySingleton<InventoryApi>(
    () => InventoryApi(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<InventoryRepository>(
    () => InventoryRepositoryImpl(inventoryApi: getIt<InventoryApi>()),
  );

  getIt.registerLazySingleton<GetProductsByBranchQueryService>(
    () => GetProductsByBranchQueryService(
      inventoryRepository: getIt<InventoryRepository>(),
    ),
  );

  getIt.registerLazySingleton<GetProductDetailQueryService>(
    () => GetProductDetailQueryService(
      inventoryRepository: getIt<InventoryRepository>(),
    ),
  );

  getIt.registerLazySingleton<GetLowStockAlertsQueryService>(
    () => GetLowStockAlertsQueryService(
      inventoryRepository: getIt<InventoryRepository>(),
    ),
  );

  getIt.registerLazySingleton<CreateProductCommandService>(
    () => CreateProductCommandService(
      inventoryRepository: getIt<InventoryRepository>(),
    ),
  );

  getIt.registerLazySingleton<RegisterBatchCommandService>(
    () => RegisterBatchCommandService(
      inventoryRepository: getIt<InventoryRepository>(),
    ),
  );

  getIt.registerFactory<InventoryViewModel>(
    () => InventoryViewModel(
      getProductsQuery: getIt<GetProductsByBranchQueryService>(),
      getProductDetailQuery: getIt<GetProductDetailQueryService>(),
      createProductCommand: getIt<CreateProductCommandService>(),
      registerBatchCommand: getIt<RegisterBatchCommandService>(),
    ),
  );

  // 8. IoT Telemetry & OBD-II Context
  getIt.registerLazySingleton<TelemetryApi>(
    () => TelemetryApi(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<TelemetryRepository>(
    () => TelemetryRepositoryImpl(telemetryApi: getIt<TelemetryApi>()),
  );

  getIt.registerLazySingleton<GetDtcAlertsQueryService>(
    () => GetDtcAlertsQueryService(
      telemetryRepository: getIt<TelemetryRepository>(),
    ),
  );

  getIt.registerLazySingleton<GetDtcDetailQueryService>(
    () => GetDtcDetailQueryService(
      telemetryRepository: getIt<TelemetryRepository>(),
    ),
  );

  getIt.registerLazySingleton<GetLiveSensorStreamQueryService>(
    () => GetLiveSensorStreamQueryService(
      telemetryRepository: getIt<TelemetryRepository>(),
    ),
  );

  getIt.registerLazySingleton<UpdateDtcStatusCommandService>(
    () => UpdateDtcStatusCommandService(
      telemetryRepository: getIt<TelemetryRepository>(),
    ),
  );

  getIt.registerFactory<TelemetryViewModel>(
    () => TelemetryViewModel(
      getDtcAlertsQuery: getIt<GetDtcAlertsQueryService>(),
      getDtcDetailQuery: getIt<GetDtcDetailQueryService>(),
      getLiveSensorsQuery: getIt<GetLiveSensorStreamQueryService>(),
      updateDtcStatusCommand: getIt<UpdateDtcStatusCommandService>(),
    ),
  );

  // 9. Billing & SUNAT Invoicing Context
  getIt.registerLazySingleton<BillingApi>(
    () => BillingApi(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<BillingRepository>(
    () => BillingRepositoryImpl(billingApi: getIt<BillingApi>()),
  );

  getIt.registerLazySingleton<GetVouchersByBranchQueryService>(
    () => GetVouchersByBranchQueryService(
      billingRepository: getIt<BillingRepository>(),
    ),
  );

  getIt.registerLazySingleton<GetVoucherDetailQueryService>(
    () => GetVoucherDetailQueryService(
      billingRepository: getIt<BillingRepository>(),
    ),
  );

  getIt.registerLazySingleton<GetQuotesQueryService>(
    () => GetQuotesQueryService(
      billingRepository: getIt<BillingRepository>(),
    ),
  );

  getIt.registerLazySingleton<EmitVoucherCommandService>(
    () => EmitVoucherCommandService(
      billingRepository: getIt<BillingRepository>(),
    ),
  );

  getIt.registerLazySingleton<ProcessPaymentCommandService>(
    () => ProcessPaymentCommandService(
      billingRepository: getIt<BillingRepository>(),
    ),
  );

  getIt.registerLazySingleton<CreateQuoteCommandService>(
    () => CreateQuoteCommandService(
      billingRepository: getIt<BillingRepository>(),
    ),
  );

  getIt.registerFactory<BillingViewModel>(
    () => BillingViewModel(
      getVouchersQuery: getIt<GetVouchersByBranchQueryService>(),
      getVoucherDetailQuery: getIt<GetVoucherDetailQueryService>(),
      getQuotesQuery: getIt<GetQuotesQueryService>(),
      emitVoucherCommand: getIt<EmitVoucherCommandService>(),
      processPaymentCommand: getIt<ProcessPaymentCommandService>(),
      createQuoteCommand: getIt<CreateQuoteCommandService>(),
    ),
  );
}
