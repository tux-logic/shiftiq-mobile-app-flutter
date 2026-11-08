import 'package:get_it/get_it.dart';
import 'package:shiftiq_mobile_app_flutter/core/app_database.dart';
import 'package:shiftiq_mobile_app_flutter/core/network/api_client.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';

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
}
