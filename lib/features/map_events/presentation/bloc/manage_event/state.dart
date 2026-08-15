import 'package:equatable/equatable.dart';

import '../../../domain/entities/map_event.dart';
import '../../../domain/entities/map_event_participant.dart';
import '../../../domain/entities/map_event_withdrawal_request.dart';
import '../../utils/map_event_error_mapper.dart';

enum ManageMapEventStatus { loading, loaded, failure }

class ManageMapEventState extends Equatable {
  final ManageMapEventStatus status;
  final MapEventEntity? event;

  /// `?status=pending` — organizer-only, and the reason this page exists.
  final List<MapEventParticipantEntity> pendingEntries;

  /// `GET /{id}/withdrawals`, grouped by owner.
  final List<MapEventWithdrawalRequestEntity> withdrawals;

  /// Ids with a review call in flight, so each row can show its own spinner
  /// instead of the page freezing as a whole.
  final Set<String> busyIds;

  /// True once a lifecycle action has finished and the page should pop.
  final bool isDeleted;

  final MapEventError? error;

  /// One-shot, for the snackbar.
  final MapEventError? actionError;

  const ManageMapEventState({
    this.status = ManageMapEventStatus.loading,
    this.event,
    this.pendingEntries = const [],
    this.withdrawals = const [],
    this.busyIds = const {},
    this.isDeleted = false,
    this.error,
    this.actionError,
  });

  ManageMapEventState copyWith({
    ManageMapEventStatus? status,
    MapEventEntity? event,
    List<MapEventParticipantEntity>? pendingEntries,
    List<MapEventWithdrawalRequestEntity>? withdrawals,
    Set<String>? busyIds,
    bool? isDeleted,
    MapEventError? error,
    bool clearError = false,
    MapEventError? actionError,
    bool clearActionError = false,
  }) {
    return ManageMapEventState(
      status: status ?? this.status,
      event: event ?? this.event,
      pendingEntries: pendingEntries ?? this.pendingEntries,
      withdrawals: withdrawals ?? this.withdrawals,
      busyIds: busyIds ?? this.busyIds,
      isDeleted: isDeleted ?? this.isDeleted,
      error: clearError ? null : (error ?? this.error),
      actionError:
          clearActionError ? null : (actionError ?? this.actionError),
    );
  }

  @override
  List<Object?> get props => [
        status,
        event,
        pendingEntries,
        withdrawals,
        busyIds,
        isDeleted,
        error,
        actionError,
      ];
}
