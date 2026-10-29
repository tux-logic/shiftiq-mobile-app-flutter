# Spec Delta

## Purpose

Provides secure authentication, session persistence, automatic token renewal with rotation, and role-based access management for customers and workshop employees.

## ADDED Requirements

### Requirement: Email and Password Authentication
The system SHALL authenticate users through email and password credentials against the ShiftIQ Platform API and store the resulting tokens securely.

#### Scenario: Successful email login
- **WHEN** user submits valid registered email and password credentials
- **THEN** system receives access token, refresh token, and user identity, saves tokens in encrypted local storage, and emits an authenticated session state

#### Scenario: Invalid credentials error
- **WHEN** user submits invalid email or password credentials
- **THEN** system receives 401 Unauthorized from the API and displays an observable invalid credentials failure without persisting any token

### Requirement: Google OAuth Authentication
The system SHALL authenticate or synchronize users through Google Sign-In identity tokens and obtain ShiftIQ session tokens.

#### Scenario: Successful Google authentication
- **WHEN** user completes Google Sign-In with an authorized Google account
- **THEN** system transmits the Google ID token to `/api/v1/authentication/sessions/google` and stores the issued ShiftIQ tokens

### Requirement: Single-Use Rotating Token Refresh
The system SHALL automatically refresh expired access tokens using the rotating single-use refresh token when receiving an HTTP 401 response on protected requests.

#### Scenario: Transparent token renewal on 401
- **WHEN** a protected request fails with status code 401 and a valid refresh token exists
- **THEN** system intercepts the failure, executes session refresh, stores the newly issued access and refresh tokens, and replays the original request

#### Scenario: Session expiration when refresh fails
- **WHEN** the refresh token is revoked or expired during renewal
- **THEN** system purges local credentials, terminates the session, and triggers navigation back to the authentication screen

### Requirement: Role and Profile Discovery
The system SHALL query active user profile roles after successful authentication to resolve the appropriate user interface workspace.

#### Scenario: Resolve customer profile role
- **WHEN** the authenticated user has ROLE_USER or ROLE_CUSTOMER in profile roles
- **THEN** system routes the application to the customer dashboard

#### Scenario: Resolve workshop employee profile role
- **WHEN** the authenticated user has ROLE_EMPLOYEE in profile roles
- **THEN** system routes the application to the workshop technician workspace

### Requirement: User Logout
The system SHALL revoke the active refresh token on the backend and clear local authentication state upon user logout.

#### Scenario: Clean logout
- **WHEN** user initiates logout
- **THEN** system calls logout endpoint, deletes stored credentials, and resets session state to unauthenticated
