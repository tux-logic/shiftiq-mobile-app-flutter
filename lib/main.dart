import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/network/dio_client.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/application/check_auth_status_usecase.dart';
import 'features/auth/application/get_active_roles_usecase.dart';
import 'features/auth/application/login_with_email_usecase.dart';
import 'features/auth/application/login_with_google_usecase.dart';
import 'features/auth/application/logout_usecase.dart';
import 'features/auth/infrastructure/datasources/auth_local_datasource.dart';
import 'features/auth/infrastructure/datasources/auth_remote_datasource.dart';
import 'features/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/screens/welcome_auth_screen.dart';
import 'features/auth/presentation/state/auth_bloc.dart';
import 'features/auth/presentation/state/auth_event.dart';
import 'features/auth/presentation/state/auth_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Core singletons
  final storageService = SecureStorageService();
  late final AuthBloc authBloc;

  final dioClient = DioClient(
    storageService: storageService,
    onSessionExpired: () {
      authBloc.add(const LogoutEvent());
    },
  );

  // Auth dependencies
  final remoteDataSource = AuthRemoteDataSource(dio: dioClient.dio);
  final localDataSource = AuthLocalDataSource(storageService: storageService);
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );

  final loginWithEmailUseCase = LoginWithEmailUseCase(repository: authRepository);
  final loginWithGoogleUseCase = LoginWithGoogleUseCase(repository: authRepository);
  final logoutUseCase = LogoutUseCase(repository: authRepository);
  final checkAuthStatusUseCase = CheckAuthStatusUseCase(repository: authRepository);
  final getActiveRolesUseCase = GetActiveRolesUseCase(repository: authRepository);

  authBloc = AuthBloc(
    loginWithEmailUseCase: loginWithEmailUseCase,
    loginWithGoogleUseCase: loginWithGoogleUseCase,
    logoutUseCase: logoutUseCase,
    checkAuthStatusUseCase: checkAuthStatusUseCase,
    getActiveRolesUseCase: getActiveRolesUseCase,
  )..add(const CheckAuthStatusEvent());

  runApp(
    ShiftIqApp(authBloc: authBloc),
  );
}

class ShiftIqApp extends StatelessWidget {
  final AuthBloc authBloc;

  const ShiftIqApp({super.key, required this.authBloc});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: authBloc,
      child: MaterialApp(
        title: 'ShiftIQ',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthRouter(),
      ),
    );
  }
}

class AuthRouter extends StatelessWidget {
  const AuthRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return AuthenticatedPlaceholderScreen(state: state);
        }

        if (state is AuthLoading && state.message == null) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        return const WelcomeAuthScreen();
      },
    );
  }
}

class AuthenticatedPlaceholderScreen extends StatelessWidget {
  final Authenticated state;

  const AuthenticatedPlaceholderScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final roleTitle = state.isWorkshopEmployee
        ? 'Panel Mecánico / Taller'
        : 'Panel Cliente (Mis Vehículos)';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(roleTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              context.read<AuthBloc>().add(const LogoutEvent());
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
                child: Icon(
                  state.isWorkshopEmployee
                      ? Icons.build_circle_outlined
                      : Icons.directions_car_filled_rounded,
                  color: AppColors.primary,
                  size: 38,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '¡Bienvenido a ShiftIQ!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sesión activa como: ${state.user.role}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () {
                  context.read<AuthBloc>().add(const LogoutEvent());
                },
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
