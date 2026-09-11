import 'package:equatable/equatable.dart';

import '../../../domain/entities/contest.dart';
import '../../utils/map_event_error_mapper.dart';

enum EventContestsStatus { initial, loading, loaded, failure }

/// Every contest of one event, for the CONTESTS tab and the Overview block.
class EventContestsState extends Equatable {
  final EventContestsStatus status;
  final String? eventId;
  final List<ContestEntity> contests;
  final MapEventError? error;

  /// True while the enter sheet's requests are in flight.
  final bool isSaving;

  /// One-shot: shown in a snackbar, then cleared.
  final MapEventError? actionError;

  const EventContestsState({
    this.status = EventContestsStatus.initial,
    this.eventId,
    this.contests = const [],
    this.error,
    this.isSaving = false,
    this.actionError,
  });

  bool get hasContests => contests.isNotEmpty;

  List<ContestEntity> get open => [for (final c in contests) if (c.isOpen) c];
  List<ContestEntity> get scheduled =>
      [for (final c in contests) if (c.isScheduled) c];
  List<ContestEntity> get finished =>
      [for (final c in contests) if (c.isFinished) c];

  bool get hasLiveContest => open.isNotEmpty;

  /// Open contests the viewer could still vote in and hasn't.
  int get unvotedOpenCount =>
      open.where((c) => c.viewer.canVote && !c.viewer.hasVoted).length;

  /// Contests (not finished) the viewer has a car on the ballot or waiting.
  int get myEnteredCount => contests
      .where((c) => !c.isFinished && c.viewer.liveEntryCarIds.isNotEmpty)
      .length;

  /// Whether the viewer has an accepted event car at all — what decides if
  /// the standing strip shows. Derived from `can_enter` and own entries.
  bool get viewerHasEventCar => contests.any(
        (c) => c.viewer.canEnter || c.viewer.myEntries.isNotEmpty,
      );

  ContestEntity? byId(String id) {
    for (final c in contests) {
      if (c.id == id) return c;
    }
    return null;
  }

  EventContestsState copyWith({
    EventContestsStatus? status,
    String? eventId,
    List<ContestEntity>? contests,
    MapEventError? error,
    bool clearError = false,
    bool? isSaving,
    MapEventError? actionError,
    bool clearActionError = false,
  }) {
    return EventContestsState(
      status: status ?? this.status,
      eventId: eventId ?? this.eventId,
      contests: contests ?? this.contests,
      error: clearError ? null : (error ?? this.error),
      isSaving: isSaving ?? this.isSaving,
      actionError: clearActionError ? null : (actionError ?? this.actionError),
    );
  }

  @override
  List<Object?> get props =>
      [status, eventId, contests, error, isSaving, actionError];
}
