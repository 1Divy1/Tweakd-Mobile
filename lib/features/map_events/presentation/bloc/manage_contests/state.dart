import 'package:equatable/equatable.dart';

import '../../../domain/entities/contest.dart';
import '../../utils/map_event_error_mapper.dart';

enum ManageContestsStatus { initial, loading, loaded, failure }

class ManageContestsState extends Equatable {
  final ManageContestsStatus status;
  final String? eventId;
  final List<ContestEntity> contests;
  final MapEventError? error;

  /// The contest an action is running on, so exactly one card shows a spinner.
  final String? busyContestId;

  /// The contest that was just finished from this screen — the dark banner.
  final ContestEntity? justFinished;
  final MapEventError? actionError;

  const ManageContestsState({
    this.status = ManageContestsStatus.initial,
    this.eventId,
    this.contests = const [],
    this.error,
    this.busyContestId,
    this.justFinished,
    this.actionError,
  });

  List<ContestEntity> get open => [for (final c in contests) if (c.isOpen) c];
  List<ContestEntity> get scheduled =>
      [for (final c in contests) if (c.isScheduled) c];
  List<ContestEntity> get finished =>
      [for (final c in contests) if (c.isFinished) c];

  int get totalVotes => contests.fold(0, (sum, c) => sum + c.votesCount);
  int get pendingEntriesCount =>
      contests.fold(0, (sum, c) => sum + c.pendingEntries.length);

  ContestEntity? byId(String id) {
    for (final c in contests) {
      if (c.id == id) return c;
    }
    return null;
  }

  ManageContestsState copyWith({
    ManageContestsStatus? status,
    String? eventId,
    List<ContestEntity>? contests,
    MapEventError? error,
    bool clearError = false,
    String? busyContestId,
    bool clearBusy = false,
    ContestEntity? justFinished,
    bool clearJustFinished = false,
    MapEventError? actionError,
    bool clearActionError = false,
  }) {
    return ManageContestsState(
      status: status ?? this.status,
      eventId: eventId ?? this.eventId,
      contests: contests ?? this.contests,
      error: clearError ? null : (error ?? this.error),
      busyContestId: clearBusy ? null : (busyContestId ?? this.busyContestId),
      justFinished:
          clearJustFinished ? null : (justFinished ?? this.justFinished),
      actionError: clearActionError ? null : (actionError ?? this.actionError),
    );
  }

  @override
  List<Object?> get props =>
      [status, eventId, contests, error, busyContestId, justFinished, actionError];
}
