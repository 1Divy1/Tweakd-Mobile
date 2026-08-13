import 'package:equatable/equatable.dart';

sealed class ManageMapEventEvent extends Equatable {
  const ManageMapEventEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the event plus the two organizer-only queues: pending car entries and
/// pending withdrawal requests.
class LoadMapEventManagement extends ManageMapEventEvent {
  final String eventId;

  const LoadMapEventManagement(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class RefreshMapEventManagement extends ManageMapEventEvent {
  const RefreshMapEventManagement();
}

/// Accept or decline one car's entry.
///
/// [reason] is what the owner will be shown on their declined strip. The
/// backend **requires** it to decline — the UI collects it in a dialog before
/// this event is ever dispatched — and ignores it on an accept.
class ReviewEntry extends ManageMapEventEvent {
  final String carId;
  final bool accept;
  final String? reason;

  const ReviewEntry({required this.carId, required this.accept, this.reason});

  @override
  List<Object?> get props => [carId, accept, reason];
}

/// Approving lets the owner out and **hard-deletes** their rows; rejecting puts
/// them back on the entry list as accepted.
class ReviewWithdrawal extends ManageMapEventEvent {
  final String ownerId;
  final bool approve;

  const ReviewWithdrawal({required this.ownerId, required this.approve});

  @override
  List<Object?> get props => [ownerId, approve];
}

class RemoveManagedOrganizer extends ManageMapEventEvent {
  final String organizerId;

  const RemoveManagedOrganizer(this.organizerId);

  @override
  List<Object?> get props => [organizerId];
}

/// Lifecycle actions. Cancel and finish keep the event; delete is creator-only
/// and irreversible.
enum MapEventLifecycleAction { cancel, finish, delete }

class RunEventLifecycleAction extends ManageMapEventEvent {
  final MapEventLifecycleAction action;

  const RunEventLifecycleAction(this.action);

  @override
  List<Object?> get props => [action];
}

class ClearManageEventError extends ManageMapEventEvent {
  const ClearManageEventError();
}
