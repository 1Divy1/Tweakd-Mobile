import 'package:equatable/equatable.dart';

sealed class MyMapEventsEvent extends Equatable {
  const MyMapEventsEvent();

  @override
  List<Object?> get props => [];
}

class LoadMyMapEvents extends MyMapEventsEvent {
  const LoadMyMapEvents();
}

/// Pull-to-refresh, and the way the list picks up an event created or edited on
/// another screen.
class RefreshMyMapEvents extends MyMapEventsEvent {
  const RefreshMyMapEvents();
}

class LoadMoreMyMapEvents extends MyMapEventsEvent {
  const LoadMoreMyMapEvents();
}
