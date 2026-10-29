# Tasks

## 1. Core Foundation & Networking

- [x] 1.1 Add required dependencies (`dio`, `flutter_bloc`, `flutter_secure_storage`, `equatable`, `google_sign_in`) to `pubspec.yaml` and verify `flutter pub get` succeeds without version conflicts
- [x] 1.2 Implement `core/errors/` with `Failure` and `AppException` hierarchies and verify unit definition compiles
- [x] 1.3 Implement `SecureStorageService` wrapper in `core/storage/` for encrypted token persistence and verify read/write/clear methods
- [x] 1.4 Implement `DioClient` and `AuthInterceptor` with `QueuedInterceptor` handling 401 token refresh rotation in `core/network/` and verify request queuing and retry logic

## 2. Domain Layer (DDD)

- [x] 2.1 Implement domain entities (`User`, `AuthTokens`, `UserProfileRole`) and value objects (`Email`, `Password`) in `features/auth/domain/` and verify entity immutability and validation logic
- [x] 2.2 Define `IAuthRepository` interface contract and domain-specific failures (`AuthFailure`) in `features/auth/domain/` and verify abstract specifications

## 3. Infrastructure Layer (DDD)

- [x] 3.1 Implement DTO models (`AuthenticatedUserDto`, `LoginRequestDto`, `GoogleLoginRequestDto`, `RefreshTokenRequestDto`) and verify JSON serialization
- [x] 3.2 Implement `AuthRemoteDataSource` and `AuthLocalDataSource` in `features/auth/infrastructure/` and verify API endpoint integration
- [x] 3.3 Implement `AuthRepositoryImpl` in `features/auth/infrastructure/` connecting remote/local data sources with domain contracts and verify error translation

## 4. Application Layer (DDD)

- [x] 4.1 Implement application use cases (`LoginWithEmailUseCase`, `LoginWithGoogleUseCase`, `RefreshTokenUseCase`, `LogoutUseCase`, `GetActiveRolesUseCase`) in `features/auth/application/` and verify use case execution flow

## 5. Presentation Layer & Automotive UI

- [x] 5.1 Implement `AuthBloc`, `AuthEvent`, and `AuthState` in `features/auth/presentation/state/` and verify state transitions
- [x] 5.2 Configure ShiftIQ automotive dark theme, neon accents, and typography in `core/theme/` and verify Material 3 styling
- [x] 5.3 Build `AutomotiveBayVisualizer` widget featuring custom animated workshop bay lift, live DTC bus pulse, and status badges in `features/auth/presentation/widgets/` and verify animation smoothness
- [ ] 5.4 Build `WelcomeAuthScreen` with staggered entrance animation, Google Sign-In, Phone entry trigger, and traditional email navigation in `features/auth/presentation/screens/` and verify layout responsiveness
- [ ] 5.5 Build `EmailLoginScreen` with email and password input fields, validation feedback, and submission state handling in `features/auth/presentation/screens/` and verify interactive validation

## 6. Integration & Verification

- [ ] 6.1 Update `lib/main.dart` with BLoC injection and initial route resolving, run `flutter analyze`, and verify clean static analysis without linter warnings
