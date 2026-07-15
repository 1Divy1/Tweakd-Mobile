import 'dart:async';

import 'package:equatable/equatable.dart';

sealed class InboxEvent extends Equatable {
  const InboxEvent();

  @override
  List<Object?> get props => [];
}

class LoadInbox extends InboxEvent {
  const LoadInbox();
}

/// Pull-to-refresh; the completer stops the indicator (see the feed page for
/// why a completer and not a state listener).
class RefreshInbox extends InboxEvent {
  final Completer<void>? completer;
  const RefreshInbox([this.completer]);
}

class InboxSearchChanged extends InboxEvent {
  final String query;
  const InboxSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}
