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
}
