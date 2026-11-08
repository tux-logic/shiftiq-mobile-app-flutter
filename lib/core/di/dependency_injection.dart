import 'package:get_it/get_it.dart';
import 'package:shiftiq_mobile_app_flutter/core/app_database.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/application/login_use_case.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/application/refresh_token_use_case.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/domain/auth_repository.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/infrastructure/auth_repository_impl.dart';
import 'package:shiftiq_mobile_app_flutter/features/auth/infrastructure/remote/auth_api.dart';
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

final getIt = GetIt.instance;

/// Global Dependency Injection registry following easyrecipe architecture
void setupDependencies() {
  // 1. Core Singletons
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  getIt.registerLazySingleton<SessionStorage>(
    () => SessionStorage(appDatabase: getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(sessionStorage: getIt<SessionStorage>()),
  );

  // 2. IAM Context (Authentication)
  getIt.registerLazySingleton<AuthApi>(
    () => AuthApi(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authApi: getIt<AuthApi>(),
      sessionStorage: getIt<SessionStorage>(),
    ),
  );

  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(repository: getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<RefreshTokenUseCase>(
    () => RefreshTokenUseCase(repository: getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(repository: getIt<AuthRepository>()),
  );

  getIt.registerFactory<LoginViewModel>(
    () => LoginViewModel(loginUseCase: getIt<LoginUseCase>()),
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
}
