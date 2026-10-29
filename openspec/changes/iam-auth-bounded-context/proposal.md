# Proposal

## Why

ShiftIQ requires a secure, production-grade identity and access foundation before customers and workshop mechanics can interact with workshop operations, vehicle telemetry, and appointments. The mobile app must authenticate against the ShiftIQ Platform API, manage single-use rotating refresh tokens, distinguish customer vs. workshop employee roles, and deliver an elevated automotive-grade user experience with smooth interactive animations right from the welcome/login screen.

## What Changes

- Introduce the **IAM (Identity & Access Management) Bounded Context** following Domain-Driven Design (DDD) with strictly separated layers: `domain`, `application`, `infrastructure`, and `presentation`.
- Implement `core/network` foundation featuring a `Dio` HTTP client with a thread-safe token refresh interceptor (single-use token rotation handling `401 Unauthorized`).
- Build authentication capabilities:
  - Email and password authentication (`POST /api/v1/authentication/sessions`).
  - Google Sign-In integration (`POST /api/v1/authentication/sessions/google`).
  - Phone / OTP-based authentication placeholders and traditional email login navigation.
  - Session refresh and token rotation (`POST /api/v1/authentication/sessions/refresh`).
  - Logout and token revocation (`DELETE /api/v1/authentication/sessions`).
  - Role-based redirection through profile active roles discovery (`GET /api/v1/profiles/roles`).
- Create an automotive high-tech visual identity for the authentication interface inspired by vehicle telemetría and workshop bays (dark high-tech theme, interactive live DTC bus status card, elevator/bay animation, and smooth staggered micro-interactions).

## Capabilities

### New Capabilities
- `iam-auth`: Authentication flows (email/password, Google OAuth, session refresh, role resolution) and secure session management with token persistence.
- `iam-presentation`: High-performance, animated automotive UI for onboarding and authentication screens following responsive layout standards.

### Modified Capabilities
<!-- None -->

## Impact

- **Dependencies**: Adds `dio`, `flutter_bloc` / state management, `flutter_secure_storage`, `google_sign_in`, and design tokens/fonts.
- **Architectural Footprint**: Establishes `lib/core/` (network, storage, errors, theme) and `lib/features/auth/` (DDD 4-layer structure).
- **APIs**: Consumes `/api/v1/authentication/*` and `/api/v1/profiles/roles`.
