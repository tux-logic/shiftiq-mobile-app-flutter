# Spec Delta

## Purpose

Delivers a high-performance, dark-themed automotive UI with animated vehicle bay diagnostics, telemetry widgets, and responsive authentication controls.

## ADDED Requirements

### Requirement: Automotive Hero Diagnostic Card
The presentation layer SHALL render an animated automotive header card visualizing live workshop bay activity, DTC bus telemetry, and plan status indicators.

#### Scenario: Telemetry card initial rendering
- **WHEN** the authentication welcome screen is displayed
- **THEN** system renders the dark card with animated elevator bay, active orders count, CAN-BUS online pulse, and DTC bus diagnostic simulation

#### Scenario: Staggered entrance animation
- **WHEN** the welcome view mounts
- **THEN** system executes a sequential staggered entrance for the diagnostic card, headline typography, and action buttons using smooth acceleration curves

### Requirement: Multi-Provider Authentication Actions
The presentation layer SHALL provide distinct interactive action triggers for Google Sign-In, Phone/OTP, and Traditional Email authentication.

#### Scenario: Tap Google Sign-In
- **WHEN** user taps the "Continuar con Google" button
- **THEN** system triggers Google Sign-In flow with a subtle tactile feedback and loading state

#### Scenario: Tap Traditional Email Login
- **WHEN** user taps "Iniciar sesión con correo tradicional"
- **THEN** system transitions to the email and password login view with a shared-axis transition

### Requirement: Responsive View Adaptation
The presentation layout SHALL adapt dimensions, padding, and font scaling across small, medium, and tablet mobile form factors without clipping or scroll overflow.

#### Scenario: Small mobile viewport rendering
- **WHEN** screen height or width is constrained
- **THEN** layout wraps content inside a physics-based scroll view maintaining visual hierarchy and accessible touch targets
