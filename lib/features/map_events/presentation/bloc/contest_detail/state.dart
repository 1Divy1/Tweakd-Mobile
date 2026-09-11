import 'package:equatable/equatable.dart';

import '../../../domain/entities/contest.dart';
import '../../utils/map_event_error_mapper.dart';

enum ContestDetailStatus { initial, loading, loaded, failure }

class ContestDetailState extends Equatable {
  final ContestDetailStatus status;
  final String? eventId;
  final String? contestId;
  final ContestEntity? contest;
  final MapEventError? error;

  /// True while a vote is in flight — the footer's buttons go inert.
  final bool isVoting;

  /// The car id a vote just landed on, so the page can say "Vote counted for
  /// BMW" once. Cleared with [actionError] on the next event.
  final String? justVotedCarId;
  final MapEventError? actionError;

  const ContestDetailState({
    this.status = ContestDetailStatus.initial,
    this.eventId,
    this.contestId,
    this.contest,
    this.error,
    this.isVoting = false,
    this.justVotedCarId,
    this.actionError,
  });

  ContestDetailState copyWith({
    ContestDetailStatus? status,
    String? eventId,
    String? contestId,
    ContestEntity? contest,
    MapEventError? error,
    bool clearError = false,
    bool? isVoting,
    String? justVotedCarId,
    bool clearJustVoted = false,
    MapEventError? actionError,
    bool clearActionError = false,
  }) {
    return ContestDetailState(
      status: status ?? this.status,
      eventId: eventId ?? this.eventId,
      contestId: contestId ?? this.contestId,
      contest: contest ?? this.contest,
      error: clearError ? null : (error ?? this.error),
      isVoting: isVoting ?? this.isVoting,
      justVotedCarId:
          clearJustVoted ? null : (justVotedCarId ?? this.justVotedCarId),
      actionError: clearActionError ? null : (actionError ?? this.actionError),
    );
  }

  @override
  List<Object?> get props => [
        status,
        eventId,
        contestId,
        contest,
        error,
        isVoting,
        justVotedCarId,
        actionError,
      ];
}
