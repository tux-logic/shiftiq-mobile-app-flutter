import 'dart:math';

/// Base contract for all in-memory domain events across bounded contexts.
/// Declared as [sealed] to guarantee exhaustive switch pattern matching.
sealed class DomainEvent {
  final String eventId;
  final DateTime occurredOn;

  DomainEvent({String? eventId, DateTime? occurredOn})
    : eventId = eventId ?? _generateEventId(),
      occurredOn = occurredOn ?? DateTime.now();

  static String _generateEventId() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final random = Random().nextInt(10000);
    return 'evt-$timestamp-$random';
  }
}

/// Dispatched when the user switches their active workshop branch.
/// Informs listening features (Fleet, Inventory, Operations, Billing)
/// to re-scope their active branch data without direct feature coupling.
final class ActiveBranchChangedEvent extends DomainEvent {
  final String branchId;
  final String branchName;

  ActiveBranchChangedEvent({
    required this.branchId,
    required this.branchName,
    super.eventId,
    super.occurredOn,
  });

  @override
  String toString() =>
      'ActiveBranchChangedEvent(branchId: $branchId, branchName: $branchName)';
}

/// Dispatched when the current user explicitly logs out of the application.
final class UserLoggedOutEvent extends DomainEvent {
  final String? userId;
  final String? reason;

  UserLoggedOutEvent({
    this.userId,
    this.reason,
    super.eventId,
    super.occurredOn,
  });

  @override
  String toString() =>
      'UserLoggedOutEvent(userId: $userId, reason: $reason)';
}

/// Dispatched when the user session token expires or an unrecoverable 401
/// response is received by the central API client.
final class SessionExpiredEvent extends DomainEvent {
  final String reason;

  SessionExpiredEvent({
    this.reason = 'Session token expired or authentication revoked',
    super.eventId,
    super.occurredOn,
  });

  @override
  String toString() => 'SessionExpiredEvent(reason: $reason)';
}
