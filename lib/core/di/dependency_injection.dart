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
import 'package:shiftiq_mobile_app_flutter/features/core/application/usecases/create_workshop.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/application/usecases/get_user_branches.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/application/usecases/get_user_profile_context.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/application/usecases/get_workshops.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/application/usecases/lookup_profile_by_document.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/application/usecases/manage_branch_subscription.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/application/usecases/manage_specialties.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/application/usecases/select_active_branch.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/repositories/core_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/infrastructure/remote/branch_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/infrastructure/remote/profile_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/infrastructure/remote/workshop_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/infrastructure/repositories/core_repository_impl.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/branch_selection_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/application/usecases/get_branch_financial_analytics.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/application/usecases/get_branch_summary.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/application/usecases/get_network_analytics_summary.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/infrastructure/remote/analytics_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/infrastructure/repositories/analytics_repository_impl.dart';
import 'package:shiftiq_mobile_app_flutter/features/analytics/presentation/controllers/dashboard_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/application/operations_application.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/domain/repositories/operations_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/infrastructure/remote/service_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/infrastructure/remote/work_order_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/infrastructure/remote/work_order_task_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/infrastructure/repositories/operations_repository_impl.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/work_order_detail_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/operations/presentation/work_orders_view_model.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/application/usecases/cancel_appointment.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/application/usecases/create_appointment.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/application/usecases/get_appointments.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/application/usecases/get_customer_registrations.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/application/usecases/manage_employee_applications.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/application/usecases/onboard_employee.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/application/usecases/register_customer_to_branch.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/application/usecases/update_appointment.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/domain/repositories/fleet_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/infrastructure/remote/appointment_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/infrastructure/remote/customer_registration_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/infrastructure/remote/employee_registration_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/fleet/infrastructure/repositories/fleet_repository_impl.dart';
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
import 'package:shiftiq_mobile_app_flutter/features/iot/application/iot_application.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/domain/repositories/iot_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/infrastructure/remote/obd2_device_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/infrastructure/remote/obd2_registration_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/infrastructure/remote/telemetry_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/infrastructure/remote/telemetry_batch_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/infrastructure/remote/vehicle_api.dart';
import 'package:shiftiq_mobile_app_flutter/features/iot/infrastructure/repositories/iot_repository_impl.dart';
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

  // 3. Core Context (Workshops, Branches, Profiles)
  getIt.registerLazySingleton<WorkshopApi>(
    () => WorkshopApi(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<BranchApi>(
    () => BranchApi(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<ProfileApi>(
    () => ProfileApi(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<CoreRepository>(
    () => CoreRepositoryImpl(
      workshopApi: getIt<WorkshopApi>(),
      branchApi: getIt<BranchApi>(),
      profileApi: getIt<ProfileApi>(),
      sessionStorage: getIt<SessionStorage>(),
      eventBus: getIt<DomainEventBus>(),
    ),
  );

  getIt.registerLazySingleton<CreateWorkshopUseCase>(
    () => CreateWorkshopUseCase(repository: getIt<CoreRepository>()),
  );

  getIt.registerLazySingleton<GetWorkshopsUseCase>(
    () => GetWorkshopsUseCase(repository: getIt<CoreRepository>()),
  );

  getIt.registerLazySingleton<ManageSpecialtiesUseCase>(
    () => ManageSpecialtiesUseCase(repository: getIt<CoreRepository>()),
  );

  getIt.registerLazySingleton<GetUserBranchesUseCase>(
    () => GetUserBranchesUseCase(repository: getIt<CoreRepository>()),
  );

  getIt.registerLazySingleton<SelectActiveBranchUseCase>(
    () => SelectActiveBranchUseCase(repository: getIt<CoreRepository>()),
  );

  getIt.registerLazySingleton<ManageBranchSubscriptionUseCase>(
    () => ManageBranchSubscriptionUseCase(repository: getIt<CoreRepository>()),
  );

  getIt.registerLazySingleton<GetUserProfileContextUseCase>(
    () => GetUserProfileContextUseCase(repository: getIt<CoreRepository>()),
  );

  getIt.registerLazySingleton<LookupProfileByDocumentUseCase>(
    () => LookupProfileByDocumentUseCase(repository: getIt<CoreRepository>()),
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

  getIt.registerLazySingleton<GetBranchFinancialAnalyticsUseCase>(
    () => GetBranchFinancialAnalyticsUseCase(
      repository: getIt<AnalyticsRepository>(),
    ),
  );

  getIt.registerLazySingleton<GetNetworkAnalyticsSummaryUseCase>(
    () => GetNetworkAnalyticsSummaryUseCase(
      repository: getIt<AnalyticsRepository>(),
    ),
  );

  getIt.registerFactory<DashboardViewModel>(
    () => DashboardViewModel(
      getBranchSummaryUseCase: getIt<GetBranchSummaryUseCase>(),
      sessionStorage: getIt<SessionStorage>(),
    ),
  );

  // 5. Operations Bounded Context (Services Catalog, Work Orders, Tasks & Stock Reservations)
  getIt.registerLazySingleton<ServiceApi>(
    () => ServiceApi(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<WorkOrderApi>(
    () => WorkOrderApi(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<WorkOrderTaskApi>(
    () => WorkOrderTaskApi(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<OperationsRepository>(
    () => OperationsRepositoryImpl(
      serviceApi: getIt<ServiceApi>(),
      workOrderApi: getIt<WorkOrderApi>(),
      workOrderTaskApi: getIt<WorkOrderTaskApi>(),
    ),
  );

  getIt.registerLazySingleton<ManageServices>(
    () => ManageServices(repository: getIt<OperationsRepository>()),
  );

  getIt.registerLazySingleton<ManageWorkOrders>(
    () => ManageWorkOrders(repository: getIt<OperationsRepository>()),
  );

  getIt.registerLazySingleton<ManageWorkOrderTasks>(
    () => ManageWorkOrderTasks(repository: getIt<OperationsRepository>()),
  );

  getIt.registerLazySingleton<ManageTaskProducts>(
    () => ManageTaskProducts(repository: getIt<OperationsRepository>()),
  );

  getIt.registerFactory<WorkOrdersViewModel>(
    () => WorkOrdersViewModel(
      manageWorkOrders: getIt<ManageWorkOrders>(),
      sessionStorage: getIt<SessionStorage>(),
    ),
  );

  getIt.registerFactory<WorkOrderDetailViewModel>(
    () => WorkOrderDetailViewModel(
      manageWorkOrders: getIt<ManageWorkOrders>(),
      manageWorkOrderTasks: getIt<ManageWorkOrderTasks>(),
      manageTaskProducts: getIt<ManageTaskProducts>(),
    ),
  );

  // 6. Fleet Context (Appointments, Customer Registrations & Employee Onboarding)
  getIt.registerLazySingleton<AppointmentApi>(
    () => AppointmentApi(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<CustomerRegistrationApi>(
    () => CustomerRegistrationApi(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<EmployeeRegistrationApi>(
    () => EmployeeRegistrationApi(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<FleetRepository>(
    () => FleetRepositoryImpl(
      appointmentApi: getIt<AppointmentApi>(),
      customerRegistrationApi: getIt<CustomerRegistrationApi>(),
      employeeRegistrationApi: getIt<EmployeeRegistrationApi>(),
    ),
  );

  getIt.registerLazySingleton<CreateAppointmentUseCase>(
    () => CreateAppointmentUseCase(repository: getIt<FleetRepository>()),
  );

  getIt.registerLazySingleton<CreateAppointmentCommandService>(
    () => CreateAppointmentCommandService(useCase: getIt<CreateAppointmentUseCase>()),
  );

  getIt.registerLazySingleton<GetAppointmentsUseCase>(
    () => GetAppointmentsUseCase(repository: getIt<FleetRepository>()),
  );

  getIt.registerLazySingleton<UpdateAppointmentUseCase>(
    () => UpdateAppointmentUseCase(repository: getIt<FleetRepository>()),
  );

  getIt.registerLazySingleton<CancelAppointmentUseCase>(
    () => CancelAppointmentUseCase(repository: getIt<FleetRepository>()),
  );

  getIt.registerLazySingleton<RegisterCustomerToBranchUseCase>(
    () => RegisterCustomerToBranchUseCase(repository: getIt<FleetRepository>()),
  );

  getIt.registerLazySingleton<GetCustomerRegistrationsUseCase>(
    () => GetCustomerRegistrationsUseCase(repository: getIt<FleetRepository>()),
  );

  getIt.registerLazySingleton<OnboardEmployeeUseCase>(
    () => OnboardEmployeeUseCase(repository: getIt<FleetRepository>()),
  );

  getIt.registerLazySingleton<ManageEmployeeApplicationsUseCase>(
    () => ManageEmployeeApplicationsUseCase(repository: getIt<FleetRepository>()),
  );

  getIt.registerFactory<AppointmentsViewModel>(
    () => AppointmentsViewModel(
      getAppointmentsQuery: getIt<GetAppointmentsUseCase>(),
      getCustomerDirectoryQuery: getIt<GetCustomerRegistrationsUseCase>(),
      createAppointmentCommand: getIt<CreateAppointmentCommandService>(),
      updateStatusCommand: getIt<UpdateAppointmentUseCase>(),
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

  // 8. IoT Bounded Context (Vehicles, OBD-II Hardware, Telemetry)
  getIt.registerLazySingleton<VehicleApi>(
    () => VehicleApi(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<Obd2DeviceApi>(
    () => Obd2DeviceApi(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<Obd2RegistrationApi>(
    () => Obd2RegistrationApi(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<TelemetryBatchApi>(
    () => TelemetryBatchApi(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<TelemetryApi>(
    () => TelemetryApi(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<IotRepository>(
    () => IotRepositoryImpl(
      vehicleApi: getIt<VehicleApi>(),
      obd2DeviceApi: getIt<Obd2DeviceApi>(),
      obd2RegistrationApi: getIt<Obd2RegistrationApi>(),
      telemetryBatchApi: getIt<TelemetryBatchApi>(),
      telemetryApi: getIt<TelemetryApi>(),
    ),
  );

  getIt.registerLazySingleton<RegisterVehicle>(
    () => RegisterVehicle(repository: getIt<IotRepository>()),
  );

  getIt.registerLazySingleton<GetVehicles>(
    () => GetVehicles(repository: getIt<IotRepository>()),
  );

  getIt.registerLazySingleton<GetCustomerVehicles>(
    () => GetCustomerVehicles(repository: getIt<IotRepository>()),
  );

  getIt.registerLazySingleton<UpdateVehicle>(
    () => UpdateVehicle(repository: getIt<IotRepository>()),
  );

  getIt.registerLazySingleton<ManageObd2Devices>(
    () => ManageObd2Devices(repository: getIt<IotRepository>()),
  );

  getIt.registerLazySingleton<ManageObd2Registrations>(
    () => ManageObd2Registrations(repository: getIt<IotRepository>()),
  );

  getIt.registerLazySingleton<GetTelemetrySnapshots>(
    () => GetTelemetrySnapshots(repository: getIt<IotRepository>()),
  );

  getIt.registerLazySingleton<GetDtcAlerts>(
    () => GetDtcAlerts(repository: getIt<IotRepository>()),
  );

  getIt.registerLazySingleton<IngestTelemetryBatch>(
    () => IngestTelemetryBatch(repository: getIt<IotRepository>()),
  );

  getIt.registerFactory<TelemetryViewModel>(
    () => TelemetryViewModel(
      getDtcAlerts: getIt<GetDtcAlerts>(),
      getTelemetrySnapshots: getIt<GetTelemetrySnapshots>(),
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
