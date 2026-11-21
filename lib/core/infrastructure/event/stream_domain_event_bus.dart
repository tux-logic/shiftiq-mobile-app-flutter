import 'dart:async';

import 'package:shiftiq_mobile_app_flutter/core/domain/event/domain_event.dart';
import 'package:shiftiq_mobile_app_flutter/core/domain/event/domain_event_bus.dart';

/// In-memory implementation of [DomainEventBus] using pure Dart Streams.
/// Uses a broadcast [StreamController] to deliver domain events to all
/// active subscribers without coupling bounded contexts.
class StreamDomainEventBus implements DomainEventBus {
  final StreamController<DomainEvent> _controller;

  StreamDomainEventBus({StreamController<DomainEvent>? controller})
    : _controller = controller ?? StreamController<DomainEvent>.broadcast();

  @override
  void emit(DomainEvent event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  @override
  Stream<T> on<T extends DomainEvent>() {
    return _controller.stream.where((event) => event is T).cast<T>();
  }

  @override
  Future<void> dispose() async {
    if (!_controller.isClosed) {
      await _controller.close();
    }
  }
}
