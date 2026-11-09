import 'dart:async';

import 'package:shiftiq_mobile_app_flutter/core/domain/event/domain_event.dart';

/// Central in-memory decoupled event aggregator for cross-context domain
/// events. Enables sibling feature contexts to publish and consume events
/// without direct compile-time coupling.
abstract interface class DomainEventBus {
  /// Publishes a [DomainEvent] to all active subscribers.
  void emit(DomainEvent event);

  /// Returns a broadcast [Stream] filtered for events of type [T].
  Stream<T> on<T extends DomainEvent>();

  /// Closes internal stream controllers and frees resources.
  Future<void> dispose();
}
