import 'dart:async';

import 'package:equatable/equatable.dart';

sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the first page of notifications (full-screen loading).
class LoadNotifications extends NotificationsEvent {
  const LoadNotifications();
}

/// Pull-to-refresh: re-fetches the first page without tearing down the list.
/// [completer], when provided, is completed once the refresh settles so the
/// indicator can stop even when the data is unchanged and no state is emitted.
class RefreshNotifications extends NotificationsEvent {
  final Completer<void>? completer;
  const RefreshNotifications([this.completer]);

  @override
  List<Object?> get props => [completer];
}

/// Fetches the next page using the held cursor. No-op when there is no next
/// page or a page is already in flight. A failed load-more keeps the list.
class LoadMoreNotifications extends NotificationsEvent {
  const LoadMoreNotifications();
}

/// Optimistically flips one notification to read and fires the request. Low
/// stakes — no revert on failure.
class MarkNotificationReadEvent extends NotificationsEvent {
  final String id;
  const MarkNotificationReadEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// Optimistically flips every notification to read and fires the request.
class MarkAllNotificationsReadEvent extends NotificationsEvent {
  const MarkAllNotificationsReadEvent();
}
