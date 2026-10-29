# Design

## Context

The mobile project is currently an initial Flutter template with `android` platform support. ShiftIQ's backend enforces JWT-based authentication where access tokens expire in 15 minutes, requiring an atomic, single-use refresh token rotation mechanism. 

To deliver a scalable foundation that accommodates both Customer and Workshop Employee personas, this design introduces the **IAM Bounded Context** following Domain-Driven Design (DDD) with four distinct layers: Domain, Application, Infrastructure, and Presentation.

## Goals / Non-Goals

**Goals:**
- Implement the 4-layer DDD structure for IAM (`domain`, `application`, `infrastructure`, `presentation`).
- Establish `core/network` with a `Dio` instance equipped with a `QueuedInterceptor` for concurrency-safe refresh token rotation.
- Secure token persistence using `flutter_secure_storage`.
- Integrate Google Sign-In and Traditional Email/Password authentication.
- Fetch and resolve active roles via `/api/v1/profiles/roles` to bifurcate routing between Customer and Employee flows.
- Render a premium automotive visual interface inspired by workshop diagnostics (CAN-BUS, DTC bus monitor, dynamic vehicle lift bay) using Flutter's explicit animation framework and responsive layout practices.

**Non-Goals:**
- Full implementation of SMS/WhatsApp OTP backend gateway (placeholder action trigger provided in presentation).
- Workshop management or vehicle telemetry tracking outside of the authentication and role discovery scope.

## Architecture & Layers (DDD)

```text
lib/
├── core/
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   ├── api_endpoints.dart
│   │   ├── auth_interceptor.dart     # QueuedInterceptor for token rotation
│   │   └── dio_client.dart
│   ├── storage/
│   │   └── secure_storage_service.dart
│   └── theme/
│       ├── app_colors.dart           # ShiftIQ automotive dark palette
│       └── app_typography.dart
└── features/
    └── auth/
        ├── domain/
        │   ├── entities/             # User, AuthTokens, UserRole
        │   ├── failures/             # AuthFailure (InvalidCredentials, Network, SessionExpired)
        │   ├── repositories/         # IAuthRepository interface
        │   └── value_objects/        # Email, Password
        ├── application/
        │   ├── login_with_email_usecase.dart
        │   ├── login_with_google_usecase.dart
        │   ├── refresh_token_usecase.dart
        │   ├── logout_usecase.dart
        │   └── get_active_roles_usecase.dart
        ├── infrastructure/
        │   ├── datasources/
        │   │   ├── auth_remote_datasource.dart
        │   │   └── auth_local_datasource.dart
        │   ├── dtos/
        │   │   ├── authenticated_user_dto.dart
        │   │   └── user_dto.dart
        │   └── repositories/
        │       └── auth_repository_impl.dart
        └── presentation/
            ├── state/
            │   ├── auth_bloc.dart
            │   ├── auth_event.dart
            │   └── auth_state.dart
            ├── screens/
            │   ├── welcome_auth_screen.dart
            │   └── email_login_screen.dart
            └── widgets/
                ├── automotive_bay_visualizer.dart   # Diagnostic card with animated lift & pulse
                ├── auth_button.dart
                └── auth_text_field.dart
```

## Decisions

### 1. State Management: Bloc / Cubit
- **Decision**: Use `flutter_bloc` for state management in the application layer.
- **Rationale**: BLoC offers strict separation of concerns, immutable state transitions, and predictable event-driven architecture, essential for complex auth lifecycles (logging in, token refreshing, role resolving, error handling).
- **Alternatives Considered**: `Provider` (less boilerplate but less structured for complex event-driven flows), `Riverpod` (modern, but BLoC aligns seamlessly with DDD's Command/Event paradigm).

### 2. Network Client & Concurrency: Dio with QueuedInterceptor
- **Decision**: Use `Dio` combined with `QueuedInterceptor` for token renewal.
- **Rationale**: The backend uses single-use rotating refresh tokens. Multiple parallel requests triggered simultaneously when an access token expires must queue behind a single refresh request. `QueuedInterceptor` locks outgoing requests until the new refresh token is obtained and stored.
- **Alternatives Considered**: Raw `http` package (requires custom synchronization locks and manual request cloning).

### 3. Encrypted Credentials Storage
- **Decision**: Use `flutter_secure_storage` (Android Keystore / iOS Keychain).
- **Rationale**: Access and refresh tokens must be shielded against device-level inspection.
- **Alternatives Considered**: `shared_preferences` (stores in plaintext, insecure for session tokens).

### 4. Automotive Diagnostic Card & Micro-Animations
- **Decision**: Build `AutomotiveBayVisualizer` utilizing Flutter's `AnimationController` and `CurvedAnimation` with staggered sequencing.
- **Rationale**: Delivers a distinct high-end automotive UX (inspired by OBD2 telemetría, live CAN-BUS data, and bay lifts) with 60 FPS performance without bulky external assets (Lottie/GIFs).

## Risks / Trade-offs

- **[Risk]** Single-use refresh token desynchronization if app crashes during rotation.  
  → **Mitigation**: Persist the newly received token pair atomically before unlocking queued requests. If renewal returns 401/403, immediately purge storage and emit `UnauthenticatedState`.
- **[Risk]** Google Sign-In setup requires platform-specific SHA-1 keys for Android.  
  → **Mitigation**: Gracefully handle missing configuration during local development with a clear UI snackbar and fallback mock authentication mode for staging.
